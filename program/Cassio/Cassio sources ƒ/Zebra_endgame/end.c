/*
   File:          end.c

   Created:       1994
   
   Modified:      November 14, 2004

   Authors:       Gunnar Andersson (gunnar@radagast.se)

   Contents:      The fast endgame solver.
*/




#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "bitbcnt.h"
#include "bitbmob.h"
#include "bitboard.h"
#include "bitbtest.h"
#include "bitbvald.h"
#include "constant.h"
#include "end.h"
#include "hash.h"
#include "macros.h"
#include "moves.h"
#include "doflip.h"
#include "stable.h"
#include "unflip.h"



#define USE_MPC                      1
#define MAX_SELECTIVITY              9
#define DISABLE_SELECTIVITY          18

#define PV_EXPANSION                 16

#define DEPTH_TWO_SEARCH             15
#define DEPTH_THREE_SEARCH           20
#define DEPTH_FOUR_SEARCH            24
#define DEPTH_SIX_SEARCH             30
#define EXTRA_ROOT_SEARCH            2

#ifdef _WIN32_WCE
#define EVENT_CHECK_INTERVAL         25000.0
#else
#define EVENT_CHECK_INTERVAL         250000.0
#endif

#define LOW_LEVEL_DEPTH              8
#define FASTEST_FIRST_DEPTH          12
#define HASH_DEPTH                   (LOW_LEVEL_DEPTH + 1)

#define VERY_HIGH_EVAL               1000000

#define GOOD_TRANSPOSITION_EVAL      10000000

/* Parameters for the fastest-first algorithm. The performance does
   not seem to depend a lot on the precise values. */
#define FAST_FIRST_FACTOR            0.45
#define MOB_FACTOR                   460

/* The disc difference when special wipeout move ordering is tried.
   This means more aggressive use of fastest first. */
#define WIPEOUT_THRESHOLD            60

/* Use stability pruning? */
#define USE_STABILITY                1



#if 0

// Profiling code

static long long int
rdtsc( void ) {
#if defined(__GNUC__)
  long long a;
  asm volatile("rdtsc":"=A" (a));
  return a;
#else
  return 0;
#endif
}

#endif



typedef enum {
  NOTHING,
  SELECTIVE_SCORE,
  WLD_SCORE,
  EXACT_SCORE
} SearchStatus;



MoveLink end_move_list[100];



/* The parities of the regions are in the region_parity bit vector. */

static unsigned int region_parity;


#if USE_STABILITY
#define  HIGH_STABILITY_THRESHOLD     24
static int stability_threshold[] = { 65, 65, 65, 65, 65, 46, 38, 30, 24,
				     24, 24, 24, 0, 0, 0, 0, 0, 0, 0 };
#endif



static int best_move, best_end_root_move;
static int true_found, true_val;
static int ff_mob_factor[61];

static BitBoard neighborhood_mask[100];
unsigned int quadrant_mask[100] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 1, 1, 1, 1, 2, 2, 2, 2, 0,
  0, 1, 1, 1, 1, 2, 2, 2, 2, 0,
  0, 1, 1, 1, 1, 2, 2, 2, 2, 0,
  0, 1, 1, 1, 1, 2, 2, 2, 2, 0,
  0, 4, 4, 4, 4, 8, 8, 8, 8, 0,
  0, 4, 4, 4, 4, 8, 8, 8, 8, 0,
  0, 4, 4, 4, 4, 8, 8, 8, 8, 0,
  0, 4, 4, 4, 4, 8, 8, 8, 8, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};



#if 1

/*
  TESTFLIPS_WRAPPER
  Checks if SQ is a valid move by
  (1) verifying that there exists a neighboring opponent disc,
  (2) verifying that the move flips some disc.
*/

INLINE static int
TestFlips_wrapper( int sq,
		   BitBoard my_bits,
		   BitBoard opp_bits ) {
  int flipped;

  if ( ((neighborhood_mask[sq].high & opp_bits.high) |
       (neighborhood_mask[sq].low & opp_bits.low)) != 0 )
    flipped = TestFlips_bitboard[sq]( my_bits, opp_bits );
  else
    flipped = 0;

  return flipped;
}

#else
#define TestFlips_wrapper( sq, my_bits, opp_bits ) \
  TestFlips_bitboard[sq]( my_bits, opp_bits )


#endif



/*
  PREPARE_TO_SOLVE
  Create the list of empty squares.
*/

static void
prepare_to_solve( const int *board ) {
  /* fixed square ordering: */
  /* jcw's order, which is the best of 4 tried (according to Warren Smith) */
  static int worst2best[64] = {
    /*B2*/      22 , 27 , 72 , 77 ,
    /*B1*/      12 , 17 , 21 , 28 , 71 , 78 , 82,  87 ,
    /*C2*/      23 , 26 , 32 , 37 , 62 , 67 , 73 , 76 ,
    /*D2*/      24 , 25 , 42 , 47 , 52 , 57 , 74 , 75 ,
    /*D3*/      34 , 35 , 43 , 46 , 53 , 56 , 64 , 65 ,
    /*C1*/      13 , 16 , 31 , 38 , 61 , 68 , 83 , 86 ,
    /*D1*/      14 , 15 , 41 , 48 , 51 , 58 , 84 , 85 ,
    /*C3*/      33 , 36 , 63 , 66 ,
    /*A1*/      11 , 18 , 81 , 88 , 
    /*D4*/      44 , 45 , 54 , 45
  };
  int i;
  int last_sq;

  region_parity = 0;

  last_sq = END_MOVE_LIST_HEAD;
  for ( i = 59; i >=0; i-- ) {
    int sq = worst2best[i];
    if ( board[sq] == EMPTY ) {
      end_move_list[last_sq].succ = sq;
      end_move_list[sq].pred = last_sq;
      region_parity ^= quadrant_mask[sq];
      last_sq = sq;
    }
  }
  end_move_list[last_sq].succ = END_MOVE_LIST_TAIL;
}



#if 0

/*
  CHECK_LIST
  Performs a minimal sanity check of the move list: That it contains
  the same number of moves as there are empty squares on the board.
*/

static void
check_list( int empties ) {
  int links = 0;
  int sq = end_move_list[END_MOVE_LIST_HEAD].succ;

  while ( sq != END_MOVE_LIST_TAIL ) {
    links++;
    sq = end_move_list[sq].succ;
  }

  if ( links != empties )
    printf( "%d links, %d empties\n", links, empties );
}

#endif




/*
  SOLVE_TWO_EMPTY
  SOLVE_THREE_EMPTY
  SOLVE_FOUR_EMPTY
  SOLVE_PARITY
  SOLVE_PARITY_HASH
  SOLVE_PARITY_HASH_HIGH
  These are the core routines of the low level endgame code.
  They all perform the same task: Return the score for the side to move.
  Structural differences:
  * SOLVE_TWO_EMPTY may only be called for *exactly* two empty
  * SOLVE_THREE_EMPTY may only be called for *exactly* three empty
  * SOLVE_FOUR_EMPTY may only be called for *exactly* four empty
  * SOLVE_PARITY uses stability, parity and fixed move ordering
  * SOLVE_PARITY_HASH uses stability, hash table and fixed move ordering
  * SOLVE_PARITY_HASH_HIGH uses stability, hash table and (non-thresholded)
    fastest first
*/

static int
solve_two_empty( BitBoard my_bits,
		 BitBoard opp_bits,
		 int sq1,
		 int sq2,
		 int alpha,
		 int beta,
		 int disc_diff,
		 int pass_legal ) {
  BitBoard new_opp_bits;
  int score = -INFINITE_EVAL;
  int flipped;
  int ev;


  /* Overall strategy: Lazy evaluation whenever possible, i.e., don't
     update bitboards until they are used. Also look at alpha and beta
     in order to perform strength reduction: Feasibility testing is
     faster than counting number of flips. */

  /* Try the first of the two empty squares... */

  flipped = TestFlips_wrapper( sq1, my_bits, opp_bits );
  if ( flipped != 0 ) {  /* SQ1 feasible for me */
    FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );


    ev = disc_diff + 2 * flipped;

    if ( ev - 2 <= alpha ) { /* Fail-low if he can play SQ2 */
      if ( ValidOneEmpty_bitboard[sq2]( new_opp_bits ) != 0 )
	ev = alpha;
      else {  /* He passes, check if SQ2 is feasible for me */
	if ( ev >= 0 ) {  /* I'm ahead, so EV will increase by at least 2 */
	  ev += 2;
	  if ( ev < beta )  /* Only bother if not certain fail-high */
	    ev += 2 * CountFlips_bitboard[sq2]( bb_flips );
	}
	else {
	  if ( ev < beta ) {  /* Only bother if not fail-high already */
	    flipped = CountFlips_bitboard[sq2]( bb_flips );
	    if ( flipped != 0 )  /* SQ2 feasible for me, game over */
	      ev += 2 * (flipped + 1);
	    /* ELSE: SQ2 will end up empty, game over */
	  }
	}
      }
    }
    else {
      flipped = CountFlips_bitboard[sq2]( new_opp_bits );
      if ( flipped != 0 )
	ev -= 2 * flipped;
      else {  /* He passes, check if SQ2 is feasible for me */
	if ( ev >= 0 ) {  /* I'm ahead, so EV will increase by at least 2 */
	  ev += 2;
	  if ( ev < beta )  /* Only bother if not certain fail-high */
	    ev += 2 * CountFlips_bitboard[sq2]( bb_flips );
	}
	else {
	  if ( ev < beta ) {  /* Only bother if not fail-high already */
	    flipped = CountFlips_bitboard[sq2]( bb_flips );
	    if ( flipped != 0 )  /* SQ2 feasible for me, game over */
	      ev += 2 * (flipped + 1);
	    /* ELSE: SQ2 will end up empty, game over */
	  }
	}
      }
    }

    /* Being legal, the first move is the best so far */
    score = ev;
    if ( score > alpha ) {
      if ( score >= beta )
	return score;
      alpha = score;
    }
  }

  /* ...and then the second */

  flipped = TestFlips_wrapper( sq2, my_bits, opp_bits );
  if ( flipped != 0 ) {  /* SQ2 feasible for me */
    FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );


    ev = disc_diff + 2 * flipped;
    if ( ev - 2 <= alpha ) {  /* Fail-low if he can play SQ1 */
      if ( ValidOneEmpty_bitboard[sq1]( new_opp_bits ) != 0 )
	ev = alpha;
      else {  /* He passes, check if SQ1 is feasible for me */
	if ( ev >= 0 ) {  /* I'm ahead, so EV will increase by at least 2 */
	  ev += 2;
	  if ( ev < beta )  /* Only bother if not certain fail-high */
	    ev += 2 * CountFlips_bitboard[sq1]( bb_flips );
	}
	else {
	  if ( ev < beta ) {  /* Only bother if not fail-high already */
	    flipped = CountFlips_bitboard[sq1]( bb_flips );
	    if ( flipped != 0 )  /* SQ1 feasible for me, game over */
	      ev += 2 * (flipped + 1);
	    /* ELSE: SQ1 will end up empty, game over */
	  }
	}
      }
    }
    else {
      flipped = CountFlips_bitboard[sq1]( new_opp_bits );
      if ( flipped != 0 )  /* SQ1 feasible for him, game over */
	ev -= 2 * flipped;
      else {  /* He passes, check if SQ1 is feasible for me */
	if ( ev >= 0 ) {  /* I'm ahead, so EV will increase by at least 2 */
	  ev += 2;
	  if ( ev < beta )  /* Only bother if not certain fail-high */
	    ev += 2 * CountFlips_bitboard[sq1]( bb_flips );
	}
	else {
	  if ( ev < beta ) {  /* Only bother if not fail-high already */
	    flipped = CountFlips_bitboard[sq1]( bb_flips );
	    if ( flipped != 0 )  /* SQ1 feasible for me, game over */
	      ev += 2 * (flipped + 1);
	    /* ELSE: SQ1 will end up empty, game over */
	  }
	}
      }
    }

    /* If the second move if better than the first (if that move was legal),
       its score is the score of the position */
    if ( ev >= score )
      return ev;
  }

  /* If both SQ1 and SQ2 are illegal I have to pass,
     otherwise return the best score. */

  if ( score == -INFINITE_EVAL ) {
    if ( !pass_legal ) {  /* Two empty squares */
      if ( disc_diff > 0 )
	return disc_diff + 2;
      if ( disc_diff < 0 )
	return disc_diff - 2;
      return 0;
    }
    else
      return -solve_two_empty( opp_bits, my_bits, sq1, sq2, -beta,
			       -alpha, -disc_diff, VALUE_FALSE );
  }
  else
    return score;
}


static int
solve_three_empty( BitBoard my_bits,
		   BitBoard opp_bits,
		   int sq1,
		   int sq2,
		   int sq3,
		   int alpha,
		   int beta,
		   int disc_diff,
		   int pass_legal ) {
  BitBoard new_opp_bits;
  int score = -INFINITE_EVAL;
  int flipped;
  int new_disc_diff;
  int ev;


  flipped = TestFlips_wrapper( sq1, my_bits, opp_bits );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    score = -solve_two_empty( new_opp_bits, bb_flips, sq2, sq3,
			      -beta, -alpha, new_disc_diff, VALUE_TRUE );
    if ( score >= beta )
      return score;
    else if ( score > alpha )
      alpha = score;
  }

  flipped = TestFlips_wrapper( sq2, my_bits, opp_bits );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    ev = -solve_two_empty( new_opp_bits, bb_flips, sq1, sq3,
			   -beta, -alpha, new_disc_diff, VALUE_TRUE );
    if ( ev >= beta )
      return ev;
    else if ( ev > score ) {
      score = ev;
      if ( score > alpha )
	alpha = score;
    }
  }

  flipped = TestFlips_wrapper( sq3, my_bits, opp_bits );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    ev = -solve_two_empty( new_opp_bits, bb_flips, sq1, sq2,
			   -beta, -alpha, new_disc_diff, VALUE_TRUE );
    if ( ev >= score )
      return ev;
  }

  if ( score == -INFINITE_EVAL ) {
    if ( !pass_legal ) {  /* Three empty squares */
      if ( disc_diff > 0 )
	return disc_diff + 3;
      if ( disc_diff < 0 )
	return disc_diff - 3;
      return 0;  /* Can't reach this code, only keep it for symmetry */
    }
    else
      return -solve_three_empty( opp_bits, my_bits, sq1, sq2, sq3,
				 -beta, -alpha, -disc_diff, VALUE_FALSE );
  }

  return score;
}



static int
solve_four_empty( BitBoard my_bits,
		  BitBoard opp_bits,
		  int sq1,
		  int sq2,
		  int sq3,
		  int sq4,
		  int alpha,
		  int beta,
		  int disc_diff,
		  int pass_legal ) {
  BitBoard new_opp_bits;
  int score = -INFINITE_EVAL;
  int flipped;
  int new_disc_diff;
  int ev;


  flipped = TestFlips_wrapper( sq1, my_bits, opp_bits );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    score = -solve_three_empty( new_opp_bits, bb_flips, sq2, sq3, sq4,
				-beta, -alpha, new_disc_diff, VALUE_TRUE );
    if ( score >= beta )
      return score;
    else if ( score > alpha )
      alpha = score;
  }

  flipped = TestFlips_wrapper( sq2, my_bits, opp_bits );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    ev = -solve_three_empty( new_opp_bits, bb_flips, sq1, sq3, sq4,
			     -beta, -alpha, new_disc_diff, VALUE_TRUE );
    if ( ev >= beta )
      return ev;
    else if ( ev > score ) {
      score = ev;
      if ( score > alpha )
	alpha = score;
    }
  }

  flipped = TestFlips_wrapper( sq3, my_bits, opp_bits );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    ev = -solve_three_empty( new_opp_bits, bb_flips, sq1, sq2, sq4,
			     -beta, -alpha, new_disc_diff, VALUE_TRUE );
    if ( ev >= beta )
      return ev;
    else if ( ev > score ) {
      score = ev;
      if ( score > alpha )
	alpha = score;
    }
  }

  flipped = TestFlips_wrapper( sq4, my_bits, opp_bits );
  if ( flipped != 0 ) {
    FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );
    new_disc_diff = -disc_diff - 2 * flipped - 1;
    ev = -solve_three_empty( new_opp_bits, bb_flips, sq1, sq2, sq3,
			     -beta, -alpha, new_disc_diff, VALUE_TRUE );
    if ( ev >= score )
      return ev;
  }

  if ( score == -INFINITE_EVAL ) {
    if ( !pass_legal ) {  /* Four empty squares */
      if ( disc_diff > 0 )
	return disc_diff + 4;
      if ( disc_diff < 0 )
	return disc_diff - 4;
      return 0;
    }
    else
      return -solve_four_empty( opp_bits, my_bits, sq1, sq2, sq3, sq4,
				-beta, -alpha, -disc_diff, VALUE_FALSE );
  }

  return score;
}



static int
solve_parity( BitBoard my_bits,
	      BitBoard opp_bits,
	      int alpha,
	      int beta, 
	      int color,
	      int empties,
	      int disc_diff,
	      int pass_legal ) {
  BitBoard new_opp_bits;
  int score = -INFINITE_EVAL;
  int oppcol = OPPONENT( color );
  int ev;
  int flipped;
  int new_disc_diff;
  int sq, old_sq, best_sq = 0;
  unsigned int parity_mask;


  /* Check for stability cutoff */

#if USE_STABILITY
  if ( alpha >= stability_threshold[empties] ) {
    int stability_bound;
    stability_bound = 64 - 2 * count_edge_stable( oppcol, opp_bits, my_bits );
    if ( stability_bound <= alpha )
      return alpha;
    stability_bound = 64 - 2 * count_stable( oppcol, opp_bits, my_bits );
    if ( stability_bound < beta )
      beta = stability_bound + 1;
    if ( stability_bound <= alpha )
      return alpha;
  }
#endif

  /* Odd parity */

  parity_mask = region_parity;

  if ( region_parity != 0 )  /* Is there any region with odd parity? */
    for ( old_sq = END_MOVE_LIST_HEAD, sq = end_move_list[old_sq].succ;
	  sq != END_MOVE_LIST_TAIL;
	  old_sq = sq, sq = end_move_list[sq].succ ) {
      unsigned int holepar = quadrant_mask[sq];
      if ( holepar & parity_mask ) {
	flipped = TestFlips_wrapper( sq, my_bits, opp_bits );
	if ( flipped != 0 ) {
	  FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );

	  end_move_list[old_sq].succ = end_move_list[sq].succ;
	  new_disc_diff = -disc_diff - 2 * flipped - 1;
	  if ( empties == 5 ) {
	    int sq1 = end_move_list[END_MOVE_LIST_HEAD].succ;
	    int sq2 = end_move_list[sq1].succ;
	    int sq3 = end_move_list[sq2].succ;
	    int sq4 = end_move_list[sq3].succ;
	    ev = -solve_four_empty( new_opp_bits, bb_flips, sq1, sq2, sq3, sq4,
				     -beta, -alpha, new_disc_diff, VALUE_TRUE );
	  }
	  else {
	    region_parity ^= holepar;
	    ev = -solve_parity( new_opp_bits, bb_flips, -beta, -alpha,
				oppcol, empties - 1, new_disc_diff, VALUE_TRUE );
	    region_parity ^= holepar;
	  }
	  end_move_list[old_sq].succ = sq;

	  if ( ev > score ) {
	    if ( ev > alpha ) {
	      if ( ev >= beta ) {
		best_move = sq;
		return ev;
	      }
	      alpha = ev;
	    }
	    score = ev;
	    best_sq = sq;
	  }
	}
      }
    }

  /* Even parity */

  parity_mask = ~parity_mask;
  for ( old_sq = END_MOVE_LIST_HEAD, sq = end_move_list[old_sq].succ;
	sq != END_MOVE_LIST_TAIL;
	old_sq = sq, sq = end_move_list[sq].succ ) {
    unsigned int holepar = quadrant_mask[sq];
    if ( holepar & parity_mask ) {
      flipped = TestFlips_wrapper( sq, my_bits, opp_bits );
      if ( flipped != 0 ) {
	FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );

	end_move_list[old_sq].succ = end_move_list[sq].succ;
	new_disc_diff = -disc_diff - 2 * flipped - 1;
	if ( empties == 5 ) {
	  int sq1 = end_move_list[END_MOVE_LIST_HEAD].succ;
	  int sq2 = end_move_list[sq1].succ;
	  int sq3 = end_move_list[sq2].succ;
	  int sq4 = end_move_list[sq3].succ;
	  ev = -solve_four_empty( new_opp_bits, bb_flips, sq1, sq2, sq3, sq4,
				  -beta, -alpha, new_disc_diff, VALUE_TRUE );
	}
	else {
	  region_parity ^= holepar;
	  ev = -solve_parity( new_opp_bits, bb_flips, -beta, -alpha,
			      oppcol, empties - 1, new_disc_diff, VALUE_TRUE );
	  region_parity ^= holepar;
	}
	end_move_list[old_sq].succ = sq;

	if ( ev > score ) {
	  if ( ev > alpha ) {
	    if ( ev >= beta ) {
	      best_move = sq;
	      return ev;
	    }
	    alpha = ev;
	  }
	  score = ev;
	  best_sq = sq;
	}
      }
    }
  }

  if ( score == -INFINITE_EVAL ) {
    if ( !pass_legal ) {
      if ( disc_diff > 0 )
	return disc_diff + empties;
      if ( disc_diff < 0 )
	return disc_diff - empties;
      return 0;
    }
    else
      return -solve_parity( opp_bits, my_bits, -beta, -alpha, oppcol,
			    empties, -disc_diff, VALUE_FALSE );
  }
  best_move = best_sq;

  return score;
}



static int
solve_parity_hash( BitBoard my_bits,
		   BitBoard opp_bits,
		   int alpha,
		   int beta,
		   int color,
		   int empties,
		   int disc_diff,
		   int pass_legal ) {
  BitBoard new_opp_bits;
  int score = -INFINITE_EVAL;
  int oppcol = OPPONENT( color );
  int in_alpha = alpha;
  int ev;
  int flipped;
  int new_disc_diff;
  int sq, old_sq, best_sq = 0;
  unsigned int parity_mask;
  HashEntry entry;


  entry = find_hash( ENDGAME_MODE );
  if ( (entry.draft == empties) &&
       (entry.selectivity == 0) &&
       valid_move( entry.move[0], color ) &&
       (entry.flags & ENDGAME_SCORE) &&
       ((entry.flags & EXACT_VALUE) ||
	((entry.flags & LOWER_BOUND) && entry.eval >= beta) ||
	((entry.flags & UPPER_BOUND) && entry.eval <= alpha)) ) {
    best_move = entry.move[0];
    return entry.eval;
  }

  /* Check for stability cutoff */

#if USE_STABILITY
  if ( alpha >= stability_threshold[empties] ) {
    int stability_bound;

    stability_bound = 64 - 2 * count_edge_stable( oppcol, opp_bits, my_bits );
    if ( stability_bound <= alpha )
      return alpha;
    stability_bound = 64 - 2 * count_stable( oppcol, opp_bits, my_bits );
    if ( stability_bound < beta )
       beta = stability_bound + 1;
    if ( stability_bound <= alpha )
      return alpha;
  }
#endif

  /* Odd parity. */

  parity_mask = region_parity;

  if ( region_parity != 0 )  /* Is there any region with odd parity? */
    for ( old_sq = END_MOVE_LIST_HEAD, sq = end_move_list[old_sq].succ;
	  sq != END_MOVE_LIST_TAIL;
	  old_sq = sq, sq = end_move_list[sq].succ ) {
      unsigned int holepar = quadrant_mask[sq];
      if ( holepar & parity_mask ) {
	flipped = TestFlips_wrapper( sq, my_bits, opp_bits );
	if ( flipped != 0 ) {
	  FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );

	  region_parity ^= holepar;
	  end_move_list[old_sq].succ = end_move_list[sq].succ;
	  new_disc_diff = -disc_diff - 2 * flipped - 1;
	  ev = -solve_parity( new_opp_bits, bb_flips, -beta, -alpha, oppcol,
			      empties - 1, new_disc_diff, VALUE_TRUE );
	  region_parity ^= holepar;
	  end_move_list[old_sq].succ = sq;
	      
	  if ( ev > score ) {
	    score = ev;
	    if ( ev > alpha ) {
	      if ( ev >= beta ) { 
		best_move = sq;
		add_hash( ENDGAME_MODE, score, best_move,
			  ENDGAME_SCORE | LOWER_BOUND, empties, 0 );
		return score;
	      }
	      alpha = ev;
	    }
	    best_sq = sq;
	  }
	}
      }
    }

  /* Even parity. */

  parity_mask = ~parity_mask;

  for ( old_sq = END_MOVE_LIST_HEAD, sq = end_move_list[old_sq].succ;
	sq != END_MOVE_LIST_TAIL;
	old_sq = sq, sq = end_move_list[sq].succ ) {
    unsigned int holepar = quadrant_mask[sq];
    if ( holepar & parity_mask ) {
      flipped = TestFlips_wrapper( sq, my_bits, opp_bits );
      if ( flipped != 0 ) {
	FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );

	region_parity ^= holepar;
	end_move_list[old_sq].succ = end_move_list[sq].succ;
	new_disc_diff = -disc_diff - 2 * flipped - 1;
	ev = -solve_parity( new_opp_bits, bb_flips, -beta, -alpha, oppcol,
			    empties - 1, new_disc_diff, VALUE_TRUE );
	region_parity ^= holepar;
	end_move_list[old_sq].succ = sq;
	      
	if ( ev > score ) {
	  score = ev;
	  if ( ev > alpha ) {
	    if ( ev >= beta ) { 
	      best_move = sq;
	      add_hash( ENDGAME_MODE, score, best_move,
			ENDGAME_SCORE | LOWER_BOUND, empties, 0 );
	      return score;
	    }
	    alpha = ev;
	  }
	  best_sq = sq;
	}
      }
    }
  }

  if ( score == -INFINITE_EVAL ) {
    if ( !pass_legal ) {
      if ( disc_diff > 0 )
	return disc_diff + empties;
      if ( disc_diff < 0 )
	return disc_diff - empties;
      return 0;
    }
    else {
      hash1 ^= hash_flip_color1;
      hash2 ^= hash_flip_color2;
      score = -solve_parity_hash( opp_bits, my_bits, -beta, -alpha, oppcol,
				  empties, -disc_diff, VALUE_FALSE );
      hash1 ^= hash_flip_color1;
      hash2 ^= hash_flip_color2;
    }
  }
  else {
    best_move = best_sq;
    if ( score > in_alpha)
      add_hash( ENDGAME_MODE, score, best_move, ENDGAME_SCORE | EXACT_VALUE,
		empties, 0 );
    else
      add_hash( ENDGAME_MODE, score, best_move, ENDGAME_SCORE | UPPER_BOUND,
		empties, 0 );
  }

  return score;
}



static int
solve_parity_hash_high( BitBoard my_bits,
			BitBoard opp_bits,
			int alpha,
			int beta,
			int color,
			int empties,
			int disc_diff,
			int pass_legal ) {
  /* Move bonuses without and with parity for the squares.
     These are only used when sorting moves in the 9-12 empties
     range and were automatically tuned by OPTIMIZE. */
  static int move_bonus[2][128] = {  /* 2 * 100 used */
    {   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	0,  24,   1,   0,  25,  25,   0,   1,  24,   0,
	0,   1,   0,   0,   0,   0,   0,   0,   1,   0,
	0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	0,  25,   0,   0,   0,   0,   0,   0,  25,   0,
	0,  25,   0,   0,   0,   0,   0,   0,  25,   0,
	0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	0,   1,   0,   0,   0,   0,   0,   0,   1,   0,
	0,  24,   1,   0,  25,  25,   0,   1,  24,   0,
	0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
    {   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	0, 128,  86, 122, 125, 125, 122,  86, 128,   0,
	0,  86, 117, 128, 128, 128, 128, 117,  86,   0,
	0, 122, 128, 128, 128, 128, 128, 128, 122,   0,
	0, 125, 128, 128, 128, 128, 128, 128, 125,   0,
	0, 125, 128, 128, 128, 128, 128, 128, 125,   0,
	0, 122, 128, 128, 128, 128, 128, 128, 122,   0,
	0,  86, 117, 128, 128, 128, 128, 117,  86,   0,
	0, 128,  86, 122, 125, 125, 122,  86, 128,   0,
	0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 }
  };
  BitBoard new_opp_bits;
  BitBoard best_new_my_bits, best_new_opp_bits;
  int i;
  int score;
  int in_alpha = alpha;
  int oppcol = OPPONENT( color );
  int flipped, best_flipped;
  int new_disc_diff;
  int ev;
  int hash_move;
  int moves;
  int parity;
  int best_value, best_index;
  int pred, succ;
  int sq, old_sq, best_sq = 0;
  int move_order[64];
  int goodness[64];
  unsigned int diff1, diff2;
  HashEntry entry;


  hash_move = -1;
  entry = find_hash( ENDGAME_MODE );
  if ( entry.draft == empties ) {
    if ( (entry.selectivity == 0) &&
	 (entry.flags & ENDGAME_SCORE) &&
	 valid_move( entry.move[0], color ) &&
	 ((entry.flags & EXACT_VALUE) ||
	  ((entry.flags & LOWER_BOUND) && entry.eval >= beta) ||
	  ((entry.flags & UPPER_BOUND) && entry.eval <= alpha)) ) {
      best_move = entry.move[0];
      return entry.eval;
    }
  }

  /* Check for stability cutoff */

#if USE_STABILITY
  if ( alpha >= stability_threshold[empties] ) {
    int stability_bound;

    stability_bound = 64 - 2 * count_edge_stable( oppcol, opp_bits, my_bits );
    if ( stability_bound <= alpha )
      return alpha;
    stability_bound = 64 - 2 * count_stable( oppcol, opp_bits, my_bits );
    if ( stability_bound < beta )
      beta = stability_bound + 1;
    if ( stability_bound <= alpha )
      return alpha;
  }
#endif

  /* Calculate goodness values for all moves */

  moves = 0;
  best_value = -INFINITE_EVAL;
  best_index = 0;
  best_flipped = 0;

  for ( old_sq = END_MOVE_LIST_HEAD, sq = end_move_list[old_sq].succ;
	sq != END_MOVE_LIST_TAIL;
	old_sq = sq, sq = end_move_list[sq].succ ) {
    flipped = TestFlips_wrapper( sq, my_bits, opp_bits );
    if ( flipped != 0 ) {

      FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );
      end_move_list[old_sq].succ = end_move_list[sq].succ;

      if ( quadrant_mask[sq] & region_parity )
	parity = 1;
      else
	parity = 0;
      goodness[moves] = move_bonus[parity][sq];
      if ( sq == hash_move )
	goodness[moves] += 128;

      goodness[moves] -= weighted_mobility( new_opp_bits, bb_flips );

      if ( goodness[moves] > best_value ) {
	best_value = goodness[moves];
	best_index = moves;
	best_new_my_bits = bb_flips;
	best_new_opp_bits = new_opp_bits;
	best_flipped = flipped;
      }

      end_move_list[old_sq].succ = sq;
      move_order[moves] = sq;
      moves++;
    }
  }

  /* Maybe there aren't any legal moves */

  if ( moves == 0 ) {  /* I have to pass */
    if ( !pass_legal ) {  /* Last move also pass, game over */
      if ( disc_diff > 0 )
	return disc_diff + empties;
      if ( disc_diff < 0 )
	return disc_diff - empties;
      return 0;
    }
    else {  /* Opponent gets the chance to play */
      hash1 ^= hash_flip_color1;
      hash2 ^= hash_flip_color2;
      score = -solve_parity_hash_high( opp_bits, my_bits, -beta, -alpha,
				       oppcol, empties, -disc_diff, VALUE_FALSE );
      hash1 ^= hash_flip_color1;
      hash2 ^= hash_flip_color2;
      return score;
    }
  }

  /* Try move with highest goodness value */

  sq = move_order[best_index];

  (void) DoFlips_hash( sq, color, oppcol );

  board[sq] = color;
  diff1 = hash_update1 ^ hash_put_value1[color][sq];
  diff2 = hash_update2 ^ hash_put_value2[color][sq];
  hash1 ^= diff1;
  hash2 ^= diff2;

  region_parity ^= quadrant_mask[sq];

  pred = end_move_list[sq].pred;
  succ = end_move_list[sq].succ;
  end_move_list[pred].succ = succ;
  end_move_list[succ].pred = pred;

  new_disc_diff = -disc_diff - 2 * best_flipped - 1;
  if ( empties <= LOW_LEVEL_DEPTH + 1 )
    score = -solve_parity_hash( best_new_opp_bits, best_new_my_bits,
				-beta, -alpha, oppcol, empties - 1,
				new_disc_diff, VALUE_TRUE );
  else
    score = -solve_parity_hash_high( best_new_opp_bits, best_new_my_bits,
				     -beta, -alpha, oppcol, empties - 1,
				     new_disc_diff, VALUE_TRUE );

  UndoFlips( best_flipped, oppcol );
  hash1 ^= diff1;
  hash2 ^= diff2;
  board[sq] = EMPTY;

  region_parity ^= quadrant_mask[sq];

  end_move_list[pred].succ = sq;
  end_move_list[succ].pred = sq;

  best_sq = sq;
  if ( score > alpha ) {
    if ( score >= beta ) { 
      best_move = best_sq;
      add_hash( ENDGAME_MODE, score, best_move,
		ENDGAME_SCORE | LOWER_BOUND, empties, 0 );
      return score;
    }
    alpha = score;
  }

  /* Play through the rest of the moves */

  move_order[best_index] = move_order[0];
  goodness[best_index] = goodness[0];

  for ( i = 1; i < moves; i++ ) {
    int j;

    best_value = goodness[i];
    best_index = i;
    for ( j = i + 1; j < moves; j++ )
      if ( goodness[j] > best_value ) {
	best_value = goodness[j];
	best_index = j;
      }
    sq = move_order[best_index];
    move_order[best_index] = move_order[i];
    goodness[best_index] = goodness[i];

    flipped = TestFlips_wrapper( sq, my_bits, opp_bits );
    FULL_ANDNOT( new_opp_bits, opp_bits, bb_flips );

    (void) DoFlips_hash( sq, color, oppcol );
    board[sq] = color;
    diff1 = hash_update1 ^ hash_put_value1[color][sq];
    diff2 = hash_update2 ^ hash_put_value2[color][sq];
    hash1 ^= diff1;
    hash2 ^= diff2;

    region_parity ^= quadrant_mask[sq];

    pred = end_move_list[sq].pred;
    succ = end_move_list[sq].succ;
    end_move_list[pred].succ = succ;
    end_move_list[succ].pred = pred;

    new_disc_diff = -disc_diff - 2 * flipped - 1;

    if ( empties <= LOW_LEVEL_DEPTH )  /* Fail-high for opp is likely. */
      ev = -solve_parity_hash( new_opp_bits, bb_flips, -beta, -alpha,
			       oppcol, empties - 1, new_disc_diff, VALUE_TRUE );
    else
      ev = -solve_parity_hash_high( new_opp_bits, bb_flips, -beta, -alpha,
				    oppcol, empties - 1, new_disc_diff, VALUE_TRUE );

    region_parity ^= quadrant_mask[sq];

    UndoFlips( flipped, oppcol );
    hash1 ^= diff1;
    hash2 ^= diff2;
    board[sq] = EMPTY;

    end_move_list[pred].succ = sq;
    end_move_list[succ].pred = sq;

    if ( ev > score ) {
      score = ev;
      if ( ev > alpha ) {
	if ( ev >= beta ) { 
	  best_move = sq;
	  add_hash( ENDGAME_MODE, score, best_move,
		    ENDGAME_SCORE | LOWER_BOUND, empties, 0 );
	  return score;
	}
	alpha = ev;
      }
      best_sq = sq;
    }
  }

  best_move = best_sq;
  if ( score > in_alpha )
    add_hash( ENDGAME_MODE, score, best_move,
	      ENDGAME_SCORE | EXACT_VALUE, empties, 0 );
  else
    add_hash( ENDGAME_MODE, score, best_move,
	      ENDGAME_SCORE | UPPER_BOUND, empties, 0 );

  return score;
}





/*
   SETUP_END_ENDGAME_MODULE
   Prepares the endgame solver for a new game.
   This means clearing a few status fields.   
*/

void
setup_zebra_endgame_module( void ) {
  int i, j;
  int dir_shift[8] = {1, -1, 7, -7, 8, -8, 9, -9};

  /* Calculate the neighborhood masks */

  for ( i = 1; i <= 8; i++ )
    for ( j = 1; j <= 8; j++ ) {
      /* Create the neighborhood mask for the square POS */

      int pos = 10 * i + j;
      int shift = 8 * (i - 1) + (j - 1);
      unsigned int k;

      neighborhood_mask[pos].low = 0;
      neighborhood_mask[pos].high = 0;

      for ( k = 0; k < 8; k++ )
	if ( dir_mask[pos] & (1 << k) ) {
	  unsigned int neighbor = shift + dir_shift[k];
	  if ( neighbor < 32 )
	    neighborhood_mask[pos].low |= (1 << neighbor);
	  else
	    neighborhood_mask[pos].high |= (1 << (neighbor - 32));
	}
    }

  /* Set the fastest-first mobility encouragements and thresholds */

  for ( i = 0; i <= 60; i++ )
    ff_mob_factor[i] = MOB_FACTOR;

  
}




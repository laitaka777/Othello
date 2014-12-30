/*
   File:            doflip.c

   Automatically created by ENDMACRO on Fri Feb 26 20:29:42 1999

   Last modified:   June 6, 2002

   Contents:        Low-level code which flips the discs (if any) affected
                    by a potential move, with or without updating the
		    hash code.
*/



#include <stdio.h>
#include <stdlib.h>
#include "doflip.h"
#include "hash.h"
#include "macros.h"
#include "moves.h"
#include "unflip.h"
#include "constant.h"


/* Global variables */

int piece_count[3][MAX_SEARCH_DEPTH];

Board board;

unsigned int hash_update1, hash_update2;


/* When no other information is available, JCW's endgame
   priority order is used also in the midgame. */
int position_list[100] = {
  /*A1*/        11 , 18 , 81 , 88 , 
  /*C1*/        13 , 16 , 31 , 38 , 61 , 68 , 83 , 86 ,
  /*C3*/        33 , 36 , 63 , 66 ,
  /*D1*/        14 , 15 , 41 , 48 , 51 , 58 , 84 , 85 ,
  /*D3*/        34 , 35 , 43 , 46 , 53 , 56 , 64 , 65 ,
  /*D2*/        24 , 25 , 42 , 47 , 52 , 57 , 74 , 75 ,
  /*C2*/        23 , 26 , 32 , 37 , 62 , 67 , 73 , 76 ,
  /*B1*/        12 , 17 , 21 , 28 , 71 , 78 , 82 , 87 ,
  /*B2*/        22 , 27 , 72 , 77 ,
  /*D4*/        44 , 45 , 54 , 45 ,
  /*North*/      0 ,  1 ,  2 ,  3 ,  4 ,  5 ,  6 ,  7 , 8,
  /*East*/       9 , 19 , 29 , 39 , 49 , 59 , 69 , 79 , 89,
  /*West*/      10 , 20 , 30 , 40 , 50 , 60 , 70 , 80 , 90,
  /*South*/     91 , 92 , 93 , 94 , 95 , 96 , 97 , 98 , 99 };





/* The board split into nine regions. */

static const int board_region[100] = {
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,   1,   1,   2,   2,   2,   2,   3,   3,   0,
  0,   1,   1,   2,   2,   2,   2,   3,   3,   0,
  0,   4,   4,   5,   5,   5,   5,   6,   6,   0,
  0,   4,   4,   5,   5,   5,   5,   6,   6,   0,
  0,   4,   4,   5,   5,   5,   5,   6,   6,   0,
  0,   4,   4,   5,   5,   5,   5,   6,   6,   0,
  0,   7,   7,   8,   8,   8,   8,   9,   9,   0,
  0,   7,   7,   8,   8,   8,   8,   9,   9,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0
};



#define DrctnlFlips_six( sq, inc, color, oppcol ) {      \
  int *pt = sq + inc;                                    \
                                                         \
  if ( *pt == oppcol ) {                                 \
    pt += inc;                                           \
    if ( *pt == oppcol ) {                               \
      pt += inc;                                         \
      if ( *pt == oppcol ) {                             \
	pt += inc;                                       \
	if ( *pt == oppcol ) {                           \
	  pt += inc;                                     \
	  if ( *pt == oppcol ) {                         \
	    pt += inc;                                   \
	    if ( *pt == oppcol )                         \
	      pt += inc;                                 \
	  }                                              \
	}                                                \
      }                                                  \
    }                                                    \
    if ( *pt == color ) {                                \
      pt -= inc;                                         \
      do {                                               \
	*pt = color;                                     \
	*(flip_stack++) = pt;                            \
	pt -= inc;                                       \
      } while ( pt != sq );                              \
    }                                                    \
  }                                                      \
}


#define DrctnlFlips_four( sq, inc, color, oppcol ) {     \
  int *pt = sq + inc;                                    \
                                                         \
  if ( *pt == oppcol ) {                                 \
    pt += inc;                                           \
    if ( *pt == oppcol ) {                               \
      pt += inc;                                         \
      if ( *pt == oppcol ) {                             \
	pt += inc;                                       \
	if ( *pt == oppcol )                             \
	  pt += inc;                                     \
      }                                                  \
    }                                                    \
    if ( *pt == color ) {                                \
      pt -= inc;                                         \
      do {                                               \
	*pt = color;                                     \
	*(flip_stack++) = pt;                            \
	pt -= inc;                                       \
      } while( pt != sq );                               \
    }                                                    \
  }                                                      \
}


INLINE int
DoFlips_no_hash( int sqnum, int color ) {
  int opp_color = OPPONENT( color );
  int *sq;
  int **old_flip_stack;

  old_flip_stack = flip_stack;
  sq = &board[sqnum];

  switch ( board_region[sqnum] ) {
  case 1:
    DrctnlFlips_six( sq, 1, color, opp_color );
    DrctnlFlips_six( sq, 11, color, opp_color );
    DrctnlFlips_six( sq, 10, color, opp_color );
    break;
  case 2:
    DrctnlFlips_four( sq, 1, color, opp_color );
    DrctnlFlips_four( sq, 11, color, opp_color );
    DrctnlFlips_six( sq, 10, color, opp_color );
    DrctnlFlips_four( sq, 9, color, opp_color );
    DrctnlFlips_four( sq, -1, color, opp_color );
    break;
  case 3:
    DrctnlFlips_six( sq, 10, color, opp_color );
    DrctnlFlips_six( sq, 9, color, opp_color );
    DrctnlFlips_six( sq, -1, color, opp_color );
    break;
  case 4:
    DrctnlFlips_four( sq, -10, color, opp_color );
    DrctnlFlips_four( sq, -9, color, opp_color );
    DrctnlFlips_six( sq, 1, color, opp_color );
    DrctnlFlips_four( sq, 11, color, opp_color );
    DrctnlFlips_four( sq, 10, color, opp_color );
    break;
  case 5:
    DrctnlFlips_four( sq, -11, color, opp_color );
    DrctnlFlips_four( sq, -10, color, opp_color );
    DrctnlFlips_four( sq, -9, color, opp_color );
    DrctnlFlips_four( sq, 1, color, opp_color );
    DrctnlFlips_four( sq, 11, color, opp_color );
    DrctnlFlips_four( sq, 10, color, opp_color );
    DrctnlFlips_four( sq, 9, color, opp_color );
    DrctnlFlips_four( sq, -1, color, opp_color );
    break;
  case 6:
    DrctnlFlips_four( sq, -10, color, opp_color );
    DrctnlFlips_four( sq, -11, color, opp_color );
    DrctnlFlips_six( sq, -1, color, opp_color );
    DrctnlFlips_four( sq, 9, color, opp_color );
    DrctnlFlips_four( sq, 10, color, opp_color );
    break;
  case 7:
    DrctnlFlips_six( sq, -10, color, opp_color );
    DrctnlFlips_six( sq, -9, color, opp_color );
    DrctnlFlips_six( sq, 1, color, opp_color );
    break;
  case 8:
    DrctnlFlips_four( sq, -1, color, opp_color );
    DrctnlFlips_four( sq, -11, color, opp_color );
    DrctnlFlips_six( sq, -10, color, opp_color );
    DrctnlFlips_four( sq, -9, color, opp_color );
    DrctnlFlips_four( sq, 1, color, opp_color );
    break;
  case 9:
    DrctnlFlips_six( sq, -10, color, opp_color );
    DrctnlFlips_six( sq, -11, color, opp_color );
    DrctnlFlips_six( sq, -1, color, opp_color );
    break;
  default:
    break;
  }

  return flip_stack - old_flip_stack;
}



#define DrctnlFlipsHash_four( sq, inc, color, oppcol ) { \
  int *pt = sq + inc;                                    \
                                                         \
  if ( *pt == oppcol ) {                                 \
    pt += inc;                                           \
    if ( *pt == oppcol ) {                               \
      pt += inc;                                         \
      if ( *pt == oppcol ) {                             \
	pt += inc;                                       \
	if ( *pt == oppcol )                             \
	  pt += inc;                                     \
      }                                                  \
    }                                                    \
    if ( *pt == color ) {                                \
      int update1;                                       \
      int update2;                                       \
      int offset;                                        \
      pt -= inc;                                         \
      offset = pt - board;                               \
      update1 = hash_flip1[offset];                      \
      update2 = hash_flip2[offset];                      \
      *pt = color;                                       \
      *(flip_stack++) = pt;                              \
      pt -= inc;                                         \
      while ( pt != sq ) {                               \
        offset -= inc;                                   \
        update1 ^= hash_flip1[offset];                   \
        update2 ^= hash_flip2[offset];                   \
	*pt = color;                                     \
	*(flip_stack++) = pt;                            \
	pt -= inc;                                       \
      }                                                  \
      hash_update1 ^= update1;                           \
      hash_update2 ^= update2;                           \
    }                                                    \
  }                                                      \
}


#define DrctnlFlipsHash_six( sq, inc, color, oppcol ) {  \
  int *pt = sq + inc;                                    \
                                                         \
  if ( *pt == oppcol ) {                                 \
    pt += inc;                                           \
    if ( *pt == oppcol ) {                               \
      pt += inc;                                         \
      if ( *pt == oppcol ) {                             \
	pt += inc;                                       \
	if ( *pt == oppcol ) {                           \
	  pt += inc;                                     \
	  if ( *pt == oppcol ) {                         \
	    pt += inc;                                   \
	    if ( *pt == oppcol )                         \
	      pt += inc;                                 \
	  }                                              \
	}                                                \
      }                                                  \
    }                                                    \
    if ( *pt == color ) {                                \
      int update1;                                       \
      int update2;                                       \
      int offset;                                        \
      pt -= inc;                                         \
      offset = pt - board;                               \
      update1 = hash_flip1[offset];                      \
      update2 = hash_flip2[offset];                      \
      *pt = color;                                       \
      *(flip_stack++) = pt;                              \
      pt -= inc;                                         \
      while ( pt != sq ) {                               \
        offset -= inc;                                   \
        update1 ^= hash_flip1[offset];                   \
        update2 ^= hash_flip2[offset];                   \
	*pt = color;                                     \
	*(flip_stack++) = pt;                            \
	pt -= inc;                                       \
      }                                                  \
      hash_update1 ^= update1;                           \
      hash_update2 ^= update2;                           \
    }                                                    \
  }                                                      \
}



INLINE int
DoFlips_hash( int sqnum, int color, int oppcol ) {
  int opp_color = OPPONENT( color );
  int *sq;
  int **old_flip_stack;

  hash_update1 = 0;
  hash_update2 = 0;

  old_flip_stack = flip_stack;
  sq = &board[sqnum];

  switch ( board_region[sqnum] ) {
  case 1:
    DrctnlFlipsHash_six( sq, 1, color, opp_color );
    DrctnlFlipsHash_six( sq, 11, color, opp_color );
    DrctnlFlipsHash_six( sq, 10, color, opp_color );
    break;
  case 2:
    DrctnlFlipsHash_four( sq, 1, color, opp_color );
    DrctnlFlipsHash_four( sq, 11, color, opp_color );
    DrctnlFlipsHash_six( sq, 10, color, opp_color );
    DrctnlFlipsHash_four( sq, 9, color, opp_color );
    DrctnlFlipsHash_four( sq, -1, color, opp_color );
    break;
  case 3:
    DrctnlFlipsHash_six( sq, 10, color, opp_color );
    DrctnlFlipsHash_six( sq, 9, color, opp_color );
    DrctnlFlipsHash_six( sq, -1, color, opp_color );
    break;
  case 4:
    DrctnlFlipsHash_four( sq, -10, color, opp_color );
    DrctnlFlipsHash_four( sq, -9, color, opp_color );
    DrctnlFlipsHash_six( sq, 1, color, opp_color );
    DrctnlFlipsHash_four( sq, 11, color, opp_color );
    DrctnlFlipsHash_four( sq, 10, color, opp_color );
    break;
  case 5:
    DrctnlFlipsHash_four( sq, -11, color, opp_color );
    DrctnlFlipsHash_four( sq, -10, color, opp_color );
    DrctnlFlipsHash_four( sq, -9, color, opp_color );
    DrctnlFlipsHash_four( sq, 1, color, opp_color );
    DrctnlFlipsHash_four( sq, 11, color, opp_color );
    DrctnlFlipsHash_four( sq, 10, color, opp_color );
    DrctnlFlipsHash_four( sq, 9, color, opp_color );
    DrctnlFlipsHash_four( sq, -1, color, opp_color );
    break;
  case 6:
    DrctnlFlipsHash_four( sq, -10, color, opp_color );
    DrctnlFlipsHash_four( sq, -11, color, opp_color );
    DrctnlFlipsHash_six( sq, -1, color, opp_color );
    DrctnlFlipsHash_four( sq, 9, color, opp_color );
    DrctnlFlipsHash_four( sq, 10, color, opp_color );
    break;
  case 7:
    DrctnlFlipsHash_six( sq, -10, color, opp_color );
    DrctnlFlipsHash_six( sq, -9, color, opp_color );
    DrctnlFlipsHash_six( sq, 1, color, opp_color );
    break;
  case 8:
    DrctnlFlipsHash_four( sq, -1, color, opp_color );
    DrctnlFlipsHash_four( sq, -11, color, opp_color );
    DrctnlFlipsHash_six( sq, -10, color, opp_color );
    DrctnlFlipsHash_four( sq, -9, color, opp_color );
    DrctnlFlipsHash_four( sq, 1, color, opp_color );
    break;
  case 9:
    DrctnlFlipsHash_six( sq, -10, color, opp_color );
    DrctnlFlipsHash_six( sq, -11, color, opp_color );
    DrctnlFlipsHash_six( sq, -1, color, opp_color );
    break;
  default:
    break;
  }

  return flip_stack - old_flip_stack;
}

/*
   File:              moves.c

   Created:           June 30, 1997

   Modified:          April 24, 2001
   
   Author:            Gunnar Andersson (gunnar@radagast.se)

   Contents:          The move generator.
*/



#include <stdio.h>
#include <stdlib.h>
#include "constant.h"
#include "doflip.h"
#include "hash.h"
#include "macros.h"
#include "moves.h"
#include "search.h"
#include "unflip.h"



/* Global variables */

int disks_played;
int move_count[MAX_SEARCH_DEPTH];
int move_list[MAX_SEARCH_DEPTH][64];
int *first_flip_direction[100];
int flip_direction[100][16];   /* 100 * 9 used */
int **first_flipped_disc[100];
int *flipped_disc[100][8];
const int dir_mask[100] = {
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
  0,  81,  81,  87,  87,  87,  87,  22,  22,   0,
  0,  81,  81,  87,  87,  87,  87,  22,  22,   0,
  0, 121, 121, 255, 255, 255, 255, 182, 182,   0,
  0, 121, 121, 255, 255, 255, 255, 182, 182,   0,
  0, 121, 121, 255, 255, 255, 255, 182, 182,   0,
  0, 121, 121, 255, 255, 255, 255, 182, 182,   0,
  0,  41,  41, 171, 171, 171, 171, 162, 162,   0,
  0,  41,  41, 171, 171, 171, 171, 162, 162,   0,
  0,   0,   0,   0,   0,   0,   0,   0,   0,   0
};
const int move_offset[8] = { 1, -1, 9, -9, 10, -10, 11, -11 };


/* Local variables */

static int flip_count[65];
static int sweep_status[MAX_SEARCH_DEPTH];



/*
  INIT_MOVES
  Initialize the move generation subsystem.
*/

void
init_moves( void ) {
  int i, j, k;
  int pos;
  int feasible;

  for ( i = 1; i <= 8; i++ )
    for ( j = 1; j <= 8; j++ ) {
      pos = 10 * i + j;
      for ( k = 0; k <= 8; k++ )
	flip_direction[pos][k] = 0;
      feasible = 0;
      for ( k = 0; k < 8; k++ )
	if ( dir_mask[pos] & (1 << k) ) {
	  flip_direction[pos][feasible] = move_offset[k];
	  feasible++;
	}
      first_flip_direction[pos] = &flip_direction[pos][0];
    }
}









/*
   MAKE_MOVE
   side_to_move = the side that is making the move
   move = the position giving the move

   Makes the necessary changes on the board and updates the
   counters.
*/

INLINE int
make_move( int side_to_move, int move, int update_hash ) {
  int flipped;
  unsigned int diff1, diff2;

  if ( update_hash ) {
    flipped = DoFlips_hash( move, side_to_move, OPPONENT( side_to_move ) );
    if ( flipped == 0 )
      return 0;
    diff1 = hash_update1 ^ hash_put_value1[side_to_move][move];
    diff2 = hash_update2 ^ hash_put_value2[side_to_move][move];
    hash_stored1[disks_played] = hash1;
    hash_stored2[disks_played] = hash2;
    hash1 ^= diff1;
    hash2 ^= diff2;
  }
  else {
    flipped = DoFlips_no_hash( move, side_to_move );
    if ( flipped == 0 )
      return 0;
    hash_stored1[disks_played] = hash1;
    hash_stored2[disks_played] = hash2;
  }

  flip_count[disks_played] = flipped;

  board[move] = side_to_move;

  if ( side_to_move == BLACKSQ ) {
    piece_count[BLACKSQ][disks_played + 1] =
      piece_count[BLACKSQ][disks_played] + flipped + 1;
    piece_count[WHITESQ][disks_played + 1] =
      piece_count[WHITESQ][disks_played] - flipped;
  }
  else {  /* side_to_move == WHITESQ */
    piece_count[WHITESQ][disks_played + 1] =
      piece_count[WHITESQ][disks_played] + flipped + 1;
    piece_count[BLACKSQ][disks_played + 1] =
      piece_count[BLACKSQ][disks_played] - flipped;
  }

  disks_played++;

  return flipped;
}


/*
   MAKE_MOVE_NO_HASH
   side_to_move = the side that is making the move
   move = the position giving the move

   Makes the necessary changes on the board. Note that the hash table
   is not updated - the move has to be unmade using UNMAKE_MOVE_NO_HASH().
*/


INLINE int
make_move_no_hash( int side_to_move, int move ) {
  int flipped;

  flipped = DoFlips_no_hash( move, side_to_move );
  if ( flipped == 0 )
    return 0;

  flip_count[disks_played] = flipped;

  board[move] = side_to_move;

#if 1
  if ( side_to_move == BLACKSQ ) {
    piece_count[BLACKSQ][disks_played + 1] =
      piece_count[BLACKSQ][disks_played] + flipped + 1;
    piece_count[WHITESQ][disks_played + 1] =
      piece_count[WHITESQ][disks_played] - flipped;
  }
  else {  /* side_to_move == WHITESQ */
    piece_count[WHITESQ][disks_played + 1] =
      piece_count[WHITESQ][disks_played] + flipped + 1;
    piece_count[BLACKSQ][disks_played + 1] =
      piece_count[BLACKSQ][disks_played] - flipped;
  }
#else
  piece_count[side_to_move][disks_played + 1] =
    piece_count[side_to_move][disks_played] + flipped + 1;
  piece_count[OPPONENT( side_to_move )][disks_played + 1] =
    piece_count[OPPONENT( side_to_move )][disks_played] - flipped;
#endif
  disks_played++;

  return flipped;
}


/*
  UNMAKE_MOVE
  Takes back a move.
*/

INLINE void
unmake_move( int side_to_move, int move ) {
  board[move] = EMPTY;

  disks_played--;

  hash1 = hash_stored1[disks_played];
  hash2 = hash_stored2[disks_played];

  UndoFlips_inlined( flip_count[disks_played], OPPONENT( side_to_move ) );
}


/*
  UNMAKE_MOVE_NO_HASH
  Takes back a move. Only to be called when the move was made without
  updating hash table, preferrable through MAKE_MOVE_NO_HASH().
*/

INLINE void
unmake_move_no_hash( int side_to_move, int move ) {
  board[move] = EMPTY;

  disks_played--;

  UndoFlips_inlined( flip_count[disks_played], OPPONENT( side_to_move ) );
}


/*
   VALID_MOVE
   Determines if a move is legal.
*/

int
valid_move( int move, int side_to_move ) {
  int i, pos, count;

  if ( (move < 11) || (move > 88) || (board[move] != EMPTY) )
    return VALUE_FALSE;

  for ( i = 0; i < 8; i++ )
    if ( dir_mask[move] & (1 << i) ) {
      for ( pos = move + move_offset[i], count = 0;
	    board[pos] == OPPONENT( side_to_move ); pos += move_offset[i], count++ )
	;
      if ( board[pos] == side_to_move ) {
	if ( count >= 1 )
	  return VALUE_TRUE;
      }
    }

  return VALUE_FALSE;
}





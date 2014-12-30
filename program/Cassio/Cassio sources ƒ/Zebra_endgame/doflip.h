/*
   doflip.h

   Automatically created by ENDMACRO on Fri Feb 26 20:29:42 1999

   Last modified:   December 25, 1999
*/



#ifndef DOFLIP_H
#define DOFLIP_H


#include "constant.h"


/* The basic board type. One index for each position;
   a1=11, h1=18, a8=81, h8=88. */
typedef int Board[128];

extern int piece_count[3][MAX_SEARCH_DEPTH];

/* Holds the current board position. Updated as the search progresses,
   but all updates must be reversed when the search stops. */
extern Board board;

extern unsigned int hash_update1, hash_update2;

/* JCW's move order */
extern int position_list[100];

int
DoFlips_hash( int sqnum, int color, int oppcol );

int
DoFlips_no_hash( int sqnum, int color );



#endif  /* DOFLIP_H */

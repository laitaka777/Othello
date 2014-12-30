/*
   File:          bitbtest.h

   Created:       November 22, 1999
   
   Modified:      April 26, 2000

   Authors:       Gunnar Andersson (gunnar@radagast.se)

   Contents:
*/



#ifndef BITBTEST_H
#define BITBTEST_H



#include "bitboard.h"



extern BitBoard bb_flips;

extern int (*TestFlips_bitboard[89])(const BitBoard, const BitBoard);



#endif  /* BITBTEST_H */

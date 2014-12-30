/*
   File:          bitboard.c

   Created:       November 21, 1999
   
   Modified:      December 26, 2000

   Authors:       Gunnar Andersson (gunnar@radagast.se)

   Contents:
*/



#include "bitboard.h"
#include "constant.h"
#include "macros.h"



BitBoard square_mask[100];



/*
  NON_ITERATIVE_POPCOUNT
  Counts the number of bits set in a 64-bit SInt16.
  This is done using some bitfiddling tricks.
*/

#define m1      0x55555555
#define m2      0x33333333

INLINE unsigned int
non_iterative_popcount( BitBoard b ) {
  unsigned int a, n1, n2;

  a = b.high - ((b.high >> 1) & m1);
  n1 = (a & m2) + ((a >> 2) & m2);
  n1 = (n1 & 0x0F0F0F0F) + ((n1 >> 4) & 0x0F0F0F0F);
  n1 = (n1 & 0xFFFF) + (n1 >> 16);
  n1 = (n1 & 0xFF) + (n1 >> 8);

  a = b.low - ((b.low >> 1) & m1);
  n2 = (a & m2) + ((a >> 2) & m2);
  n2 = (n2 & 0x0F0F0F0F) + ((n2 >> 4) & 0x0F0F0F0F);
  n2 = (n2 & 0xFFFF) + (n2 >> 16);
  n2 = (n2 & 0xFF) + (n2 >> 8);

  return n1 + n2;
}



/*
  ITERATIVE_POPCOUNT
  Counts the number of bits set in a 64-bit SInt16.
  This is done using an iterative procedure which loops
  a number of times equal to the number of bits set,
  hence this function is fast when the number of bits
  set is low.
*/

INLINE unsigned int
iterative_popcount( BitBoard b ) {
  unsigned int n;
  n = 0;
  for ( ; b.high != 0; n++, b.high &= (b.high - 1) )
    ;
  for ( ; b.low != 0; n++, b.low &= (b.low - 1) )
    ;

  return n;
}



/*
  BIT_REVERSE_32
  Returns the bit-reverse of a 32-bit integer.
*/

unsigned int
bit_reverse_32( unsigned int val ) {
  val = ((val >>  1) & 0x55555555) | ((val <<  1) & 0xAAAAAAAA);
  val = ((val >>  2) & 0x33333333) | ((val <<  2) & 0xCCCCCCCC);
  val = ((val >>  4) & 0x0F0F0F0F) | ((val <<  4) & 0xF0F0F0F0);
  val = ((val >>  8) & 0x00FF00FF) | ((val <<  8) & 0xFF00FF00);
  val = ((val >> 16) & 0x0000FFFF) | ((val << 16) & 0xFFFF0000);

  return val;
}



/*
  SET_BITBOARDS
  Converts the vector board representation to the bitboard representation.
*/

void
set_bitboards( int *board, int side_to_move,
	       BitBoard *my_out, BitBoard *opp_out ) {
  int i, j;
  int pos;
  unsigned long mask;
  BitBoard my_bits, opp_bits;

  my_bits.high = 0;
  my_bits.low = 0;
  opp_bits.high = 0;
  opp_bits.low = 0;

  mask = 1;
  for ( i = 1; i <= 4; i++ )
    for ( j = 1; j <= 8; j++, mask <<= 1 ) {
      pos = 10 * i + j;
      if ( board[pos] == side_to_move )
	my_bits.low |= mask;
      else if ( board[pos] == OPPONENT( side_to_move ) )
	opp_bits.low |= mask;
    }

  mask = 1;
  for ( i = 5; i <= 8; i++ )
    for ( j = 1; j <= 8; j++, mask <<= 1 ) {
      pos = 10 * i + j;
      if ( board[pos] == side_to_move )
	my_bits.high |= mask;
      else if ( board[pos] == OPPONENT( side_to_move ) )
	opp_bits.high |= mask;
    }

  *my_out = my_bits;
  *opp_out = opp_bits;
}



void
init_bitboard( void ) {
  int i, j;

  for ( i = 1; i <= 8; i++ )
    for ( j = 1; j <= 8; j++ ) {
      int pos = 10 * i + j;
      unsigned shift = 8 * (i - 1) + (j - 1);
      if ( shift < 32 ) {
	square_mask[pos].low = 1ul << shift;
	square_mask[pos].high = 0;
      }
      else {
	square_mask[pos].low = 0;
	square_mask[pos].high = 1ul << (shift - 32);
      }
    }
}

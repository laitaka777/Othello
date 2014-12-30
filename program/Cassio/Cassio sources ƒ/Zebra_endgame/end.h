/*
   File:          end.h

   Created:       June 25, 1997

   Modified:      December 3, 2002

   Author:        Gunnar Andersson (gunnar@radagast.se)

   Contents:      The interface to the endgame solver.
*/



#ifndef END_H
#define END_H




#define END_MOVE_LIST_HEAD        0
#define END_MOVE_LIST_TAIL        99


typedef struct  {
  int pred;
  int succ;
} MoveLink;


extern MoveLink end_move_list[100];
extern unsigned int quadrant_mask[100];




extern void setup_zebra_endgame_module( void );


#endif  /* END_H */




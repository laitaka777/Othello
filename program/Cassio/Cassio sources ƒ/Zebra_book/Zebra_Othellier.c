/* La classe qui implémente un Othellier */
#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "Zebra_Othellier.h"

static	int	Dir[11] = {1, 11, 10, 9, -1, -11, -10, -9, 1, 11, 10} ;

static	int	BIDir[100] = {	0,0,0,0,0,0,0,0,0,0,
							0,0,0,0,0,0,0,2,2,0,
							0,0,0,0,0,0,0,2,2,0,
							0,6,6,0,0,0,0,2,2,0,
							0,6,6,0,0,0,0,2,2,0,
							0,6,6,0,0,0,0,2,2,0,
							0,6,6,0,0,0,0,2,2,0,
							0,6,6,4,4,4,4,4,4,0,
							0,6,6,4,4,4,4,4,4,0,
							0,0,0,0,0,0,0,0,0,0} ;
							 
static	int	BSDir[100] = {	7, 7, 7,7,7,7,7,7,7,7,
							7, 2, 2,4,4,4,4,4,4,7,
							7, 2, 2,4,4,4,4,4,4,7,
							7,10,10,7,7,7,7,6,6,7,
							7,10,10,7,7,7,7,6,6,7,
							7,10,10,7,7,7,7,6,6,7,
							7,10,10,7,7,7,7,6,6,7,
							7, 8, 8,8,8,8,8,6,6,7,
							7, 8, 8,8,8,8,8,6,6,7,
							7, 7, 7,7,7,7,7,7,7,7} ;


	int	Board[100] ;
	int	toMove ;
	int	numProchainCoup ;
	int ListeCoups[100] ;

void InitOthellier(void)
{
	int i ;
	for (i=0 ; i<100 ; i++)
		Board[i] = VIDE ;
	for (i=0 ; i<9 ; i++)
		Board[i] = Board[10*(i+1)] = Board[10*i+9] = Board[91+i] = BIDON ;
	Board[45] = Board[54] = NOIR ;
	Board[44] = Board[55] = BLANC ;
	toMove = NOIR ;
	numProchainCoup = 1 ;
}

short OthellierLegal(int move, int coul)
{
	register int index, offset ;
	int oppon, tmp;
	int i ;
	unsigned short compte = 0, cptLigne ;

	if ( (move < 11) || (move > 88) || (Board[move] != VIDE) ) return 0;
	if ( (coul==VIDE) && (toMove==PASS)) return 0 ;
	tmp = ( (coul == VIDE) ? toMove : coul ) ;
	oppon = ADVERSAIRE( tmp )  ;
	for (i = BIDir[move] ; i <= BSDir[move];i++)
	{
		offset = Dir[i] ;
		index = move + offset ;
		cptLigne = 0 ;
		if (Board[index] == oppon)
		{
			do
			{
				cptLigne++ ;
				index += offset ;
			}
			while (Board[index] == oppon) ;
			if (Board[index] == tmp) 
				compte += cptLigne;
		}
	}
	return compte ;
}

short OthellierJoue(int move, int coul)
{
	register int index, offset ;
	int oppon, i ;
	unsigned short compte=0, cptLigne ;

	if ( !OthellierLegal(move, coul) ) return 0 ;
	if (coul != VIDE) toMove = coul ;
	oppon = ADVERSAIRE( toMove ) ;
	for (i = BIDir[move] ; i <= BSDir[move];i++)
	{
		offset = Dir[i] ;
		index = move + offset ;
		cptLigne = 0 ;
		if (Board[index] == oppon)
		{
			do
			{
				index += offset ;
				cptLigne++ ;
			}
			while (Board[index] == oppon) ;
			if (Board[index] == toMove)
			{
				compte += cptLigne ;
				index -= offset ;
 				do
 				{
 					Board[index] = toMove ;
 					index -= offset ;
 				}
 				while (index != move) ;
 			}
		}
	}
	Board[move] = toMove ;
	ListeCoups[numProchainCoup-1] = move ;
	numProchainCoup++;
	toMove = ADVERSAIRE (toMove) ;
	if (OthellierCheckPass(toMove)) 
	{
		toMove = ADVERSAIRE (toMove) ;
		if (OthellierCheckPass(toMove)) toMove = PASS ;
	}
	return compte ;
}


short OthellierCheckPass(int coul)
{
	int i ;
	for (i=11 ; i < 89 ; i++)
		if ( OthellierLegal(i, coul) ) return 0 ;
	return 1 ;
}

short OthellierFinPartie(void)
{
	return OthellierCheckPass(NOIR) && OthellierCheckPass(BLANC) ;
}

short OthellierGoBack(void) {
	int num = numProchainCoup -3 ;
	int i ;
	int Liste[100] ;
	
	if (numProchainCoup == 1)
		return 0 ;
	if (numProchainCoup == 2) {
		InitOthellier() ;
		return 1 ;
	}
	for (i=0 ; i<100 ; i++)
		Liste[i] = ListeCoups[i] ; /* sauvegarde liste coups */
	InitOthellier() ;
	for (i=0 ; i<=num; i++)
		OthellierJoue( Liste[i], VIDE ) ;
	return numProchainCoup ;
}

void GetOthellier(int *Pos)
{
	int i ;
	for ( i=0 ; i<100 ; i++)
		Pos[i] = Board[i] ;
}

void DrawOthellier(void)
{
	int i, j, CASE ;
	
	for ( i=1 ; i<=8 ; i++)
	{
		for ( j=1 ; j<=8 ; j++) {
			CASE = Board[i*10+j] ;
			switch(CASE) {
				case NOIR : printf("x") ;
							break ;
				case BLANC : printf("o") ;
							break ;
				case VIDE : printf(".") ;
							break ;
			}
		}
		printf("\n") ;
	}
	printf("\n") ;
	switch(toMove)
	{
		case NOIR  : printf("Trait a Noir\n") ;
					 break ;
		case BLANC : printf("Trait a Blanc\n") ;
					 break ;
		case PASS  : printf("Fini !\n") ;
					 break ;
	}
}

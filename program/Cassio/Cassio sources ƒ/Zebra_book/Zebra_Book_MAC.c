#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <time.h>


#include "Zebra_Book.h"
#include "Zebra_HashPattern.h"

/************/

static BookNode *nodesTable   ;         /* La table de toutes les positions */
static int FileNodeCount   = 0;         /* Nombre de positions dans la table */


#define ZEBRA_BOOK_READING_BLOCK         4096;


pascal 
int read_binary_database( char *file_name ) {
	int i,size;
	short magic1, magic2 ;
	FILE *stream;
	int nodeCountStoredInFile;
	int reste;
    
    
	stream = fopen( file_name, "rb" );
	if ( stream == NULL ) {
		/* printf( "Could not open database file: %s\n", file_name ); */
		return (-1) ;
	}

	fread( &magic1, sizeof( short ), 1, stream );
	fread( &magic2, sizeof( short ), 1, stream );
	if ( (magic1 != BOOK_MAGIC1) || (magic2 != BOOK_MAGIC2) ) {
		printf( "Wrong checksum, might be an old version or the wrong format: %s\n", file_name );
	}
	fread( &nodeCountStoredInFile, sizeof( int ), 1, stream );
	/* printf( "%d nodes in file\n", FileNodeCount) ; */
	
	free(nodesTable);
	size = nodeCountStoredInFile*sizeof(BookNode);
	nodesTable = malloc(size) ;
	
	if (nodesTable)
    	for ( i = 0; i < nodeCountStoredInFile; i++ ) {
    		if (!fread( &nodesTable[i].hash_val1, sizeof( int ), 1, stream ) )
    			break ;
    		if (!fread( &nodesTable[i].hash_val2, sizeof( int ), 1, stream ) )
    			break ;
    		if (!fread( &nodesTable[i].black_minimax_score, sizeof( short ), 1, stream ) )
    			break ;
    		if (!fread( &nodesTable[i].white_minimax_score, sizeof( short ), 1, stream ) )
    			break ;
    		if (!fread( &nodesTable[i].best_alternative_move, sizeof( short ), 1, stream ) )
    			break ;
    		if (!fread( &nodesTable[i].alternative_score, sizeof( short ), 1, stream ) )
    			break ;
    		if (!fread( &nodesTable[i].flags, sizeof( unsigned short ), 1, stream ) )
    			break ;
    	
    	  reste = i % ZEBRA_BOOK_READING_BLOCK;
    	  if ((!reste) && Lecture_ZebraBook_Interrompue_Par_Evenement())
      	    {
      	    FileNodeCount = 0;
      	    fclose( stream );
      	    return (-1);
      	    }
    	}
	fclose( stream );
	prepare_Zebra_hash() ; /* Preparation des valeurs des tables de hash */
	if (i != nodeCountStoredInFile) {
		// printf(" There was an error reading the Zebra-book.data file.\n") ; 
		// printf(" Or maybe allocating %d bytes failed....\n",size) ; 
		return (-1);
	}
	
	FileNodeCount = nodeCountStoredInFile;
	
	return i ;
}


/* A partir d'une position, renvoie l'index dans la table des positions. */
/* Ainsi que son orientation (cf. HashPattern.h)                         */
/* Renvoie -1 si la position n'est pas dans la biblio                    */
pascal 
int Trouver_Position_in_ZebraBook( int *Pos, int* orientation, char*  file_name) {
	int hash1, hash2, i ;
	int low, high;
	
	if (FileNodeCount <= 0)
	   FileNodeCount = read_binary_database(file_name);
	   
	if (FileNodeCount <= 0)
	  return (-1);

	get_Zebra_hash( Pos, &hash1, &hash2, orientation ) ; /* Hash de la position */
	
    /* Recherche dichotomique dans la table ! */
    low = 0;
    high = FileNodeCount - 1;
    while ((high - low) > 1) { 
      i = (high + low ) / 2;
      
      if ((nodesTable[i].hash_val1 < hash1) || ((nodesTable[i].hash_val1 == hash1) && nodesTable[i].hash_val2 <= hash2))
         low = i;
      else 
         high = i;
    }
    if (nodesTable[low].hash_val1 == hash1 && nodesTable[low].hash_val2 == hash2)
      return low ; /* found */
      
	return (-1) ; /* not found */
}


/* Extrait les valeurs d'un element de la table des noeuds */
pascal 
void ExtraireVals(int index, short *SN, short *SB, short *AM, short *AS, unsigned short *F) {
	*SN = nodesTable[index].black_minimax_score ;
	*SB = nodesTable[index].white_minimax_score ;
	*AM = nodesTable[index].best_alternative_move ;
	*AS = nodesTable[index].alternative_score ;
	*F = nodesTable[index].flags ;
}

/* Renvoie le coup correspondant a move dans l'orientation consideree */
pascal 
int SymetriseCoup( int orientation, int move ) {
	int c, l ;

	c = move % 10 ; /* numero de colonne */
	l = move / 10 ; /* numero de ligne */
	switch( orientation ) {
		case 0 : return move ;
		case 1 : return 10*l + (9-c) ;
		case 2 : return 10*(9-l) + (9-c) ;
		case 3 : return 10*(9-l) + c ;
		case 4 : return 10*c + l ;
		case 5 : return 10*(9-c) + l ;
		case 6 : return 10*(9-c) + (9-l);
		case 7 : return 10*c + (9-l) ;
		default : printf("BUG in SymetriseCoup !!") ; exit (1) ;
	}
	return 0 ;
}


pascal 
int NumberOfPositionsInZebraBook()
{
  if (FileNodeCount > 0)
    return FileNodeCount;
  else 
    return 0;
}
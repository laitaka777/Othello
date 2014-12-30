/* Définition pour une classe d'Othelliers… */

/* D'abord quelques #defines pour plus de clarte. */

#define PASS		 99
#define NOIR		  1
#define BLANC		  2
#define VIDE		  0
#define BIDON		  3
#define SPECIAL       4

#define ADVERSAIRE( color )  ((NOIR + BLANC) - (color))


/* L'othellier est code par les cases 0 a 99. a1=11, b1=12… case = 10*ligne + colonne */


	     /* cree les variables + position de depart. Permet de reinitialise le jeu. */
void InitOthellier(void) ;

		 /* Teste si un coup est legal (renvoie le nombre de pions retournes) */
		 /* pour la couleur en parametre. */
short OthellierLegal(int , int ) ;
		
		 /* Test et event. joue le coup en param. avec la couleur en param. */
		 /* renvoie Legal(coup, coul). */
		 /* Si la couleur est VIDE, on prend la couleur qui doit jouer.		*/
short OthellierJoue(int , int ) ;

		 /* Renvoie 0 si la couleur passee en parametre peut jouer, sinon renvoie 1. */
short OthellierCheckPass(int) ;

		 /* Pour les trois fonctions precedentes, si couleur=VIDE, on prend la */
		 /* couleur de la variable toMove, mise à jour a chaque coup joue. */
		 
		 /* Renvoie 1 si la partie est finie. */
short OthellierFinPartie(void) ;

		 /*	Revient en arriere d'un coup */	
		 /* Renvoie le numero du prochain coup */
short OthellierGoBack() ;

		 /* Pos, qui est int Pos[100], se voit egal a la position courante (Board[100]). */
void GetOthellier(int *Pos) ;
		
void DrawOthellier(void) ;


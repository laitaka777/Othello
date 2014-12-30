
#define ZEBRABOOK_FILENAME "Zebra-book.data"



/* Magic numbers for the opening book file format.
   Name convention: Decimals of E. */
#define BOOK_MAGIC1                2718
#define BOOK_MAGIC2                2818
/* In file MAGIC.H */

/* Values denoting absent moves and scores */
#define NONE                      -1
#define NO_MOVE                   -1
#define POSITION_EXHAUSTED        -2
#define NO_SCORE                  9999
#define CONFIRMED_WIN             30000
#define UNWANTED_DRAW             (CONFIRMED_WIN - 1)
#define INFINITE_WIN              32000
#define INFINITE_SPREAD           (1000 * 128)

/* Flag bits and shifts*/
#define NULL_MOVE                 0
#define BLACK_TO_MOVE             1
#define WHITE_TO_MOVE             2
#define WLD_SOLVED                4
#define NOT_TRAVERSED             8
#define FULL_SOLVED               16
#define PRIVATE_NODE              32
#define DEPTH_SHIFT               10

/* This is not a true flag bit but used in the context of generating
   book moves; it must be different from all flag bits though. */
#define DEVIATION                 64
/* In file OSFBOOK.H */


/* Voici les conventions pour le contenu des cases de la position         */
/* Un othellier = int Pos[100] avec les valeurs ci-dessous pour les cases */
/* a1 = 11, a8 = 18...                                                    */
#define VIDE		  0
#define NOIR		  1
#define BLANC		  2


/* La structure d'un element de la table des positions dans la fichier */
typedef struct {
  int hash_val1;
  int hash_val2;
  short black_minimax_score;
  short white_minimax_score;
  short best_alternative_move;
  short alternative_score;
  unsigned short flags;
} BookNode;
/* hash_val1 et hash_val2 sont les valeurs de hash calculees sur la position  */
/* les trois scores sont calcules comme suit :                                */
/* Alternative_move donne la meilleure alternative qui n'est pas dans la      */
/* table des positions (attention a l'orientation)                            */
/* Remarque : ce coup amenant a une feuille, celle-ci n'est PAS dans          */
/* la table ; normal, on y aurait aucune info supplementaire                  */
/* Pour avoir tous les coups ayant une evaluation a partir d'une position     */
/* donnee, il faut regarder tous les coups legaux, voir si la position        */
/* resultante existe dans la table [et recuperer son evaluation] mais aussi   */
/* afficher le Alternative_move [avec son eval]                               */


/* Prototypes */

pascal int read_binary_database( char * ) ;
/* Lit le fichier de base dont on passe le nom en parametre           */
/* Le fichier doit avoir un format de nombres Macintosh et pas Intel. */
/* La fonction va appeler "prepare_hash()" pour preparer les valeurs  */
/* des tableaux de hash.                                              */
/* Renvoie le nombre de positions dans le fichier.                    */
 
 
pascal int Trouver_Position_in_ZebraBook( int *, int *, char *) ;
/* Renvoie l'index de la position dans la table                 */
/* Ainsi que son orientation (cf. HashPattern.h)                */
/* Renvoie -1 si la position n'existe pas dans la table         */
/* Pour l'instant, est implementee comme recherche lineaire     */
/* de 1 a NbrElements.                                          */
/* La table etant triee par hash_val1 et hash_val2, on pourrait */
/* faire une recherche dichotomique                             */


pascal void ExtraireVals(int , short *, short *, short *, short *, unsigned short *) ;
/* extrait les valeurs d'un element de la table des positions */
/* a partir de l'index. Renvoie Score_Noir, Score_Blanc,      */
/* Coup_Alt, Score_Alt, Flags                                 */


pascal int SymetriseCoup( int orient, int move) ;
/* Symetrise un coup en fonction d'une orientation                       */
/* Celle-ci indique la symetrie a effectuer pour retomber sur nos pattes */
/* 0 =  b1 -> b1 (Pas de symetrie)                                       */      
/* 1 =  g1 -> b1 (symetrie axe vertical)                                 */
/* 2 =  g8 -> b1 (symetrie centrale)                                     */
/* 3 =  b8 -> b1 (symetrie axe horizontal)                               */
/* 4 =  a2 -> b1 (symetrie diagonale 1)                                  */
/* 5 =  a7 -> b1 (symetrie axe horizontal + diagonale 1)                 */
/* 6 =  h7 -> b1 (symetrie diagonale 2)                                  */
/* 7 =  h2 -> b1 (symetrie axe horizontal + diagonale 2)                 */


pascal int Afficher_ZebraBook();
/* Affiche une console texte et permet de naviguer un peu dans une partie */
/* tout en affichant les infos de la bibliotheque de Zebra.               */
/* Renvoie toujours 0, surtout utile pour le debugage                     */


pascal int NumberOfPositionsInZebraBook();
/* Renvoie le nombre de positions dans le fichier Zebra-book.data         */


pascal int Lecture_ZebraBook_Interrompue_Par_Evenement();
/* Renvoie 1 si on a recu un evenement (souris, clavier, etc), 0 sinon    */


















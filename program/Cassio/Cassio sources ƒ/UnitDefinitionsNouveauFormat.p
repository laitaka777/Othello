UNIT UnitDefinitionsNouveauFormat;



INTERFACE







USES MacTypes,UnitPackedOthelloPosition,UnitFichiersTEXT;


const kFicPartiesNouveauFormat=1;
      kFicJoueursNouveauFormat=2;
      kFicTournoisNouveauFormat=3;
      kFicJoueursCourtsNouveauFormat=4;
      kFicTournoisCourtsNouveauFormat=5;
      kFicIndexJoueursNouveauFormat=6;
      kFicIndexTournoisNouveauFormat=7;
      kFicIndexJoueursCourtsNouveauFormat=8;
      kFicIndexTournoisCourtsNouveauFormat=9;
      kFicIndexPartiesNouveauFormat=10;
      kFicSolitairesNouveauFormat=11;
      kUnknownDataNouveauFormat=1000;
      
      
      nbMaxDistributions = 50;  {attention, doit etre <= 255, ou sinon changer le type de tableDistributionDeLaPartie}
      nbMaxFichiersNouveauFormat = 400;



type  t_EnTeteNouveauFormat =
        packed record
                 siecleCreation : byte;
                 anneeCreation : byte;
                 MoisCreation : byte;
                 JourCreation : byte;
                 NombreEnregistrementsParties : SInt32;             {4 octets,sans signe}
                 NombreEnregistrementsTournoisEtJoueurs : SInt16;   {2 octets,sans signe}
                 AnneeParties : SInt16;                             {2 octets,sans signe}
                 case SInt16 of 
                   0 : (
                     TailleDuPlateau           : byte; {parametre P1}
		                 EstUnFichierSolitaire     : byte; {parametre P2}
		                 ProfondeurCalculTheorique : byte; {parametre P3}
		                 reservedByte              : byte; {reserved}
		                 )
		               1 :
		                 (
		                 PlaceMemoireIndex     : SInt32;  {4 octets}
		                 )
               end;
               
     t_JoueurRecNouveauFormat  = 
        packed array[1..20] of byte;
        
     t_TournoiRecNouveauFormat = 
        packed array[1..26] of byte;
        
     t_PartieRecNouveauFormat  =
        packed record
	        nroTournoi : SInt16; 
	        nroJoueurNoir : SInt16; 
	        nroJoueurBlanc : SInt16; 
	        scoreReel : byte;
	        scoreTheorique : byte;
	        listeCoups : packed array [1..60] of UInt8;
	      end;
	  
	  t_SolitaireRecNouveauFormat =
	      packed record
	        annee : SInt16;                   { 2 octets }
	        nroTournoi : SInt16;              { 2 octets }
	        nroJoueurNoir : SInt32;           { 4 octets }
	        nroJoueurBlanc : SInt32;          { 4 octets }
	        position:packedOthelloPosition;  { 16 octets }
	        nbVides : byte;                    { 1 octet }
	        traitSolitaire : byte;             { 1 octet, codage : 1 = Noir, 2 = Blanc }
	        scoreParfait : byte;               { score de la solution }
	        solution : byte;                   { premier coup de la solution }
	        scoreReel : byte;                  { score rŽel de la partie, si disponible (0 sinon) }
	        coup25 : byte;                     { coup 25 de la partie dans la base, si disponible (0 sinon) }
	        reserved1 : byte;
	        reserved2 : byte;
	      end;

   indexArray    = packed array[-10..-10] of byte;
   indexArrayPtr = ^indexArray;
     	      
	      

    DistributionRec = 
         record
	         name                            : stringPtr;
	         path                            : stringPtr;
	         nomUsuel                        : stringPtr;
	         typeDonneesDansDistribution     : SInt16; 
	         decalageNrosJoueurs             : SInt32;
	         decalageNrosTournois            : SInt32;
	       end;
	       
	  DistributionSet = set of 0..nbMaxDistributions;
	       
    FichierNouveauFormatRec =  
         record
           open : boolean;
           nomFichier : stringPtr;
           pathFichier : stringPtr;
           refNum : SInt16; 
           parID : SInt16; 
           vRefNum : SInt16; 
           entete : t_EnTeteNouveauFormat;
           typeDonnees : SInt16; 
           nroDistribution : SInt16;   { pour les fichiers de parties ou de solitaires ou un index}
           annee : SInt16;             { pour les fichiers de parties ou de solitaires ou un index}
           NroFichierDual : SInt16;    {index associŽ si c'est un fichier de parties, et reciproquement}
           theFichierTEXT : FichierTEXT;
         end;
     
     
     

     
     PartieNouveauFormatRecPtr = ^t_PartieRecNouveauFormat;
     tablePartiesNouveauFormat = array[0..0] of t_PartieRecNouveauFormat;
     tablePartiesNouveauFormatPtr = ^tablePartiesNouveauFormat;
     
     JoueursNouveauFormatRecPtr = ^JoueursNouveauFormatRec;
     JoueursNouveauFormatRec = record
                                 nom:str30;
                                 nomCourt:str30;
                                 nomEnMajusculesSansEspace:str30;
                                 numeroDansOrdreAlphabetique : SInt32;
                                 numeroDansFichierJoueurs : SInt32;
                                 nomJaponais : stringHandle;
                                 anneePremierePartie : SInt16; 
                                 anneeDernierePartie : SInt16; 
                                 classementData : SInt32;
                               end;
     tableJoueursNouveauFormat = array[0..0] of JoueursNouveauFormatRec;
     tableJoueursNouveauFormatPtr = ^tableJoueursNouveauFormat;
     
     TournoisNouveauFormatRecPtr = ^TournoisNouveauFormatRec;
     TournoisNouveauFormatRec = record
                                  nom:str30;
                                  nomCourt:str30;
                                  numeroDansOrdreAlphabetique : SInt32;
                                  numeroDansFichierTournois : SInt32;
                                  nomJaponais : stringHandle;
                                end;
     tableTournoisNouveauFormat = array[0..0] of TournoisNouveauFormatRec;
     tableTournoisNouveauFormatPtr = ^tableTournoisNouveauFormat;
 
var 
   DistributionsNouveauFormat : 
        record
          nbDistributions : SInt16; 
          Distribution : array[1..nbMaxDistributions] of DistributionRec;
        end;
   InfosFichiersNouveauFormat :
        record
          nbFichiers : SInt16; 
          fichiers : array[1..nbMaxFichiersNouveauFormat] of FichierNouveauFormatRec;
        end;
   IndexNouveauFormat :
        record
          tailleIndex : SInt32;
          indexNoir:indexArrayPtr;
          indexBlanc:indexArrayPtr;
          indexOuverture:indexArrayPtr;
          indexTournoi:indexArrayPtr;
        end;
   PartiesNouveauFormat :
          record
            nbPartiesEnMemoire : SInt32;
            listeParties:tablePartiesNouveauFormatPtr;
          end;
   JoueursNouveauFormat :
	      record
	        nbJoueursNouveauFormat : SInt32;
	        plusLongNomDeJoueur : SInt32;
	        nombreJoueursDansBaseOfficielle : SInt32;
	        listeJoueurs:tableJoueursNouveauFormatPtr;
	        dejaTriesAlphabetiquement : boolean;
	      end;
   TournoisNouveauFormat :
	      record
	        nbTournoisNouveauFormat : SInt32;
	        nombreTournoisDansBaseOfficielle : SInt32;
	        listeTournois:tableTournoisNouveauFormatPtr;
	        dejaTriesAlphabetiquement : boolean;
	      end;

   ChoixDistributions:
        record
          genre : SInt16; 
          distributionsALire : DistributionSet;
          nbTotalPartiesDansDistributionsALire : SInt32;
        end;
    
   nroDistributionWThor : SInt32;  
    
 const TailleEnTeteNouveauFormat=sizeof(t_EnTeteNouveauFormat);             {16 octets}
       TaillePartieRecNouveauFormat=sizeof(t_PartieRecNouveauFormat);       {68 octets}
       TailleJoueurRecNouveauFormat=sizeof(t_JoueurRecNouveauFormat);       {20 octets}
       TailleTournoiRecNouveauFormat=sizeof(t_TournoiRecNouveauFormat);     {26 octets}
       TailleSolitaireRecNouveauFormat=sizeof(t_SolitaireRecNouveauFormat); {36 octets}

       kToutesLesDistributions = -1;
       kAucuneDistribution = -2;
       kQuelquesDistributions = -3;
       
       
       {quelques numeros de tournois et de joueursÉ}
       kNroTournoiDiversesParties      = 0;
       kNroTournoiPartiesInternet_1_6  = 57;
       kNroTournoiPartiesInternet_7_12 = 58;
       kNroTournoiPartiesInternet      = 90;
       kNroJoueurInconnu               = 0;
       kNroJoueurKitty                 = 10;
       kNroJoueurLogistello            = 16;
       kNroJoueurCassio                = 147;
       
       
IMPLEMENTATION







END.
UNIT UnitAccesStructuresNouvFormat;



INTERFACE



USES UnitOth0,UnitDefinitionsNouveauFormat,UnitDefinitionsPackedThorGame;


CONST kChercherSeulementDansBaseOfficielle = 1;
      kChercherDansTousLesFichiersDeJoueurs = 2;


procedure MetPartieDansTableStockageParties(nroReference : SInt32; var partieStr : PackedThorGame);
procedure ExtraitPartieTableStockageParties(nroReference : SInt32; var partieStr : PackedThorGame);  
procedure ExtraitCoupTableStockagePartie(nroReference, nroCoup : SInt32; var coup : byte);
function GetPartieTableStockageParties(nroReference : SInt32) : PackedThorGame;
function GetNroJoueurNoirParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNroJoueurBlancParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNroTournoiParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNomJoueurNoirParNroRefPartie(nroReference : SInt32):str19;
function GetNomJoueurBlancParNroRefPartie(nroReference : SInt32):str19;
function GetNomJoueurNoirSansPrenomParNroRefPartie(nroReference : SInt32):str30;
function GetNomJoueurBlancSansPrenomParNroRefPartie(nroReference : SInt32):str30;
function GetNomJoueurNoirCommeDansPappParNroRefPartie(nroReference : SInt32):str30;
function GetNomJoueurBlancCommeDansPappParNroRefPartie(nroReference : SInt32):str30;
function GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNomTournoiParNroRefPartie(nroReference : SInt32):str29;
function GetNomCourtTournoiParNroRefPartie(nroReference : SInt32):str29;
function GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNumeroJoueurNoirDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNumeroJoueurBlancDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
function GetNumeroTournoiDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
function GetAnneePartieParNroRefPartie(nroReference : SInt32) : SInt16; 
function GetNomTournoiAvecAnneeParNroRefPartie(nroReference : SInt32;longueurTotaleVoulue : SInt16) : str255;
function GetNomCourtTournoiAvecAnneeParNroRefPartie(nroReference : SInt32;longueurTotaleVoulue : SInt16) : str255;
function GetScoreReelParNroRefPartie(nroReference : SInt32) : SInt16; 
function GetScoreTheoriqueParNroRefPartie(nroReference : SInt32) : SInt16; 
procedure GetScoresTheoriqueEtReelParNroRefPartie(nroReference : SInt32; var theorique,reel : SInt16);
function GetGainTheoriqueParNroRefPartie(nroReference : SInt32):str7;
procedure GetGainsTheoriqueEtReelParNroRefPartie(nroReference : SInt32; var gainNoirTheorique,gainNoirReel : SInt32);
function GetPartieRecordParNroRefPartie(nroReference : SInt32):t_PartieRecNouveauFormat;
function GetNroDistributionParNroRefPartie(nroReference : SInt32) : unsignedByte;
function GetNomDistributionParNroRefPartie(nroReference : SInt32) : str255;
procedure SetNroJoueurNoirParNroRefPartie(nroReference : SInt32;nroJoueur : SInt32);
procedure SetNroJoueurBlancParNroRefPartie(nroReference : SInt32;nroJoueur : SInt32);
procedure SetNroTournoiParNroRefPartie(nroReference : SInt32;nroTournoi : SInt32);
procedure SetAnneePartieParNroRefPartie(nroReference : SInt32;annee : SInt16);
procedure SetScoreReelParNroRefPartie(nroReference : SInt32;scoreReel : SInt16);
procedure SetScoreTheoriqueParNroRefPartie(nroReference : SInt32;scoreTheorique : SInt16);
procedure SetPartieRecordParNroRefPartie(nroReference : SInt32; var GameRecord:t_PartieRecNouveauFormat);
procedure SetNroDistributionParNroRefPartie(nroReference : SInt32;nroDistribution : unsignedByte);


function GetNomJoueur(nroJoueur : SInt32):str30;
function GetNomJoueurEnMajusculesSansEspace(nroJoueur : SInt32):str30;
function GetNomJoueurSansPrenom(nroJoueur : SInt32):str30;
function GetNomDeFamilleSansDifferencierLesPrenoms(nroJoueur : SInt32):str30;
function GetNomJoueurCommeDansPapp(nroJoueur : SInt32):str30;
function GetNroOrdreAlphabetiqueJoueur(nroJoueur : SInt32) : SInt32;
function GetNroJoueurDansSonFichier(nroJoueur : SInt32) : SInt32;
function GetAnneePremierePartieDeCeJoueur(nroJoueur : SInt32) : SInt32;
function GetAnneeDernierePartieDeCeJoueur(nroJoueur : SInt32) : SInt32;
function GetNbreAnneesActiviteDeCeJoueur(nroJoueur : SInt32) : SInt32;
function GetDonneesClassementDeCeJoueur(nroJoueur : SInt32) : SInt32;


procedure SetNomJoueur(nroJoueur : SInt32;joueur:str30);
procedure SetNomCourtJoueur(nroJoueur : SInt32;joueur:str30);
procedure SetNroOrdreAlphabetiqueJoueur(nroJoueur : SInt32;nroDansOrdreAlphabetique : SInt32);
procedure SetNroDansFichierJoueur(nroJoueur : SInt32;nroDansSonFichier : SInt32);
procedure SetAnneePremierePartieDeCeJoueur(nroJoueur : SInt32;annee : SInt32);
procedure SetAnneeDernierePartieDeCeJoueur(nroJoueur : SInt32;annee : SInt32);
procedure SetDonneesClassementDeCeJoueur(nroJoueur : SInt32;data : SInt32);


function GetNomTournoi(nroTournoi : SInt32):str30;
function GetNomCourtTournoi(nroTournoi : SInt32):str30;
function GetNroOrdreAlphabetiqueTournoi(nroTournoi : SInt32) : SInt32;
function GetNroTournoiDansSonFichier(nroTournoi : SInt32) : SInt32;
procedure SetNomTournoi(nroTournoi : SInt32;tournoi:str30);
procedure SetNomCourtTournoi(nroTournoi : SInt32;tournoi:str30);
procedure SetNroOrdreAlphabetiqueTournoi(nroTournoi : SInt32;nroDansOrdreAlphabetique : SInt32);
procedure SetNroDansFichierTournoi(nroTournoi : SInt32;nroDansSonFichier : SInt32);


function JoueurAUnNomJaponais(nroJoueur : SInt32) : boolean;
function TournoiAUnNomJaponais(nroTournoi : SInt32) : boolean;
function EstUnePartieAvecTournoiJaponais(nroReferencePartie : SInt32) : boolean;
function EstUnePartieAvecJoueurNoirJaponais(nroReferencePartie : SInt32) : boolean;
function EstUnePartieAvecJoueurBlancJaponais(nroReferencePartie : SInt32) : boolean;


function GetNomJaponaisDuJoueur(nroJoueur : SInt32) : str255;
function GetNomJaponaisDuJoueurNoirParNroRefPartie(nroReference : SInt32) : str255;
function GetNomJaponaisDuJoueurBlancParNroRefPartie(nroReference : SInt32) : str255;
function GetNomJaponaisDuTournoi(nroTournoi : SInt32) : str255;
function GetNomJaponaisDuTournoiParNroRefPartie(nroReference : SInt32) : str255;
function GetNomJaponaisDuTournoiAvecAnneeParNroRefPartie(nroReference : SInt32;longueurTotaleVoulue : SInt16) : str255;
procedure SetNomJaponaisDuJoueur(nroJoueur : SInt32; const nomJaponais : str255);
procedure SetNomJaponaisDuTournoi(nroTournoi : SInt32; const nomJaponais : str255);


function TrouveNumeroDuJoueur(const nomJoueur : str255; var numeroJoueur : SInt32;fromIndex,genreRecherche : SInt32) : boolean;
function TrouveNumeroDuJoueurDansBaseThor(const nomJoueur : str255; var numeroJoueur : SInt32) : boolean;
function TrouveNumeroDuTournoi(const nomTournoi : str255; var numeroTournoi : SInt32;fromIndex : SInt32) : boolean;


function LongueurPlusLongNomDeJoueurDansBase() : SInt32;
function NombreJoueursDansBaseOfficielle() : SInt32;
procedure SetNombreJoueursDansBaseOfficielle(combien : SInt32);
function NombreTournoisDansBaseOfficielle() : SInt32;
procedure SetNombreTournoisDansBaseOfficielle(combien : SInt32);


function GetNomUsuelDistribution(nroDistribution : SInt32) : str255;
function GetNameOfDistribution(nroDistribution : SInt32) : str255;
function GetPathOfDistribution(nroDistribution : SInt32) : str255;


IMPLEMENTATION



USES UnitSortedSet,UnitUtilitaires,MyStrings,UnitRapport,SNStrings,UnitPackedThorGame; 


procedure MetPartieDansTableStockageParties(nroReference : SInt32; var partieStr : PackedThorGame);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  MoveMemory(GET_ADRESS_OF_FIRST_MOVE(partieStr),@partieArrow^.listeCoups[1],60);
end;

procedure ExtraitPartieTableStockageParties(nroReference : SInt32; var partieStr : PackedThorGame);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  MoveMemory(@partieArrow^.listeCoups[1],GET_ADRESS_OF_FIRST_MOVE(partieStr),60);
  SET_LENGTH_OF_PACKED_GAME(partieStr, 60);
end;

function GetPartieTableStockageParties(nroReference : SInt32) : PackedThorGame;
var s : PackedThorGame;
begin
  ExtraitPartieTableStockageParties(nroReference, s);
  GetPartieTableStockageParties := s;
end;

procedure ExtraitCoupTableStockagePartie(nroReference, nroCoup : SInt32; var coup : byte);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  coup := partieArrow^.listeCoups[nroCoup];
end;

function GetNroJoueurNoirParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNroJoueurNoirParNroRefPartie := partieArrow^.nroJoueurNoir;
end;

function GetNroJoueurBlancParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNroJoueurBlancParNroRefPartie := partieArrow^.nroJoueurBlanc;
end;

procedure SetNroJoueurNoirParNroRefPartie(nroReference : SInt32;nroJoueur : SInt32);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  partieArrow^.nroJoueurNoir := nroJoueur;
end;

procedure SetNroJoueurBlancParNroRefPartie(nroReference : SInt32;nroJoueur : SInt32);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  partieArrow^.nroJoueurBlanc := nroJoueur;
end;

function GetNomJoueurNoirParNroRefPartie(nroReference : SInt32):str19;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurNoirParNroRefPartie := GetNomJoueur(partieArrow^.nroJoueurNoir);
end;

function GetNomJoueurBlancParNroRefPartie(nroReference : SInt32):str19;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurBlancParNroRefPartie := GetNomJoueur(partieArrow^.nroJoueurBlanc);
end;

function GetNomJoueurNoirSansPrenomParNroRefPartie(nroReference : SInt32):str30;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurNoirSansPrenomParNroRefPartie := GetNomJoueurSansPrenom(partieArrow^.nroJoueurNoir);
end;

function GetNomJoueurBlancSansPrenomParNroRefPartie(nroReference : SInt32):str30;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurBlancSansPrenomParNroRefPartie := GetNomJoueurSansPrenom(partieArrow^.nroJoueurBlanc);
end;

function GetNomJoueurNoirCommeDansPappParNroRefPartie(nroReference : SInt32):str30;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurNoirCommeDansPappParNroRefPartie := GetNomJoueurCommeDansPapp(partieArrow^.nroJoueurNoir);
end;

function GetNomJoueurBlancCommeDansPappParNroRefPartie(nroReference : SInt32):str30;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNomJoueurBlancCommeDansPappParNroRefPartie := GetNomJoueurCommeDansPapp(partieArrow^.nroJoueurBlanc);
end;

function GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNumeroOrdreAlphabetiqueJoueurNoirParNroRefPartie := GetNroOrdreAlphabetiqueJoueur(partieArrow^.nroJoueurNoir);
end;

function GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNumeroOrdreAlphabetiqueJoueurBlancParNroRefPartie := GetNroOrdreAlphabetiqueJoueur(partieArrow^.nroJoueurBlanc);
end;

function GetNroTournoiParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNroTournoiParNroRefPartie := partieArrow^.nroTournoi;
end;

function GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNumeroOrdreAlphabetiqueTournoiParNroRefPartie := GetNroOrdreAlphabetiqueTournoi(partieArrow^.nroTournoi);
end;

function GetNumeroJoueurNoirDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNumeroJoueurNoirDansFichierParNroRefPartie := GetNroJoueurDansSonFichier(partieArrow^.nroJoueurNoir);
end;


function GetNumeroJoueurBlancDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNumeroJoueurBlancDansFichierParNroRefPartie := GetNroJoueurDansSonFichier(partieArrow^.nroJoueurBlanc);
end;


function GetNumeroTournoiDansFichierParNroRefPartie(nroReference : SInt32) : SInt32;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNumeroTournoiDansFichierParNroRefPartie := GetNroTournoiDansSonFichier(partieArrow^.nroTournoi);
end;


procedure SetNroTournoiParNroRefPartie(nroReference : SInt32;nroTournoi : SInt32);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  partieArrow^.nroTournoi := nroTournoi;
end;

function GetNomTournoiParNroRefPartie(nroReference : SInt32):str29;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNomTournoiParNroRefPartie := GetNomTournoi(partieArrow^.nroTournoi);
end;

function GetNomCourtTournoiParNroRefPartie(nroReference : SInt32):str29;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNomCourtTournoiParNroRefPartie := GetNomCourtTournoi(partieArrow^.nroTournoi);
end;

procedure SetAnneePartieParNroRefPartie(nroReference : SInt32;annee : SInt16);
begin
  tableAnneeParties^^[nroReference] := annee;
end;

function GetAnneePartieParNroRefPartie(nroReference : SInt32) : SInt16; 
begin
  GetAnneePartieParNroRefPartie := tableAnneeParties^^[nroReference];
end;

function GetNomTournoiAvecAnneeParNroRefPartie(nroReference : SInt32;longueurTotaleVoulue : SInt16) : str255;
var s : str255;
    i : SInt16; 
begin
  {if (GetNroDistributionParNroRefPartie(nroReference) <> nroDistributionWThor) &
     (GetNroTournoiParNroRefPartie(nroReference) = kNroTournoiDiversesParties) 
     then s := GetNomDistributionParNroRefPartie(nroReference)
     else s := GetNomTournoiParNroRefPartie(nroReference);}
  s := GetNomTournoiParNroRefPartie(nroReference);
  for i := 1 to longueurTotaleVoulue-Length(s)-4 do s := s+' ';
  GetNomTournoiAvecAnneeParNroRefPartie := s+NumEnString(GetAnneePartieParNroRefPartie(nroReference));
end;

function GetNomCourtTournoiAvecAnneeParNroRefPartie(nroReference : SInt32;longueurTotaleVoulue : SInt16) : str255;
var s : str255;
begin  {$UNUSED longueurTotaleVoulue}
  s := GetNomCourtTournoiParNroRefPartie(nroReference);
  GetNomCourtTournoiAvecAnneeParNroRefPartie := s + '  '+ NumEnString(GetAnneePartieParNroRefPartie(nroReference));
end;

procedure SetScoreReelParNroRefPartie(nroReference : SInt32;scoreReel : SInt16);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  partieArrow^.scoreReel := scoreReel;
end;

function GetScoreReelParNroRefPartie(nroReference : SInt32) : SInt16; 
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetScoreReelParNroRefPartie := partieArrow^.scoreReel;
end;

procedure SetScoreTheoriqueParNroRefPartie(nroReference : SInt32;scoreTheorique : SInt16);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  partieArrow^.scoreTheorique := scoreTheorique;
end;

procedure SetPartieRecordParNroRefPartie(nroReference : SInt32; var GameRecord:t_PartieRecNouveauFormat);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  partieArrow^ := GameRecord;
end;

procedure SetNroDistributionParNroRefPartie(nroReference : SInt32;nroDistribution : unsignedByte);
begin
  tableDistributionDeLaPartie^[nroReference] := nroDistribution;
end;

function GetScoreTheoriqueParNroRefPartie(nroReference : SInt32) : SInt16; 
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetScoreTheoriqueParNroRefPartie := partieArrow^.scoreTheorique;
end;

procedure GetScoresTheoriqueEtReelParNroRefPartie(nroReference : SInt32; var theorique,reel : SInt16);
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  theorique := partieArrow^.scoreTheorique;
  reel      := partieArrow^.scoreReel;
end;


function GetGainTheoriqueParNroRefPartie(nroReference : SInt32):str7;
var scoreTheorique : SInt16; 
    partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  scoreTheorique := partieArrow^.scoreTheorique;
  if scoreTheorique>32 then GetGainTheoriqueParNroRefPartie := CaracterePourNoir else
  if scoreTheorique<32 then GetGainTheoriqueParNroRefPartie := CaracterePourBlanc else
  {if scoreTheorique=32 then} GetGainTheoriqueParNroRefPartie := CaracterePourEgalite;
end;

procedure GetGainsTheoriqueEtReelParNroRefPartie(nroReference : SInt32; var gainNoirTheorique,gainNoirReel : SInt32);
var scoreTheorique,scoreReel : SInt16; 
    partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  scoreTheorique := partieArrow^.scoreTheorique;
  scoreReel := partieArrow^.scoreReel;
  if scoreTheorique>32 then   gainNoirTheorique := 2 else
  if scoreTheorique<32 then   gainNoirTheorique := 0 else
  {if scoreTheorique=32 then} gainNoirTheorique := 1;
  if scoreReel>32 then   gainNoirReel := 2 else
  if scoreReel<32 then   gainNoirReel := 0 else
  {if scoreReel=32 then} gainNoirReel := 1;
end;


function GetPartieRecordParNroRefPartie(nroReference : SInt32):t_PartieRecNouveauFormat;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetPartieRecordParNroRefPartie := partieArrow^;
end;


function GetNroDistributionParNroRefPartie(nroReference : SInt32) : unsignedByte;
begin
  GetNroDistributionParNroRefPartie := tableDistributionDeLaPartie^[nroReference];
end;


function GetNomDistributionParNroRefPartie(nroReference : SInt32) : str255;
begin
  GetNomDistributionParNroRefPartie := GetNomUsuelDistribution(tableDistributionDeLaPartie^[nroReference]);
end;


function GetNomJoueur(nroJoueur : SInt32):str30;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) & 
     (nroJoueur < nbJoueursNouveauFormat) & 
     (listeJoueurs <> NIL) 
       then
         begin
           JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
           GetNomJoueur := JoueurArrow^.nom;
         end
       else
         GetNomJoueur := '******';
end;


function GetNomJoueurEnMajusculesSansEspace(nroJoueur : SInt32):str30;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) & 
     (nroJoueur < nbJoueursNouveauFormat) & 
     (listeJoueurs <> NIL) 
       then
         begin
           JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
           GetNomJoueurEnMajusculesSansEspace := JoueurArrow^.nomEnMajusculesSansEspace;
         end
       else
         GetNomJoueurEnMajusculesSansEspace := '******';
end;


function GetNomTournoi(nroTournoi : SInt32):str30;
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) & 
      (nroTournoi >= 0) & 
      (nroTournoi < nbTournoisNouveauFormat) &
      (listeTournois <> NIL) 
        then
          begin
            TournoiArrow := MakeMemoryPointer(ord4(listeTournois)+nroTournoi*sizeof(TournoisNouveauFormatRec));
            GetNomTournoi := TournoiArrow^.nom;
          end
        else
          GetNomTournoi := '******';
end;

function GetNomCourtTournoi(nroTournoi : SInt32):str30;
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat > 0) & 
      (nroTournoi >= 0) & 
      (nroTournoi < nbTournoisNouveauFormat) &
      (listeTournois <> NIL) 
        then
          begin
            TournoiArrow := MakeMemoryPointer(ord4(listeTournois)+nroTournoi*sizeof(TournoisNouveauFormatRec));
            
            if (TournoiArrow^.nomCourt <> '')
              then GetNomCourtTournoi := TournoiArrow^.nomCourt
              else
                begin
                  TournoiArrow^.nomCourt := NomCourtDuTournoi(TournoiArrow^.nom);
                  GetNomCourtTournoi := TournoiArrow^.nomCourt;
                end;
          end
        else
          GetNomCourtTournoi := '******';
end;


function GetNomUsuelDistribution(nroDistribution : SInt32) : str255;
begin
  with DistributionsNouveauFormat do
  if (nroDistribution >= 1) & (nroDistribution <= nbDistributions)
    then GetNomUsuelDistribution := distribution[nroDistribution].nomUsuel^
    else GetNomUsuelDistribution := '******';
end;

function GetNameOfDistribution(nroDistribution : SInt32) : str255;
begin
  with DistributionsNouveauFormat do
  if (nroDistribution >= 1) & (nroDistribution <= nbDistributions)
    then GetNameOfDistribution := distribution[nroDistribution].name^
    else GetNameOfDistribution := '******';
end;

function GetPathOfDistribution(nroDistribution : SInt32) : str255;
begin
  with DistributionsNouveauFormat do
  if (nroDistribution >= 1) & (nroDistribution <= nbDistributions)
    then GetPathOfDistribution := distribution[nroDistribution].path^
    else GetPathOfDistribution := '******';
end;

procedure SetNomJoueur(nroJoueur : SInt32;joueur:str30);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.nom                       := joueur;
         JoueurArrow^.nomEnMajusculesSansEspace := FabriqueNomEnMajusculesSansEspaceDunNomWThor(joueur);
         
         if Length(joueur) > plusLongNomDeJoueur then plusLongNomDeJoueur := Length(joueur);
       end;
end;

procedure SetNomCourtJoueur(nroJoueur : SInt32;joueur:str30);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.nomCourt := joueur;
       end;
end;


procedure SetNomTournoi(nroTournoi : SInt32;tournoi:str30);
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat>0) & 
     (nroTournoi>=0) & 
     (nroTournoi<nbTournoisNouveauFormat) &
     (listeTournois <> NIL) then
       begin
         TournoiArrow := MakeMemoryPointer(ord4(listeTournois)+nroTournoi*sizeof(TournoisNouveauFormatRec));
         TournoiArrow^.nom := tournoi;
       end;
end;

procedure SetNomCourtTournoi(nroTournoi : SInt32;tournoi:str30);
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat>0) & 
     (nroTournoi>=0) & 
     (nroTournoi<nbTournoisNouveauFormat) &
     (listeTournois <> NIL) then
       begin
         TournoiArrow := MakeMemoryPointer(ord4(listeTournois)+nroTournoi*sizeof(TournoisNouveauFormatRec));
         TournoiArrow^.nomCourt := tournoi;
       end;
end;


function GetNroOrdreAlphabetiqueJoueur(nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetNroOrdreAlphabetiqueJoueur := -1;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetNroOrdreAlphabetiqueJoueur := JoueurArrow^.numeroDansOrdreAlphabetique;
       end;
end;

function GetNroJoueurDansSonFichier(nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetNroJoueurDansSonFichier := -1;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetNroJoueurDansSonFichier := JoueurArrow^.numeroDansFichierJoueurs;
       end;
end;

function GetAnneePremierePartieDeCeJoueur(nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetAnneePremierePartieDeCeJoueur := -1;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetAnneePremierePartieDeCeJoueur := JoueurArrow^.anneePremierePartie;
       end;
end;

function GetAnneeDernierePartieDeCeJoueur(nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetAnneeDernierePartieDeCeJoueur := -1;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetAnneeDernierePartieDeCeJoueur := JoueurArrow^.anneeDernierePartie;
       end;
end;

function GetDonneesClassementDeCeJoueur(nroJoueur : SInt32) : SInt32;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  GetDonneesClassementDeCeJoueur := -1;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         GetDonneesClassementDeCeJoueur := JoueurArrow^.classementData;
       end;
end;


function LongueurPlusLongNomDeJoueurDansBase() : SInt32;
begin
  LongueurPlusLongNomDeJoueurDansBase := JoueursNouveauFormat.plusLongNomDeJoueur;
end;


function NombreJoueursDansBaseOfficielle() : SInt32;
begin
  NombreJoueursDansBaseOfficielle := JoueursNouveauFormat.nombreJoueursDansBaseOfficielle;
end;


procedure SetNombreJoueursDansBaseOfficielle(combien : SInt32);
begin
  JoueursNouveauFormat.nombreJoueursDansBaseOfficielle := combien;
end;


function NombreTournoisDansBaseOfficielle() : SInt32;
begin
  NombreTournoisDansBaseOfficielle := TournoisNouveauFormat.nombreTournoisDansBaseOfficielle;
end;


procedure SetNombreTournoisDansBaseOfficielle(combien : SInt32);
begin
  TournoisNouveauFormat.nombreTournoisDansBaseOfficielle := combien;
end;


function GetNbreAnneesActiviteDeCeJoueur(nroJoueur : SInt32) : SInt32;
begin
  if GetAnneePremierePartieDeCeJoueur(nroJoueur) > 0
    then GetNbreAnneesActiviteDeCeJoueur := GetAnneeDernierePartieDeCeJoueur(nroJoueur) - GetAnneePremierePartieDeCeJoueur(nroJoueur) + 1
    else GetNbreAnneesActiviteDeCeJoueur := 0;
end;



function GetNroOrdreAlphabetiqueTournoi(nroTournoi : SInt32) : SInt32;
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  GetNroOrdreAlphabetiqueTournoi := -1;
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat>0) & 
     (nroTournoi>=0) &
     (nroTournoi<nbTournoisNouveauFormat) &
     (listeTournois <> NIL) then
       begin
         TournoiArrow := MakeMemoryPointer(ord4(listeTournois)+nroTournoi*sizeof(TournoisNouveauFormatRec));
         GetNroOrdreAlphabetiqueTournoi := TournoiArrow^.numeroDansOrdreAlphabetique;
       end;
end;

function GetNroTournoiDansSonFichier(nroTournoi : SInt32) : SInt32;
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  GetNroTournoiDansSonFichier := -1;
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat>0) & 
     (nroTournoi>=0) &
     (nroTournoi<nbTournoisNouveauFormat) &
     (listeTournois <> NIL) then
       begin
         TournoiArrow := MakeMemoryPointer(ord4(listeTournois)+nroTournoi*sizeof(TournoisNouveauFormatRec));
         GetNroTournoiDansSonFichier := TournoiArrow^.numeroDansFichierTournois;
       end;
end;


procedure SetNroOrdreAlphabetiqueJoueur(nroJoueur : SInt32;nroDansOrdreAlphabetique : SInt32);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.numeroDansOrdreAlphabetique := nroDansOrdreAlphabetique;
       end;
end;

procedure SetNroOrdreAlphabetiqueTournoi(nroTournoi : SInt32;nroDansOrdreAlphabetique : SInt32);
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat>0) & 
     (nroTournoi>=0) &
     (nroTournoi<nbTournoisNouveauFormat) &
     (listeTournois <> NIL) then
       begin
         TournoiArrow := MakeMemoryPointer(ord4(listeTournois)+nroTournoi*sizeof(TournoisNouveauFormatRec));
         TournoiArrow^.numeroDansOrdreAlphabetique := nroDansOrdreAlphabetique;
       end;
end;

procedure SetNroDansFichierJoueur(nroJoueur : SInt32;nroDansSonFichier : SInt32);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.numeroDansFichierJoueurs := nroDansSonFichier;
       end;
end;

procedure SetAnneePremierePartieDeCeJoueur(nroJoueur : SInt32;annee : SInt32);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.anneePremierePartie := annee;
       end;
end;

procedure SetAnneeDernierePartieDeCeJoueur(nroJoueur : SInt32;annee : SInt32);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.anneeDernierePartie := annee;
       end;
end;

procedure SetDonneesClassementDeCeJoueur(nroJoueur : SInt32;data : SInt32);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
       begin
         JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
         JoueurArrow^.classementData := data;
       end;
end;

procedure SetNroDansFichierTournoi(nroTournoi : SInt32;nroDansSonFichier : SInt32);
var TournoiArrow : TournoisNouveauFormatRecPtr;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat>0) & 
     (nroTournoi>=0) &
     (nroTournoi<nbTournoisNouveauFormat) &
     (listeTournois <> NIL) then
       begin
         TournoiArrow := MakeMemoryPointer(ord4(listeTournois)+nroTournoi*sizeof(TournoisNouveauFormatRec));
         TournoiArrow^.numeroDansFichierTournois := nroDansSonFichier;
       end;
end;


function JoueurAUnNomJaponais(nroJoueur : SInt32) : boolean;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  JoueurAUnNomJaponais := false;
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) 
    then 
      begin
        JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
        JoueurAUnNomJaponais := JoueurArrow^.nomJaponais <> NIL;
      end;
end;

function TournoiAUnNomJaponais(nroTournoi : SInt32) : boolean;
begin
  TournoiAUnNomJaponais := false;
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat>0) & 
     (nroTournoi>=0) &
     (nroTournoi<nbTournoisNouveauFormat) &
     (listeTournois <> NIL) 
    then TournoiAUnNomJaponais := listeTournois^[nroTournoi].nomJaponais <> NIL;
end;

function EstUnePartieAvecTournoiJaponais(nroReferencePartie : SInt32) : boolean;
begin
  EstUnePartieAvecTournoiJaponais := TournoiAUnNomJaponais(GetNroTournoiParNroRefPartie(nroReferencePartie));
end;

function EstUnePartieAvecJoueurNoirJaponais(nroReferencePartie : SInt32) : boolean;
var aux : SInt32;
begin
  aux := GetNroJoueurNoirParNroRefPartie(nroReferencePartie);
  EstUnePartieAvecJoueurNoirJaponais := JoueurAUnNomJaponais(aux);
end;

function EstUnePartieAvecJoueurBlancJaponais(nroReferencePartie : SInt32) : boolean;
var aux : SInt32;
begin
  aux := GetNroJoueurBlancParNroRefPartie(nroReferencePartie);
  EstUnePartieAvecJoueurBlancJaponais := JoueurAUnNomJaponais(aux);
end;


function TrouveNumeroDuJoueur(const nomJoueur : str255; var numeroJoueur : SInt32;fromIndex,genreRecherche : SInt32) : boolean;
const kParfaite    = 3;
      kMoyenne     = 2;
      kMauvaise    = 1;
      kInexistante = 0;
var i,positionSousChaine : SInt32;
    nomCherche,nomCourant : str255;
    nomChercheEnMajuscules : str255;
    nomCourantEnMajuscules : str255;
    indexMax : SInt32;
    qualiteSolution,nouvelleQualite : SInt32;
begin

  numeroJoueur := -1;
  TrouveNumeroDuJoueur := false;
  qualiteSolution := kInexistante;
  
  if (Length(nomJoueur) > LongueurPlusLongNomDeJoueurDansBase()) 
    then exit(TrouveNumeroDuJoueur);

  nomCherche := FabriqueNomEnMajusculesSansEspaceDunNomWThor(nomJoueur);
  nomChercheEnMajuscules := MyUpperString(nomJoueur,true);
  
  if (genreRecherche = kChercherSeulementDansBaseOfficielle) & 
     (NombreJoueursDansBaseOfficielle() > 0)
     then indexMax := NombreJoueursDansBaseOfficielle()
     else indexMax := JoueursNouveauFormat.nbJoueursNouveauFormat;
     
  for i := fromIndex to indexMax do
    begin
      { Attention avant de changer la ligne suivante !! Certaines fonctions
        (par exemple EssayerInterpreterJoueursPGNCommeNomDeFichier(), mais il
        pourrait y en avoir d'autres) *reposent* sur le fait que TrouveNumeroDuJoueur()
        utilise GetNomJoueurEnMajusculesSansEspace()...
      }
      nomCourant := GetNomJoueurEnMajusculesSansEspace(i);
      
      positionSousChaine := Pos(nomCherche,nomCourant);
      if (positionSousChaine > 0) then
	      begin
	        
          if (positionSousChaine = 1)
            then
              begin
                nomCourantEnMajuscules := MyUpperString(GetNomJoueur(i),true);
                nouvelleQualite := kMauvaise;
                
                {WritelnDansRapport('');
                WritelnDansRapport('nomChercheEnMajuscules = '+nomChercheEnMajuscules);
                WritelnDansRapport('nomCourantEnMajuscules = '+nomCourantEnMajuscules);}
                
                if (Pos(nomChercheEnMajuscules,nomCourantEnMajuscules) = 1) then 
                  if (Length(nomJoueur) = Length(nomCourantEnMajuscules)) |
                     (nomCourantEnMajuscules[Length(nomJoueur)+1] = ' ')
                    then nouvelleQualite := kParfaite
                    else nouvelleQualite := kMoyenne;
                
                if (nouvelleQualite > qualiteSolution) then
                  begin
                    qualiteSolution := nouvelleQualite;
                    numeroJoueur := i;
                  end;
              end
            else
	            if (numeroJoueur = -1) 
	              then numeroJoueur := i;
	          
	        TrouveNumeroDuJoueur := true;
	        
	        if (qualiteSolution = kParfaite) then exit(TrouveNumeroDuJoueur);
	        
	      end;
    end;
end;


function TrouveNumeroDuJoueurDansBaseThor(const nomJoueur : str255; var numeroJoueur : SInt32) : boolean;
var trouve : boolean;
    formeAlternative : str255;
begin
  trouve := TrouveNumeroDuJoueur(nomJoueur,numeroJoueur,0,kChercherSeulementDansBaseOfficielle);
  
  if not(trouve) & (Pos('van den ',nomJoueur) = 1) then
    begin
      formeAlternative := ReplaceStringByStringInString('van den ','v/d ',nomJoueur);
      formeAlternative := LeftOfString(formeAlternative,LongueurPlusLongNomDeJoueurDansBase());
      trouve := TrouveNumeroDuJoueur(formeAlternative,numeroJoueur,0,kChercherSeulementDansBaseOfficielle);
    end;
  
  if not(trouve) & (Pos('Van den ',nomJoueur) = 1) then
    begin
      formeAlternative := ReplaceStringByStringInString('Van den ','v/d ',nomJoueur);
      formeAlternative := LeftOfString(formeAlternative,LongueurPlusLongNomDeJoueurDansBase());
      trouve := TrouveNumeroDuJoueur(formeAlternative,numeroJoueur,0,kChercherSeulementDansBaseOfficielle);
    end;
  
  if not(trouve) & (Pos('Van Den ',nomJoueur) = 1) then
    begin
      formeAlternative := ReplaceStringByStringInString('Van Den ','v/d ',nomJoueur);
      formeAlternative := LeftOfString(formeAlternative,LongueurPlusLongNomDeJoueurDansBase());
      trouve := TrouveNumeroDuJoueur(formeAlternative,numeroJoueur,0,kChercherSeulementDansBaseOfficielle);
    end;
  
  if not(trouve) & (Pos('vd ',nomJoueur) = 1) then
    begin
      formeAlternative := ReplaceStringByStringInString('vd ','v/d ',nomJoueur);
      formeAlternative := LeftOfString(formeAlternative,LongueurPlusLongNomDeJoueurDansBase());
      trouve := TrouveNumeroDuJoueur(formeAlternative,numeroJoueur,0,kChercherSeulementDansBaseOfficielle);
    end;
  
  if not(trouve) & (Pos('vd ',nomJoueur) = 1) then
    begin
      formeAlternative := ReplaceStringByStringInString('vd ','van den ',nomJoueur);
      formeAlternative := LeftOfString(formeAlternative,LongueurPlusLongNomDeJoueurDansBase());
      trouve := TrouveNumeroDuJoueur(formeAlternative,numeroJoueur,0,kChercherSeulementDansBaseOfficielle);
    end;
  
  if not(trouve) & (Pos('v/d ',nomJoueur) = 1) then
    begin
      formeAlternative := ReplaceStringByStringInString('v/d ','van den ',nomJoueur);
      formeAlternative := LeftOfString(formeAlternative,LongueurPlusLongNomDeJoueurDansBase());
      trouve := TrouveNumeroDuJoueur(formeAlternative,numeroJoueur,0,kChercherSeulementDansBaseOfficielle);
    end;
  
  TrouveNumeroDuJoueurDansBaseThor := trouve;
end;


function TrouveNumeroDuTournoi(const nomTournoi : str255; var numeroTournoi : SInt32;fromIndex : SInt32) : boolean;
var i,positionSousChaine : SInt32;
    nomCherche,nomCourant : str255;
begin
  numeroTournoi := -1;
  TrouveNumeroDuTournoi := false;
  
  nomCherche := nomTournoi;
  UpperString(nomCherche,false);
     
  for i := fromIndex to TournoisNouveauFormat.nbTournoisNouveauFormat do
    begin
      nomCourant := GetNomTournoi(i);
      UpperString(nomCourant,false);
      
      positionSousChaine := Pos(nomCherche,nomCourant);
      if (positionSousChaine > 0) then
	      begin
	        if (positionSousChaine = 1) | (numeroTournoi = -1) 
	          then numeroTournoi := i;
	        TrouveNumeroDuTournoi := true;
	        if (positionSousChaine = 1) then exit(TrouveNumeroDuTournoi);
	      end;
    end;
end;


function GetNomJaponaisDuJoueur(nroJoueur : SInt32) : str255;
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) 
       then
		     begin
		       JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
		       if JoueurArrow^.nomJaponais <> NIL
		         then GetNomJaponaisDuJoueur := JoueurArrow^.nomJaponais^^
		         else GetNomJaponaisDuJoueur := '******';
		     end
		   else
		     begin
		       GetNomJaponaisDuJoueur := '******';
		     end;
end;

function GetNomJaponaisDuJoueurNoirParNroRefPartie(nroReference : SInt32) : str255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNomJaponaisDuJoueurNoirParNroRefPartie := GetNomJaponaisDuJoueur(partieArrow^.nroJoueurNoir);
end;

function GetNomJaponaisDuJoueurBlancParNroRefPartie(nroReference : SInt32) : str255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNomJaponaisDuJoueurBlancParNroRefPartie := GetNomJaponaisDuJoueur(partieArrow^.nroJoueurBlanc);
end;


function GetNomJaponaisDuTournoi(nroTournoi : SInt32) : str255;
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat>0) & 
     (nroTournoi>=0) &
     (nroTournoi<nbTournoisNouveauFormat) &
     (listeTournois <> NIL) &
     (listeTournois^[nroTournoi].nomJaponais <> NIL)
    then GetNomJaponaisDuTournoi := listeTournois^[nroTournoi].nomJaponais^^
    else GetNomJaponaisDuTournoi := '******';
end;

function GetNomJaponaisDuTournoiParNroRefPartie(nroReference : SInt32) : str255;
var partieArrow : PartieNouveauFormatRecPtr;
begin
  partieArrow := MakeMemoryPointer(ord4(PartiesNouveauFormat.listeParties)+nroReference*TaillePartieRecNouveauFormat);
  GetNomJaponaisDuTournoiParNroRefPartie := GetNomJaponaisDuTournoi(partieArrow^.nroTournoi);
end;


function GetNomJaponaisDuTournoiAvecAnneeParNroRefPartie(nroReference : SInt32;longueurTotaleVoulue : SInt16) : str255;
var s : str255;
    i : SInt16; 
begin
  s := GetNomJaponaisDuTournoiParNroRefPartie(nroReference);
  for i := 1 to longueurTotaleVoulue-Length(s)-4 do s := s+' ';
  GetNomJaponaisDuTournoiAvecAnneeParNroRefPartie := s+NumEnString(GetAnneePartieParNroRefPartie(nroReference));
end;

procedure SetNomJaponaisDuJoueur(nroJoueur : SInt32; const nomJaponais : str255);
var JoueurArrow : JoueursNouveauFormatRecPtr;
begin
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) then
     begin
       JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
       if (JoueurArrow^.nomJaponais <> NIL) then 
         begin
           DisposeMemoryHdl(Handle(JoueurArrow^.nomJaponais));
           JoueurArrow^.nomJaponais := NIL;
         end;
       if nomJaponais<>'' then
         begin
           JoueurArrow^.nomJaponais := StringHandle(AllocateMemoryHdl(Length(nomJaponais)+4));
           if JoueurArrow^.nomJaponais <> NIL then 
             JoueurArrow^.nomJaponais^^ := nomJaponais;
         end;
     end;
end;


procedure SetNomJaponaisDuTournoi(nroTournoi : SInt32; const nomJaponais : str255);
begin
  with TournoisNouveauFormat do
  if (nbTournoisNouveauFormat>0) & 
     (nroTournoi>=0) &
     (nroTournoi<nbTournoisNouveauFormat) &
     (listeTournois <> NIL) then
     begin
       if (listeTournois^[nroTournoi].nomJaponais <> NIL) then 
         begin
           DisposeMemoryHdl(Handle(listeTournois^[nroTournoi].nomJaponais));
           listeTournois^[nroTournoi].nomJaponais := NIL;
         end;
       if nomJaponais<>'' then
         begin
           listeTournois^[nroTournoi].nomJaponais := StringHandle(AllocateMemoryHdl(Length(nomJaponais)+4));
           if listeTournois^[nroTournoi].nomJaponais <> NIL then 
             listeTournois^[nroTournoi].nomJaponais^^ := nomJaponais;
         end;
     end;
end;


function GetNomJoueurSansPrenom(nroJoueur : SInt32):str30;
const longueurFratrieCherchee = 15;
var nroAlphabetique : SInt32;
    nroMinAvant,nroMaxApres : SInt32;
    nomJoueur,nomSansPrenom : str255;
    nomJoueurTeste,nomTesteSansPrenom : str255;
    result : str255;
    nomSansPrenomEnMajuscule : str255;
    JoueurArrow:JoueursNouveauFormatRecPtr;
    JoueurArrow2:JoueursNouveauFormatRecPtr;
    aux,k : SInt32;
    longueur,longueurMax,longueurInitiale,longueurDiscriminante : SInt32;
begin
  
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) 
    then
			begin
			  JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
        
        {Le nom court a-t-il deja ete calculé ? si c'est 
         le cas, on peut renvoyer directement le resultat}
        
        nomJoueur := JoueurArrow^.nomCourt;
        if (nomJoueur <> '') then
          begin
            GetNomJoueurSansPrenom := nomJoueur;
            exit(GetNomJoueurSansPrenom);
          end;
			
			  {Sinon, il faut le calculer a partir du nom avec prenom}
			  nomJoueur := JoueurArrow^.nom;
			  EnlevePrenom(nomJoueur,nomSansPrenom);
			  
			  nomSansPrenomEnMajuscule := nomSansPrenom;
			  UpperString(nomSansPrenomEnMajuscule, false);
			  
			  if not(differencierLesFreres) | (Pos('TASTET',nomSansPrenomEnMajuscule) > 0) then
			    begin
			      nomSansPrenom := EnleveEspacesDeDroite(nomSansPrenom);
			      JoueurArrow^.nomCourt := nomSansPrenom;
			      GetNomJoueurSansPrenom := nomSansPrenom;
			      exit(GetNomJoueurSansPrenom);
			    end;
			  
			  longueurMax := Length(nomJoueur);
			  longueur := Length(nomSansPrenom);
			  longueurInitiale := longueur;
			  longueurDiscriminante := longueur;
			  
			  {on determine l'intervalle des numeros alphabetiques 
			   qui nous interessent pour les comparaisons}
			  nroAlphabetique := GetNroOrdreAlphabetiqueJoueur(nroJoueur);
			  nroMinAvant := Max(0, nroAlphabetique - longueurFratrieCherchee);
			  nroMaxApres := Min(nbJoueursNouveauFormat - 1, nroAlphabetique + longueurFratrieCherchee);
			  
			  			  
			  JoueurArrow2 := MakeMemoryPointer(ord4(listeJoueurs));
			  for k := 0 to nbJoueursNouveauFormat-1 do
			    begin
			      aux := JoueurArrow2^.numeroDansOrdreAlphabetique;
			      
			      if (nroMinAvant <= aux) & (aux <= nroMaxApres) & (k<>nroJoueur) then
			        begin
			          nomJoueurTeste := JoueurArrow2^.nom;
			          EnlevePrenom(nomJoueurTeste,nomTesteSansPrenom);
			          if (nomSansPrenom = nomTesteSansPrenom) & (nomJoueurTeste <> nomJoueur) then
			            begin
			              longueur := longueurInitiale;
			              while (longueur < longueurMax) & 
			                    (nomJoueur[longueur] = nomJoueurTeste[longueur]) &
			                    (nomJoueur[longueur] <> '(') & 
			                    (nomJoueur[longueur+1] <> '(') do
			                inc(longueur);
			              if longueur > longueurDiscriminante then
			                longueurDiscriminante := longueur;
			              {WritelnDansRapport(nomJoueurTeste);}
			            end;
			        end;
			      			      
			      JoueurArrow2 := MakeMemoryPointer(ord4(JoueurArrow2)+sizeof(JoueursNouveauFormatRec));
			    end;
			  
			  if longueurDiscriminante = longueurInitiale
			    then 
			      begin
			        JoueurArrow^.nomCourt := EnleveEspacesDeDroite(nomSansPrenom);
			        GetNomJoueurSansPrenom := JoueurArrow^.nomCourt;
			      end
			    else 
			      begin
			        result := TPCopy(nomJoueur,1,longueurDiscriminante);
			        {WritelnDansRapport('result = '+result);}
			        
			        EnleveEspacesDeDroiteSurPlace(nomJoueur);
			        {WritelnDansRapport('nomJoueur = '+nomJoueur);}
			        
			        if nomJoueur = result 
			          then 
			            begin
			              {WritelnDansRapport('pas de rajout, on prend le nom complet');}
			              JoueurArrow^.nomCourt := nomJoueur;
			              GetNomJoueurSansPrenom := JoueurArrow^.nomCourt;
			            end
			          else 
			            begin
			              {WritelnDansRapport('rajout d''un point apres l''initiale du prenom');}
			              JoueurArrow^.nomCourt := EnleveEspacesDeDroite(result) + '.';
			              GetNomJoueurSansPrenom := JoueurArrow^.nomCourt;
			            end;
			      end;
			end
	 else
	   GetNomJoueurSansPrenom := '******';
end;



function GetNomDeFamilleSansDifferencierLesPrenoms(nroJoueur : SInt32):str30;
var nomJoueur,nomSansPrenom : str255;
    JoueurArrow:JoueursNouveauFormatRecPtr;
begin
  
  with JoueursNouveauFormat do
  if (nbJoueursNouveauFormat > 0) & 
     (nroJoueur >= 0) &
     (nroJoueur < nbJoueursNouveauFormat) &
     (listeJoueurs <> NIL) 
    then
			begin
			  JoueurArrow := MakeMemoryPointer(ord4(listeJoueurs)+nroJoueur*sizeof(JoueursNouveauFormatRec));
        
			  nomJoueur := JoueurArrow^.nom;
			  EnlevePrenom(nomJoueur,nomSansPrenom);
			  
			  nomSansPrenom := EnleveEspacesDeDroite(nomSansPrenom);
			  GetNomDeFamilleSansDifferencierLesPrenoms := nomSansPrenom;
			end
	 else
	   GetNomDeFamilleSansDifferencierLesPrenoms := '******';
end;



function GetNomJoueurCommeDansPapp(nroJoueur : SInt32):str30;
var s1,s2 : str255;
begin
  s1 := GetNomDeFamilleSansDifferencierLesPrenoms(nroJoueur);
  s2 := GetNomJoueur(nroJoueur);
  StripDiacritics(@s2[1],Length(s2),smSystemScript);
  GetNomJoueurCommeDansPapp := MyUpperString(s1,false) + RightOfString(s2,Length(s2)-Length(s1));
end;


END.




UNIT UnitArbresTernairesRecherche;

{cf http://www.cs.princeton.edu/~rs/strings/}

INTERFACE







USES MacTypes, UnitPagesATR;

type ATRProc=procedure(var x : ATR);

{Creation et destruction}
function MakeEmptyATR() : ATR;
procedure DisposeATR(var theATR : ATR);

{fonction d'insertion dans un ATR}
procedure InsererDansATR(var arbre : ATR; const s : string);

{Affichages}
procedure AfficherATRNodeDansRapport(var x : ATR);
procedure ATRAffichageInfixe(nomATR : str255;x : ATR);

{Iterateurs}
procedure ATRParcoursInfixe(x : ATR;DoWhatBefore,DoWhatAfter:ATRProc);


{Acces et tests sur les ATR}
function TrouveATRDansChaine(x : ATR; const chaine : string; var position : SInt32) : boolean;
function TrouveSuffixeDeChaineDansATR(x : ATR; const chaine : string; var position : SInt32) : boolean;
function TrouveSuffixeDeChaineCommePrefixeDansATR(x : ATR; const chaine : string; var position : SInt32) : boolean;

function TrouveChaineDansATR(x : ATR; const chaine : string) : boolean;
function ChaineEstPrefixeDansATR(x : ATR; const chaine : string) : boolean;
function ATREstPrefixeDeChaine(x : ATR; const chaine : string) : boolean;


function ATRIsEmpty(x : ATR) : boolean;
function ATRHauteur(x : ATR) : SInt32;

{Test de l'unite}
procedure TestUnitATR;

IMPLEMENTATION







USES MyMathUtils,UnitServicesMemoire,UnitRapport,SNStrings;

const kCaractereSentinelle = chr(0);

function MakeEmptyATR() : ATR;
begin
  MakeEmptyATR := NIL;
end;

procedure DisposeATR(var theATR : ATR);
begin
  if theATR <> NIL then
    begin
      DisposeATR(theATR^.filsMoins);
      DisposeATR(theATR^.filsEgal);
      DisposeATR(theATR^.filsPlus);
      
      DisposeATRPaginee(theATR);
      theATR := NIL;
    end;
end;


procedure ATRParcoursInfixe(x : ATR;DoWhatBefore,DoWhatAfter:ATRProc);
begin
  if x <> NIL then
    begin
      {WriteStringDansRapport('(');}
      ATRParcoursInfixe(x^.filsMoins,DoWhatBefore,DoWhatAfter);
      DoWhatBefore(x);
      ATRParcoursInfixe(x^.filsEgal,DoWhatBefore,DoWhatAfter);
      DoWhatAfter(x);
      ATRParcoursInfixe(x^.filsPlus,DoWhatBefore,DoWhatAfter);
      {WriteStringDansRapport(')');}
    end;
end;

var chaineAffichageATR : string;

procedure AfficherATRNodeDansRapport(var x : ATR);
begin
  if x = NIL
    then 
      WritelnDansRapport('ATR = NIL !')
    else
      begin
        if x^.splitChar = kCaractereSentinelle
          then WritelnStringDansRapport(chaineAffichageATR);
          
        SET_LENGTH_OF_STRING(chaineAffichageATR, LENGTH_OF_STRING(chaineAffichageATR) + 1);
        chaineAffichageATR[LENGTH_OF_STRING(chaineAffichageATR)] := x^.splitChar;
        {WriteStringDansRapport(x^.splitChar);}
      end;
end;

procedure OublierATRNodeEtSauterLigneDansRapport(var x : ATR);
begin  {$UNUSED x}
  if x = NIL
    then 
      WritelnDansRapport('ATR = NIL !')
    else
      begin
        chaineAffichageATR[0] := Chr(LENGTH_OF_STRING(chaineAffichageATR) - 1);
        {WritelnDansRapport('');}
      end;
end;


procedure ATRAffichageInfixe(nomATR : str255; x : ATR);
begin
  WritelnDansRapport('ATR : '+nomATR);
  
  chaineAffichageATR := '';
  ATRParcoursInfixe(x,AfficherATRNodeDansRapport,OublierATRNodeEtSauterLigneDansRapport);
end;

{renvoie true si le suffixe de "chaine" commencant a
 la position "indexDepart", est prefixe de l'une
 des chaines stockees dans l'ATR "x"}
function SuffixeDeChaineEstPrefixeDansATR(x : ATR; const chaine : string;indexDepart,longueur : SInt32) : boolean;
var index : SInt32;
    p : ATR;
    c : char;
begin
  p := x;
  index := indexDepart;
  if indexDepart <= longueur then
    begin
		  while (p <> NIL) do
		    with p^ do
			    begin
			      c := chaine[index];
			      
			      if c < splitChar then p := filsMoins else
			      if c > splitChar then p := filsPlus else
			      {if c = splitChar then}
			        begin
			          inc(index);
			          if index > longueur then
			            begin
			              SuffixeDeChaineEstPrefixeDansATR := true;
			              exit(SuffixeDeChaineEstPrefixeDansATR);
			            end;
			          p := filsEgal;
			          if (p = NIL) then
			            begin
			              SuffixeDeChaineEstPrefixeDansATR := false;
			              exit(SuffixeDeChaineEstPrefixeDansATR);
			            end;
			        end;
			    end;
		end;
  SuffixeDeChaineEstPrefixeDansATR := false;
end;

{renvoie true si l'une des chaines stockees dans l'ATR "x"
 est sous-mot, a partir de "indexDepart", de la chaine "chaine"}
function ATREstSousMotDeChaine(x : ATR; const chaine : string;indexDepart,longueur : SInt32) : boolean;
var index : SInt32;
    p : ATR;
    c : char;
begin
  p := x;
  index := indexDepart;
  if indexDepart <= longueur then
    begin
		  while (p <> NIL) do
		    with p^ do
			    begin
			      c := chaine[index];
			      
			      if c < splitChar then p := filsMoins else
			      if c > splitChar then p := filsPlus else
			      {if c = splitChar then}
			        begin
			          inc(index);
			          p := filsEgal;
			          if (p = NIL) | (p^.splitChar = kCaractereSentinelle) then
			            begin
			              ATREstSousMotDeChaine := true;
			              exit(ATREstSousMotDeChaine);
			            end;
			          if (index > longueur) then
			            begin
			              ATREstSousMotDeChaine := false;
			              exit(ATREstSousMotDeChaine);
			            end;
			        end;
			    end;
		end;
  ATREstSousMotDeChaine := false;
end;

{TrouveATRDansChaine(x,chaine,i) : renvoie true si l'une des chaines
 de l'ATR "x" est un sous-mot de "chaine"; dans ce cas, "i" est la position 
 de ce sous-mot dans chaine}
function TrouveATRDansChaine(x : ATR; const chaine : string; var position : SInt32) : boolean;
var longueur,i : SInt32;
begin
  longueur := Length(chaine);
  for i := 1 to longueur do
    if ATREstSousMotDeChaine(x,chaine,i,longueur) then
      begin
        position := i;
        TrouveATRDansChaine := true;
        exit(TrouveATRDansChaine);
      end;
  TrouveATRDansChaine := false;
  position := -1;
end;

{TrouveSuffixeDeChaineCommePrefixeDansATR(x,chaine,i) : renvoie true si l'un des suffixes
 de la chaine "chaine" est prefixe de l'une des chaines de l'ATR "x"; dans ce cas, 
 ce suffixe commence a la position "i" dans "chaine"}
function TrouveSuffixeDeChaineCommePrefixeDansATR(x : ATR; const chaine : string; var position : SInt32) : boolean;
var longueur,i : SInt32;
begin
  longueur := Length(chaine);
  for i := 1 to longueur do
    if SuffixeDeChaineEstPrefixeDansATR(x,chaine,i,longueur) then
      begin
        position := i;
        TrouveSuffixeDeChaineCommePrefixeDansATR := true;
        exit(TrouveSuffixeDeChaineCommePrefixeDansATR);
      end;
  TrouveSuffixeDeChaineCommePrefixeDansATR := false;
  position := -1;
end;

{TrouveSuffixeDeChaineDansATR(x,chaine,i) : renvoie true si l'un des suffixes
 de la chaine "chaine" est exactement l'une des chaines de l'ATR "x"; dans ce cas,
 ce suffixe commence a la position "i" dans chaine}
function TrouveSuffixeDeChaineDansATR(x : ATR; const chaine : string; var position : SInt32) : boolean;
var longueur,i : SInt32;
    s : str255;
begin
  s := Concat(chaine,kCaractereSentinelle);
  longueur := Length(s);
  for i := 1 to longueur - 1 do
    if SuffixeDeChaineEstPrefixeDansATR(x,s,i,longueur) then
      begin
        position := i;
        TrouveSuffixeDeChaineDansATR := true;
        exit(TrouveSuffixeDeChaineDansATR);
      end;
  TrouveSuffixeDeChaineDansATR := false;
  position := -1;
end;

 
{TrouveChaineDansATR(x,chaine) : renvoie true si "chaine" est exactement l'une 
des chaines de l'ATR "x"}
function TrouveChaineDansATR(x : ATR; const chaine : string) : boolean;
var s : str255;
begin
  s := Concat(chaine,kCaractereSentinelle);
  TrouveChaineDansATR := SuffixeDeChaineEstPrefixeDansATR(x,s,1,Length(s));
end;

{ChaineEstPrefixeDansATR(x,chaine) : renvoie true si "chaine" est prefixe de l'une des
 chaines de l'ATR "x"}
function ChaineEstPrefixeDansATR(x : ATR; const chaine : string) : boolean;
begin
  ChaineEstPrefixeDansATR := SuffixeDeChaineEstPrefixeDansATR(x,chaine,1,Length(chaine));
end;

{ATREstPrefixeDeChaine(x,chaine) : renvoie true si "chaine" commence par l'une
 des chaines de l'ATR "x"}
function ATREstPrefixeDeChaine(x : ATR; const chaine : string) : boolean;
begin
  ATREstPrefixeDeChaine := ATREstSousMotDeChaine(x,chaine,1,Length(chaine));
end;


function ATRIsEmpty(x : ATR) : boolean;
begin
  ATRIsEmpty := (x = NIL);
end;

function ATRHauteur(x : ATR) : SInt32;
var a,b,c : SInt32;
begin
  if x = NIL
    then ATRHauteur := 0
    else
      begin
        a := ATRHauteur(x^.filsMoins);
        b := ATRHauteur(x^.filsPlus);
        c := ATRHauteur(x^.filsEgal);
        ATRHauteur := 1+Max(Max(a,b),c);
      end;
end;


procedure InsererDansATR(var arbre : ATR; const chaine : string);
var longueur,index : SInt32;
    c : char;
    s : str255;
    
		procedure ATRInsererRecursivement(var x : ATR);
		begin
		  if index <= longueur then
		    begin
		      if x = NIL
		        then
		          begin
		            x := NewATRPaginee();
		            if x <> NIL then
		              with x^ do
		                begin
		                  splitChar := s[index];
		                  filsMoins := NIL;
		                  filsEgal := NIL;
		                  filsPlus := NIL;
		                  index := succ(index);
		                  ATRInsererRecursivement(filsEgal);
		                end;
		          end
		        else
		          with x^ do
			          begin
			            c := s[index];
			            
			            if c < splitChar then  ATRInsererRecursivement(filsMoins) else
			            if c > splitChar then  ATRInsererRecursivement(filsPlus) else
			           {if c = splitChar then} 
			             begin
			               index := succ(index);
			               ATRInsererRecursivement(filsEgal);
			             end;
			          end;
		    end;
		end;    

begin
  s := Concat(chaine,kCaractereSentinelle);
  longueur := Length(s);
  if (longueur > 1) then
    begin
		  index := 1;
		  ATRInsererRecursivement(arbre);
		end;
end;


procedure TestUnitATR;
var S1 : ATR;
    {i : SInt32;}
    s : str255;
begin
  {WritelnSoldesCreationsPropertiesDansRapport('entrŽe dans TestATR : ');}


  S1 := MakeEmptyATR();
  ATRAffichageInfixe('ensemble vide S1',S1);
  DisposeATR(S1);
  
  {WritelnSoldesCreationsPropertiesDansRapport('aprs ensemble vide : ');}
  s := 'blah blah';
  
  S1 := MakeEmptyATR();
  InsererDansATR(S1,s);
  InsererDansATR(S1,'toto est grand');
  InsererDansATR(S1,'cassio 5.1.2');
  InsererDansATR(S1,'tastet');
  InsererDansATR(S1,'cassio');
  InsererDansATR(S1,'total fina');
  InsererDansATR(S1,'c');
  InsererDansATR(S1,'nicolet');
  InsererDansATR(S1,'zebra');
  InsererDansATR(S1,'cassio 5.1.5');
  InsererDansATR(S1,'tastet serge');
  InsererDansATR(S1,'cassio 5.1.6');
  
  ATRAffichageInfixe('ATR infixe',S1);

  {
  WritelnStringAndBooleanDansRapport('tastet => ',TrouveATRDansChaine(S1,'tastet',i));
  WritelnStringAndBooleanDansRapport('tastet marc => ',TrouveATRDansChaine(S1,'tastet marc',i));
  WritelnStringAndBooleanDansRapport('toto => ',TrouveATRDansChaine(S1,'toto',i));
  WritelnStringAndBooleanDansRapport('cassio  => ',TrouveATRDansChaine(S1,'cassio ',i));
  WritelnStringAndBooleanDansRapport('compoth => ',TrouveATRDansChaine(S1,'compoth',i));
  WritelnStringAndBooleanDansRapport('zebr => ',TrouveATRDansChaine(S1,'zebr',i));
  WritelnStringAndBooleanDansRapport('wzebra => ',TrouveATRDansChaine(S1,'wzebra',i));
  WritelnStringAndBooleanDansRapport('wzebra 2.0.1 => ',TrouveATRDansChaine(S1,'wzebra 2.0.1',i));
  
  
  WritelnStringAndBooleanDansRapport('tastet => ',ChaineEstPrefixeDansATR(S1,'tastet'));
  WritelnStringAndBooleanDansRapport('tastet marc => ',TrouveSuffixeDeChaineDansATR(S1,'tastet marc',i));
  WritelnStringAndBooleanDansRapport('toto => ',TrouveSuffixeDeChaineDansATR(S1,'toto',i));
  WritelnStringAndBooleanDansRapport('cassio  => ',TrouveSuffixeDeChaineDansATR(S1,'cassio ',i));
  WritelnStringAndBooleanDansRapport('compoth => ',TrouveSuffixeDeChaineDansATR(S1,'compoth',i));
  WritelnStringAndBooleanDansRapport('zebr => ',TrouveSuffixeDeChaineDansATR(S1,'zebr',i));
  WritelnStringAndBooleanDansRapport('wzebra => ',TrouveSuffixeDeChaineDansATR(S1,'wzebra',i));
  WritelnStringAndBooleanDansRapport('wzebra 2.0.1 => ',TrouveSuffixeDeChaineDansATR(S1,'wzebra 2.0.1',i));
  }
  
  DisposeATR(S1); 
  
  {WritelnSoldesCreationsPropertiesDansRapport('sortie de TestATR : ');}
end;


END.
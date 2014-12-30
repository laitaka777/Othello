UNIT UnitStringSet;


{Gestion d'ensembles de chaines de caracteres, 
avec du hachage puis des arbres binaires de recherche}

INTERFACE







USES UnitArbresBinairesRecherche;

type StringSet = record
                   cardinal : SInt32;
                   arbre : ABR;
                 end;

{Creation et destruction}
function MakeEmptyStringSet() : StringSet;
function MakeOneElementStringSet(const theString : string;data : SInt32) : StringSet;
procedure DisposeStringSet(var S : StringSet);

{Fonctions de test}
function StringSetEstVide(S : StringSet) : boolean;
function CardinalOfStringSet(S : StringSet) : SInt32;
function MemberOfStringSet(const theString : string; var data : SInt32;S : StringSet) : boolean;

{Ajout et retrait destructifs}
procedure AddStringToSet(const theString : string;data : SInt32; var S : StringSet);
procedure RemoveStringFromSet(const theString : string; var S : StringSet);

{Ecriture dans le rapport}
procedure WriteStringSetDansRapport(const nom : str255;S : StringSet;avecCardinal : boolean);
procedure WritelnStringSetDansRapport(const nom : str255;S : StringSet;avecCardinal : boolean);
procedure WritelnStringDansRapportSansRepetition(theString : str255; var stringPool : StringSet);


{Verification de l'unite}
procedure TestStringSet;


IMPLEMENTATION







USES UnitHashing,UnitRapport;


function MakeEmptyStringSet() : StringSet;
var result : StringSet;
begin
  result.cardinal := 0;
  result.arbre := MakeEmptyABR();
  MakeEmptyStringSet := result;
end;

function MakeOneElementStringSet(const theString : string;data : SInt32) : StringSet;
var hash : SInt32;
    result : StringSet;
begin
  hash := HashString(theString);
  result.cardinal := 1;
  result.arbre := MakeOneElementABR(hash,data);
  MakeOneElementStringSet := result;
end;

procedure DisposeStringSet(var S : StringSet);
begin
  with S do
    begin
      cardinal := 0;
      DisposeABR(arbre);
    end;
end;

function StringSetEstVide(S : StringSet) : boolean;
begin
  StringSetEstVide := (S.cardinal=0) | ABRIsEmpty(S.arbre);
end;


function CardinalOfStringSet(S : StringSet) : SInt32;
begin
  CardinalOfStringSet := S.cardinal;
end;


function MemberOfStringSet(const theString : string; var data : SInt32;S : StringSet) : boolean;
var hash : SInt32;
    elementTrouve : ABR;
begin
  if StringSetEstVide(S)
    then MemberOfStringSet := false
    else
      begin
        hash := HashString(theString);
        elementTrouve := ABRSearch(S.arbre,hash);
        if elementTrouve <> NIL
          then
            begin
              MemberOfStringSet := true;
              data := elementTrouve^.data;
            end
          else
            begin
              MemberOfStringSet := false;
              data := -1;
            end;
      end;
end;


procedure AddStringToSet(const theString : string;data : SInt32; var S : StringSet);
var element : ABR;
    hash : SInt32;
begin
  if StringSetEstVide(S) 
    then S := MakeOneElementStringSet(theString,data)
    else
      begin
        hash := HashString(theString);
        if (ABRSearch(S.arbre,hash) = NIL) then {s'il n'y est pas deja...}
          begin
            element := MakeOneElementABR(hash,data);
            if element <> NIL then
              begin
                S.cardinal := S.cardinal+1;
                ABRInserer(S.arbre,element);
              end;
          end;
    end;
end;


procedure RemoveStringFromSet(const theString : string; var S : StringSet);
var element : ABR;
    hash : SInt32;
begin
  if not(StringSetEstVide(S)) then
    begin
      hash := HashString(theString);
      element := ABRSearch(S.arbre,hash);
      if (element <> NIL) then {s'il y est...}
        begin
          S.cardinal := S.cardinal-1;
          SupprimerDansABR(S.arbre,element);
        end;
    end;
end;


procedure WriteStringSetDansRapport(const nom : str255;S : StringSet;avecCardinal : boolean);
begin
  WritelnStringDansRapport('StringSet '+nom+' :');
  if avecCardinal then 
    WritelnStringAndNumDansRapport(Concat(nom,'.cardinal='),S.cardinal);
  WritelnStringDansRapport(Concat(nom,'.ABR = {'));
  ABRAffichageInfixe('',S.arbre);
  WriteDansRapport('}');
end;

procedure WritelnStringSetDansRapport(const nom : str255;S : StringSet;avecCardinal : boolean);
begin
  WriteStringSetDansRapport(nom,S,avecCardinal);
  WritelnDansRapport('');
end;

procedure WritelnStringDansRapportSansRepetition(theString : str255; var stringPool : StringSet);
var data : SInt32;
begin
  if not(MemberOfStringSet(theString,data,stringPool)) then
    begin
      WritelnDansRapport(theString);
      AddStringToSet(theString,0,stringPool);
    end;
end;

procedure TestStringSet;
var S : StringSet;
    theString : string;
    data : SInt32;
begin
  S := MakeOneElementStringSet('',0);
  WritelnStringSetDansRapport('initial ',S,true);
  DisposeStringSet(S);
  
  WritelnStringSetDansRapport('apres dispose, initial ',S,true);
  
  
  S := MakeEmptyStringSet();
  
  theString := '';
  AddStringToSet(theString,0,S);
  AddStringToSet('F5',0,S);
  AddStringToSet('F5D6',0,S);
  AddStringToSet('F5D6C3',0,S);
  AddStringToSet('F5D6C3D3',0,S);
  AddStringToSet('F5D6C3D3C4',0,S);
  WritelnStringSetDansRapport('apres 5 coups ',S,true);
  
  
  theString := '';
  AddStringToSet(theString,0,S);
  AddStringToSet('F5',0,S);
  AddStringToSet('F5D6',0,S);
  AddStringToSet('F5D6C4',0,S);
  AddStringToSet('F5D6C4D3',0,S);
  AddStringToSet('F5D6C4D3C3',0,S);
  WritelnStringSetDansRapport('apres 5 coups (inter)',S,true);
  
  
  WritelnStringAndBoolDansRapport('member('',S)=',MemberOfStringSet('',data,S));
  
  RemoveStringFromSet('',S);
  WritelnStringSetDansRapport('apres avoir enleve la position de depart',S,true);
  
  RemoveStringFromSet('',S);
  WritelnStringSetDansRapport('apres avoir enleve la position de depart',S,true);
  
  DisposeStringSet(S);
  
  WritelnStringSetDansRapport('apres dispose, S ',S,true);
end;


END.
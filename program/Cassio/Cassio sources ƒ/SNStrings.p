UNIT SNStrings;


INTERFACE



USES MacTypes,StringTypes;

(*
{$definec LENGTH_OF_STRING(s) (ord(s[0])) }
{$definec SET_LENGTH_OF_STRING( s , len )  s[0] := chr((len)) }
*)

  function LENGTH_OF_STRING(const s : string) : SInt32;
  procedure SET_LENGTH_OF_STRING(var s : string; len : SInt32);

  procedure InitSNStrings;

	function ExtraitNomDirectoryOuFichier(chemin : str255) : str255;
	function ExtraitCheminDAcces(nomComplet : str255) : str255;
	function EstUnNomDeFichierTronquePourPanther(const nomFichier : str255) : boolean; 
	
  function ReplaceStringByStringInString(const pattern,replacement,s : str255) : str255;
  function ReplaceVariableByStringInString(const pattern,replacement,s : str255) : str255;
  function DeleteSpacesBefore(const s : str255;p : SInt16) : str255;
  function DeleteSpacesAfter(const s : str255;p : SInt16) : str255;
  function MyUpperString(const s : str255;diacritiques : boolean) : str255;
  function MyLowerString(const s : str255;diacritiques : boolean) : str255;
  function MyStripDiacritics(const s : str255) : str255;
  
  
  {le premier argument n'est pas un const ni un var pour pouvoir passer s dans tete ou dans reste}
  procedure Parser (s : str255; var tete,reste : str255);
  procedure Parser2(s : str255; var s1,s2,reste : str255);
  procedure Parser3(s : str255; var s1,s2,s3,reste : str255);
  procedure Parser4(s : str255; var s1,s2,s3,s4,reste : str255);
  procedure Parser5(s : str255; var s1,s2,s3,s4,s5,reste : str255);
  procedure Parser6(s : str255; var s1,s2,s3,s4,s5,s6,reste : str255);
  
  procedure SetParsingProtectionWithQuotes(flag : boolean);
  function  GetParsingProtectionWithQuotes() : boolean;
  procedure SetParsingCaracterSet(parsingCaracters : SetOfChar);
  function  GetParsingCaracterSet() : SetOfChar;
 
   
  function EndsWith(const s : str255; const sub : str255) : boolean;
	function EndsWithDeuxPoints(var s : str255) : boolean;
	
	function BoolEnString(myBool : boolean) : string;
  function NumEnString(num : SInt32): string;
  function NumEnStringAvecFormat(num,nbDeChiffres : SInt32) : string;
  function BigNumEnString(milliards,num : SInt32) : string;
  
  function CharInRange(ch : char; min,max : char) : boolean;
  function ContientUneLettre(const s : str255) : boolean;
  function IsAnArrowKey(ch : char) : boolean;
  function EstUnChiffreHexa(ch : char) : boolean;
  
	function EstUnReel(alpha : str255): boolean;
	function EnMinuscule(var s: string): str255;
	function ParamStr(s, p0, p1, p2, p3: string): string;
	function ReadStringFromRessource(stringListID, index: SInt16): string;
	function SeulementLesChiffres(var s: string): string;
	function SeulementLesChiffresOuLesPoints(var s: string): string;
	function EnleveEspacesDeGauche(const s : string) : str255;
  function EnleveEspacesDeDroite(const s : string) : str255;
  procedure EnleveEspacesDeGaucheSurPlace(var s : string);
  procedure EnleveEspacesDeDroiteSurPlace(var s : string);
  procedure EnleveEtCompteEspacesDeGauche(var s : string; var nbEspacesEnleves : SInt16);
  procedure EnleveEtCompteEspacesDeDroite(var s : string; var nbEspacesEnleves : SInt16);
  procedure EnleveEtCompteCeCaractereAGauche(var s : string;ch : char; var nbCaracteresEnleves : SInt16);
  procedure EnleveEtCompteCeCaractereADroite(var s : string;ch : char; var nbCaracteresEnleves : SInt16);
  procedure EnleveEtCompteCeCaractereAGaucheDansBuffer(buffer : Ptr; var tailleBuffer : SInt32;ch : char; var nbCaracteresEnleves : SInt32);
  function ASeulementCeCaractere(c : char; var s : string) : boolean;
  function CompterOccurencesDeSousChaine(const subString,s : str255) : SInt32;
  function DeleteSubstringBeforeThisChar(theChar : char; const s : str255;keepTheChar : boolean) : str255;
  function DeleteSubstringAfterThisChar(theChar : char; const s : str255;keepTheChar : boolean) : str255;

  function ReelEnString(unreel : extended) : str255;
  function ReelEnStringAvecDecimales(unreel : extended;nbChiffresSignificatifs : SInt16) : str255;
  function PourcentageReelEnString(x : extended) : str255;
  function ReelEnStringRapide(unreel : extended) : str255;
  function StringSimpleEnReel(alpha : str255) : extended;
  function PourcentageEntierEnString(num : SInt32) : string;
  function ChaineEnInteger(const s : str255) : SInt16; 
  function ChaineEnLongint(const s : str255) : SInt32;
  procedure ChaineToInteger(const s : str255; var theInteger : SInt16);
  procedure ChaineToLongint(const s : str255; var theLongint : SInt32);
  
  function Hexa(num : SInt32) : string;
  function SeparerLesChiffresParTrois(var s : str255) : string;
  function SecondesEnJoursHeuresSecondes(secondes : SInt32) : str255;

  function BufferToPascalString(buffer : Ptr;indexDepart,indexFin : SInt32) : str255;


IMPLEMENTATION



USES MacTypes, MyTypes , MyStrings , TextUtils, UnitMacExtras, UnitRapport;


var protect_parsing_with_quotes : boolean; 
    parsing_set : SetOfChar;
    

function LENGTH_OF_STRING(const s : string) : SInt32;
begin
  LENGTH_OF_STRING := ord(s[0]);
end;


procedure SET_LENGTH_OF_STRING(var s : string; len : SInt32);
begin
  s[0] := chr((len));
end;


procedure InitSNStrings;
begin
  SetParsingProtectionWithQuotes(false);
  SetParsingCaracterSet([' ',tab]);
end;

procedure SetParsingProtectionWithQuotes(flag : boolean);
begin
  protect_parsing_with_quotes := flag;
end;

function GetParsingProtectionWithQuotes() : boolean;
begin
  GetParsingProtectionWithQuotes := protect_parsing_with_quotes;
end;

function GetParsingCaracterSet() : SetOfChar;
begin
  GetParsingCaracterSet := parsing_set;
end;

procedure SetParsingCaracterSet(parsingCaracters : SetOfChar);
begin
  parsing_set := parsingCaracters;
end;
  

function ExtraitNomDirectoryOuFichier(chemin : str255) : str255;
const separateur = ':';
var LastPosDeuxPoints : SInt16; 
begin
  if RightOfString(chemin,1) = StringOf(separateur) 
    then LeftP(chemin,Length(chemin)-1);
  LastPosDeuxPoints := LastPos(separateur,chemin);
  ExtraitNomDirectoryOuFichier := RightOfString(chemin,Length(chemin)-LastPosDeuxPoints);
end;


function ExtraitCheminDAcces(nomComplet : str255) : str255;
var nomFichier : str255;
begin
  nomFichier := ExtraitNomDirectoryOuFichier(nomComplet);
  ExtraitCheminDAcces := LeftOfString(nomComplet,Length(nomComplet)-Length(nomFichier));
end;


function EstUnNomDeFichierTronquePourPanther(const nomFichier : str255) : boolean;
var longueur,i : SInt32;
begin
  longueur := Length(nomFichier);
  
    
    
  if (longueur >= 10) & (nomFichier[longueur-3] = '.') then
    begin
      
      for i := (longueur - 9) to (longueur - 4) do
        if not(EstUnChiffreHexa(nomFichier[i])) then
          begin
            EstUnNomDeFichierTronquePourPanther := false;
            exit(EstUnNomDeFichierTronquePourPanther);
          end;
       EstUnNomDeFichierTronquePourPanther := true;
       exit(EstUnNomDeFichierTronquePourPanther);
    end;
  
  if (longueur >= 11) & (nomFichier[longueur-4] = '.') then
    begin
      for i := (longueur - 10) to (longueur - 5) do
        if not(EstUnChiffreHexa(nomFichier[i])) then
          begin
            EstUnNomDeFichierTronquePourPanther := false;
            exit(EstUnNomDeFichierTronquePourPanther);
          end;
       EstUnNomDeFichierTronquePourPanther := true;
       exit(EstUnNomDeFichierTronquePourPanther);
    end;
  
  if (longueur >= 6) then
    begin
      for i := (longueur - 5) to (longueur) do
        if not(EstUnChiffreHexa(nomFichier[i])) then
          begin
            EstUnNomDeFichierTronquePourPanther := false;
            exit(EstUnNomDeFichierTronquePourPanther);
          end;
       EstUnNomDeFichierTronquePourPanther := true;
       exit(EstUnNomDeFichierTronquePourPanther);
    end;
  
  EstUnNomDeFichierTronquePourPanther := false;
end;


function ReplaceStringByStringInString(const pattern,replacement,s : str255) : str255;
var positionSubstring : SInt16; 
      res : str255;
begin
  positionSubstring := Pos(pattern,s);
  if (positionSubstring > 0)
     then
       begin
         res := s;
         Delete(res,positionSubstring,Length(pattern));
         Insert(replacement,res,positionSubstring);
         ReplaceStringByStringInString := res;
       end
     else
       ReplaceStringByStringInString := s;
end;


function ReplaceVariableByStringInString(const pattern,replacement,s : str255) : str255;
var positionSubstring,posDeuxPoint : SInt32;
    posCrochetOuvrant,posCrochetFermant : SInt32;
    longueurDuFormat,depart,fin : SInt32;
    resultat,reste,insertion : str255;
begin
    
  positionSubstring := Pos(pattern,s);
  if (positionSubstring > 0)
     then
       begin
         (* 
            on cherche si le pattern est en fait une 
            variable de la forme $VARIABLE[deb..fin]
         *)
         reste := TPCopy(s,positionSubstring,255);
         posCrochetOuvrant := Pos('[',reste);
         posCrochetFermant := Pos(']',reste);
         
         if (reste[1] = '$') & 
            (posCrochetOuvrant > 0) & 
            (posCrochetFermant > posCrochetOuvrant) 
           then
             begin
               longueurDuFormat := posCrochetFermant - posCrochetOuvrant + 1;
               reste  := TPCopy(reste,posCrochetOuvrant+1,longueurDuFormat-2);
               
               depart := 1;
               fin    := 255;
               
               posDeuxPoint := Pos('..',reste);
               if (posDeuxPoint >= 2) 
                 then depart := ChaineEnLongint(LeftOfString(reste,posDeuxPoint - 1));
               if (posDeuxPoint <= Length(reste) - 2) 
                 then fin    := ChaineEnLongint(TPCopy(reste,posDeuxPoint + 2,255));
               
               insertion := TPCopy(replacement,depart,fin - depart + 1);
             end
           else
             begin
               longueurDuFormat := 0;
               insertion := replacement;
             end;
       
         resultat := s;
         Delete(resultat,positionSubstring,Length(pattern)+longueurDuFormat);
         Insert(insertion,resultat,positionSubstring);
         ReplaceVariableByStringInString := resultat;
       end
     else
       ReplaceVariableByStringInString := s;
end;

function DeleteSpacesBefore(const s : str255;p : SInt16) : str255;
var n,len : SInt16; 
begin
  len := Length(s);
  if (p>len) | (p<1) then
    begin
      DeleteSpacesBefore := s;
      exit(DeleteSpacesBefore);
    end;
  n := p;
  while (n>=1) & (s[n]=' ') do n := n-1;
  if (n>=1) 
    then DeleteSpacesBefore := TPCopy(s,1,n) + TPCopy(s,p+1,len-p)
    else DeleteSpacesBefore := TPCopy(s,p+1,len-p);
end;

function DeleteSpacesAfter(const s : str255;p : SInt16) : str255;
var n,len : SInt16; 
begin
  len := Length(s);
  if (p>len) | (p<1) then
    begin
      DeleteSpacesAfter := s;
      exit(DeleteSpacesAfter);
    end;
  n := p;
  while (n<=len) & (s[n]=' ') do n := n+1;
  if (n<=len)
    then DeleteSpacesAfter := TPCopy(s,1,p-1) + TPCopy(s,n,len-n+1)
    else DeleteSpacesAfter := TPCopy(s,1,p-1);
end;

function MyUpperString(const s : str255;diacritiques : boolean) : str255;
var aux : str255;
begin
  aux := s;
  UpperString(aux,diacritiques);
  MyUpperString := aux;
end;

function MyLowerString(const s : str255; diacritiques : boolean) : str255;
var result : str255;
begin
  if not(diacritiques) 
    then result := MyStripDiacritics(s)
    else result := s;
  MyLowerString := LowerCaseStr(result);
end;

function MyStripDiacritics(const s : str255) : str255;
var result : str255;
begin
  result := s;
  StripDiacritics(@result[1],Length(result),smSystemScript);
  MyStripDiacritics := result;
end;

procedure Parser(s : str255; var tete,reste : str255);
var n,len : SInt16; 
begin
  tete := '';
  reste := '';
  len := Length(s);
  if len>0 then
    begin
      n := 1;
      while (n<=len) & (s[n] in parsing_set) do n := n+1;  {on saute les espaces en tete de s}
      if n<=len then
        begin
          if protect_parsing_with_quotes & (s[n] = '"') 
            then
              begin
                n := n+1;
                while (n<=len) & (s[n] <> '"') do {on va jusqu'au prochain quote}
                  begin
                    tete := Concat(tete,s[n]);
                    n := n+1; 
                  end;
                if (s[n]='"') & (n<=len) then n := n+1; {on saute le quote fermant}
              end
            else
              while (n<=len) & (not(s[n] in parsing_set)) do {on va jusqu'au prochain espace}
                begin
                  tete := Concat(tete,s[n]);
                  n := n+1;
                end;
          while (n<=len) & (s[n] in parsing_set) do n := n+1; {on saute les espaces en tete du reste}
          if n<=len then reste := TPCopy(s,n,len-n+1);
        end;
    end;
end;

procedure Parser2(s : str255; var s1,s2,reste : str255);
begin
  Parser(s,s1,reste);
  Parser(reste,s2,reste);
end;

procedure Parser3(s : str255; var s1,s2,s3,reste : str255);
begin
  Parser(s,s1,reste);
  Parser(reste,s2,reste);
  Parser(reste,s3,reste);
end;

procedure Parser4(s : str255; var s1,s2,s3,s4,reste : str255);
begin
  Parser(s,s1,reste);
  Parser(reste,s2,reste);
  Parser(reste,s3,reste);
  Parser(reste,s4,reste);
end;

procedure Parser5(s : str255; var s1,s2,s3,s4,s5,reste : str255);
begin
  Parser(s,s1,reste);
  Parser(reste,s2,reste);
  Parser(reste,s3,reste);
  Parser(reste,s4,reste);
  Parser(reste,s5,reste);
end;

procedure Parser6(s : str255; var s1,s2,s3,s4,s5,s6,reste : str255);
begin
  Parser(s,s1,reste);
  Parser(reste,s2,reste);
  Parser(reste,s3,reste);
  Parser(reste,s4,reste);
  Parser(reste,s5,reste);
  Parser(reste,s6,reste);
end;

function EndsWith(const s : str255; const sub : str255) : boolean;
var len1,len2,i : SInt16; 
begin
  len1 := length(s);
  len2 := length(sub);
  if (len1<=0) | (len2<=0) | (len1<len2)
    then
      EndsWith := false
    else
      begin
        for i := 1 to len2 do
          if s[len1-len2+i]<>sub[i] then
            begin
              EndsWith := false;
              exit(EndsWith);
            end;
        EndsWith := true;
      end;
end;

function EndsWithDeuxPoints(var s : str255) : boolean;
begin
  EndsWithDeuxPoints := (s[Length(s)]=':');
end;


function BoolEnString(myBool : boolean) : string;
begin
  if myBool
    then BoolEnString := 'TRUE'
    else BoolEnString := 'FALSE';
end;


function NumEnString(num : SInt32) : string;
	var
		s: str255;
begin
	NumToString(num, s);
	NumEnString := s;
end;

function NumEnStringAvecFormat(num,nbDeChiffres : SInt32) : string;
var i : SInt32;
		s: str255;
begin
	NumToString(num, s);
	for i := 1 to (nbDeChiffres - Length(s)) do
	  s := '0'+s;
	NumEnStringAvecFormat := s;
end;

function CharInRange(ch : char; min,max : char) : boolean;
begin
  CharInRange := (ch >= min) & (ch <= max);
end;

function ContientUneLettre(const s : str255) : boolean;
var i : SInt32;
    c : char;
begin
  for i := 1 to Length(s) do
    begin
      c := s[i];
      if ((c >= 'a') & (c <= 'z')) | ((c >= 'A') & (c <= 'Z')) then
        begin
          ContientUneLettre := true;
          exit(ContientUneLettre);
        end;
    end;
  ContientUneLettre := false;
end;


function EstUnChiffreHexa(ch : char) : boolean;
begin
  EstUnChiffreHexa := CharInRange(ch,'0','9') |
                      CharInRange(ch,'A','F') |
                      CharInRange(ch,'a','f');
end;


function IsAnArrowKey(ch : char) : boolean;
const TopDocumentKey=1;
      BottomDocumentKey=4;
      PageUpKey=11;
      PageDownKey=12;
      FlecheGaucheKey=28;
      FlecheDroiteKey=29;
      FlecheHautKey=30;
      FlecheBasKey=31;
var ascii : SInt32;
begin
  ascii := ord(ch);
  IsAnArrowKey := (ascii = TopDocumentKey)    |
                  (ascii = BottomDocumentKey) |
                  (ascii = PageUpKey)         |
                  (ascii = PageDownKey)       |
                  (ascii = FlecheGaucheKey)   |
                  (ascii = FlecheDroiteKey)   |
                  (ascii = FlecheHautKey)     |
                  (ascii = FlecheBasKey);
end;

function BigNumEnString(milliards,num : SInt32) : string;
var
		s,s1: str255;
begin
  if milliards = 0 
  	then
    	begin
    		NumToString(num, s);
    		BigNumEnString := s;
    	end
    else
    	begin
    	  if num < 0 then 
    	    begin
    	      num := -num;
    	      milliards := -milliards;
    	    end;
    	 	NumToString(milliards, s1);
    	 	NumToString(num, s);
    	 	if num < 100000000 then begin s := Concat('0',s);
    	 	if num <  10000000 then begin s := Concat('0',s);
    	 	if num <   1000000 then begin s := Concat('0',s);
    	 	if num <    100000 then begin s := Concat('0',s);
    	 	if num <     10000 then begin s := Concat('0',s);
    	 	if num <      1000 then begin s := Concat('0',s);
    	 	if num <       100 then begin s := Concat('0',s);
    	 	if num <        10 then begin s := Concat('0',s); end; end; end; end; end; end; end; end;
    		BigNumEnString := Concat(s1,s);
    	end;
end;

function EstUnReel(alpha: str255): boolean;
	var
		i, nbPoints: SInt16; 
		flag: boolean;
begin
	if alpha = '' then
		begin
			EstUnReel := false;
			exit(EstUnReel);
		end;

	if Pos('.', alpha) = 0 then
		begin
			i := Pos(',', alpha);
			if i <> 0 then
				alpha[i] := '.';  {on remplace la virgule par un point}
		end;
	nbPoints := 0;
	flag := true;
	for i := 1 to Length(alpha) do
		if (IsDigit(alpha[i])  
		    | (alpha[i] = '.')
		    | (alpha[i] = 'e')
		    | (alpha[i] = 'E')
		    | (alpha[i] = '-')) 
		then {bons caractres}
			begin
				if alpha[i] = '.' then
					begin
						nbPoints := nbPoints + 1;
						if nbPoints > 1 then
							flag := false;
					end;
			end
		else
			flag := false;
	EstUnReel := flag;
end;

function EnMinuscule(var s: string): str255;
	var
		c : char;
		s1: str255;
		i: SInt16; 
begin
	s1 := '';
	for i := 1 to Length(s) do
		begin
			c := s[i];
			if (c >= 'A') & (c <= 'Z') then
				c := chr(ord(c) + 32);
			s1 := s1 + c;
		end;
	EnMinuscule := s1;
end;

function ParamStr(s, p0, p1, p2, p3: string): string;
	var
		i, j: SInt16; 
		code: string[2];
begin
	if s <> '' then
		for i := 0 to 3 do
			begin
				code := Concat('^', chr(i + ord('0')));
				j := Pos(code, s);
				if j > 0 then
					begin
						Delete(s, j, 2);
						case i of
							0: 
								Insert(p0, s, j);
							1: 
								Insert(p1, s, j);
							2: 
								Insert(p2, s, j);
							3: 
								Insert(p3, s, j);
						end;
					end;
			end;
	ParamStr := s;
end;

function ReadStringFromRessource(stringListID, index: SInt16): string;
	var
		s: str255;
begin
	s := '';
	GetIndString(s, stringListID, index);
	ReadStringFromRessource := s;
end;


function SeulementLesChiffres(var s: string): string;
	var
		i: SInt16; 
		result: string;
		c : char;
begin
	result := '';
	for i := 1 to Length(s) do
		begin
			c := s[i];
			if (c >= '0') & (c <= '9') then
				result := result + c;
		end;
	SeulementLesChiffres := result;
end;

function SeulementLesChiffresOuLesPoints(var s: string): string;
	var
		i: SInt16; 
		result: string;
		c : char;
begin
	result := '';
	for i := 1 to Length(s) do
		begin
			c := s[i];
			if ((c >= '0') & (c <= '9')) | (c = '.') | (c = ',') then
				result := result + c;
		end;
	SeulementLesChiffresOuLesPoints := result;
end;


function EnleveEspacesDeGauche(const s : string) : str255;
var len,i,j : SInt16; 
    result : str255;
begin
  len := Length(s);
  result := '';
  if (len>0) then
    begin
      i := 1;
      if (s[1]=' ') then repeat inc(i); until (i>len) | (s[i]<>' ');
      for j := i to len do result := result + s[j];
    end;
  EnleveEspacesDeGauche := result;
  
  {WritelnStringAndNumDansRapport('len=',len);
  for i := 1 to len do
    WritelnStringAndNumDansRapport('s['+NumEnString(i)+']=',ord(s[i]));
  WritelnStringAndNumDansRapport('length(result)=',length(result));
  for i := 1 to length(result) do
    WritelnStringAndNumDansRapport('result['+NumEnString(i)+']=',ord(result[i]));} 
end;

procedure EnleveEtCompteEspacesDeGauche(var s : string; var nbEspacesEnleves : SInt16);
var len,i,j : SInt16; 
begin
  len := LENGTH_OF_STRING(s);
  nbEspacesEnleves := 0;
  if (len>0) then
    begin
      i := 1;
      if (s[1]=' ') then 
        repeat 
          inc(i); 
          inc(nbEspacesEnleves);
        until (i>len) | (s[i]<>' ');
      if nbEspacesEnleves>0 then
        begin
          for j := 1 to len-nbEspacesEnleves do 
            s[j] := s[j+nbEspacesEnleves];
          s[0] := chr(len-nbEspacesEnleves);
        end;
    end;
end;

function EnleveEspacesDeDroite(const s : string) : str255;
var len,i,j : SInt16; 
    result : str255;
begin
  len := Length(s);
  result := '';
  if (len>0) then
    begin
      i := len;
      if (s[len]=' ') then 
        repeat 
          dec(i); 
        until (i<1) | (s[i]<>' ');
      for j := 1 to i do result := result + s[j];
    end;
  EnleveEspacesDeDroite := result;
  
  {WritelnStringAndNumDansRapport('len=',len);
  for i := 1 to len do
    WritelnStringAndNumDansRapport('s['+NumEnString(i)+']=',ord(s[i]));
  WritelnStringAndNumDansRapport('length(result)=',length(result));
  for i := 1 to length(result) do
    WritelnStringAndNumDansRapport('result['+NumEnString(i)+']=',ord(result[i]));}
end;


procedure EnleveEtCompteEspacesDeDroite(var s : string; var nbEspacesEnleves : SInt16);
var len,i : SInt16; 
begin
  len := LENGTH_OF_STRING(s);
  nbEspacesEnleves := 0;
  if (len>0) then
    begin
      i := len;
      if (s[len] = ' ') then 
        repeat 
          dec(i); 
          inc(nbEspacesEnleves);
        until (i<1) | (s[i]<>' ');
      if nbEspacesEnleves>0 then
        s[0] := chr(len-nbEspacesEnleves);
    end;
end;

procedure EnleveEtCompteCeCaractereAGauche(var s : string;ch : char; var nbCaracteresEnleves : SInt16);
var len,i,j : SInt16; 
begin
  len := LENGTH_OF_STRING(s);
  nbCaracteresEnleves := 0;
  if (len>0) then
    begin
      i := 1;
      if (s[1]=ch) then 
        repeat 
          inc(i); 
          inc(nbCaracteresEnleves);
        until (i>len) | (s[i]<>ch);
      if nbCaracteresEnleves>0 then
        begin
          for j := 1 to len-nbCaracteresEnleves do 
            s[j] := s[j+nbCaracteresEnleves];
          s[0] := chr(len-nbCaracteresEnleves);
        end;
    end;
end;

procedure EnleveEtCompteCeCaractereADroite(var s : string;ch : char; var nbCaracteresEnleves : SInt16);
var len,i : SInt16; 
begin
  len := LENGTH_OF_STRING(s);
  nbCaracteresEnleves := 0;
  if (len>0) then
    begin
      i := len;
      if (s[len]=ch) then 
        repeat 
          dec(i); 
          inc(nbCaracteresEnleves);
        until (i<1) | (s[i]<>ch);
      if nbCaracteresEnleves>0 then
        s[0] := chr(len-nbCaracteresEnleves);
    end;
end;

procedure EnleveEspacesDeGaucheSurPlace(var s : string);
var nbEspacesEnleves : SInt16; 
begin
  EnleveEtCompteEspacesDeGauche(s,nbEspacesEnleves);
end;


procedure EnleveEspacesDeDroiteSurPlace(var s : string);
var nbEspacesEnleves : SInt16; 
begin
  EnleveEtCompteEspacesDeDroite(s,nbEspacesEnleves);
end;


procedure EnleveEtCompteCeCaractereAGaucheDansBuffer(buffer : Ptr; var tailleBuffer : SInt32;ch : char; var nbCaracteresEnleves : SInt32);
type charArray = packed array[0..0] of char;
     charArrayPtr = ^charArray;
var len,i,j : SInt32;
    localBuffer:charArrayPtr;
begin

  localBuffer := charArrayPtr(buffer);
  
  len := tailleBuffer;
  nbCaracteresEnleves := 0;
  
  if (len>0) then
    begin
      i := 0;
      if (localBuffer^[0] = ch) then 
        repeat 
          inc(i); 
          inc(nbCaracteresEnleves);
        until (i >= len) | (localBuffer^[i] <> ch);
        
      if (nbCaracteresEnleves > 0) then
        begin
          for j := 0 to (len - 1 - nbCaracteresEnleves) do 
            localBuffer^[j] := localBuffer^[j+nbCaracteresEnleves];
          tailleBuffer := len-nbCaracteresEnleves;
        end;
    end;
end;

function ASeulementCeCaractere(c : char; var s : string) : boolean;
var len,i : SInt16; 
begin
  len := LENGTH_OF_STRING(s);
  if len<=0
    then 
      begin
        ASeulementCeCaractere := false;
        exit(ASeulementCeCaractere);
      end
    else
      begin
        for i := 1 to len do
          if s[i]<>c then
            begin
              ASeulementCeCaractere := false;
              exit(ASeulementCeCaractere);
            end;
        ASeulementCeCaractere := true;
      end;
end;

{Compte les occurences de la chaine subString dans s, sans recouvrement.
 Par exemple CompterOccurencesDeSousChaine('aa','aabaaa') renvoie 2 }
function CompterOccurencesDeSousChaine(const subString,s : str255) : SInt32;
var len,lensub,i,k : SInt32;
    occ : SInt32;
begin
  len := LENGTH_OF_STRING(s);
  lenSub := LENGTH_OF_STRING(subString);
  if (len <= 0) | (lensub <= 0)
    then 
      begin
        CompterOccurencesDeSousChaine := 0;
        exit(CompterOccurencesDeSousChaine);
      end
    else
      begin
        occ := 0;
        
        i := 1;
        
        while (i <= len-lensub+1) do
          begin
            k := 1;
            while (k <= lenSub) & (i+k-1 <= len) & (s[i+k-1] = subString[k]) do
             inc(k);
            
            if (k > lenSub) 
              then
                begin
                  inc(occ);
                  i := i + lensub;
                end
              else
                inc(i);
          end;
        
        CompterOccurencesDeSousChaine := occ;
      end;
end;


function DeleteSubstringAfterThisChar(theChar : char; const s : str255;keepTheChar : boolean) : str255;
var position : SInt16; 
begin
  position := Pos(theChar,s);
  if position > 0
    then 
      begin
        if keepTheChar
          then DeleteSubstringAfterThisChar := TPCopy(s,1,position)
          else DeleteSubstringAfterThisChar := TPCopy(s,1,position-1);
      end
    else DeleteSubstringAfterThisChar := s;
end;


function DeleteSubstringBeforeThisChar(theChar : char; const s : str255;keepTheChar : boolean) : str255;
var position : SInt16; 
begin
  position := Pos(theChar,s);
  if position > 0
    then 
      begin
        if keepTheChar
          then DeleteSubstringBeforeThisChar := TPCopy(s,position,Length(s)-position+1)
          else DeleteSubstringBeforeThisChar := TPCopy(s,position+1,Length(s)-position);
      end
    else DeleteSubstringBeforeThisChar := s;
end;



function PourcentageReelEnString(x : extended) : str255;
var aux : SInt32;
    s : str255;
begin
  aux := MyTrunc(100*Abs(x));
  NumToString(aux,s);
  if x<0 then s := Concat('-',s);
  PourcentageReelEnString := Concat(s,'%');
end;


{ReelEnString pour un reel qui doit etre entre 0.0 et 100.0 (avec une seule decimale) }
function ReelEnStringRapide(unreel : extended) : str255;
var aux : SInt32;
begin
  if unreel=100.0
   then ReelEnStringRapide := '100.0'
   else
     begin
       unreel := unreel+0.05;
       aux := MyTrunc(unreel);
       if aux<10
         then
           ReelEnStringRapide := Concat(chr((aux mod 10)+48),
                                     '.',
                                     chr(MyTrunc(10*(unreel-aux))+48))
         else
           ReelEnStringRapide := Concat(chr((aux div 10)+48),
                                      chr((aux mod 10)+48),
                                      '.',
                                      chr(MyTrunc(10*(unreel-aux))+48))
     end;
end;


{marche seulement pour les chaines au format aaaa.bbbbbb (pas aaaaa.bbbbbEEEEcc)
 et ne conserve que les 5 premieres decimales !}
function StringSimpleEnReel(alpha : str255) : extended;
var i : SInt16; 
    ChainePartieEntiere,ChainePartieDecimale,s : str255;
    partieEntiere,partieDecimale,mult : extended;
    aux,aux2 : SInt32;
begin
  if EstUnReel(alpha)
    then
      begin
        if Pos('.',alpha)=0 then
          begin
            i := Pos(',',alpha);  
            if i <> 0 then alpha[i] := '.';   {on remplace la virgule par un point}
          end;
          
          
        i := Pos('.',alpha);
        if i=0
          then 
            begin
              ChaineToLongint(alpha,aux);
              StringSimpleEnReel := 1.0*aux;
            end
          else
            begin
              ChainePartieEntiere := TPCopy(alpha,1,i-1);
              
              ChainePartieDecimale := TPCopy(alpha,i+1,Length(alpha)-i);
              for i := Length(ChainePartieDecimale)+1 to 7 do 
                ChainePartieDecimale := ChainePartieDecimale+'0';
              
              ChaineToLongint(ChainePartieEntiere,aux);
              partieEntiere := 1.0*aux;
              
              partieDecimale := 0.0;
              mult := 0.1;
              for i := 1 to 7 do
                begin
                  s := ChainePartieDecimale[i];
                  ChaineToLongint(s,aux2);
                  partieDecimale := partieDecimale + mult*aux2;
                  mult := mult * 0.1;
                end;
              
              StringSimpleEnReel := partieEntiere+partieDecimale;
            end;
      end
    else
      StringSimpleEnReel := 0.0;
end;


{NumToString pour un num qui doit etre entre 0 et 100}
function PourcentageEntierEnString(num : SInt32) : string;
begin
  if num=100
   then PourcentageEntierEnString := '100'
   else if num<10
         then PourcentageEntierEnString := chr((num mod 10)+48)
         else PourcentageEntierEnString := Concat(chr((num div 10)+48),chr((num mod 10)+48));
end;



function ReelEnString(unreel : extended) : str255;
var s,s1 : str255;
begin
  if unreel<0 then s := '-' else s := '';
  unreel := Abs(unreel);
  unreel := unreel+0.00499;
  NumToString(MyTrunc(unreel),s1);
  s := s+s1+StringOf('.');
  unreel := 10.0*(unreel-MyTrunc(unreel));
  NumToString(MyTrunc(unreel),s1);
  s := s+s1;
  unreel := 10.0*(unreel-MyTrunc(unreel));
  NumToString(MyTrunc(unreel),s1);
  s := s+s1;
  ReelEnString := s;
end;



function ReelEnStringAvecDecimales(unreel : extended;nbChiffresSignificatifs : SInt16) : str255;
var s,s1,s2 : str255;
    i,longueur : SInt32;
    nbUnites,nbMilliers,nbMillions,nbMilliards,nbBillions : SInt16; 
    dejaEcritDesChiffres : boolean;
begin
  
  if unreel<0 then s := '-' else s := '';
  unreel := Abs(unreel);
  
  dejaEcritDesChiffres := false;
  s1 := '';
  nbBillions := MyTrunc(unreel/1000000000000.0);
  if nbBillions>=1 then 
    begin
      s2 := NumEnString(nbBillions);
      s1 := s1+s2;
      dejaEcritDesChiffres := true;
      unreel := unreel- nbBillions*1000000000000.0;
    end;
  nbMilliards := MyTrunc(unreel/1000000000.0);
  if (nbMilliards=0) & (dejaEcritDesChiffres) then s1 := s1+'000' else
  if (nbMilliards>=1) then 
    begin
      s2 := NumEnString(nbMilliards);
      if (nbMilliards>=0)  & (nbMilliards<=9)  & dejaEcritDesChiffres then s2 := Concat('00',s2);
      if (nbMilliards>=10) & (nbMilliards<=99) & dejaEcritDesChiffres then s2 := Concat('0',s2);
      s1 := s1+s2;
      dejaEcritDesChiffres := true;
      unreel := unreel- nbMilliards*1000000000.0;
    end;
  nbMillions := MyTrunc(unreel/1000000.0);
  if (nbMillions=0) & (dejaEcritDesChiffres) then s1 := s1+'000' else
  if nbMillions>=1 then 
    begin
      s2 := NumEnString(nbMillions);
      if (nbMillions>=1)  & (nbMillions<=9)  & dejaEcritDesChiffres then s2 := Concat('00',s2);
      if (nbMillions>=10) & (nbMillions<=99) & dejaEcritDesChiffres then s2 := Concat('0',s2);
      s1 := s1+s2;
      dejaEcritDesChiffres := true;
      unreel := unreel- nbMillions*1000000.0;
    end;
  nbMilliers := MyTrunc(unreel/1000.0);
  if (nbMilliers=0) & (dejaEcritDesChiffres) then s1 := s1+'000' else
  if nbMilliers>=1 then 
    begin
      s2 := NumEnString(nbMilliers);
      if (nbMilliers>=1)  & (nbMilliers<=9)  & dejaEcritDesChiffres then s2 := Concat('00',s2);
      if (nbMilliers>=10) & (nbMilliers<=99) & dejaEcritDesChiffres then s2 := Concat('0',s2);
      s1 := s1+s2;
      dejaEcritDesChiffres := true;
      unreel := unreel- nbMilliers*1000.0;
    end;
  nbUnites := MyTrunc(unreel);
  if (nbUnites=0) & (dejaEcritDesChiffres) then s1 := s1+'000' else
  if (nbUnites>=0) then   { >=0 au lieu de >=1 car on veut ecrire 0.abc et non pas .abc}
    begin
      s2 := NumEnString(nbUnites);
      if (nbUnites>=1)  & (nbUnites<=9)  & dejaEcritDesChiffres then s2 := Concat('00',s2);
      if (nbUnites>=10) & (nbUnites<=99) & dejaEcritDesChiffres then s2 := Concat('0',s2);
      s1 := s1+s2;
      dejaEcritDesChiffres := true;
      unreel := unreel- nbUnites;
    end;
    
  longueur := Length(s1);
  if nbChiffresSignificatifs<1 then nbChiffresSignificatifs := 1;
  if nbChiffresSignificatifs>20 then nbChiffresSignificatifs := 20;
  if nbChiffresSignificatifs>longueur
    then s := s+s1+StringOf('.')
    else s := s+s1;
  for i := 1 to nbChiffresSignificatifs-longueur do
    begin
      unreel := 10.0*(unreel-MyTrunc(unreel));
      NumToString(MyTrunc(unreel),s1);
      s := s+s1;
    end;
  ReelEnStringAvecDecimales := s;
end;


procedure ChaineToInteger(const s : str255; var theInteger : SInt16);
var unlong : SInt32;
begin
  StringToNum(EnleveEspacesDeDroite(s),unlong);
  theInteger := unlong;
end;

procedure ChaineToLongint(const s : str255; var theLongint : SInt32);
var unlong : SInt32;
begin
  StringToNum(EnleveEspacesDeDroite(s),unlong);
  theLongint := unlong;
end;

function Hexa(num : SInt32) : string;
const chiffres = '0123456789ABCDEF';
var i : SInt16; 
    v : UInt32;
    s : str255;
begin
  s := '$';
  for i := 1 to 8 do
    begin
      v := BAND(BSR(num,(8-i)*4),$F);
      s := Concat(s,chiffres[v+1]);
    end;
  Hexa := s;
end;

function ChaineEnInteger(const s : str255) : SInt16; 
var unlong : SInt32;
begin
  StringToNum(EnleveEspacesDeDroite(s),unlong);
  ChaineEnInteger := unlong;
end;


function ChaineEnLongint(const s : str255) : SInt32;
var unlong : SInt32;
begin
  StringToNum(EnleveEspacesDeDroite(s),unlong);
  ChaineEnLongint := unlong;
end;


function SeparerLesChiffresParTrois(var s : str255) : string;
var len,i : SInt16; 
    result : str255;
begin
  result := '';
  len := LENGTH_OF_STRING(s);
  if len>0
    then
      begin
        i := len;
			  while i>3 do
			    begin
			      result := StringOf(' ') + s[i-2] + s[i-1] + s[i] + result;
			      i := i - 3;
			    end;
			  if i >= 3 
			    then SeparerLesChiffresParTrois := Concat(s[1],s[2],s[3],result) else
			  if i >= 2 
			    then SeparerLesChiffresParTrois := Concat(s[1],s[2],result) else
			  if i>=1
			    then SeparerLesChiffresParTrois := Concat(s[1],result);
      end
    else
      SeparerLesChiffresParTrois := '';
end;

function SecondesEnJoursHeuresSecondes(secondes : SInt32) : str255;
var s : str255;
    aux : SInt32;
    jours,heures : boolean;
begin
  s := '';
  if secondes>0
    then
      begin
        jours := false;
        if (secondes > 86400) then
          begin
            jours := true;
            aux := secondes div 86400;
            secondes := secondes - aux*86400;
            s := s + NumEnString(aux) + ' jours ';
          end;
        heures := false;
        if (secondes > 3600) | jours then
          begin
            heures := true;
            aux := secondes div 3600;
            secondes := secondes - aux*3600;
            s := s + NumEnString(aux) + ' h. ';
          end;
        if (secondes > 60) | heures then
          begin
            aux := secondes div 60;
            secondes := secondes - aux*60;
            s := s + NumEnString(aux) + ' min. ';
          end;
        s := s + NumEnString(secondes) + ' sec. ';
      end
    else
      begin
        s := NumEnString(secondes)+' sec.';
      end;
  SecondesEnJoursHeuresSecondes := s;
end;


function BufferToPascalString(buffer : Ptr;indexDepart,indexFin : SInt32) : str255;
type charArray = packed array[0..0] of char;
     charArrayPtr = ^charArray;
var s : str255;
    len,i : SInt32;
    localBuffer:charArrayPtr;
begin
  s := '';
  
  len := indexFin - indexDepart + 1;
  if len > 255 then len := 255;
  
  if len > 0 then
    begin
      localBuffer := charArrayPtr(buffer);
      for i := 0 to len - 1 do 
        s[i+1] := localBuffer^[indexDepart + i];
      s[0] := chr(len);
    end;
  
  BufferToPascalString := s;
end;

END.
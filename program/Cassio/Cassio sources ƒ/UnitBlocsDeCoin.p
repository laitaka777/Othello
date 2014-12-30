UNIT UnitBlocsDeCoin;




INTERFACE







USES UnitOth0;



type t_table_BlocsDeCoin = array[-3280..3280] of  SInt16;  {6560=3^8-1}
     tableBlocsDeCoinPtr= ^t_table_BlocsDeCoin;
var  valeurBlocsDeCoin:tableBlocsDeCoinPtr;

    { les puissances de 3 et leurs opposees }
    { puiss3 : array[0..9] of SInt16;  }
    { puiss3 est déjà déclaré dans UnitOth0  }
    { puiss3[i] = 3^(i-1)  , sauf puiss3[0]=0}
                                      
    coul1 : array[pionNoir..pionBlanc] of SInt16;
    coul3 : array[pionNoir..pionBlanc] of SInt16;
    coul9 : array[pionNoir..pionBlanc] of SInt16;
    coul27 : array[pionNoir..pionBlanc] of SInt16;
    coul81 : array[pionNoir..pionBlanc] of SInt16;
    coul243 : array[pionNoir..pionBlanc] of SInt16;
    coul729 : array[pionNoir..pionBlanc] of SInt16;
    coul2187 : array[pionNoir..pionBlanc] of SInt16;
    
    coulm1 : array[pionNoir..pionBlanc] of SInt16;
    coulm3 : array[pionNoir..pionBlanc] of SInt16;
    coulm9 : array[pionNoir..pionBlanc] of SInt16;
    coulm27 : array[pionNoir..pionBlanc] of SInt16;
    coulm81 : array[pionNoir..pionBlanc] of SInt16;
    coulm243 : array[pionNoir..pionBlanc] of SInt16;
    coulm729 : array[pionNoir..pionBlanc] of SInt16;
    coulm2187 : array[pionNoir..pionBlanc] of SInt16;
    
type t_codage=str8;
var equ_codage : array['0'..'2'] of SInt16;


procedure InitMaterielBlocsDeCoins;
function ValeurBlocsDeCoinPourNoir(var pl : plateauOthello) : SInt16; 
function ValeurBlocsDeCoinPourBlanc(var pl : plateauOthello) : SInt16; 
(*
procedure EcritCalculBlocsDeCoinSurDisque;
procedure EcritTablesBlocsDeCoinSurDisque(nomDesSegments : string);
procedure apprendBlocDeCoin(bloc : SInt16; gain : char);
procedure apprendBlocsDeCoinPosition(var pl : plateauOthello;gain : char);
*)



IMPLEMENTATION







USES Sound;

procedure InitMaterielBlocsDeCoins;
var i : SInt16; 
begin
  puiss3[0] := 0;
  puiss3[1] := 1;
  for i := 2 to kTailleMaximumPattern+1 do 
    puiss3[i] := 3*puiss3[i-1];
  
  coul1[pionVide] := 0;
  coul3[pionVide] := 0;
  coul9[pionVide] := 0;
  coul27[pionVide] := 0;
  coul81[pionVide] := 0;
  coul243[pionVide] := 0;
  coul729[pionVide] := 0;
  coul2187[pionVide] := 0;
  coul1[pionBlanc] := 1;
  coul3[pionBlanc] := 3;
  coul9[pionBlanc] := 9;
  coul27[pionBlanc] := 27;
  coul81[pionBlanc] := 81;
  coul243[pionBlanc] := 243;
  coul729[pionBlanc] := 729;
  coul2187[pionBlanc] := 2187;
  coul1[pionNoir] := -1;
  coul3[pionNoir] := -3;
  coul9[pionNoir] := -9;
  coul27[pionNoir] := -27;
  coul81[pionNoir] := -81;
  coul243[pionNoir] := -243;
  coul729[pionNoir] := -729;
  coul2187[pionNoir] := -2187;
  
  coulm1[pionVide] := 0;
  coulm3[pionVide] := 0;
  coulm9[pionVide] := 0;
  coulm27[pionVide] := 0;
  coulm81[pionVide] := 0;
  coulm243[pionVide] := 0;
  coulm729[pionVide] := 0;
  coulm2187[pionVide] := 0;
  coulm1[pionBlanc] := -1;
  coulm3[pionBlanc] := -3;
  coulm9[pionBlanc] := -9;
  coulm27[pionBlanc] := -27;
  coulm81[pionBlanc] := -81;
  coulm243[pionBlanc] := -243;
  coulm729[pionBlanc] := -729;
  coulm2187[pionBlanc] := -2187;
  coulm1[pionNoir] := 1;
  coulm3[pionNoir] := 3;
  coulm9[pionNoir] := 9;
  coulm27[pionNoir] := 27;
  coulm81[pionNoir] := 81;
  coulm243[pionNoir] := 243;
  coulm729[pionNoir] := 729;
  coulm2187[pionNoir] := 2187;
  
  equ_codage['0'] := 0;
  equ_codage['1'] := 1;
  equ_codage['2'] := -1;
end;


function ValeurBlocsDeCoinPourNoir(var pl : plateauOthello) : SInt16; 
var bloc1,bloc2,bloc3,bloc4 : SInt16; 
    bloc5,bloc6,bloc7,bloc8 : SInt16; 
begin
  bloc1 := -pl[11]+coulm3[pl[12]]+coulm9[pl[13]]+coulm27[pl[14]]
         +coulm81[pl[21]]+coulm243[pl[22]]+coulm729[pl[23]]+coulm2187[pl[24]];
  bloc2 := -pl[18]+coulm3[pl[17]]+coulm9[pl[16]]+coulm27[pl[15]]
         +coulm81[pl[28]]+coulm243[pl[27]]+coulm729[pl[26]]+coulm2187[pl[25]];
  bloc3 := -pl[81]+coulm3[pl[82]]+coulm9[pl[83]]+coulm27[pl[84]]
         +coulm81[pl[71]]+coulm243[pl[72]]+coulm729[pl[73]]+coulm2187[pl[74]];
  bloc4 := -pl[88]+coulm3[pl[87]]+coulm9[pl[86]]+coulm27[pl[85]]
         +coulm81[pl[78]]+coulm243[pl[77]]+coulm729[pl[76]]+coulm2187[pl[75]];
  bloc5 := -pl[11]+coulm3[pl[21]]+coulm9[pl[31]]+coulm27[pl[41]]
         +coulm81[pl[12]]+coulm243[pl[22]]+coulm729[pl[32]]+coulm2187[pl[42]];
  bloc6 := -pl[81]+coulm3[pl[71]]+coulm9[pl[61]]+coulm27[pl[51]]
         +coulm81[pl[82]]+coulm243[pl[72]]+coulm729[pl[62]]+coulm2187[pl[52]];
  bloc7 := -pl[18]+coulm3[pl[28]]+coulm9[pl[38]]+coulm27[pl[48]]
         +coulm81[pl[17]]+coulm243[pl[27]]+coulm729[pl[37]]+coulm2187[pl[47]];
  bloc8 := -pl[88]+coulm3[pl[78]]+coulm9[pl[68]]+coulm27[pl[58]]
         +coulm81[pl[87]]+coulm243[pl[77]]+coulm729[pl[67]]+coulm2187[pl[57]];  
 
  if (bloc1<-3280) | (bloc1>3280) |
     (bloc2<-3280) | (bloc2>3280) |
     (bloc3<-3280) | (bloc3>3280) |
     (bloc4<-3280) | (bloc4>3280) |
     (bloc5<-3280) | (bloc5>3280) |
     (bloc6<-3280) | (bloc6>3280) |
     (bloc7<-3280) | (bloc7>3280) |
     (bloc8<-3280) | (bloc8>3280)
     then SysBeep(0);
                
  ValeurBlocsDeCoinPourNoir := valeurBlocsDeCoin^[bloc1]+valeurBlocsDeCoin^[bloc2]+
                             valeurBlocsDeCoin^[bloc3]+valeurBlocsDeCoin^[bloc4]+
                             valeurBlocsDeCoin^[bloc5]+valeurBlocsDeCoin^[bloc6]+
                             valeurBlocsDeCoin^[bloc7]+valeurBlocsDeCoin^[bloc8];
end;


function ValeurBlocsDeCoinPourBlanc(var pl : plateauOthello) : SInt16; 
var bloc1,bloc2,bloc3,bloc4 : SInt16; 
    bloc5,bloc6,bloc7,bloc8 : SInt16; 
begin
  bloc1 := pl[11]+coul3[pl[12]]+coul9[pl[13]]+coul27[pl[14]]
         +coul81[pl[21]]+coul243[pl[22]]+coul729[pl[23]]+coul2187[pl[24]];
  bloc2 := pl[18]+coul3[pl[17]]+coul9[pl[16]]+coul27[pl[15]]
         +coul81[pl[28]]+coul243[pl[27]]+coul729[pl[26]]+coul2187[pl[25]];
  bloc3 := pl[81]+coul3[pl[82]]+coul9[pl[83]]+coul27[pl[84]]
         +coul81[pl[71]]+coul243[pl[72]]+coul729[pl[73]]+coul2187[pl[74]];
  bloc4 := pl[88]+coul3[pl[87]]+coul9[pl[86]]+coul27[pl[85]]
         +coul81[pl[78]]+coul243[pl[77]]+coul729[pl[76]]+coul2187[pl[75]];
  bloc5 := pl[11]+coul3[pl[21]]+coul9[pl[31]]+coul27[pl[41]]
         +coul81[pl[12]]+coul243[pl[22]]+coul729[pl[32]]+coul2187[pl[42]];
  bloc6 := pl[81]+coul3[pl[71]]+coul9[pl[61]]+coul27[pl[51]]
         +coul81[pl[82]]+coul243[pl[72]]+coul729[pl[62]]+coul2187[pl[52]];
  bloc7 := pl[18]+coul3[pl[28]]+coul9[pl[38]]+coul27[pl[48]]
         +coul81[pl[17]]+coul243[pl[27]]+coul729[pl[37]]+coul2187[pl[47]];
  bloc8 := pl[88]+coul3[pl[78]]+coul9[pl[68]]+coul27[pl[58]]
         +coul81[pl[87]]+coul243[pl[77]]+coul729[pl[67]]+coul2187[pl[57]];
  
  if (bloc1<-3280) | (bloc1>3280) |
     (bloc2<-3280) | (bloc2>3280) |
     (bloc3<-3280) | (bloc3>3280) |
     (bloc4<-3280) | (bloc4>3280) |
     (bloc5<-3280) | (bloc5>3280) |
     (bloc6<-3280) | (bloc6>3280) |
     (bloc7<-3280) | (bloc7>3280) |
     (bloc8<-3280) | (bloc8>3280)
     then SysBeep(0);
        
  ValeurBlocsDeCoinPourBlanc := valeurBlocsDeCoin^[bloc1]+valeurBlocsDeCoin^[bloc2]+
                              valeurBlocsDeCoin^[bloc3]+valeurBlocsDeCoin^[bloc4]+
                              valeurBlocsDeCoin^[bloc5]+valeurBlocsDeCoin^[bloc6]+
                              valeurBlocsDeCoin^[bloc7]+valeurBlocsDeCoin^[bloc8];
end;

(*
procedure EcritTablesBlocsDeCoinSurDisque(nomDesSegments : string);
var fichierBlocsDeCoin:TEXT;
    reply : SFReply;
    nomfichier,s : str255;
    i,compteurLignes,compteurProc : SInt16; 


     function nomKiemeprocedure(nom : str255;k : SInt16) : string;
     var s : str255;
     begin
       NumToString(k,s);
       nomKiemeprocedure := nom+StringOf('_')+s;
     end;

     procedure OuvreNouvelleprocedure(nom : str255);
     var s : str255;
     begin
       compteurProc := compteurProc+1;
       Writeln(fichierBlocsDeCoin,'');
       NumToString(compteurProc,s);
       Writeln(fichierBlocsDeCoin,'{$s '+nomDesSegments+s+StringOf('}'));
       Writeln(fichierBlocsDeCoin,'procedure '+nomKiemeprocedure(nom,compteurProc)+StringOf(';'));
       Writeln(fichierBlocsDeCoin,'begin');
     end;

     procedure Fermeprocedure;
     begin
       Writeln(fichierBlocsDeCoin,'');
       Writeln(fichierBlocsDeCoin,'end;');
     end;

begin
  nomfichier := 'sans titre';
  reply.fname := nomfichier;
  if MakeFileName(reply,'Nom du fichier ?',nomfichier) then
      begin
        SetFileCreator('CWIE'); 
        SetFileType('TEXT');
        
        compteurLignes := 1;
        compteurProc := 0;
        
        nomfichier := reply.fName;
        reWrite(fichierBlocsDeCoin,nomfichier);
        
        
        
        OuvreNouvelleprocedure(nomfichier);
        
        for i := -3280 to 3280 do
          begin
            if valeurBlocsDeCoin^[-i]<>-valeurBlocsDeCoin^[i] then 
              begin
                WriteStringAndNumAt(NumEnString(valeurBlocsDeCoin^[-i])+'<>',valeurBlocsDeCoin^[i],10,10);
                SysBeep(0);
              end;
            NumToString(i,s);
            Write(fichierBlocsDeCoin,'valeurBlocsDeCoin^[');
            Write(fichierBlocsDeCoin,s);
            Write(fichierBlocsDeCoin,'] := ');
            NumToString(valeurBlocsDeCoin^[i],s);
            if (i mod 3) = 0 
              then Writeln(fichierBlocsDeCoin,s+StringOf(';'))
              else Write(fichierBlocsDeCoin,s+StringOf(';'));
            if (i mod 3) = 0 then 
              begin
                compteurLignes := compteurLignes+1;
                if (compteurLignes mod 500) = 0 then
                  begin
                    Fermeprocedure;
                    OuvreNouvelleprocedure(nomfichier);
                  end;
              end;
          end;
          
          
          Fermeprocedure;
          
          Writeln(fichierBlocsDeCoin,'');
          Writeln(fichierBlocsDeCoin,'{$s '+nomDesSegments+StringOf('}'));
          
          Writeln(fichierBlocsDeCoin,'');
          Writeln(fichierBlocsDeCoin,'procedure '+nomfichier+StringOf(';'));
          Writeln(fichierBlocsDeCoin,'begin');
          for i := 1 to compteurProc do
            Writeln(fichierBlocsDeCoin,'  '+nomKiemeprocedure(nomfichier,i)+StringOf(';'));
          
          for i := 1 to compteurProc do
            Writeln(fichierBlocsDeCoin,'  UnloadSeg(@'+nomKiemeprocedure(nomfichier,i)+');');
          Writeln(fichierBlocsDeCoin,'end;');
          
        Close(fichierBlocsDeCoin);
      end;
end;



procedure apprendBlocDeCoin(bloc : SInt16; gain:str7);
begin
  nbOccurencesLigne8^[bloc] := nbOccurencesLigne8^[bloc]+1;
  if gain=CaracterePourBlanc then valeurBlocsDeCoin^[bloc] := valeurBlocsDeCoin^[bloc]+1 else
  if gain=CaracterePourNoir then valeurBlocsDeCoin^[bloc] := valeurBlocsDeCoin^[bloc]-1;
  if nbOccurencesLigne8^[bloc]>=30000 then
    begin
      nbOccurencesLigne8^[bloc] := nbOccurencesLigne8^[bloc] div 2;
      valeurBlocsDeCoin^[bloc] := valeurBlocsDeCoin^[bloc] div 2;
    end;
  
  nbOccurencesLigne8^[-bloc] := nbOccurencesLigne8^[-bloc]+1;
  if gain=CaracterePourBlanc then valeurBlocsDeCoin^[-bloc] := valeurBlocsDeCoin^[-bloc]-1 else
  if gain=CaracterePourNoir then valeurBlocsDeCoin^[-bloc] := valeurBlocsDeCoin^[-bloc]+1;
  if nbOccurencesLigne8^[-bloc]>=30000 then
    begin
      nbOccurencesLigne8^[-bloc] := nbOccurencesLigne8^[-bloc] div 2;
      valeurBlocsDeCoin^[-bloc] := valeurBlocsDeCoin^[-bloc] div 2;
    end;
    
end;


procedure apprendBlocsDeCoinPosition(var pl : plateauOthello;gain : char);
var bloc1,bloc2,bloc3,bloc4 : SInt16; 
    bloc5,bloc6,bloc7,bloc8 : SInt16; 
begin
  bloc1 := pl[11]+coul3[pl[12]]+coul9[pl[13]]+coul27[pl[14]]
         +coul81[pl[21]]+coul243[pl[22]]+coul729[pl[23]]+coul2187[pl[24]];
  bloc2 := pl[18]+coul3[pl[17]]+coul9[pl[16]]+coul27[pl[15]]
         +coul81[pl[28]]+coul243[pl[27]]+coul729[pl[26]]+coul2187[pl[25]];
  bloc3 := pl[81]+coul3[pl[82]]+coul9[pl[83]]+coul27[pl[84]]
         +coul81[pl[71]]+coul243[pl[72]]+coul729[pl[73]]+coul2187[pl[74]];
  bloc4 := pl[88]+coul3[pl[87]]+coul9[pl[86]]+coul27[pl[85]]
         +coul81[pl[78]]+coul243[pl[77]]+coul729[pl[76]]+coul2187[pl[75]];
  bloc5 := pl[11]+coul3[pl[21]]+coul9[pl[31]]+coul27[pl[41]]
         +coul81[pl[12]]+coul243[pl[22]]+coul729[pl[32]]+coul2187[pl[42]];
  bloc6 := pl[81]+coul3[pl[71]]+coul9[pl[61]]+coul27[pl[51]]
         +coul81[pl[82]]+coul243[pl[72]]+coul729[pl[62]]+coul2187[pl[52]];
  bloc7 := pl[18]+coul3[pl[28]]+coul9[pl[38]]+coul27[pl[48]]
         +coul81[pl[17]]+coul243[pl[27]]+coul729[pl[37]]+coul2187[pl[47]];
  bloc8 := pl[88]+coul3[pl[78]]+coul9[pl[68]]+coul27[pl[58]]
         +coul81[pl[87]]+coul243[pl[77]]+coul729[pl[67]]+coul2187[pl[57]];
  apprendBlocDeCoin(bloc1,gain);
  apprendBlocDeCoin(bloc2,gain);
  apprendBlocDeCoin(bloc3,gain);
  apprendBlocDeCoin(bloc4,gain);
  apprendBlocDeCoin(bloc5,gain);
  apprendBlocDeCoin(bloc6,gain);
  apprendBlocDeCoin(bloc7,gain);
  apprendBlocDeCoin(bloc8,gain);
end;




procedure EcritCalculBlocsDeCoinSurDisque;
var fichierBlocs:TEXT;
    reply : SFReply;
    nomfichier,s,s1,s2 : str255;
    i,j,k : SInt16; 
begin
  nomfichier := 'sans titre';
  reply.fname := nomfichier;
  if MakeFileName(reply,'Nom du fichier ?',nomfichier) then
      begin
        SetFileCreator('CWIE'); 
        SetFileType('TEXT');
        
        nomfichier := reply.fName;
        reWrite(fichierBlocs,nomfichier);
        
        
        Write(fichierBlocs,'bloc1 := ');
        k := 0;
        for i := 1 to 2 do
          for j := 1 to 4 do
            begin
              k := k+1;
              NumToString(puiss3[k],s1);
              NumToString(i*10+j,s2);
              if k>1 then Write(fichierBlocs,'+');
              if k=1
                then Write(fichierBlocs,'pl['+s2+StringOf(']'))
                else Write(fichierBlocs,'coul'+s1+'[pl['+s2+']]');
              if k=4 then Writeln(fichierBlocs,'');
              if k=4 then Write(fichierBlocs,'       ');
            end;
        Writeln(fichierBlocs,';');
        Write(fichierBlocs,'bloc2 := ');
        k := 0;
        for i := 1 to 2 do
          for j := 8 downto 5 do
            begin
              k := k+1;
              NumToString(puiss3[k],s1);
              NumToString(i*10+j,s2);
              if k>1 then Write(fichierBlocs,'+');
              if k=1
                then Write(fichierBlocs,'pl['+s2+StringOf(']'))
                else Write(fichierBlocs,'coul'+s1+'[pl['+s2+']]');
              if k=4 then Writeln(fichierBlocs,'');
              if k=4 then Write(fichierBlocs,'       ');
            end;
        Writeln(fichierBlocs,';');
        Write(fichierBlocs,'bloc3 := ');
        k := 0;
        for i := 8 downto 7 do
          for j := 1 to 4 do
            begin
              k := k+1;
              NumToString(puiss3[k],s1);
              NumToString(i*10+j,s2);
              if k>1 then Write(fichierBlocs,'+');
              if k=1
                then Write(fichierBlocs,'pl['+s2+StringOf(']'))
                else Write(fichierBlocs,'coul'+s1+'[pl['+s2+']]');
              if k=4 then Writeln(fichierBlocs,'');
              if k=4 then Write(fichierBlocs,'       ');
            end;
        Writeln(fichierBlocs,';');
        Write(fichierBlocs,'bloc4 := ');
        k := 0;
        for i := 8 downto 7 do
          for j := 8 downto 5 do
            begin
              k := k+1;
              NumToString(puiss3[k],s1);
              NumToString(i*10+j,s2);
              if k>1 then Write(fichierBlocs,'+');
              if k=1
                then Write(fichierBlocs,'pl['+s2+StringOf(']'))
                else Write(fichierBlocs,'coul'+s1+'[pl['+s2+']]');
              if k=4 then Writeln(fichierBlocs,'');
              if k=4 then Write(fichierBlocs,'       ');
            end;
        Writeln(fichierBlocs,';');
        Write(fichierBlocs,'bloc5 := ');
        k := 0;
        for i := 1 to 2 do
          for j := 1 to 4 do
            begin
              k := k+1;
              NumToString(puiss3[k],s1);
              NumToString(i+10*j,s2);
              if k>1 then Write(fichierBlocs,'+');
              if k=1
                then Write(fichierBlocs,'pl['+s2+StringOf(']'))
                else Write(fichierBlocs,'coul'+s1+'[pl['+s2+']]');
              if k=4 then Writeln(fichierBlocs,'');
              if k=4 then Write(fichierBlocs,'       ');
            end;
        Writeln(fichierBlocs,';');
        Write(fichierBlocs,'bloc6 := ');
        k := 0;
        for i := 1 to 2 do
          for j := 8 downto 5 do
            begin
              k := k+1;
              NumToString(puiss3[k],s1);
              NumToString(i+10*j,s2);
              if k>1 then Write(fichierBlocs,'+');
              if k=1
                then Write(fichierBlocs,'pl['+s2+StringOf(']'))
                else Write(fichierBlocs,'coul'+s1+'[pl['+s2+']]');
              if k=4 then Writeln(fichierBlocs,'');
              if k=4 then Write(fichierBlocs,'       ');
            end;
        Writeln(fichierBlocs,';');
        Write(fichierBlocs,'bloc7 := ');
        k := 0;
        for i := 8 downto 7 do
          for j := 1 to 4 do
            begin
              k := k+1;
              NumToString(puiss3[k],s1);
              NumToString(i+10*j,s2);
              if k>1 then Write(fichierBlocs,'+');
              if k=1
                then Write(fichierBlocs,'pl['+s2+StringOf(']'))
                else Write(fichierBlocs,'coul'+s1+'[pl['+s2+']]');
              if k=4 then Writeln(fichierBlocs,'');
              if k=4 then Write(fichierBlocs,'       ');
            end;
        Writeln(fichierBlocs,';');
        Write(fichierBlocs,'bloc8 := ');
        k := 0;
        for i := 8 downto 7 do
          for j := 8 downto 5 do
            begin
              k := k+1;
              NumToString(puiss3[k],s1);
              NumToString(i+10*j,s2);
              if k>1 then Write(fichierBlocs,'+');
              if k=1
                then Write(fichierBlocs,'pl['+s2+StringOf(']'))
                else Write(fichierBlocs,'coul'+s1+'[pl['+s2+']]');
              if k=4 then Writeln(fichierBlocs,'');
              if k=4 then Write(fichierBlocs,'       ');
            end;
        Writeln(fichierBlocs,';');
        
        
        
        
        Writeln(fichierBlocs,'');
        Writeln(fichierBlocs,'');
        Close(fichierBlocs);
      end;
end;
*)



end.
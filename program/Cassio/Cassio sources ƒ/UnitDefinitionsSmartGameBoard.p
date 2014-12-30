UNIT UnitDefinitionsSmartGameBoard;


INTERFACE







USES UnitZoneMemoire,UnitPositionEtTrait,UnitDefinitionsProperties;


var LectureSmartGameBoard :
      record
        compteurCaracteres             : SInt32;
        dernierCaractereLu             : char;
        avantDernierCaractereLu        : char;
        TheZoneMemoire                 : ZoneMemoire;
        QuitterLecture                 : boolean;
        EmboitementParentheses         : SInt32;
        profondeur                     : SInt32;
        ProprietesDeLaRacinesDejaLues  : boolean;
        thePosition                    : PositionEtTraitRec;
        buffer                         : packed array[0..4095] of char; 
        premierOctetDansBuffer         : SInt32;
        dernierOctetDansBuffer         : SInt32;
      end;

  EcritureSmartGameBoard :
    record
      TheZoneMemoire                   : ZoneMemoire;
      QuitterEcriture                  : boolean;
      DernierCaractereEcrit            : char;
      compteurCaracteres               : SInt32;
      EmboitementParentheses           : SInt32;
      profondeur                       : SInt32;
      ProprietesDeLaRacinesDejaEcrites : boolean;
      AvecPrettyPrinter                : boolean;
      CompteurDeCoupsNoirsEcrits       : SInt32;
      typesDePropertyAEcrire           : SetOfPropertyTypes;
    end;


procedure InitUnitDefinitionsSmartGameBoard;
procedure LibereMemoireUnitDefinitionsSmartGameBoard;


function PendantLectureFormatSmartGameBoard() : boolean;
function PendantEcritureFormatSmartGameBoard() : boolean;



IMPLEMENTATION







procedure InitUnitDefinitionsSmartGameBoard;
begin
  LectureSmartGameBoard.compteurCaracteres := 0;
  EcritureSmartGameBoard.compteurCaracteres := 0;
end;

procedure LibereMemoireUnitDefinitionsSmartGameBoard;
begin
end;

function PendantLectureFormatSmartGameBoard() : boolean;
begin
  PendantLectureFormatSmartGameBoard := (LectureSmartGameBoard.compteurCaracteres > 0);
end;

function PendantEcritureFormatSmartGameBoard() : boolean;
begin
  PendantEcritureFormatSmartGameBoard := (EcritureSmartGameBoard.compteurCaracteres > 0);
end;



END.
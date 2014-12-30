UNIT UnitSearchValues;




INTERFACE







USES MacTypes;

type  

     {le type suivant defini une valeur de retour minimax dont la representation 
      est privee : on ne doit y acceder que par les fonctions d'acces}
     
     SearchResult = record
                       minimax        : SInt32;
                       proofNumber    : extended;
                       disproofNumber : extended;
                    end;
     
     SearchWindow = record
                      alpha:SearchResult;
                      beta:SearchResult;
                    end;
     

function MakeSearchResultFromHeuristicValue(midgameValue : SInt32):SearchResult;
function MakeSearchResultForSolvedPosition(endgameScore : SInt32):SearchResult;
function InitialiseSearchResult():SearchResult;


procedure SetMinimaxValueInResult(value : SInt32; var myResult:SearchResult);
procedure SetProofNumberInResult(proof : extended; var myResult:SearchResult);
procedure SetDisproofNumberInResult(disproof : extended; var myResult:SearchResult);
function GetMinimaxValueOfResult(var myResult:SearchResult) : SInt32;
function GetProofNumberOfResult(var myResult:SearchResult) : extended;
function GetDisproofNumberOfResult(var myResult:SearchResult) : extended;
procedure SetProofAndDisproofNumberFromHeuristicValue(midgameValue : SInt32; var result:SearchResult);


function SearchResultEnMidgameEval(var result:SearchResult) : SInt32;
function GetWindowAlphaEnMidgameEval(var window:SearchWindow) : SInt32;
function GetWindowBetaEnMidgameEval(var window:SearchWindow) : SInt32;


function DecalerSearchResult(var myResult:SearchResult;midgameDecalage : SInt32):SearchResult;

function MakeSearchWindow(var alpha,beta:SearchResult):SearchWindow;
function MakeNullWindow(var v:SearchResult):SearchWindow;

function GetWindowAlpha(var window:SearchWindow):SearchResult;
function GetWindowBeta(var window:SearchWindow):SearchResult;



function FailSoltInWindow(var result:SearchResult; var window:SearchWindow) : boolean;
function FailHighInWindow(var result:SearchResult; var window:SearchWindow) : boolean;
function ResultInsideWindow(var result:SearchResult; var window:SearchWindow) : boolean;
function IsNullWindow(var window:SearchWindow) : boolean;

function AlphaBetaCut(var window:SearchWindow) : boolean;

function ReverseResult(var result:SearchResult):SearchResult;
function ReverseWindow(var window:SearchWindow):SearchWindow;

procedure UpdateSearchResult(var result:SearchResult; var valeurDuFils:SearchResult; var ameliorationMinimax,ameliorationProofNumber : boolean);
function UpdateSearchWindow(var value:SearchResult; var window:SearchWindow) : boolean;

 
IMPLEMENTATION







USES UnitOth0,Unit_AB_Simple;


procedure SetMinimaxValueInResult(value : SInt32; var myResult:SearchResult);
begin
  myResult.minimax := value;
end;

function GetMinimaxValueOfResult(var myResult:SearchResult) : SInt32;
begin
  GetMinimaxValueOfResult := myResult.minimax;
end;


procedure SetProofNumberInResult(proof : extended; var myResult:SearchResult);
begin
  myResult.proofNumber := proof;
end;

procedure SetDisproofNumberInResult(disproof : extended; var myResult:SearchResult);
begin
  myResult.disproofNumber := disproof;
end;

function GetProofNumberOfResult(var myResult:SearchResult) : extended;
begin
  GetProofNumberOfResult := myResult.proofNumber;
end;

function GetDisproofNumberOfResult(var myResult:SearchResult) : extended;
begin
  GetDisproofNumberOfResult := myResult.disproofNumber;
end;


procedure SetProofAndDisproofNumberFromHeuristicValue(midgameValue : SInt32; var result:SearchResult);
var PN,DN : extended;
begin
  quantumProofNumber            := 0.0;
  (* exponentialMappingProofNumber := ; {0.07;} *)
  
  PN := ProofNumberMapping(midgameValue, 0, exponentialMappingProofNumber);
  DN := ProofNumberMapping(-midgameValue,0, exponentialMappingProofNumber);
  
  SetProofNumberInResult(PN, result);
  SetDisproofNumberInResult(DN ,result);
end;


function MakeSearchResultFromHeuristicValue(midgameValue : SInt32):SearchResult;
var result:SearchResult;
begin
  SetMinimaxValueInResult(midgameValue,result);
  SetProofAndDisproofNumberFromHeuristicValue(midgameValue,result);
  MakeSearchResultFromHeuristicValue := result;
end;


function MakeSearchResultForSolvedPosition(endgameScore : SInt32):SearchResult;
var result:SearchResult;
begin
  if utilisationNouvelleEval
    then SetMinimaxValueInResult(100*endgameScore,result)
    else SetMinimaxValueInResult(500*endgameScore,result);
  
  if (endgameScore > 0)
    then
      begin
        SetProofNumberInResult(0.0, result);
        SetDisproofNumberInResult(1e50,result);
      end
    else
  if (endgameScore < 0)
    then
      begin
        SetProofNumberInResult(1e50, result);
        SetDisproofNumberInResult(0.0 ,result);
      end
    else
      begin
        SetProofNumberInResult(1.0, result);
        SetDisproofNumberInResult(1.0,result);
      end;
  
  MakeSearchResultForSolvedPosition := result;
end;


function InitialiseSearchResult():SearchResult;
var result:SearchResult;
begin
  SetMinimaxValueInResult(-32767,result);
  
  SetProofNumberInResult(1e50, result);
  SetDisproofNumberInResult(0.0 ,result);
  
  InitialiseSearchResult := result;
end;

function SearchResultEnMidgameEval(var result:SearchResult) : SInt32;
begin
  SearchResultEnMidgameEval := GetMinimaxValueOfResult(result);
end;

function GetWindowAlphaEnMidgameEval(var window:SearchWindow) : SInt32;
begin
  GetWindowAlphaEnMidgameEval := GetMinimaxValueOfResult(GetWindowAlpha(window));
end;

function GetWindowBetaEnMidgameEval(var window:SearchWindow) : SInt32;
begin
  GetWindowBetaEnMidgameEval := GetMinimaxValueOfResult(GetWindowBeta(window));
end;

function DecalerSearchResult(var myResult:SearchResult;midgameDecalage : SInt32):SearchResult;
var aux:SearchResult;
begin
  SetMinimaxValueInResult(GetMinimaxValueOfResult(myResult) + midgameDecalage,aux);
  DecalerSearchResult := aux;
end;

function MakeSearchWindow(var alpha,beta:SearchResult):SearchWindow;
var window:SearchWindow;
begin
  window.alpha := alpha;
  window.beta  := beta;
  MakeSearchWindow := window;
end;

function MakeNullWindow(var v:SearchResult):SearchWindow;
begin
  MakeNullWindow := MakeSearchWindow(MakeSearchResultFromHeuristicValue(GetMinimaxValueOfResult(v)),
                                     MakeSearchResultFromHeuristicValue(GetMinimaxValueOfResult(v)+1));
end;

function GetWindowAlpha(var window:SearchWindow):SearchResult;
begin
  GetWindowAlpha := window.alpha;
end;

function GetWindowBeta(var window:SearchWindow):SearchResult;
begin
  GetWindowBeta := window.beta;
end;


{renvoie true  sssi  v1 > v2}
function StriclyBetterSearchValue(var v1,v2:SearchResult) : boolean;
begin
  StriclyBetterSearchValue := GetMinimaxValueOfResult(v1) > GetMinimaxValueOfResult(v2);
end;

{renvoie true  sssi  result <= alpha}
function FailSoltInWindow(var result:SearchResult; var window:SearchWindow) : boolean;
begin
  FailSoltInWindow := not(StriclyBetterSearchValue(result,window.alpha));
end;

{renvoie true  sssi   result >= beta}
function FailHighInWindow(var result:SearchResult; var window:SearchWindow) : boolean;
begin
  FailHighInWindow := not(StriclyBetterSearchValue(window.beta,result));
end;

{renvoie true  sssi   alpha < result < beta}
function ResultInsideWindow(var result:SearchResult; var window:SearchWindow) : boolean;
begin
  ResultInsideWindow := StriclyBetterSearchValue(result, window.alpha) &
                        StriclyBetterSearchValue(window.beta, result);
end;

function IsNullWindow(var window:SearchWindow) : boolean;
begin
  IsNullWindow := ((GetMinimaxValueOfResult(window.beta) - GetMinimaxValueOfResult(window.alpha)) <= 1);
end;

function ReverseResult(var result:SearchResult):SearchResult;
var aux:SearchResult;
    proofNumber,disproofNumber : extended;
begin
  SetMinimaxValueInResult(-GetMinimaxValueOfResult(result),aux);
  
  {swap proof and disproof numbers}
  proofNumber    := GetProofNumberOfResult(result);
  disproofNumber := GetDisproofNumberOfResult(result);
  SetProofNumberInResult(disproofNumber,aux);
  SetDisproofNumberInResult(proofNumber,aux);
  
  ReverseResult := aux;
end;

function ReverseWindow(var window:SearchWindow):SearchWindow;
begin
  ReverseWindow := MakeSearchWindow(ReverseResult(GetWindowBeta(window)),
                                    ReverseResult(GetWindowAlpha(window)));
end;


function AlphaBetaCut(var window:SearchWindow) : boolean;
begin
  AlphaBetaCut := not(StriclyBetterSearchValue(window.beta,window.alpha));
end;

function UpdateSearchWindow(var value:SearchResult; var window:SearchWindow) : boolean;
begin
  UpdateSearchWindow := false;
  if StriclyBetterSearchValue(value,window.alpha) then
    begin
      UpdateSearchWindow := true;
      window.alpha := value;
    end;
end;

procedure UpdateSearchResult(var result:SearchResult; var valeurDuFils:SearchResult; var ameliorationMinimax,ameliorationProofNumber : boolean);
begin
  ameliorationMinimax := false;
  if StriclyBetterSearchValue(valeurDuFils,result) then
    begin
      SetMinimaxValueInResult(GetMinimaxValueOfResult(valeurDuFils),result);
      ameliorationMinimax := true;
    end;
  
  ameliorationProofNumber := false;
  if GetProofNumberOfResult(valeurDuFils) < GetProofNumberOfResult(result) then
    begin
      SetProofNumberInResult(GetProofNumberOfResult(valeurDuFils),result);
      ameliorationProofNumber := true;
    end;
  
  SetDisproofNumberInResult(GetDisproofNumberOfResult(result)+GetDisproofNumberOfResult(valeurDuFils),result);
end;


end.
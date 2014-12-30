UNIT UnitServicesDialogs;


INTERFACE







USES MacTypes;



procedure AlerteSimple(s : str255);
function MySimpleAlerte(alertID : SInt16; s : str255) : SInt16; 



IMPLEMENTATION







USES UnitDialog,UnitOth1,UnitOth2;


procedure AlerteSimple(s : str255);
const AlerteOKID=1130;
      ok=1;
var item : SInt16; 
    tempoDoitAjusterCurseur : boolean;
begin

  BeginDialog;
  ParamText(s,'','','');
  
  tempoDoitAjusterCurseur := doitAjusterCurseur;
  doitAjusterCurseur := false;
  
  item := MyAlert(AlerteOKID,FiltreClassiqueAlerteUPP,[ok]);
  
  doitAjusterCurseur := tempoDoitAjusterCurseur;
  EndDialog;
  
end;

function MySimpleAlerte(alertID : SInt16; s : str255) : SInt16; 
begin
  BeginDialog;
  ParamText(s,'','','');
  MySimpleAlerte := Alert(alertID,FiltreClassiqueAlerteUPP);
  EndDialog;
end;


END.
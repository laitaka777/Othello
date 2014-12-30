UNIT UnitTestHashing;


INTERFACE







USES UnitHashing;


procedure TestUnitHashing;

IMPLEMENTATION







USES UnitRapport;

procedure TestUnitHashing;
var s,s1,s2 : str255;
    aux,i : SInt32;
begin
  s:='tot';
  s1:='toto';
  s2:='toto est grand, pas grand, pas pas pas pas grand ¸¸¸¸¸';
  
  aux:=GenericHash(@s[0],length(s)+1);
  WritelnStringAndNumDansRapport('hasher '+s +' => ',aux);
  aux:=GenericHash(@s1[0],length(s1)+1);
  WritelnStringAndNumDansRapport('hasher '+s1 +' => ',aux);
  aux:=GenericHash(@s2[0],length(s2)+1);
  WritelnStringAndNumDansRapport('hasher '+s2 +' => ',aux);
  
  for i:=0 to length(s2) do
    begin
      s:=Copy(s2,1,i);
      aux:=GenericHash(@s[0],length(s)+1);
      WritelnStringAndNumDansRapport('hacher '+s +' => ',aux);
    end;
  
end;


END.
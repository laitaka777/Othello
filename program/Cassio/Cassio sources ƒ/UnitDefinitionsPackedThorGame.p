UNIT UnitDefinitionsPackedThorGame;


INTERFACE








USES MacTypes;


TYPE
  PackedThorGame =
    record
      theMoves : packed array[0..60] of UInt8;
    end;
  PackedThorGamePtr = ^PackedThorGame;
       
      
       
IMPLEMENTATION







END.
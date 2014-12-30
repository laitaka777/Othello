UNIT UnitBitField;



INTERFACE







USES MacTypes,UnitServicesMemoire;

type BitField = record
                  cardinal : SInt32;
                  data : array[0..0] of UInt32;
                end;

{Creation et destruction}

{Les fonctions du polymorphisme}

{fonction d'insertion et de suppression dans un ABR}

{Affichages}

{Iterateurs}

{Acces et tests sur les ABR}

{fonctions auxiliaires}

{Test de l'unite}

IMPLEMENTATION







USES MyMathUtils,UnitRapport;




END.
UNIT UnitDefinitionsProperties;



INTERFACE







uses MacTypes;

const
    UnknowProp                   = 0;
    
    {Propriétés définies dans la thèse de Kierulf}
    BlackMoveProp                = 1;
    WhiteMoveProp                = 2;
    CommentProp                  = 3;
    NodeNameProp                 = 4;
    NodeValueProp                = 5;
    GoodForBlackProp             = 6;
    GoodForWhiteProp 	           = 7;
    TesujiProp                   = 8;
    BadMoveProp                  = 9;
    TimeLeftBlackProp            = 10;
    TimeLeftWhiteProp            = 11;
    FigureProp                   = 12;
    AddBlackStoneProp            = 13;
    AddWhiteStoneProp            = 14;
    RemoveStoneProp              = 15;
    PlayerToPlayFirstProp        = 16;
    GameNameProp                 = 17;
    GameCommentProp              = 18;
    EventProp                    = 19;
    RoundProp                    = 20;
    DateProp                     = 21;
    PlaceProp                    = 22;
    BlackPlayerNameProp          = 23;
    WhitePlayerNameProp          = 24;
    ResultProp                   = 25;
    UserProp                     = 26;
    TimeLimitByPlayerProp        = 27;
    SourceProp                   = 28;
    GameNumberIDProp             = 29;
    BoardSizeProp                = 30;
    PartialViewProp              = 31;
    BlackSpeciesProp             = 32;
    WhiteSpeciesProp             = 33;
    ComputerEvaluationProp       = 34;
    ExpectedNextMoveProp         = 35;
    SelectedPointsProp           = 36;
    MarkedPointsProp             = 37;
    LabelOnPointsProp            = 38;    
    BlackRankProp                = 39;
    WhiteRankProp                = 40;
    HandicapProp                 = 41;
    KomiProp                     = 42;
    BlackTerritoryProp           = 43;
    WhiteTerritoryProp           = 44;
    SecureStonesProp             = 45;
    RegionOfTheBoardProp         = 46;    
    PerfectScoreProp             = 47;
    OptimalScoreProp             = 48;
    EmptiesForOptimalScoreProp   = 49;
    CheckMarkProp                = 50;
    
    {propriétés non définies dans la thèse de Kierulf, mais dont je suis "sûr"}
    WhiteTeamProp                = 51;
    BlackTeamProp                = 52;
    OpeningNameProp              = 53;
    FileFormatProp               = 54;
    FlippedProp                  = 55;
    DrawMarkProp                 = 56;
    InterestingMoveProp          = 57;
    DubiousMoveProp              = 58;
    DepthProp                    = 59;
    UnclearPositionProp          = 60;
    
    {propriétés définies par Cassio}
    DeltaWhiteProp               = 61;
    DeltaBlackProp               = 62;
    DeltaProp                    = 63;
    LosangeWhiteProp             = 64;
    LosangeBlackProp             = 65;
    LosangeProp                  = RegionOfTheBoardProp;
    CarreWhiteProp               = WhiteTerritoryProp;
    CarreBlackProp               = BlackTerritoryProp;
    CarreProp                    = 69;
    EtoileProp                   = 70;
    PetitCercleWhiteProp         = 71;
    PetitCercleBlackProp         = 72;
    PetitCercleProp              = 73;
    TranspositionProp            = 74;
    RapportProp                  = 75;
    WhitePassProp                = 76;
    BlackPassProp                = 77;
    ValueMinProp                 = 78;
    ValueMaxProp                 = 79;
    TimeTakenProp                = 80;
    SigmaProp                    = 81;
    ExoticMoveProp               = 82;
    
    {propriétés definies dans SGF FF[4], cf http://www.sbox.tu-graz.ac.at/home/h/hollosi/sgf}
    HotSpotProp                  = 83;  {Human opening ?}
    PDProp                       = 84;  {a quelque chose a voir avec "DepthProp" ?}
    ApplicationProp              = 85;
    CharSetProp                  = 86;
    StyleOfDisplayProp           = 87;
    DimPointsProp                = 88;
    CopyrightProp                = 89;
    AnnotatorProp                = 90;
    ArrowProp                    = 91;
    LineProp                     = 92;
    
    
    
    {autres proprietes, internes}
    MarquageProp                 = 93;  {property speciale de marquage temporaire}
    VerbatimProp                 = 94;  {property pour remettre exactement dans le fichier ce qu'on y a lu}
    PointeurPropertyProp         = 95;  {property pour stocker un Ptr sur le noeud, l'adresse et le rectangle d'affichage d'une autre property}
    FinVarianteProp              = 96;  {property pour stocker un Ptr sur le noeud de fin variante et le rectangle d'affichage de l'icone}
    EmbranchementProp            = 97;  {property pour stocker un Ptr sur le noeud d'embranchement et le rectangle d'affichage de l'icone}
    TranspositionRangeProp       = 98;  {property pour afficher "1/7" a cote du cycle}
    ZebraBookProp                = 99;  {property pour afficher les notes de la bibliothèque de Zebra}
    
    {attention : changer cette constante quand on ajoute de nouveaux types de property !!}
    nbMaxOfPropertyTypes         = 99;
    
    
    
    
    
    

type SetOfPropertyTypes=Set of 0..nbMaxOfPropertyTypes;
     Triple = record    {type pour les points d'exclamation (bons coups) et d'interrogation (mauvais coup)}
                nbTriples : SInt32;
              end;



const 
   StockageInconnu            = 0;
   StockageEnLongint          = 1;
   StockageEnReal             = 2;
   StockageEnStr255           = 3;
   StockageEnCaseOthello      = 4;
   StockageEnCaseOthelloAlpha = 5;
   StockageEnEnsembleDeCases  = 6;
   StockageEnTexte            = 7;
   StockageEnSeptCaracteres   = 8;
   StockageEnTriple           = 9;
   StockageEnBooleen          = 10;
   StockageEnChar             = 11;
   StockageArgumentVide       = 12;
   StockageEnValeurOthello    = 13;
   StockageEnCoupleLongint    = 14;
   StockageEnPtrProperty      = 15;
   StockageEnCoupleCases      = 16;
   StockageEnQuintuplet       = 17;
   StockageAutre              = 18;
   
const CoupSpecialPourPasse = -1;       
       

    
IMPLEMENTATION







end.

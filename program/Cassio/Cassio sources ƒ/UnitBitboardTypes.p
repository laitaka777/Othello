UNIT UnitBitboardTypes;


INTERFACE







USES ConditionalMacros,MacTypes,UnitOth0;

{$DEFINEC USING_BITBOARD   TRUE}
{$DEFINEC DEBUG_BITBOARD_ALPHA_BETA   FALSE}



type
  bitboard =
    record
      g_my_bits_low : UInt32;
      g_my_bits_high : UInt32;
      g_opp_bits_low : UInt32;
      g_opp_bits_high : UInt32;
    end;
  t_othellierBitboard_descr = 
      array[0..99] of 
		    record
		      isLow : boolean;
		      isHigh : boolean;
		      constanteHexa : UInt32;
		    end;

   
   listeCoupsAvecBitboard = array[0..99] of 
      		                      record
      		                        the_move     : SInt32;
      		                        the_parity   : SInt32;
      		                        the_score    : SInt32;
      		                        the_position  : bitboard;
      		                      end;
      		                      
var 
  othellierBitboardDescr : t_othellierBitboard_descr;



function EmptyBitboard():bitboard;
function MakeBitboard(my_low,my_high,opp_low,opp_hi : UInt32):bitboard;

{$IFC USING_BITBOARD}
procedure EcritBitboardDansRapport(s : string;position:bitboard);
procedure EcritBitboardState(s : string;position:bitboard;ESprof,alpha,beta,diffPions : SInt32);
{$ENDC}

IMPLEMENTATION







USES UnitRapport,UnitRapportImplementation,UnitMacExtras;





function EmptyBitboard():bitboard;
var result:bitboard;
begin
  with result do
    begin
      g_my_bits_low   := 0;
      g_my_bits_high  := 0;
      g_opp_bits_low  := 0;
      g_opp_bits_high := 0;
    end;
  EmptyBitboard := result;
end;

function MakeBitboard(my_low,my_high,opp_low,opp_hi : UInt32):bitboard;
var result:bitboard;
begin
  with result do
    begin
      g_my_bits_low   := my_low;
      g_my_bits_high  := my_high;
      g_opp_bits_low  := opp_low;
      g_opp_bits_high := opp_hi;
    end;
  MakeBitboard := result;
end;

{$IFC USING_BITBOARD}
procedure EcritBitboardDansRapport(s : string;position:bitboard);
var i,j,square : SInt32;
    v : UInt32;
    s1,s2,s3 : str255;
    estUneVraiePosition : boolean;
begin

 { On definit une vraie position comme une position ou
   les deux bitmaps dans position ne se superposent pas;
   Cela permet d'afficher ˆ droite les deux bitboard sous 
   une forme compacte (plus lisible) }
  
  with position do
    estUneVraiePosition := (BAND(g_my_bits_low,g_opp_bits_low)=0) &
                           (BAND(g_my_bits_high,g_opp_bits_high)=0);
  
  ChangeFontDansRapport(MonacoID);
  WritelnDansRapport(s);
  for j := 1 to 8 do
    begin
      s1 := '';
      s2 := '';
      s3 := '';
      for i := 1 to 8 do
        begin
          square := i + j*10;
          v := othellierBitboardDescr[square].constanteHexa;
          if othellierBitboardDescr[square].isLow
            then
              begin
                if (BAND(position.g_my_bits_low,v)=0) & (BAND(position.g_opp_bits_low,v)=0)
                  then
                    begin
                      s1 := s1 + '.';
                      s2 := s2 + '.';
                      s3 := s3 + '.';
                    end
                  else
                    begin
			                if BAND(position.g_my_bits_low,v)<>0
			                  then 
			                    begin
			                      s1 := s1 + 'X';
			                      s3 := s3 + 'X';
			                    end
			                  else s1 := s1 + '.';
			                if BAND(position.g_opp_bits_low,v)<>0
			                  then 
			                    begin
			                      s2 := s2 + 'O';
			                      s3 := s3 + 'O';
			                    end
			                  else s2 := s2 + '.';
			              end;
              end
            else
              begin
                if (BAND(position.g_my_bits_high,v)=0) & (BAND(position.g_opp_bits_high,v)=0)
                  then
                    begin
                      s1 := s1 + '.';
                      s2 := s2 + '.';
                      s3 := s3 + '.';
                    end
                  else
                    begin
			                if BAND(position.g_my_bits_high,v)<>0
			                  then 
			                    begin
			                      s1 := s1 + 'X';
			                      s3 := s3 + 'X';
			                    end
			                  else s1 := s1 + '.';
			                if BAND(position.g_opp_bits_high,v)<>0
			                  then 
			                    begin
			                      s2 := s2 + 'O';
			                      s3 := s3 + 'O';
			                    end
			                  else s2 := s2 + '.';
			              end;
              end;
        end;
      if estUneVraiePosition
        then WritelnDansRapport(s1 + '      ' + s2 + '      ' + s3)
        else WritelnDansRapport(s1 + '      ' + s2);
    end;
end;

procedure EcritBitboardState(s : string;position:bitboard;ESprof,alpha,beta,diffPions : SInt32);
begin
  SetDeroulementAutomatiqueDuRapport(true);
  WritelnDansRapport(s);
  WritelnStringAndNumDansRapport('ESProf = ',ESProf);
  WritelnStringAndNumDansRapport('diffPions = ',diffPions);
  WritelnStringAndNumDansRapport('alpha = ',alpha);
  WritelnStringAndNumDansRapport('beta = ',beta);
  EcritBitboardDansRapport('MY_BITS       OPP_BITS',position);
end;


{$ENDC}

END.
UNIT UnitBitboardHash;



INTERFACE







USES UnitBitboardTypes,UnitPositionEtTrait;


(* bitboards use the hash table heuristics *)
{$DEFINEC BITBOARD_USE_HASH_TABLE TRUE}


(* bitboards use the enhanced transposition cutoff heuristic *)
{$DEFINEC BITBOARD_USE_ENHANCED_TRANSPOSITION_CUTOFF FALSE }



{$IFC USING_BITBOARD}

type 
   BitboardHash = ^BitboardHashRec;
   BitboardHashRec = packed record
                             lower         : signedByte;
                             upper         : signedByte;
                             stored_move   : signedByte;
                             empties       : signedByte;
                             lock_my_low   : UInt32;
                             lock_my_high  : UInt32;
                             lock_opp_low  : UInt32;
                             lock_opp_high : UInt32;
                           end;
    
    BitboardHashEntry = ^BitboardHashEntryRec;             
    BitboardHashEntryRec = record
                             deepest : BitboardHashRec;
                             newest  : BitboardHashRec;
                           end;
    
    BitboardHashTable = ^BitboardHashTableRec;
    BitboardHashTableRec = 
                        record
                          hash_mask  : UInt32;
                          hash_entry : array[0..0] of BitboardHashEntryRec;
                        end;
    
var gBitboardHashTable : BitboardHashTable;
    
procedure InitUnitBitboardHash;
procedure LibereMemoireUnitBitboardHash;
function BITBOARD_HASH_TABLE_OK(hash_table:BitboardHashTable) : boolean;

procedure BitboardHashAllocate(var hash_table:BitboardHashTable; n_bits : SInt32);
procedure BitboardHashClear(hash_table:BitboardHashTable);
procedure BitboardHashDispose(var hash_table:BitboardHashTable);     

procedure BitboardHashUpdate(hash_table:BitboardHashTable;hash_index : UInt32;
                             pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
                             board_empties : SInt32;alpha,beta,score,move : SInt32);
function BitboardHashGet(hash_table:BitboardHashTable;pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32; var hash_index : UInt32):BitboardHash;
function GetEndgameValuesInBitboardHashTableForThisPosition(var plat : PositionEtTraitRec; var valMinPourNoir,valMaxPourNoir,bestMove : SInt32) : boolean;
                          
                          
 
procedure ChangeHashRandomization;
                         
                          
{$ENDC}


IMPLEMENTATION







USES UnitServicesMemoire,UnitRapport,UnitBitboardMobilite,UnitMacExtras;


{$IFC USING_BITBOARD}

(* infinite score: a huge value unreachable as a score and fitting in a char *)
const INF_SCORE = 127;


var gHashRandomization : UInt32;


procedure InitUnitBitboardHash;
begin
  gBitboardHashTable := NIL;
  if gIsRunningUnderMacOSX
    then BitboardHashAllocate(gBitboardHashTable,20)   {Attention : deja 40 megaoctets :-( }
    else BitboardHashAllocate(gBitboardHashTable,16);  {Attention : 2.5 megaoctets         }
end;


procedure LibereMemoireUnitBitboardHash;
begin
  if (gBitboardHashTable <> NIL) then
    BitboardHashDispose(gBitboardHashTable);
end;


function BITBOARD_HASH_TABLE_OK(hash_table:BitboardHashTable) : boolean;
begin
  BITBOARD_HASH_TABLE_OK := (hash_table <> NIL);
end;


procedure BitboardHashAllocate(var hash_table:BitboardHashTable;n_bits : SInt32);
var size_in_bytes : UInt32;
    nb_slots,i : UInt32;
begin
  if (hash_table <> NIL) then BitboardHashDispose(hash_table);
  
  nb_slots := 1;
  for i := 1 to n_bits do
    nb_slots := nb_slots * 2;
  
  size_in_bytes := SizeOf(BitboardHashEntryRec) * (nb_slots + 10);
  hash_table := BitboardHashTable(AllocateMemoryPtrClear(size_in_bytes));
  
  if hash_table <> NIL then
    begin
      hash_table^.hash_mask := nb_slots - 1;
      
      (*
      WritelnStringAndNumDansRapport('hash_table^.hash_mask = ',hash_table^.hash_mask);
      WritelnStringAndNumDansRapport('size_in_bytes = ',size_in_bytes);
      *)
      
    end;
end;


procedure BitboardHashClear(hash_table:BitboardHashTable);
var i : SInt32;
    init_entry:BitboardHashEntryRec;
begin
  if BITBOARD_HASH_TABLE_OK(hash_table) then
    with hash_table^ do
    begin
      with init_entry do
        begin
          deepest.lower         := -INF_SCORE;
          deepest.upper         :=  INF_SCORE;
          deepest.stored_move   := 0;
          deepest.empties       := 0;
          deepest.lock_my_low   := 0;
          deepest.lock_my_high  := 0;
          deepest.lock_opp_low  := 0;
          deepest.lock_opp_high := 0;
          
          newest := deepest;
        end;
      for i := 0 to hash_mask do
        hash_entry[i] := init_entry;
    end;
end;


procedure BitboardHashDispose(var hash_table:BitboardHashTable);
begin
	if (hash_table <> NIL) then
	  DisposeMemoryPtr(Ptr(hash_table));
end;


procedure BitboardHashUpdate(hash_table:BitboardHashTable;hash_index : UInt32;
                             pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32;
                             board_empties : SInt32;alpha,beta,score,move : SInt32);
var my_hash_entry : BitboardHashEntry;
    deepest,newest : BitboardHash;
begin

  if (hash_table <> NIL) then
    begin
    
      (* get the hash table entry *)
      my_hash_entry := @hash_table^.hash_entry[hash_index];
      deepest       := @my_hash_entry^.deepest;
      newest        := @my_hash_entry^.newest;
  
      (* try to update deepest entry *)
      with deepest^ do
    	  begin
    	    if (lock_my_low   = pos_my_bits_low)  & 
    	       (lock_my_high  = pos_my_bits_high) &
    	       (lock_opp_low  = pos_opp_bits_low) &
    	       (lock_opp_high = pos_opp_bits_high) then
        	  begin
          		if (score < beta)  & (score < upper) then upper := score;
          		if (score > alpha) & (score > lower) then lower := score;
          		stored_move := move;
          		exit(BitboardHashUpdate);
            end;
        end;
        
    	(* else try to update newest entry *)
    	with newest^ do
    	  begin
    	    if (lock_my_low   = pos_my_bits_low)  & 
    	       (lock_my_high  = pos_my_bits_high) &
    	       (lock_opp_low  = pos_opp_bits_low) &
    	       (lock_opp_high = pos_opp_bits_high) then
        	  begin
          		if (score < beta)  & (score < upper) then upper := score;
          		if (score > alpha) & (score > lower) then lower := score;
          		stored_move := move;
          		exit(BitboardHashUpdate);
            end;
        end;
        
    	(* else try to add to deepest entry *)
      if (deepest^.empties < board_empties) then
        with deepest^ do
      	  begin
        		if (newest^.empties < deepest^.empties) 
        		  then newest^ := deepest^;
        		lock_my_low   := pos_my_bits_low;
    	      lock_my_high  := pos_my_bits_high;
    	      lock_opp_low  := pos_opp_bits_low;
    	      lock_opp_high := pos_opp_bits_high;
        		empties       := board_empties;
        		stored_move   := move;
        		lower         := -INF_SCORE;
        		upper         := +INF_SCORE;
        		if (score < beta)  then upper := score;
        		if (score > alpha) then lower := score;
          end else
          
    	(* else add to newest entry *)
    	with newest^ do
      	begin
      		lock_my_low   := pos_my_bits_low;
    	    lock_my_high  := pos_my_bits_high;
    	    lock_opp_low  := pos_opp_bits_low;
    	    lock_opp_high := pos_opp_bits_high;
      		empties       := board_empties;
      		stored_move   := move;
      		lower         := -INF_SCORE;
      		upper         := +INF_SCORE;
      		if (score < beta)  then upper := score;
      		if (score > alpha) then lower := score;
      	end;
  end;
  
end;


function BitboardHashGet(hash_table:BitboardHashTable;pos_my_bits_low,pos_my_bits_high,pos_opp_bits_low,pos_opp_bits_high : UInt32; var hash_index : UInt32):BitboardHash;
var my_hash_entry:BitboardHashEntry;
begin
    
  if (hash_table <> NIL) then
    with hash_table^ do
      begin
    
        (* calculate the hash index and get the hash table entry *)
        hash_index := ((pos_my_bits_low * pos_opp_bits_high) + (pos_my_bits_high + pos_opp_bits_low)) and hash_mask;
        my_hash_entry := @hash_entry[hash_index];
        
        (* check deepest entry *)
        with my_hash_entry^.deepest do
      	  if (lock_my_low   = pos_my_bits_low)  & 
      	     (lock_my_high  = pos_my_bits_high) &
      	     (lock_opp_low  = pos_opp_bits_low) &
      	     (lock_opp_high = pos_opp_bits_high) then
          	begin
          	  BitboardHashGet := @hash_entry[hash_index].deepest;
          	  exit(BitboardHashGet);
          	end;
          	
        (* check newest entry *)
        with my_hash_entry^.newest do
      	  if (lock_my_low   = pos_my_bits_low)  & 
      	     (lock_my_high  = pos_my_bits_high) &
      	     (lock_opp_low  = pos_opp_bits_low) &
      	     (lock_opp_high = pos_opp_bits_high) then
          	begin
          	  BitboardHashGet := @hash_entry[hash_index].newest;
          	  exit(BitboardHashGet);
          	end;
    
      end;
  
  BitboardHashGet := NIL;
end;


function GetEndgameValuesInBitboardHashTableForThisPosition(var plat : PositionEtTraitRec; var valMinPourNoir,valMaxPourNoir,bestMove : SInt32) : boolean;
var theBitboard:bitboard;
    hash:BitboardHash;
    hash_table:BitboardHashTable;
    hash_index : UInt32;
begin
  GetEndgameValuesInBitboardHashTableForThisPosition := false;
  
  theBitboard := PositionEtTraitToBitboard(plat);
  
  with theBitboard do
    begin
      hash_table := gBitboardHashTable;
      hash := BitboardHashGet(hash_table,g_my_bits_low,g_my_bits_high,g_opp_bits_low,g_opp_bits_high,hash_index);
    	if (hash <> NIL) then
    	  with hash^ do
      	  begin
      	    GetEndgameValuesInBitboardHashTableForThisPosition := true;
      	    if GetTraitOfPosition(plat) = pionBlanc
      	      then
      	        begin
      	          valMinPourNoir := -upper;
      	          valMaxPourNoir := -lower;
      	        end
      	      else
      	        begin
      	          valMinPourNoir := lower;
      	          valMaxPourNoir := upper;
      	        end;
      		  bestmove := stored_move;
      		end;
    end;
  		
end;



procedure ChangeHashRandomization;
begin
  gHashRandomization := RandomLongint();
end;




{$ENDC}

END.
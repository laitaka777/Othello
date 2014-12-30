UNIT  UnitServicesMemoire;


INTERFACE







USES UnitServicesTypes,MacTypes;


{ Une macro pour fabriquer un pointeur : ce n'est pas la meme
  methode dans CodeWarrio et GNU Pascal }

{$definec MakeMemoryPointer( p )  Pointer((p)) }




{Allocation de Ptr et de Handle}
function AllocateMemoryPtr(whichSize : SInt32) : Ptr;
function AllocateMemoryHdl(whichSize : SInt32) : handle;

{Allocation de Ptr et de Handle, les blocs memoires sont remplis de zeros}
function AllocateMemoryPtrClear(whichSize : SInt32) : Ptr;
function AllocateMemoryHdlClear(whichSize : SInt32) : handle;

{Liberation des blocs memoire; les pointeurs sont remis a NIL ensuite}
procedure DisposeMemoryPtr(var whichPtr : Ptr);
procedure DisposeMemoryHdl(var whichHandle : handle);

{Remplissage d'un bloc de memoire par un caractere donné}
procedure MemoryFillChar(bufferPtr: univ PackedArrayOfCharPtr; byteCount: SInt32; caractere : char);

{Deplacement d'un bloc de memoire}
procedure MoveMemory(sourcePtr,destPtr: Ptr; byteCount: SInt32);


IMPLEMENTATION







USES MacMemory;


function AllocateMemoryPtr(whichSize : SInt32) : Ptr;
begin
  AllocateMemoryPtr := NewPtr(whichSize);
end; 


function AllocateMemoryHdl(whichSize : SInt32) : handle;
begin
  AllocateMemoryHdl := NewHandle(whichSize);
end;


function AllocateMemoryPtrClear(whichSize : SInt32) : Ptr;
begin
  AllocateMemoryPtrClear := NewPtrClear(whichSize);
end;


function AllocateMemoryHdlClear(whichSize : SInt32) : handle;
begin
  AllocateMemoryHdlClear := NewHandleClear(whichSize);
end;



procedure DisposeMemoryPtr(var whichPtr : Ptr);
begin
  DisposePtr(whichPtr);
  whichPtr := NIL;
end;


procedure DisposeMemoryHdl(var whichHandle : handle);
begin
  DisposeHandle(whichHandle);
  whichHandle := NIL;
end;


procedure MemoryFillChar(bufferPtr: univ PackedArrayOfCharPtr; byteCount: SInt32; caractere : char);
begin
	FillChar(bufferPtr^, byteCount, caractere);
end;


procedure MoveMemory(sourcePtr,destPtr : Ptr;byteCount : SInt32);
begin
  BlockMoveData(sourcePtr,destPtr,byteCount);
end;

END.


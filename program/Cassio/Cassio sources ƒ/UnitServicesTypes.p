UNIT UnitServicesTypes;


INTERFACE







{ Sur Macintosh, inclure le fichier "MacTypes.p" d'Apple}
USES  MacTypes;

TYPE 
		PackedArrayOfChar = packed array[0..0] of char;
		PackedArrayOfCharPtr = ^PackedArrayOfChar;


    
    CharArray = PACKED ARRAY [0..32000] OF CHAR;
    CharArrayPtr = ^CharArray;
    CharArrayHandle = ^CharArrayPtr;

{
    str255 = STRING[255];
    
    Byte = 0..255;
    SignedByte = -128..127;
    UInt8 = Byte;
    SInt8 = SignedByte;
    UInt16 = integer;
    SInt16 = integer;
    UInt32 = longint;
    SInt32 = longint;
    UniChar = UInt16;
    
    Ptr = ^SignedByte;
    Handle = ^Ptr;
    }

IMPLEMENTATION







END.
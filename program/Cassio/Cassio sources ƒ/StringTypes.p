UNIT StringTypes;


INTERFACE







  type 
    SetOfChar = SET OF CHAR;
    
  const 
    sizeofStr60=62;
  type 
     str2 = string[2];
     str3 = string[3];
     str5 = string[5];
     str7 = string[7];
     str8 = string[8]; 
     str10 = string[10];
     str16 = string[16];  
     str19 = string[19];
     str21 = string[21];
     str29 = string[29]; 
     str30 = string[30];
     str33 = string[33];
     str39 = string[39];
     str41 = string[41];
     str60 = string[60];
     str120 = string[120];
     str185 = string[185];
     str60Ptr = ^str60;
     str60Hdl = ^str60Ptr;
     str120Ptr = ^str120;
     str120Hdl = ^str120Ptr;


IMPLEMENTATION








END.
@echo -off
mode 80 24

cls
if exist .\efi\boot\bootx64.efi then
 .\efi\boot\bootx64.efi
 goto END
endif

if exist fs0:\efi\boot\bootx64.efi then
 fs0:
 efi\boot\bootx64.efi
 goto END
endif

if exist fs1:\efi\boot\bootx64.efi then
 fs1:
 efi\boot\bootx64.efi
 goto END
endif

if exist fs2:\efi\boot\bootx64.efi then
 fs2:
 efi\boot\bootx64.efi
 goto END
endif

if exist fs3:\efi\boot\bootx64.efi then
 fs3:
 efi\boot\bootx64.efi
 goto END
endif

if exist fs4:\efi\boot\bootx64.efi then
 fs4:
 efi\boot\bootx64.efi
 goto END
endif

if exist fs5:\efi\boot\bootx64.efi then
 fs5:
 efi\boot\bootx64.efi
 goto END
endif

if exist fs6:\efi\boot\bootx64.efi then
 fs6:
 efi\boot\bootx64.efi
 goto END
endif

if exist fs7:\efi\boot\bootx64.efi then
 fs7:
 efi\boot\bootx64.efi
 goto END
endif

 echo "Unable to find bootloader".
 
:END

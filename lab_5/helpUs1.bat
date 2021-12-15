@echo off
@set AsmSourceName=what
@if [%1]==[] goto :EXIST
@set AsmSourceName=%~dpn1
 
:EXIST
 
@set AsmSourceDir=
@set AsmSourceFullName=%AsmSourceDir%%AsmSourceName%
@del %AsmSourceFullName%.obj > NUL
@del %AsmSourceFullName%.lst > NUL
@del %AsmSourceFullName%.exe > NUL
@del %AsmSourceFullName%.com > NUL
@del %AsmSourceDir%*.obj > NUL
@del %AsmSourceDir%*.map > NUL
 
c:\masm32\bin\ml.exe /c /Fl /Sa %AsmSourceFullName%.asm %AsmSourceFullName%.obj
 
@if not exist %AsmSourceFullName%.obj goto FINISH
c:\masm32\bin\link16 /TINY %AsmSourceFullName%.obj,%AsmSourceFullName%.com,,,,
 
:FINISH
pause
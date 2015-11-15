@echo off
stack install --test
if %errorlevel% neq 0 exit /b %errorlevel%
for /f "delims=" %%a in ('stack path --local-bin-path') do @set BINPATH=%%a
strip %BINPATH%\pandoc.exe
strip %BINPATH%\pandoc-citeproc.exe
%BINPATH%\pandoc.exe -s -S ..\README -o README.html
if %errorlevel% neq 0 exit /b %errorlevel%
%BINPATH%\pandoc.exe -s ..\COPYING -t rtf -S -o COPYING.rtf
if %errorlevel% neq 0 exit /b %errorlevel%
copy ..\COPYRIGHT COPYRIGHT.txt
for /f "tokens=1-2 delims= " %%a in ('%BINPATH%\pandoc.exe --version') do (
  @set VERSION=%%b
  goto :next
  )
:next
if "%VERSION%" == "" (
  echo Error: could not determine version number.
  exit /b 1 
)
echo Detected version %VERSION%
echo Creating msi...
candle -dVERSION=%VERSION% -dBINPATH=%BINPATH% pandoc.wxs
if %errorlevel% neq 0 exit /b %errorlevel%
light  -sw1076 -ext WixUIExtension -ext WixUtilExtension -out pandoc-%VERSION%-windows.msi pandoc.wixobj
if %errorlevel% neq 0 exit /b %errorlevel%
echo Starting kSign: sign, then quit kSign to complete the build...
kSign

echo Copying to shared drive
copy pandoc-%VERSION%-windows.msi \\VBOXSVR\WindowsShared\

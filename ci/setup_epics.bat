rem Set the paths for the builds 
set PATH=C:\Strawberry\perl\bin;%PATH%
rem %PATH%

rem Execute the Visual Studio batch file for 64-bit builds
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" %VC_ARCH


@echo off
set EXE_NAME=example.exe
set EXAMPLE_OPTIONS=%1 %2 %3 %4 %5 %6 %7 %8 %9

set BUILD_OPT=-o:minimal
set BUILD_DEBUG=-debug
set COLLECTION=-collection:ffmpeg=../odin-ffmpeg
set BUILD_OPTIONS=-out=%EXE_NAME% %BUILD_OPT% %COLLECTION% %BUILD_DEBUG% -vet -strict-style -show-timings

odin build . %BUILD_OPTIONS% && ctime -begin example.ctm && example.exe %EXAMPLE_OPTIONS% && ctime -end example.ctm && del *.ctm
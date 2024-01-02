@echo off
color 0a
cd ..
echo BUILDING GAME
lime build android -D NO_PRECOMPILED_HEADERS
echo.
echo done.
pause
pwd
explorer.exe export\release\android\bin
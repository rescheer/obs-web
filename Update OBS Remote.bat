@echo off
echo getting latest code from git...
git fetch origin >NUL
git reset --hard origin/main >NUL
echo latest code fetched!
echo updating dependencies...
call npm ci >NUL 2>NUL
echo dependencies installed!
echo building application...
call npm run build >NUL
echo build completed!
set /p exitkey= "update successful! yayyy ok press any key to close this window"
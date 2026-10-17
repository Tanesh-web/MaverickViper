@echo off
title Maverick Viper - GlassFish Server Stopper
echo ========================================================
echo       MAVERICK VIPER - STOPPING GLASSFISH SERVER
echo ========================================================
echo.
set "JAVA_HOME=C:\Program Files\Java\jdk-21\jdk"
echo Stopping GlassFish domain1...
"D:\glassfish7\glassfish7\bin\asadmin.bat" stop-domain domain1
echo.
echo GlassFish Server stopped.
pause

@echo off
title Maverick Viper - GlassFish Server Starter
echo ========================================================
echo       MAVERICK VIPER - STARTING GLASSFISH SERVER
echo ========================================================
echo.
set "JAVA_HOME=C:\Program Files\Java\jdk-21\jdk"
echo Starting GlassFish domain1 on port 8081...
"D:\glassfish7\glassfish7\bin\asadmin.bat" start-domain domain1
echo.
echo ========================================================
echo   GlassFish is now RUNNING!
echo   Main Website: http://localhost:8081/MaverickViper/
echo   Admin Portal: http://localhost:8081/MaverickViper/admin-login.html
echo ========================================================
pause

@echo off
echo ========================================================
echo       MAVERICK VIPER - GITHUB PUSH ASSISTANT
echo ========================================================
echo.
echo Make sure you have created an empty repository on GitHub:
echo   https://github.com/new
echo (e.g., name: MaverickViper)
echo.
set /p REPO_URL="Enter your GitHub Repository URL (e.g. https://github.com/adityajamge/MaverickViper.git): "

if "%REPO_URL%"=="" (
    echo Error: No URL provided. Aborting.
    pause
    exit /b 1
)

echo.
echo [1/3] Setting git remote...
git remote remove origin >nul 2>&1
git remote add origin %REPO_URL%

echo [2/3] Ensuring branch is main...
git branch -M main

echo [3/3] Pushing code to GitHub...
git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo  SUCCESS! Your code is now live on GitHub!
    echo ========================================================
    echo Next step: Deploy on Render.com or Railway.app
) else (
    echo.
    echo ========================================================
    echo  PUSH FAILED! Check your GitHub login or URL.
    echo ========================================================
)
pause

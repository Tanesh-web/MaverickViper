@echo off
setlocal
echo ========================================================
echo       MAVERICK VIPER - GITHUB PUSH ASSISTANT
echo ========================================================
echo Target Repo: https://github.com/Tanesh-web/MaverickViper.git
echo.
echo Choose authentication method:
echo   [1] GitHub Browser Login (Opens your default browser to sign in)
echo   [2] Paste GitHub Personal Access Token (PAT)
echo.
set /p CHOICE="Enter 1 or 2 (Default is 1): "

if "%CHOICE%"=="2" (
    echo.
    echo To generate a token: https://github.com/settings/tokens
    echo Select 'Generate new token (classic)', tick 'repo', and copy the token.
    echo.
    set /p TOKEN="Paste your Personal Access Token: "
    if "%TOKEN%"=="" (
        echo Error: No token provided.
        pause
        exit /b 1
    )
    set REPO_URL=https://%TOKEN%@github.com/Tanesh-web/MaverickViper.git
) else (
    set REPO_URL=https://github.com/Tanesh-web/MaverickViper.git
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
    echo  Check it out at: https://github.com/Tanesh-web/MaverickViper
    echo ========================================================
    echo Next step: Deploy on Render.com or Railway.app
) else (
    echo.
    echo ========================================================
    echo  PUSH FAILED!
    echo  Make sure you are logged in as 'Tanesh-web'.
    echo ========================================================
)
pause

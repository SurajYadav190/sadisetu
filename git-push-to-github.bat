@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo        Shaadi Setu - Git GitHub Upload Script
echo        Repository: https://github.com/SurajYadav190/sadisetu.git
echo ========================================================
echo.

:: Initialize git repository if not present
if not exist ".git" (
    echo [1/5] Initializing Git repository...
    git init
) else (
    echo [1/5] Git repository already initialized.
)

:: Set default branch to main
echo [2/5] Setting branch to main...
git branch -M main

:: Configure remote origin
echo [3/5] Setting remote origin...
git remote remove origin 2>nul
git remote add origin https://github.com/SurajYadav190/sadisetu.git

:: Add all files
echo [4/5] Staging all project files (respecting .gitignore)...
git add .

:: Commit
echo [5/5] Committing code...
git commit -m "feat: complete Shaadi Setu platform (Spring Boot backend, Angular 21 admin dashboard, Flutter mobile app)"

:: Push to GitHub
echo.
echo Pushing to GitHub (main branch)...
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ========================================================
    echo [SUCCESS] All code successfully pushed to GitHub!
    echo Visit: https://github.com/SurajYadav190/sadisetu
    echo ========================================================
) else (
    echo.
    echo [NOTE] If remote contains existing files (e.g. README), try:
    echo        git pull origin main --rebase
    echo        git push -u origin main
)

pause

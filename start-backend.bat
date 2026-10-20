@echo off
echo ==============================================
echo   Starting Shaadi Setu Spring Boot 3 Backend
echo ==============================================
cd /d "%~dp0backend"
call mvnw.cmd spring-boot:run
pause

@echo off
setlocal enabledelayedexpansion

echo ====================================================
echo POSIX Shell Utils - Comprehensive Container Testing
echo ====================================================
echo.

set "OVERALL_SUCCESS=1"

echo Testing UBI (Red Hat Universal Base Image)
echo --------------------------------------------
cd /d "%~dp0\ubi"
call runTests.bat
if !ERRORLEVEL! neq 0 (
  echo ERROR: UBI tests failed
  set "OVERALL_SUCCESS=0"
) else (
  echo SUCCESS: UBI tests passed
)

echo.
echo Testing Alpine Linux
echo ---------------------
cd /d "%~dp0\alpine"
call runTests.bat
if !ERRORLEVEL! neq 0 (
  echo ERROR: Alpine tests failed
  set "OVERALL_SUCCESS=0"
) else (
  echo SUCCESS: Alpine tests passed
)

echo.
echo Testing Debian Linux
echo ---------------------
cd /d "%~dp0\debian"
call runTests.bat
if !ERRORLEVEL! neq 0 (
  echo ERROR: Debian tests failed
  set "OVERALL_SUCCESS=0"
) else (
  echo SUCCESS: Debian tests passed
)

echo.
echo ====================================================
echo Test Summary
echo ====================================================
if !OVERALL_SUCCESS! equ 1 (
  echo SUCCESS: All containerized tests passed!
  exit /b 0
) else (
  echo FAILURE: Some tests failed!
  exit /b 1
)

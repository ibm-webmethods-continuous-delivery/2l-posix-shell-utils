@echo off

echo Testing with Debian Linux (multiple shells)
docker compose run --rm test

echo.
echo Testing individual shells:
echo.

echo Testing with default /bin/sh (dash):
docker compose run --rm -e SHELL_TYPE=sh shell-test

echo.
echo Testing with bash:
docker compose run --rm -e SHELL_TYPE=bash shell-test

echo.
echo Testing with dash:
docker compose run --rm -e SHELL_TYPE=dash shell-test

echo.
echo All Debian tests completed.

@echo off

echo Testing with Alpine Linux (multiple shells)
docker compose run --rm test

echo.
echo Testing individual shells:
echo.

echo Testing with bash:
docker compose run --rm -e SHELL_TYPE=bash shell-test

echo.
echo Testing with dash:
docker compose run --rm -e SHELL_TYPE=dash shell-test

echo.
echo Testing with ash:
docker compose run --rm -e SHELL_TYPE=ash shell-test

echo.
echo All Alpine tests completed.

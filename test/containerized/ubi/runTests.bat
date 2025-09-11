@echo off

echo Testing with UBI Linux (bash-based)
docker compose run --rm test

echo.
echo Testing individual shells:
echo.

echo Testing with default /bin/sh (bash):
docker compose run --rm -e SHELL_TYPE=sh shell-test

echo.
echo Testing with bash:
docker compose run --rm -e SHELL_TYPE=bash shell-test

echo.
echo All UBI tests completed.
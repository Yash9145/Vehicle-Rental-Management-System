@echo off
echo Vehicle Rental Management System - MySQL setup
echo.
set /p MYSQLPWD=Enter MySQL root password:
mysql -u root -p%MYSQLPWD% < database\schema.sql
mysql -u root -p%MYSQLPWD% < database\seed.sql
mysql -u root -p%MYSQLPWD% < database\views.sql
mysql -u root -p%MYSQLPWD% < database\triggers.sql
mysql -u root -p%MYSQLPWD% < database\procedures.sql
echo.
echo Database setup finished. If there were errors, run the SQL files in MySQL Workbench.
pause

@ECHO OFF
REM FDNET.BAT — FreeDOS standard networking startup
REM Loads NE2000 packet driver and gets an IP via DHCP.
REM After this, you can use FTP, TELNET, PING, HTGET.

IF "%FDNET_ACTIVE%"=="1" GOTO ALREADY

SET MTCPCFG=C:\NET\MTCP.CFG

ECHO Loading NE2000 packet driver...
C:\NET\NE2000 0x60 3 0x300
IF ERRORLEVEL 1 GOTO DRVFAIL

ECHO.
ECHO Running DHCP...
C:\NET\DHCP
REM DHCP may fail to write config on read-only disks; that is OK
REM because MTCP.CFG ships with correct SLIRP defaults.

SET FDNET_ACTIVE=1
ECHO.
ECHO Network is ready. Available commands:
ECHO   FTP host            - Transfer files
ECHO   TELNET host [port]  - Remote terminal
ECHO   PING host           - Test connectivity
ECHO   HTGET url file      - Download from web
ECHO.
GOTO END

:ALREADY
ECHO Network support appears to be active.
GOTO END

:DRVFAIL
ECHO ERROR: Could not load NE2000 packet driver.
GOTO END

:END

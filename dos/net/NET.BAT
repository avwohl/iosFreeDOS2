@ECHO OFF
REM NET.BAT — Start NE2000 networking with SLIRP
REM Loads the packet driver and gets an IP via DHCP.
REM After this, you can use FTP, TELNET, PING, HTGET.

IF "%MTCPCFG%"=="" SET MTCPCFG=C:\NET\MTCP.CFG

ECHO Loading NE2000 packet driver...
C:\NET\NE2000 0x60 3 0x300
IF ERRORLEVEL 1 GOTO DRVFAIL

ECHO.
ECHO Getting IP address via DHCP...
C:\NET\DHCP
IF ERRORLEVEL 1 GOTO DHCPFAIL

ECHO.
ECHO Network is ready. Available commands:
ECHO   FTP host            - Transfer files
ECHO   TELNET host [port]  - Remote terminal
ECHO   PING host           - Test connectivity
ECHO   HTGET url file      - Download from web
ECHO.
GOTO END

:DRVFAIL
ECHO ERROR: Could not load NE2000 packet driver.
GOTO END

:DHCPFAIL
ECHO ERROR: DHCP failed. Check your network connection.
GOTO END

:END

@echo off
@rem ==============================
@rem  Combined WinkasEC + CLRemoServer launcher
@rem ==============================

@rem --- Sync time and prep drives ---
rem net time \\Serv2012 /set /yes
rem type F:\CLWINBIN\BAT\Wait.txt
rem if not exist M: net use M: \\192.168.1.251\D /persistent:no

@rem --- Update WinkasEC if needed ---
if exist F:\CLWinBin\UpdateExe\UpdateExe.A1 (
    copy /Y S:\CLWinBin\UpdateExe\WinkasEC.EXE S:\CLWinBin
    del S:\CLWinBin\UpdateExe\UpdateExe.A1
)

@rem --- Launch WinkasEC ---
start "" "S:\CLWinBin\WinkasEC.exe" S S 1 0

@rem --- Build today's date folder path ---
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set datestr=%datetime:~0,8%
set statuspath=S:\CLWinDev\Remote\%datestr%\Status

@echo Waiting for folder: %statuspath%

:WAITLOOP
if not exist "%statuspath%" (
    timeout /t 1 >nul
    goto WAITLOOP
)

@echo Status folder detected — launching CLRemoServer.exe...

@rem --- Update CLRemoServer if needed ---
if exist F:\CLWinBin\UpdateExe\UpdateExe.R5 (
    copy /Y S:\CLWinBin\UpdateExe\CLRemoServer.EXE S:\CLWinBin
    del S:\CLWinBin\UpdateExe\UpdateExe.R5
)

@rem --- Launch CLRemoServer ---
start "" "S:\CLWinBin\CLRemoServer.exe" S S 5 1

@echo Both applications launched successfully.
exit /b

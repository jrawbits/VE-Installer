@echo off

setlocal EnableExtensions
setlocal EnableDelayedExpansion

REM Use the required version to find Rscript
SET /P R_VERSION=<r.version
IF EXIST r-paths.bat CALL r-paths.bat

IF NOT DEFINED RSCRIPT (
	echo Finding R %R_VERSION%
	rem echo Finding Rscript...
	set ROOT_KEY=\Software\R-core\R\%R_VERSION%
	set MACHINE_KEY="HKLM!ROOT_KEY!"
	set USER_KEY="HKCU!ROOT_KEY!"
	set VALUE_NAME=InstallPath
	rem echo Looking in !MACHINE_KEY! for !VALUE_NAME!
	for /f "usebackq skip=2 tokens=1-2*" %%i in (`reg query !MACHINE_KEY! /v !VALUE_NAME! 2^>nul`) do set R_HOME=%%k
	rem echo R_HOME: "!R_HOME!"
	if [!R_HOME!] == [] (
		rem echo Not in HKLM...
		rem echo Looking in !USER_KEY! for !VALUE_NAME!
		for /f "usebackq skip=2 tokens=1-2*" %%x in (`reg query !USER_KEY! /v !VALUE_NAME! 2^>nul`) do set R_HOME=%%z
		rem echo R_HOME: "!R_HOME!"
	) else goto Found
	if [!R_HOME!] == [] (
		rem echo Not in HKCU either...
		echo R Version %R_VERSION% not found - Opening download page
		echo Install R and then run VisionEval.bat again
		start "" https://cran.r-project.org/bin/windows/base/old/%R_VERSION%
		EXIT /B 1
	)
	:Found
	set RSCRIPT="!R_HOME!\bin\Rscript.exe"
	set RGUI="!R_HOME!\bin\x64\Rgui.exe"
	echo SET R_HOME="!R_HOME!" >>r-paths.bat
	echo SET RSCRIPT=!RSCRIPT! >>r-paths.bat
	echo SET RGUI=!RGUI! >>r-paths.bat
) ELSE echo Loaded installed values

rem echo Found RSCRIPT %RSCRIPT%
rem echo Found R_HOME %R_HOME%
rem echo Found R_VERSION %R_VERSION%
rem echo And in the file:
rem type r-version.bat
%RSCRIPT% VisionEval.R
START %RGUI% VisionEval.RData

@ECHO OFF
:: SETLOCAL EnableDelayedExpansion is needed for passing variables
SETLOCAL EnableDelayedExpansion
:: Sets some paths
SET parentf=%~dp0
SET me=%~n0
SET filename=""
:: Sets log-file
SET log="%parentf%\%me%.log"
ECHO [%date%, %time%] %me% script started >> %log%

ECHO -------------------------------
:: Lists files in current folder
ECHO All dat files in the current folder and in sub-folders:
DIR /S /B *.dat
ECHO [%date%, %time%] files in working dir and sub-dir >> %log%
DIR /S /B *.dat >> %log%
ECHO -------------------------------
ECHO Files should be named like this:
ECHO 'PREFIX_INFIX_POSTFIX.dat' so e.g. 'ID_Experiment_Session.dat'
ECHO -------------------------------
:: setups subjects
SET sub=""
SET /P "sub=Enter subjects ID's you want to klusta [e.g. 10,20,11]: "
ECHO You typed following subjects:
ECHO %sub%
ECHO [%date%, %time%] Subjects %sub% >> %log%
ECHO -------------------------------
:: setups experiment
SET exp=""
SET /P "exp=Enter experiments you want to klusta [e.g. Random1000]: "
ECHO You typed following experiment:
ECHO %exp%
ECHO [%date%, %time%] Experiment %exp% >> %log%
ECHO -------------------------------
:: setups sessions
SET ses=""
SET /P "ses=Enter sessions you want to klusta [e.g. CC1,CC2,CC6]: "
ECHO You typed following sessions:
ECHO %ses%
ECHO [%date%, %time%] Sessions %ses% >> %log%
ECHO -------------------------------
:: setups probe-file
SET prb=""
SET /P "prb=Enter probe-file you're using [leave empty is using default]: "
IF %prb% == "" (
	ECHO No probe-file typed. Using default probe-file:
	SET prb=revisedAtlas32ch4shaft_default.prb
	ECHO !prb!
)
IF EXIST %prb% (
	ECHO Probe-file found
	ECHO Folowing probe-file is used:
	ECHO [%date%, %time%] Probe-file found: !prb! >> %log%
	ECHO !prb!
) ELSE (
	ECHO Probe-file NOT found
	ECHO File should be:
	ECHO [%date%, %time%] Probe-file NOT found: !prb! >> %log%
	ECHO !prb!
	ECHO Exiting...
	GOTO END
)
ECHO -------------------------------
:: setups klusta parameter file
SET prm=""
SET /P "prm=Enter Klusta parameter-file you're using [leave empty is using default]: "
IF %prm% == "" (
	ECHO No parameter-file typed. Using default prm-file:
	SET prm=klustaParam.prm
	ECHO !prm!
)
IF EXIST %prm% (
	ECHO Klusta parameter-file found
	ECHO Folowing prm-file is used:	
	ECHO [%date%, %time%] Prm-file found: !prm! >> %log%
	ECHO !prm!
) ELSE (
	ECHO Klusta parameter-file NOT found!
	ECHO File should be:
	ECHO [%date%, %time%] Prm-file NOT found: !prm! >> %log%
	ECHO !prm!
	ECHO Exiting...
	GOTO END
)
ECHO -------------------------------
::Print list of files
ECHO You're about to process these files:
FOR %%i IN (%sub%) DO (
	FOR %%y IN (%exp%) DO (
		FOR %%x IN (%ses%) DO (
			SET filename=%cd%\%%i\%%y\%%x\%%i_%%y_%%x.dat
			IF EXIST !filename! (
				ECHO !filename! File exist.		
				ECHO [%date%, %time%] !filename! File exist. >> %log%
			) ELSE (
				ECHO !filename! File NOT found.
				ECHO [%date%, %time%] !filename! File NOT found. >> %log%
			)
			
		)
	)
)
ECHO -------------------------------
::Print list of files
ECHO Everything OK? Enought disk space for Klusta?
SET cont=N
SET /P "cont=Do you want to kluster files (Y/[N])?"
IF /I "%cont%" NEQ "Y" GOTO END

::If yes, do this
ECHO -------------------------------
ECHO Copy probe and parameter files to folders...
ECHO [%date%, %time%] Copy .prb and .prm files to folders >> %log%
FOR %%i IN (%sub%) DO (
	FOR %%y IN (%exp%) DO (
		FOR %%x IN (%ses%) DO (
			SET filename=%cd%\%%i\%%y\%%x\%%i_%%y_%%x.dat
			IF EXIST !filename! (
				ECHO File exist.		
				ECHO [%date%, %time%] !filename! File exist. >> %log%
				:: Print klusta parameters to dat-file folder with correct name
				ECHO experiment_name = '%%i_%%y_%%x.dat' > "%cd%\%%i\%%y\%%x\%%i_%%y_%%x.prm"
				ECHO prb_file = '!prb!' >> "%cd%\%%i\%%y\%%x\%%i_%%y_%%x.prm"
				TYPE !prm! >> "%cd%\%%i\%%y\%%x\%%i_%%y_%%x.prm"
				:: Copy probe file to correct folder
				XCOPY !prb! "%cd%\%%i\%%y\%%x\"
			) ELSE (		
				ECHO [%date%, %time%] !filename! No file found >> %log%
				ECHO No file found. Exiting...
				GOTO END
			)
			
		)
	)
)
ECHO -------------------------------
ECHO Klusta stage...
ECHO [%date%, %time%] Klusta stage started >> %log%
ECHO Starting Klusta...
FOR %%i IN (%sub%) DO (
	FOR %%y IN (%exp%) DO (
		FOR %%x IN (%ses%) DO (
			SET filename=%cd%\%%i\%%y\%%x\%%i_%%y_%%x.prm
			IF EXIST !filename! (
				ECHO File exist.
				ECHO [%date%, %time%] Klusta started %cd%\%%i\%%y\%%x\%%i_%%y_%%x.prm  >> %log%
				CD %cd%\%%i\%%y\%%x\
				CALL activate klustaviewa				
				klusta "%cd%\%%i\%%y\%%x\%%i_%%y_%%x.prm"
				ECHO [%date%, %time%] Klusta finished %cd%\%%i\%%y\%%x\%%i_%%y_%%x.prm  >> %log%
				CALL deactivate
				CD %cd%
			) ELSE (		
				ECHO [%date%, %time%] !filename! No file found >> %log%
				ECHO No file found. Exiting...
				GOTO END
			)
			
		)
	)
)

::Exit
:END
ENDLOCAL
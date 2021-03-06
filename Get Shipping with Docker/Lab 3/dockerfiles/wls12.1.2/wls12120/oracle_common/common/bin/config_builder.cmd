@ECHO OFF
SETLOCAL

FOR /f %%i in ('cd') do set MYPWD=%%i

SET SCRIPT_PATH=%~dp0
FOR %%i IN ("%SCRIPT_PATH%") DO SET SCRIPT_PATH=%%~fsi

@REM Set the ORACLE_HOME relative to this script...
FOR %%i IN ("%SCRIPT_PATH%\..\..") DO SET ORACLE_HOME=%%~fsi

@REM Set the MW_HOME relative to the ORACLE_HOME...
FOR %%i IN ("%ORACLE_HOME%\..") DO SET MW_HOME=%%~fsi

@REM Set the home directories...
CALL "%SCRIPT_PATH%\setHomeDirs.cmd"

CALL "%SCRIPT_PATH%\commEnv.cmd"

SET CLASSPATH=%FMWCONFIG_CLASSPATH%;%DERBY_CLASSPATH%;%POINTBASE_CLASSPATH%

:PARSEARGS
SET VALIDATE=%2
FOR %%I IN (%VALIDATE%) DO SET VALIDATE=%%~I
if NOT {%1}=={} (
  IF "%VALIDATE:~0,1%"=="-" (
    ECHO ERROR! Missing equal^(=^) sign. Arguments must be -name=value!
    EXIT /B 1
  )
  IF "%VALIDATE%"=="" (
    ECHO ERROR! Missing value! Arguments must be -name=value!
    EXIT /B 1
  )
  GOTO :SETARG
) ELSE (
  GOTO :RUN
)

:SETARG
SET ARGNAME=%1
SET ARGVALUE=%2
SHIFT
SHIFT
FOR %%I IN (%ARGVALUE%) DO SET ARGVALUE=%%~I
IF /i "%ARGNAME%"=="-log" (
  IF "%ARGVALUE:~1,1%"==":" (
    SET ARGUMENTS=%ARGUMENTS% %ARGNAME%=%ARGVALUE% 
  ) ELSE (    
    SET ARGUMENTS=%ARGUMENTS% %ARGNAME%=%MYPWD%\%ARGVALUE%  
  )  
  GOTO :PARSEARGS
) ELSE (
  SET ARGUMENTS=%ARGUMENTS% %ARGNAME%=%ARGVALUE% 
  GOTO :PARSEARGS
)

:RUN
PUSHD %COMMON_COMPONENTS_HOME%\common\lib

IF EXIST %JAVA_HOME% (
  IF "%ARGUMENTS%" == "" (
    %JAVA_HOME%\bin\javaw %MEM_ARGS% -Dprod.props.file="%WL_HOME%\.product.properties" com.oracle.cie.wizard.WizardController -target=template %ARGUMENTS%
  ) ELSE (
    %JAVA_HOME%\bin\java %MEM_ARGS% -Dprod.props.file="%WL_HOME%\.product.properties" com.oracle.cie.wizard.WizardController -target=template %ARGUMENTS%
  )
) ELSE (
  CALL :SET_RC 1
)

SET RETURN_CODE=%ERRORLEVEL%

POPD

IF DEFINED USE_CMD_EXIT (
  EXIT %RETURN_CODE%
) ELSE (
  EXIT /B %RETURN_CODE%
)

:SET_RC
EXIT /B %1

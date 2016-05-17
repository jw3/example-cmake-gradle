@echo off

set JAVA_HOME="C:\Program Files (x86)\Java\jdk1.8.0_73"
set JAVA_EXEC=%JAVA_HOME%\bin\java

set PATH=%JAVA_HOME%\jre\bin;%PATH%

echo %JAVA_HOME%

cmake

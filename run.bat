@echo off

set JAVA_HOME="C:\Program Files (x86)\Java\jdk1.8.0_73"
set JAVA_EXEC=%JAVA_HOME%\bin\java

set PATH=%JAVA_HOME%\jre\bin;%PATH%

echo %JAVA_HOME%
%JAVA_EXEC% -cp build\libs\example-cmake-gradle-0.1-SNAPSHOT.jar -Djava.library.path="C:/Users/wassj/.CLion15/system/cmake/generated/example-cmake-990d7a36/990d7a36/Debug1" example.Example

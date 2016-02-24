cmake_minimum_required(VERSION 3.4)
project(example_cmake)

find_package(Java REQUIRED)
find_package(JNI REQUIRED)
include(UseJava)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set (_stubDir "${CMAKE_CURRENT_BINARY_DIR}")
add_custom_command(
        OUTPUT Example.h
        COMMAND ${Java_JAVAH_EXECUTABLE} -verbose
        -classpath ${_classDir}
        -d ${_stubDir}
        -jni JNIFoo
)


include_directories(${JAVA_INCLUDE_PATH} ${_classDir} ${_stubDir})
add_library(example MODULE Example.cpp Example.h)
set_target_properties(example PROPERTIES SUFFIX ".jnilib")
target_link_libraries(example ${JNI_LIBRARIES})

cmake_minimum_required(VERSION 3.4)
project(example_cmake)

find_package(Java)
find_package(JNI)
include(UseJava)

#message (STATUS "JNI_INCLUDE_DIRS=${JNI_INCLUDE_DIRS}")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set (_classes "${PROJECT_SOURCE_DIR}/build/classes/main")
set (_jnih "${PROJECT_SOURCE_DIR}/build/jnih")
add_custom_command(
        OUTPUT Example.h
        COMMAND ${Java_JAVAH_EXECUTABLE} -verbose
        -classpath ${_classes}
        -d ${_jnih}
        example.Example
)


include_directories(${JAVA_INCLUDE_PATH} ${JNI_INCLUDE_DIRS} ${_jnih})
add_library(example MODULE src/main/cpp/Example.cpp Example.h)
set_target_properties(example PROPERTIES SUFFIX ".jnilib")
target_link_libraries(example ${JNI_LIBRARIES})

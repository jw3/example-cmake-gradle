#.rst:
# FindJNI
# -------
#
# Find JNI java libraries.
#
# This module finds if Java is installed and determines where the
# include files and libraries are.  It also determines what the name of
# the library is.  The caller may set variable JAVA_HOME to specify a
# Java installation prefix explicitly.
#
# This module sets the following result variables:
#
# ::
#
#   JNI_INCLUDE_DIRS      = the include dirs to use
#   JNI_LIBRARIES         = the libraries to use
#   JNI_FOUND             = TRUE if JNI headers and libraries were found.
#   JAVA_AWT_LIBRARY      = the path to the jawt library
#   JAVA_JVM_LIBRARY      = the path to the jvm library
#   JAVA_INCLUDE_PATH     = the include path to jni.h
#   JAVA_INCLUDE_PATH2    = the include path to jni_md.h
#   JAVA_AWT_INCLUDE_PATH = the include path to jawt.h

#=============================================================================
# Copyright 2001-2009 Kitware, Inc.
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

# Expand {libarch} occurences to java_libarch subdirectory(-ies) and set ${_var}
macro(java_append_library_directories _var)
    # Determine java arch-specific library subdir
    # Mostly based on openjdk/jdk/make/common/shared/Platform.gmk as of openjdk
    # 1.6.0_18 + icedtea patches. However, it would be much better to base the
    # guess on the first part of the GNU config.guess platform triplet.
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
        if(CMAKE_LIBRARY_ARCHITECTURE STREQUAL "x86_64-linux-gnux32")
            set(_java_libarch "x32" "amd64" "i386")
        else()
            set(_java_libarch "amd64" "i386")
        endif()
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^i.86$")
        set(_java_libarch "i386")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^alpha")
        set(_java_libarch "alpha")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^arm")
        # Subdir is "arm" for both big-endian (arm) and little-endian (armel).
        set(_java_libarch "arm")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^mips")
        # mips* machines are bi-endian mostly so processor does not tell
        # endianess of the underlying system.
        set(_java_libarch "${CMAKE_SYSTEM_PROCESSOR}" "mips" "mipsel" "mipseb" "mips64" "mips64el" "mipsn32" "mipsn32el")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(powerpc|ppc)64le")
        set(_java_libarch "ppc64" "ppc64le")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(powerpc|ppc)64")
        set(_java_libarch "ppc64" "ppc")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(powerpc|ppc)")
        set(_java_libarch "ppc")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^sparc")
        # Both flavours can run on the same processor
        set(_java_libarch "${CMAKE_SYSTEM_PROCESSOR}" "sparc" "sparcv9")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^(parisc|hppa)")
        set(_java_libarch "parisc" "parisc64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^s390")
        # s390 binaries can run on s390x machines
        set(_java_libarch "${CMAKE_SYSTEM_PROCESSOR}" "s390" "s390x")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^sh")
        set(_java_libarch "sh")
    else()
        set(_java_libarch "${CMAKE_SYSTEM_PROCESSOR}")
    endif()

    # Append default list architectures if CMAKE_SYSTEM_PROCESSOR was empty or
    # system is non-Linux (where the code above has not been well tested)
    if(NOT _java_libarch OR NOT (CMAKE_SYSTEM_NAME MATCHES "Linux"))
        list(APPEND _java_libarch "i386" "amd64" "ppc")
    endif()

    # Sometimes ${CMAKE_SYSTEM_PROCESSOR} is added to the list to prefer
    # current value to a hardcoded list. Remove possible duplicates.
    list(REMOVE_DUPLICATES _java_libarch)

    foreach(_path ${ARGN})
        if(_path MATCHES "{libarch}")
            foreach(_libarch ${_java_libarch})
                string(REPLACE "{libarch}" "${_libarch}" _newpath "${_path}")
                list(APPEND ${_var} "${_newpath}")
            endforeach()
        else()
            list(APPEND ${_var} "${_path}")
        endif()
    endforeach()
endmacro()

SET(CMAKE_FIND_LIBRARY_SUFFIXES ".dll")
include(${CMAKE_ROOT}/Modules/CMakeFindJavaCommon.cmake)

# Save CMAKE_FIND_FRAMEWORK
if(DEFINED CMAKE_FIND_FRAMEWORK)
    set(_JNI_CMAKE_FIND_FRAMEWORK ${CMAKE_FIND_FRAMEWORK})
else()
    unset(_JNI_CMAKE_FIND_FRAMEWORK)
endif()

if(_JAVA_HOME_EXPLICIT)
    set(CMAKE_FIND_FRAMEWORK NEVER)
endif()

set(JAVA_AWT_LIBRARY_DIRECTORIES)
if(_JAVA_HOME)
    JAVA_APPEND_LIBRARY_DIRECTORIES(JAVA_AWT_LIBRARY_DIRECTORIES
            ${_JAVA_HOME}/jre/bin
            )
endif()
get_filename_component(java_install_version
        "[HKEY_LOCAL_MACHINE\\SOFTWARE\\JavaSoft\\Java Development Kit;CurrentVersion]" NAME)

list(APPEND JAVA_AWT_LIBRARY_DIRECTORIES
        )
JAVA_APPEND_LIBRARY_DIRECTORIES(JAVA_AWT_LIBRARY_DIRECTORIES
        )

set(JAVA_JVM_LIBRARY_DIRECTORIES)
foreach(dir ${JAVA_AWT_LIBRARY_DIRECTORIES})
    list(APPEND JAVA_JVM_LIBRARY_DIRECTORIES
            "${dir}"
            "${dir}/client"
            "${dir}/server"
            # IBM SDK, Java Technology Edition, specific paths
            "${dir}/j9vm"
            "${dir}/default"
            )
endforeach()

set(JAVA_AWT_INCLUDE_DIRECTORIES)
if(_JAVA_HOME)
    list(APPEND JAVA_AWT_INCLUDE_DIRECTORIES ${_JAVA_HOME}/include)
endif()
list(APPEND JAVA_AWT_INCLUDE_DIRECTORIES
        )

foreach(JAVA_PROG "${JAVA_RUNTIME}" "${JAVA_COMPILE}" "${JAVA_ARCHIVE}")
    get_filename_component(jpath "${JAVA_PROG}" PATH)
    foreach(JAVA_INC_PATH ../include ../java/include ../share/java/include)
        if(EXISTS ${jpath}/${JAVA_INC_PATH})
            list(APPEND JAVA_AWT_INCLUDE_DIRECTORIES "${jpath}/${JAVA_INC_PATH}")
        endif()
    endforeach()
    foreach(JAVA_LIB_PATH
            ../lib ../jre/lib ../jre/lib/i386
            ../java/lib ../java/jre/lib ../java/jre/lib/i386
            ../share/java/lib ../share/java/jre/lib ../share/java/jre/lib/i386)
        if(EXISTS ${jpath}/${JAVA_LIB_PATH})
            list(APPEND JAVA_AWT_LIBRARY_DIRECTORIES "${jpath}/${JAVA_LIB_PATH}")
        endif()
    endforeach()
endforeach()

if(APPLE)
    if(CMAKE_FIND_FRAMEWORK STREQUAL "ONLY")
        set(_JNI_SEARCHES FRAMEWORK)
    elseif(CMAKE_FIND_FRAMEWORK STREQUAL "NEVER")
        set(_JNI_SEARCHES NORMAL)
    elseif(CMAKE_FIND_FRAMEWORK STREQUAL "LAST")
        set(_JNI_SEARCHES NORMAL FRAMEWORK)
    else()
        set(_JNI_SEARCHES FRAMEWORK NORMAL)
    endif()
    set(_JNI_FRAMEWORK_JVM NAMES JavaVM)
    set(_JNI_FRAMEWORK_JAWT "${_JNI_FRAMEWORK_JVM}")
else()
    set(_JNI_SEARCHES NORMAL)
endif()

set(_JNI_NORMAL_JVM
        NAMES jvm
        PATHS ${JAVA_JVM_LIBRARY_DIRECTORIES}
        )

set(_JNI_NORMAL_JAWT
        NAMES jawt
        PATHS ${JAVA_AWT_LIBRARY_DIRECTORIES}
        )

foreach(search ${_JNI_SEARCHES})
    find_library(JAVA_JVM_LIBRARY ${_JNI_${search}_JVM})
    find_library(JAVA_AWT_LIBRARY ${_JNI_${search}_JAWT})
    if(JAVA_JVM_LIBRARY)
        break()
    endif()
endforeach()
unset(_JNI_SEARCHES)
unset(_JNI_FRAMEWORK_JVM)
unset(_JNI_FRAMEWORK_JAWT)
unset(_JNI_NORMAL_JVM)
unset(_JNI_NORMAL_JAWT)

# Find headers matching the library.
if("${JAVA_JVM_LIBRARY};${JAVA_AWT_LIBRARY};" MATCHES "(/JavaVM.framework|-framework JavaVM);")
    set(CMAKE_FIND_FRAMEWORK ONLY)
else()
    set(CMAKE_FIND_FRAMEWORK NEVER)
endif()

# add in the include path
find_path(JAVA_INCLUDE_PATH jni.h
        ${JAVA_AWT_INCLUDE_DIRECTORIES}
        )

find_path(JAVA_INCLUDE_PATH2 jni_md.h
        ${JAVA_INCLUDE_PATH}
        ${JAVA_INCLUDE_PATH}/darwin
        ${JAVA_INCLUDE_PATH}/win32
        ${JAVA_INCLUDE_PATH}/linux
        ${JAVA_INCLUDE_PATH}/freebsd
        ${JAVA_INCLUDE_PATH}/openbsd
        ${JAVA_INCLUDE_PATH}/solaris
        ${JAVA_INCLUDE_PATH}/hp-ux
        ${JAVA_INCLUDE_PATH}/alpha
        )

find_path(JAVA_AWT_INCLUDE_PATH jawt.h
        ${JAVA_INCLUDE_PATH}
        )

# Restore CMAKE_FIND_FRAMEWORK
if(DEFINED _JNI_CMAKE_FIND_FRAMEWORK)
    set(CMAKE_FIND_FRAMEWORK ${_JNI_CMAKE_FIND_FRAMEWORK})
    unset(_JNI_CMAKE_FIND_FRAMEWORK)
else()
    unset(CMAKE_FIND_FRAMEWORK)
endif()

include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(JNI  DEFAULT_MSG  JAVA_AWT_LIBRARY JAVA_JVM_LIBRARY
        JAVA_INCLUDE_PATH  JAVA_INCLUDE_PATH2 JAVA_AWT_INCLUDE_PATH)

mark_as_advanced(
        JAVA_AWT_LIBRARY
        JAVA_JVM_LIBRARY
        JAVA_AWT_INCLUDE_PATH
        JAVA_INCLUDE_PATH
        JAVA_INCLUDE_PATH2
)

set(JNI_LIBRARIES
        ${JAVA_AWT_LIBRARY}
        ${JAVA_JVM_LIBRARY}
        )

set(JNI_INCLUDE_DIRS
        ${JAVA_INCLUDE_PATH}
        ${JAVA_INCLUDE_PATH2}
        ${JAVA_AWT_INCLUDE_PATH}
        )

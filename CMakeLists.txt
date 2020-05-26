cmake_minimum_required(VERSION 3.10)

# set the project name
project(teensy_loader_cli C)

# find the current architecture
include(${CMAKE_CURRENT_LIST_DIR}/cmake/TargetArch.cmake)
target_architecture(TARGET_ARCH)

if(${TARGET_ARCH} STREQUAL "i386")
    set(TARGET_ARCH "x86")
endif()

if(WIN32)
    set(TARGET_SYSTEM_PREFIX "win")
    if(TARGET_ARCH STREQUAL "unknown")
        string(TOLOWER ${CMAKE_VS_PLATFORM_NAME} TARGET_ARCH)
    endif()
elseif(APPLE)
    set(TARGET_SYSTEM_PREFIX "macos")
else()
    string(TOLOWER ${CMAKE_SYSTEM_NAME} TARGET_SYSTEM_PREFIX)
endif()

# set output path to bin/os-arch folder
set(ARCH_DIR_NAME ${TARGET_SYSTEM_PREFIX}-${TARGET_ARCH})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/bin/${ARCH_DIR_NAME})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_CURRENT_LIST_DIR}/bin/${ARCH_DIR_NAME})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_CURRENT_LIST_DIR}/bin/${ARCH_DIR_NAME})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/lib/${ARCH_DIR_NAME})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_CURRENT_LIST_DIR}/lib/${ARCH_DIR_NAME})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_CURRENT_LIST_DIR}/lib/${ARCH_DIR_NAME})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/lib/${ARCH_DIR_NAME})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${CMAKE_CURRENT_LIST_DIR}/lib/${ARCH_DIR_NAME})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_CURRENT_LIST_DIR}/lib/${ARCH_DIR_NAME})

# add the executable target
add_executable(teensy_loader_cli teensy_loader_cli.c)

# project generator options
if(APPLE)
    option(USE_APPLE_IOKIT "Uses the Apple IOKit framework instead of libusb" ON)
endif()

# set target preprocessor definitions
if(WIN32)
    target_compile_definitions(teensy_loader_cli PRIVATE "WIN32" "_CRT_SECURE_NO_WARNINGS" "_CRT_NONSTDC_NO_DEPRECATE" "USE_WIN32")
elseif(APPLE)
    if(USE_APPLE_IOKIT)
        target_compile_definitions(teensy_loader_cli PRIVATE "USE_APPLE_IOKIT")
    else()
        set(USE_LIBUSB TRUE)
        target_compile_definitions(teensy_loader_cli PRIVATE "USE_LIBUSB" "MACOSX")
    endif()
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(USE_LIBUSB TRUE)
    target_compile_definitions(teensy_loader_cli PRIVATE "USE_LIBUSB")
else()
    target_compile_definitions(teensy_loader_cli PRIVATE "USE_UHID")
endif()

# if using libusb, search for libusb path
# and add its include path and link the usb lib
if(USE_LIBUSB)
    if(APPLE)
        find_path(LIBUSB_INCLUDE_DIR NAMES usb.h PATH_SUFFIXES "include")
    else()
        find_path(LIBUSB_INCLUDE_DIR NAMES libusb.h PATH_SUFFIXES "include" "libusb" "libusb-1.0")
    endif()
    find_library(LIBUSB_LIBRARY NAMES usb PATH_SUFFIXES "lib" "lib32" "lib64" )
    target_include_directories(teensy_loader_cli PRIVATE ${LIBUSB_INCLUDE_DIR})
    target_link_libraries(teensy_loader_cli ${LIBUSB_LIBRARY})
elseif(USE_APPLE_IOKIT)
    find_library(APPLE_CORE_FOUNDATION CoreFoundation)
    find_library(APPLE_IO_KIT IOKit)
    target_link_libraries(teensy_loader_cli ${APPLE_IO_KIT} ${APPLE_CORE_FOUNDATION})
elseif(WIN32)
    target_include_directories(teensy_loader_cli PRIVATE unistd-win32)
    target_sources(teensy_loader_cli PRIVATE unistd-win32/getopt.c)
    target_link_libraries(teensy_loader_cli hid setupapi winmm)
endif()

# configure compiler options
if(MSVC)
    target_compile_options(teensy_loader_cli PRIVATE /W4 /WX)
elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
    target_compile_options(teensy_loader_cli PRIVATE -s -Wall -Wextra -pedantic -Werror)
endif()

if(WIN32)
    add_custom_command(TARGET teensy_loader_cli POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE:teensy_loader_cli>" "${CMAKE_CURRENT_LIST_DIR}/bin/$<TARGET_FILE_NAME:teensy_loader_cli>")
else()
    add_custom_command(TARGET teensy_loader_cli POST_BUILD COMMAND ${CMAKE_COMMAND} -E create_symlink "$<TARGET_FILE:teensy_loader_cli>" "${CMAKE_CURRENT_LIST_DIR}/bin/$<TARGET_FILE_NAME:teensy_loader_cli>")
endif()
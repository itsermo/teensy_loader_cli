cmake_minimum_required(VERSION 3.10)

# set the project name
project(teensy_loader_cli C)

# add the executable
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
elseif(${CMAKE_SYSTEM} MATCHES "Linux")
    set(USE_LIBUSB TRUE)
    target_compile_definitions(teensy_loader_cli PRIVATE "USE_LIBUSB")
else()
message(FATAL_ERROR "${CMAKE_SYSTEM}")
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
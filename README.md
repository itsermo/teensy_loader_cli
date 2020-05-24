# Teensy Loader - Command Line Version (CMake Edition) #

The Teensy Loader is available in a command line version for advanced users who want to automate programming, typically using a Makefile. For most uses, the graphical version in Automatic Mode is much easier. 

http://www.pjrc.com/teensy/loader_cli.html

The command line version is provided as source code for most platforms. To compile, you must have gcc or visual studio installed.

* Note: * This version uses CMake to generate projects, and builds on Visual Studio/Windows platforms with no need for mingw.  In order to support Visual Studio, we have added some POSIX compatibility code (`getopt.h` and `unistd.h`) in the folder `unistd-win32`.

## Compiling From Source (Windows & Visual Studio)

1. Install Visual Studio 2019 with
  - The latest C++ x86/x64/ARM/ARM64 build tools (as determined by your platform)
  - The Windows SDK required by the Windows Driver Development Kit (WinDDK).  As of today, that version is Windows 10 SDK (10.0.19041.1)
2. Install the Windows Driver Development Kit - https://docs.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk
3. Install latest CMake tools - https://cmake.org/download/
4. Generate the project using CMake gui or command line as follows:
    
    `cmake -B build-x64 -A x64` (substitute x64 with Win32, ARM, or ARM64 for your target platform)
 
5. Open the solution from the new `build-x64` folder using Visual Studio or with the command:
  
    `cmake -open ./build-x64`
  
6. You can build from Visual Studio, or just use this command to build directly without the need for opening the solution:
  
    `cmake --build ./build-x64 --config Release`
  
## Compiling From Source (Linux)

1. On Ubuntu, you may need to install "libusb-dev" to compile:

    `sudo apt-get install libusb-dev`

Other Linux systems may [require other package installation](https://forum.pjrc.com/threads/40965-Linux-64bit-Arduino-1-6-13-Issues-starting-Teensy-Loader-and-libusb-0-1-so-4-error?p=127873&viewfull=1#post127873) to compile.

2. Use CMake to generate the project:

    `cmake -B build-linux`
  
3. Run the build using CMake:

    `cmake --build ./build-linux --config Release`
  
3. OR run the make command yourself from the `build-linux` folder:

    `cd build-linux`
    `make`
  
## Compiling From Source (macOS)

There are two ways to compile on macOS.  You can compile using Apple's IOKit framework to handle USB flashing, or you can use libusb (which requires an install of homebrew).  The most straightforward method is to use Apple's IOKit framework, which is enabled by default in the CMakeLists.txt under the CMake flag `USE_APPLE_IOKIT`.

### macOS IOKit Method (easier if you already have XCode & CMake installed)

You must first install XCode and/or XCode Command Line Tools & CMake.  You can use the CMake GUI to configure and build the project, or run commands from terminal (make sure `cmake` command is in your path):

1. Open Terminal and in the teensy_loader_cli folder run the command

    `cmake -B build-macos`
    
    by default, the CMake command line generator will generate a Unix Makefile.  That's ok and can be used.  Alternatively you can create an XCode project if you prefer:
    
    `cmake -b build-macos -G "Xcode"
    
2. Build using the command

     `cmake --build ./build-macos --config Release`

### macOS libusb Method

1. Install homebrew by typing this command into the terminal

    `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`
    
2. Use homebrew package manager to install cmake and libusb

   `brew install cmake libusb`
   
3. Open Terminal and in the teensy_loader_cli folder run the command
    
    `cmake -B build-macos -DUSE_APPLE_IOKIT=OFF`
    
4. Build using the command

     `cmake --build ./build-macos --config Release`

## Usage and Command Line Options

A typical usage from the command line may look like this:

`teensy_loader_cli --mcu=mk20dx256 -w blink_slow_Teensy32.hex`

Required command line parameters:

```
--mcu=<MCU> : Specify Processor. You must specify the target processor. This syntax is the same as used by gcc, which makes integrating with your Makefile easier. Valid options are:
--mcu=imxrt1062 : 	Teensy 4.0
--mcu=mk66fx1m0 : 	Teensy 3.6
--mcu=mk64fx512 : 	Teensy 3.5
--mcu=mk20dx256 : 	Teensy 3.2 & 3.1
--mcu=mk20dx128 : 	Teensy 3.0
--mcu=mkl26z64 : 	Teensy LC
--mcu=at90usb1286 : 	Teensy++ 2.0
--mcu=atmega32u4 : 	Teensy 2.0
--mcu=at90usb646 : 	Teensy++ 1.0
--mcu=at90usb162 : 	Teensy 1.0
```

Caution: HEX files compiled with USB support must be compiled for the correct chip. If you load a file built for a different chip, often it will hang while trying to initialize the on-chip USB controller (each chip has a different PLL-based clock generator). On some PCs, this can "confuse" your USB port and a cold reboot may be required to restore USB functionality. When a Teensy has been programmed with such incorrect code, the reset button must be held down BEFORE the USB cable is connected, and then released only after the USB cable is fully connected.

Optional command line parameters:

`-w` : Wait for device to appear. When the pushbuttons has not been pressed and HalfKay may not be running yet, this option makes teensy_loader_cli wait. It is safe to use this when HalfKay is already running. The hex file is read before waiting to verify it exists, and again immediately after the device is detected.

`-r` : Use hard reboot if device not online. Perform a hard reset using a second Teensy 2.0 running this [rebooter](rebootor) code, with pin C7 connected to the reset pin on your main Teensy. While this requires using a second board, it allows a Makefile to fully automate reprogramming your Teensy. This method is recommended for fully automated usage, such as Travis CI with PlatformIO. No manual button press is required!

`-s` : Use soft reboot (Linux only) if device not online. Perform a soft reset request by searching for any Teensy running USB Serial code built by Teensyduino. A request to reboot is transmitted to the first device found.

`-n` : No reboot after programming. After programming the hex file, do not reboot. HalfKay remains running. This option may be useful if you wish to program the code but do not intend for it to run until the Teensy is installed inside a system with its I/O pins connected.

`-v` : Verbose output. Normally teensy_loader_cli prints only error messages if any operation fails. This enables verbose output, which can help with troubleshooting, or simply show you more status information.

## System Specific Setup

Linux requires UDEV rules for non-root users.

http://www.pjrc.com/teensy/49-teensy.rules

FreeBSD requires a [device configuration file](freebsd-teensy.conf) for non-root users.

OpenBSD's make is incompatible with most AVR makefiles. Use "`pkg_add -r gmake`", and then compile code with "`gmake all`" to obtain the .hex file.

On Macintosh OS-X 10.8, Casey Rodarmor shared this tip:

I recently had a little trouble getting the teensy cli loader working on Mac OSX 10.8. Apple moved the location of the SDKs around, so that they now reside inside of the xcode app itself. This is the line in the makefile that got it working for me:
SDK ?= /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk

## CMake Integration

- [ ] TODO: Create CMake functions that can be used to build teensy_loader_cli and integrate teensy programming command as a target in CMake projects

## PlatformIO Integration

[Platformio](http://platformio.org) includes support for loading via teensy_loader.

list(APPEND TEENSY_MCU_LIST 
    "at90usb162"
    "atmega32u4"
    "at90usb646"
    "at90usb1286"
    "mkl26z64"
    "mk20dx128"
    "mk20dx256"
    "mk66fx1m0"
    "mk64fx512"
    "imxrt1062"
    "TEENSY2"
    "TEENSY2PP"
    "TEENSYLC"
    "TEENSY30"
    "TEENSY31"
    "TEENSY32"
    "TEENSY35"
    "TEENSY36"
    "TEENSY40"
)

macro(generate_teensy_args_list args mcu wait hard_reboot soft_reboot no_reboot boot_only verbose hex_file)
        
        set(teensy_cli_args "--mcu=${mcu}")
        
        if(${wait})
            set(teensy_cli_args "${teensy_cli_args} -w")
        endif()
        if(${hard_reboot})
            set(teensy_cli_args "${teensy_cli_args} -r")
        endif()
        if(${soft_reboot})
            set(teensy_cli_args "${teensy_cli_args} -s")
        endif()
        if(${no_reboot})
            set(teensy_cli_args "${teensy_cli_args} -n")
        endif()
        if(${boot_only})
            set(teensy_cli_args "${teensy_cli_args} -b")
        endif()
        if(${verbose})
            set(teensy_cli_args "${teensy_cli_args} -v")
        endif()

        set(teensy_cli_args "${teensy_cli_args} ${hex_file}")

        separate_arguments(args NATIVE_COMMAND ${teensy_cli_args})

endmacro()

function(add_teensy_flash_target target mcu wait hard_reboot soft_reboot no_reboot boot_only verbose)
    if("${mcu}" IN_LIST TEENSY_MCU_LIST)
        # Create a custom utility target for flashing teensy
        add_custom_target(flash-${target})

        # Create the argument list for the teensy_loader_cli
        generate_teensy_args_list(
            args
            ${mcu}
            ${wait}
            ${hard_reboot}
            ${soft_reboot}
            ${no_reboot}
            ${boot_only}
            ${verbose}
            "$<TARGET_FILE_DIR:${target}>/$<TARGET_FILE_BASE_NAME:${target}>.hex"
        )

        # Add a post-build command to call teensy_loader_cli
        add_custom_command(TARGET flash-${target} POST_BUILD COMMAND ${TEENSY_LOADER_COMMAND} ${args})

        # Add this utility target to the dependency chain of your target
        add_dependencies(flash-${target} ${target})
    else()
        message(FATAL_ERROR "Teensy MCU \"${mcu}\" is not valid. You must select one of the following: ${TEENSY_MCU_LIST}")
    endif()
endfunction()

function(add_teensy_flash_command target mcu wait hard_reboot soft_reboot no_reboot boot_only verbose)
    if("${mcu}" IN_LIST TEENSY_MCU_LIST)
        # Create the argument list for the teensy_loader_cli
        generate_teensy_args_list(
            args
            ${mcu}
            ${wait}
            ${hard_reboot}
            ${soft_reboot}
            ${no_reboot}
            ${boot_only}
            ${verbose}
            "$<TARGET_FILE_DIR:${target}>/$<TARGET_FILE_BASE_NAME:${target}>.hex"
        )

        # Create a post-build command for your target that calls the teensy_loader_cli command
        add_custom_command(TARGET ${target} POST_BUILD COMMAND ${TEENSY_LOADER_COMMAND} ${args})
    else()
        message(FATAL_ERROR "Teensy MCU \"${mcu}\" is not valid. You must select one of the following: ${TEENSY_MCU_LIST}")
    endif()
endfunction()
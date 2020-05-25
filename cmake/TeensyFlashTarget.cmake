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
function(add_teensy_flash_target target mcu wait)
    if("${mcu}" IN_LIST TEENSY_MCU_LIST)
        if(${wait})
            add_custom_target(flash-teensy COMMAND ${TEENSY_LOADER_COMMAND} "--mcu=${mcu}" "-w" "-v" "$<TARGET_FILE_BASE_NAME:${target}>.hex")
        else()
            add_custom_target(flash-teensy COMMAND ${TEENSY_LOADER_COMMAND} "--mcu=${mcu}" "-v" "$<TARGET_FILE_BASE_NAME:${target}>.hex")
        endif()
    else()
        message(FATAL_ERROR "Teensy MCU \"${mcu}\" is not valid. You must select one of the following: ${TEENSY_MCU_LIST}")
    endif()
endfunction()
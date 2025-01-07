# Generated Cmake Pico project file

cmake_minimum_required(VERSION 3.13)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(PICO_SDK_PATH "/home/sonny/pico/pico-sdk")
set(PICO_BOARD pico_w CACHE STRING "Board type")
include(pico_sdk_import.cmake)

project(udp1 C CXX ASM)
pico_sdk_init()
add_executable(udp1 udp1.c i2c_lib.c)
pico_set_program_name(udp1 "udp1")
pico_set_program_version(udp1 "0.1")
pico_enable_stdio_uart(udp1 1)
pico_enable_stdio_usb(udp1 0)

# Add the standard library to the build
target_link_libraries(udp1
        pico_stdlib)

# Add the standard include files to the build
target_include_directories(udp1 PRIVATE
  ${CMAKE_CURRENT_LIST_DIR}
  ${CMAKE_CURRENT_LIST_DIR}/.. # for our common lwipopts or any other standard includes, if required
)

# Add any user requested libraries
target_link_libraries(udp1 
        hardware_i2c
        hardware_spi
        pico_cyw43_arch_lwip_poll
        )

pico_add_extra_outputs(udp1)


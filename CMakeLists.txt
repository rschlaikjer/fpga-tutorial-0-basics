cmake_minimum_required(VERSION 3.8)
project(four_bit_adder)

# We need to locate the verilator install path.
# If this doesn't work off the bat on your system, try setting
# the VERILATOR_ROOT environment variable to your install location.
# On a default install, this will be /usr/local/share/verilator
find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
    message(FATAL_ERROR "Could not find Verilator. Install or set $VERILATOR_ROOT")
endif()

# Create our testbench executable.
# We will have just the one testbench source file.
add_executable(adder_testbench adder_testbench.cpp)

# Based on how I understand the verilator plugin to work, if you specify several
# verilog sources in the same target it will pick a top level module and
# only export the interface for that module. If you want to be able to poke
# around in lower-level modules, it seems that you need to specify them
# individually. To make this easier, I put all the sources in a list here
# so that I can add targets for them iteratively.
set(VERILOG_SOURCES
    ${PROJECT_SOURCE_DIR}/full_adder.v
    ${PROJECT_SOURCE_DIR}/adder_4b.v
)

# For each of the verilog sources defined above, create a verilate target
foreach(SOURCE ${VERILOG_SOURCES})
# We need to speicify an existing executable target to add the verilog sources
# and includes to. We also speicfy here that we want to build support
# for signal tracing
verilate(adder_testbench COVERAGE TRACE
    INCLUDE_DIRS "${PROJECT_SOURCE_DIR}"
    VERILATOR_ARGS -O2 -x-assign 0
    SOURCES ${SOURCE})
endforeach()

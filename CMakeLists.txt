cmake_minimum_required(VERSION 3.10)
Project(MiniC)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
list(APPEND CMAKE_PREFIX_PATH "/opt/homebrew/opt/llvm")
find_package(LLVM REQUIRED CONFIG)
find_package(FLEX)
# Specify the path to the Bison executable
set(BISON_EXECUTABLE /opt/homebrew/opt/bison/bin/bison)

find_package(BISON 3.8 REQUIRED)
FLEX_TARGET(LEXER lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp
DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/lexer.hpp)
BISON_TARGET(PARSER parser.ypp ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp
             DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/parser.hpp)

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")
add_flex_bison_dependency(LEXER PARSER)
include_directories(${LLVM_INCLUDE_DIRS})
add_definitions(${LLVM_DEFINITIONS})
add_executable(MiniC "${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp" "${CMAKE_CURRENT_BINARY_DIR}/parser.cpp" "${CMAKE_CURRENT_BINARY_DIR}/ast.cpp")

# Find the libraries that correspond to the LLVM components
# that we wish to use
llvm_map_components_to_libnames(llvm_libs support core irreader)

# Link against LLVM libraries
target_link_libraries(MiniC ${llvm_libs} l)
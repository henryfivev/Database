cmake_minimum_required(VERSION 3.20)
cmake_policy(VERSION 3.20)

project(usepqxx VERSION 0.1 LANGUAGES CXX)

list(APPEND CMAKE_PREFIX_PATH "/usr")
list(APPEND CMAKE_PREFIX_PATH "/usr/local")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
# set(CMAKE_C_COMPILER /usr/bin/clang-11)
# set(CMAKE_CXX_COMPILER /usr/bin/clang++-11)

set(CMAKE_C_COMPILER /usr/bin/gcc)
set(CMAKE_CXX_COMPILER /usr/bin/g++)

set(CMAKE_EXPORT_COMPILE_COMMANDS True)

find_package(PostgreSQL REQUIRED)

add_compile_options(-fsanitize=address -fsanitize=leak -fno-omit-frame-pointer -fprofile-arcs -ftest-coverage)
add_link_options(-fsanitize=address -fsanitize=leak -fno-omit-frame-pointer -fprofile-arcs -ftest-coverage)
set(default_build_type "Debug")

set(PROJECT_SOURCES
        usepqxx.cxx
)
# INCLUDE_DIRECTORIES($(INCLUDE_DIRECTORIES)  /usr/include/c++/10)

add_executable(usepqxx ${PROJECT_SOURCES})

target_link_libraries(usepqxx PRIVATE pqxx PostgreSQL::PostgreSQL)

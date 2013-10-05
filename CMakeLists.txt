#--------------------------------------------
# SQLite build script for amalgamation
#--------------------------------------------
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

set(PROJECT_NAME sqlite3)

# define project for C language
project(${PROJECT_NAME} C)

if (NOT DEFINED BUILD_SHARED_LIBS)
  option(BUILD_SHARED "Build SQLite shared library" ON)
endif()

set(WIN_BUILD OFF)

if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	set(WIN_BUILD ON)
endif()

# ---------------------
# Version detection
# ---------------------
file(STRINGS "${PROJECT_SOURCE_DIR}/sqlite3.h" _sqlite_api_h_VER_STRING REGEX ".*#define[ ]+SQLITE_VERSION[ ]+")

string(REGEX MATCH "[0-9\\.]+" SQLITE_VER_STRING ${_sqlite_api_h_VER_STRING})
string(REGEX MATCHALL "[0-9]+" _sqlite_ver_LIST "${SQLITE_VER_STRING}")
list(LENGTH _sqlite_ver_LIST _sqlite_list_len)
list(GET _sqlite_ver_LIST 0 SQLITE_VER_MAJOR)
list(GET _sqlite_ver_LIST 1 SQLITE_VER_MINOR)
list(GET _sqlite_ver_LIST 2 SQLITE_VER_PATCH)
if(_sqlite_list_len EQUAL 4)
	list(GET _sqlite_ver_LIST 3 SQLITE_VER_PATCHLEVEL)
	message("Patch level: ${SQLITE_VER_PATCHLEVEL}")
endif()

message("FOUND: SQLite version = ${SQLITE_VER_STRING}")

set(lib_name "${PROJECT_NAME}")

foreach (type LIBRARY RUNTIME ARCHIVE)
  if (DEFINED sqlite3_CMAKE_${type}_OUTPUT_DIRECTORY
      AND NOT EXISTS ${sqlite3_CMAKE_${type}_OUTPUT_DIRECTORY})
    message(FATAL_ERROR "sqlite3_CMAKE_${type}_OUTPUT_DIRECTORY is set to non existing directory
    [${sqlite3_CMAKE_${type}_OUTPUT_DIRECTORY}]")
  endif() 

  if (NOT DEFINED sqlite3_CMAKE_${type}_OUTPUT_DIRECTORY)
    set(sqlite3_CMAKE_${type}_OUTPUT_DIRECTORY ${sqlite3_BINARY_DIR})
  endif() 
  set(CMAKE_${type}_OUTPUT_DIRECTORY ${sqlite3_CMAKE_${type}_OUTPUT_DIRECTOR} CACHE INTERNAL "Single output directory for building all libraries.")
endforeach()

set(${PROJECT_NAME}_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}
    CACHE INTERNAL "${PROJECT_NAME} include dirs" FORCE)
# add include path for project
include_directories(${PROJECT_SOURCE_DIR})

message(STATUS "project_source_dir is" ${PROJECT_SOURCE_DIR})


#------------------------------------------------------------------------------------------
# Install headers
#------------------------------------------------------------------------------------------
set(SRC_LIB_FILE ${PROJECT_SOURCE_DIR}/sqlite${SQLITE_VER_MAJOR}.c)
set(SRC_SHELL_FILE ${PROJECT_SOURCE_DIR}/shell.c)
file(GLOB HDR_FILES ${PROJECT_SOURCE_DIR}/*.h)

if(NOT DEFINED ${PROJECT_NAME}_INSTALL_NO_DEVELOPMENT)
    set(${PROJECT_NAME}_INSTALL_NO_DEVELOPMENT ON)
endif()

if(NOT ${PROJECT_NAME}_INSTALL_NO_DEVELOPMENT)
  install(
    FILES ${HDR_FILES} 
    DESTINATION include/${PROJECT_NAME} COMPONENT Development
    )
endif()

add_library(${lib_name} SHARED ${HDR_FILES} ${SRC_LIB_FILE})
if (WIN_BUILD)
  set_target_properties(${lib_name} PROPERTIES DEFINE_SYMBOL "SQLITE_API=__declspec(dllexport)")
endif()
target_link_libraries(${lib_name} pthread dl)

# build shell executable
add_executable(shell ${HDR_FILES} ${SRC_SHELL_FILE})
target_link_libraries(shell ${lib_name} pthread dl)

#
# Apply user-defined properties to the library target.
#
if (sqlite3_LIBRARY_PROPERTIES)
  set_target_properties(${lib_name} PROPERTIES ${sqlite3_LIBRARY_PROPERTIES})
endif()

#
# export target
#
set(${PROJECT_NAME}_TARGETS ${lib_name} CACHE INTERNAL "${PROJECT_NAME} targets" FORCE)
export(TARGETS ${lib_name} FILE ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Targets.cmake)

# installation
list(APPEND TO_INSTALL shell)

set(INSTALL_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR})
set(INSTALL_LIB_DIR ${CMAKE_CURRENT_BINARY_DIR})
set(INSTALL_INC_DIR ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})

install(TARGETS ${TO_INSTALL}
  RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
  LIBRARY DESTINATION "${INSTALL_LIB_DIR}"
  ARCHIVE DESTINATION "${INSTALL_LIB_DIR}" 
)

install(TARGETS ${lib_name}
  RUNTIME DESTINATION ${INSTALL_BIN_DIR} COMPONENT RuntimeLibraries
  LIBRARY DESTINATION ${INSTALL_LIB_DIR} COMPONENT RuntimeLibraries
  ARCHIVE DESTINATION ${INSTALL_LIB_DIR} COMPONENT Development
  )

install(FILES ${HDR_FILES} DESTINATION "${INSTALL_INC_DIR}")

#install support files
if (NOT ${PROJECT_NAME}_INSTALL_NO_DEVELOPMENT)
  install(FILE
    ${CMAKE_CURRENT_BINARY_DIR}/Usesqlite3.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/install/sqlite3Config.cmake
    DESTINATION lib/${lib_name} COMPONENT Development)
endif()

 #
include(Generatesqlite3Config.cmake)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Usesqlite3.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/Usesqlite3.cmake COPYONLY)


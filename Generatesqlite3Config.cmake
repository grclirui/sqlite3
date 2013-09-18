# Generate the sqlite3Config.cmake file in the buid tree

# Settings specific to the build tree
#
set(SQLITE_INCLUDE_DIR_CONFIG
  ${sqlite3_INCLUDE_DIR}
  )

set(SQLITE_LIBRARIES_CONFIG sqlite3)

#set(SQLITE3_LIBRARY_DIR_CONFIG
#  ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
#  ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
#  )

set(SQLITE_USE_FILE_CONFIG
  ${sqlite3_BINARY_DIR}/Usesqlite3.cmake
  )

# configure PythonCppApiConfig.cmake for the build tree
#
message(STATUS " SOURCE dir" ${sqlite3_SOURCE_DIR})
message(STATUS " BINARY dir" ${sqlite3_BINARY_DIR})

configure_file(
  ${sqlite3_SOURCE_DIR}/sqlite3Config.cmake.in
  ${sqlite3_BINARY_DIR}/sqlite3Config.cmake
  @ONLY
  )

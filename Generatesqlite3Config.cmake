# Generate the sqlite3Config.cmake file in the buid tree

# Settings specific to the build tree
#
set(sqlite3_INCLUDE_DIR_CONFIG
  ${sqlite3_INCLUDE_DIR}
  )

set(sqlite3_LIBRARIES_CONFIG sqlite3)

set(sqlite3_USE_FILE_CONFIG
  ${sqlite3_BINARY_DIR}/Usesqlite3.cmake
  )

# configure PythonCppApiConfig.cmake for the build tree
#
message(STATUS " SOURCE dir" ${sqlite3_SOURCE_DIR})
message(STATUS " INCLUDE dir" ${sqlite3_INCLUDE_DIR})
message(STATUS " BINARY dir" ${sqlite3_BINARY_DIR})

configure_file(
  ${sqlite3_SOURCE_DIR}/sqlite3Config.cmake.in
  ${sqlite3_BINARY_DIR}/sqlite3Config.cmake
  @ONLY
  )

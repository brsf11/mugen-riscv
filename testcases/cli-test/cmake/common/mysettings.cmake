if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
    if(BUILD_TYPE)
        string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
               CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
    else()
        set(CMAKE_INSTALL_CONFIG_NAME "Debug")
    endif()
    message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()
# Projects Settings
cmake_minimum_required(VERSION 3.1)
project(tech-camp)

# The main executable
add_executable(main
        src/main.cpp
        src/utils/datamanager.cpp
        src/graphics/camera.cpp
        src/graphics/shader.cpp
        src/graphics/window.cpp
        src/graphics/buffers/buffer.cpp
        src/graphics/buffers/indexbuffer.cpp
        src/graphics/buffers/vertexarray.cpp
        lib/GLAD/glad.c
        )

target_include_directories(main PRIVATE
        src/utils
        src/graphics
        src/graphics/buffers
        lib/
        )

set_property(TARGET main PROPERTY CXX_STANDARD 11)
target_compile_options(main PRIVATE -Wall)

# Detect emscripten is used.
if (CMAKE_CXX_COMPILER MATCHES "/em\\+\\+(-[a-zA-Z0-9.])?$")
    set_target_properties(main PROPERTIES OUTPUT_NAME "main.js")

    # glfw
    #string(APPEND CMAKE_CXX_FLAGS " -s USE_GLFW=3")

    string(APPEND CMAKE_CXX_FLAGS " -s DEMANGLE_SUPPORT=1")
    string(APPEND CMAKE_CXX_FLAGS " -s DISABLE_EXCEPTION_CATCHING=1")
    string(APPEND CMAKE_CXX_FLAGS " -s USE_GLFW=3")
    string(APPEND CMAKE_CXX_FLAGS " -s USE_WEBGL2=1")
    string(APPEND CMAKE_CXX_FLAGS " -s WASM=1")

    # Release flags
    #string(APPEND CMAKE_CXX_FLAGS " --closure 1")
    #string(APPEND CMAKE_CXX_FLAGS " --js-opts 3")
    #string(APPEND CMAKE_CXX_FLAGS " --llvm-lto 3")
    #string(APPEND CMAKE_CXX_FLAGS " --llvm-opts 3")
    #string(APPEND CMAKE_CXX_FLAGS " -O3")

    # Allow the directories /shader and /data to be fetched by the web browser.
    file(GLOB shader_files "./shaders/*")
    foreach (file ${shader_files})
        file(RELATIVE_PATH relative_file ${CMAKE_SOURCE_DIR} ${file})
        string(APPEND CMAKE_CXX_FLAGS " --preload-file ${file}@/${relative_file}")
        message(STATUS CMAKE_CXX_FLAGS " --preload-file ${file}@/${relative_file}")
    endforeach ()

else () # Not Web

    # glfw
    add_subdirectory(lib/glfw EXCLUDE_FROM_ALL)
    target_link_libraries(main PRIVATE glfw)

    # glew
    add_definitions(-DGLEW_STATIC)
    add_subdirectory(lib/glew EXCLUDE_FROM_ALL)
    target_link_libraries(main PRIVATE libglew_static)

endif ()

# glm
add_subdirectory(lib/glm EXCLUDE_FROM_ALL)
target_link_libraries(main PRIVATE glm)

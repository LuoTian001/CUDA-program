cmake_minimum_required(VERSION 3.18)
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -allow-unsupported-compiler" CACHE STRING "" FORCE)

if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES 86)
endif()

# set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 定义项目名称并启用 CUDA 和 CXX
project(CUDA_Program LANGUAGES CUDA CXX)

# 指定标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CUDA_STANDARD 17)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

# 设置包含路径
include_directories(
    ${PROJECT_SOURCE_DIR}/include
)

# 搜索 CUDA 库
find_package(CUDAToolkit REQUIRED)

# 添加可执行程序
add_executable(cuda_main src/main.cu)

# 只有在 Release 模式下，且编译 CUDA 文件时，才添加 -O3
target_compile_options(cuda_main PRIVATE
    $<$<AND:$<COMPILE_LANGUAGE:CUDA>,$<CONFIG:Release>>:-O3>
)

# 链接库
target_link_libraries(cuda_main 
    PUBLIC 
    CUDA::cudart
    CUDA::cublas
    CUDA::curand
)

# 设置输出目录
set_target_properties(cuda_main PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
)
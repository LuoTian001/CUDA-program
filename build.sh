#!/bin/bash

# 1. 强制删除旧的 build 目录
echo "Cleaning old build..."
rm -rf build

# 2. 创建新目录
echo "Creating new build directory..."
mkdir build

# 3. 进入目录
cd build

# 4. 生成构建文件 (CMake)
# 注意：这里我们显式指定使用 Ninja 或保持默认生成器
echo "Configuring with CMake..."
cmake .. 

# 5. 执行编译 (Debug 模式)
echo "Building project..."
cmake --build . --config Debug

echo "Build finished!"


# 单次调试
# cmake --build . --config Debug
# cmake --build . --config Release
# ./Debug/cuda_main.exe
# ./Release/cuda_main.exe
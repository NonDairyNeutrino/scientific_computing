cmake_minimum_required(VERSION 3.27)
project(TestProject CUDA)

set(CMAKE_CUDA_STANDARD 17)
#set(CUDA_PATH "C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.3")

#find_package(CUDA REQUIRED)
find_package(CUDAToolkit)
#set(CMAKE_CUDA_FLAGS "-Wall")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} --extended-lambda -g -lineinfo")

add_executable(TestProject main.cu)

target_link_libraries(TestProject PRIVATE CUDA::curand)

set_target_properties(
        TestProject
        PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)

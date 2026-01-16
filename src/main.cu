#include <iostream>
#include <cuda_runtime.h>

__global__ void helloCUDA() 
{
    printf("Hello from GPU thread %d\n", threadIdx.x);
}

int main() 
{
    std::cout << "Hello from CPU" << std::endl;
    
    helloCUDA<<<1, 5>>>();
    cudaDeviceSynchronize();
    
    return 0;
}
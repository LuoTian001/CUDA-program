#include <iostream>
#include <vector>
#include <cmath>

#include <cuda_runtime.h>
#include <device_launch_parameters.h>

const int N = 1 << 12;
const int BLOCK_SIZE = 64;

// Kernel 1: High Divergence

__global__ void kernel_high_divergence(float *data)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if(tid >=N) return;
    float val = data[tid];
    if(tid % 2 == 0)
    {
        for(int i = 0; i < 100; ++i)
        {
            val = sinf(val) * cosf(val);
        }
    }
    else
    {
        for(int i = 0; i < 100; i++)
        {
            val  = sqrtf(fabsf(val)) + 1.0f;
        }
    }
    data[tid] = val;
}
__global__ void kernel_low_divergence(float* data)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if(tid > N) return;
    float val = data[tid];
    bool condition = (tid < (N / 2));
    if(condition)
    {
        for(int i = 0; i < 100; i++)
        {
            val = sinf(val) + cosf(val);
        }
    }
    else
    {
        for(int i = 0; i < 100; i++)
        {
            val = sqrtf(fabsf(val)) + 1.0f;
        }
        data[tid] = val;
    }
}
__global__ void kernel_branchless(float* data)
{
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if(tid >= N) return;
    float val = data[tid];
    float mask_a = (float)(tid % 2 == 0);
    float mask_b = 1.0f - mask_a;
    float res_a = val;
    float res_b = val;
    for(int i = 0; i < 100; i++)
    {
        res_a = sinf(res_a) * cosf(res_a);
    }
    for(int i = 0; i < 100; i++)
    {
        res_b = sqrtf(fabs(res_b)) + 1.0f;
    }
    data[tid] = mask_a * res_a + mask_b * res_b;
}
void run_test(const char *name, void(*kernel)(float*), float* d_data, int blocks)
{
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    kernel<<<blocks, BLOCK_SIZE>>>(d_data);
    cudaDeviceSynchronize();
    cudaEventRecord(start);
    for(int i = 0; i < 10; i++)
    {
        kernel<<<blocks, BLOCK_SIZE>>>(d_data);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    std::cout << "Kernel [" << name << "] Time: " << milliseconds << "ms" << std::endl;

    cudaEventDestroy(start);
    cudaEventDestroy(stop);

}

int main() 
{
    size_t bytes = N * sizeof(float);
    float* d_data;
    cudaMalloc(&d_data, bytes);
    cudaMemset(d_data, 0, bytes);
    int blocks = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;
    std::cout << "Running Warp Divergence Experiment..." << std::endl;
    std::cout << "Total Threads: " << N << std::endl;
    std::cout << "Block Size: " << BLOCK_SIZE << std::endl;
    std::cout << "--------------------------------------" << std::endl;

    run_test("High Divergence (tid % 2)", kernel_high_divergence, d_data, blocks);
    run_test("Low Divergence (Sorted)", kernel_low_divergence, d_data, blocks);
    run_test("Branchless (Compute Both)", kernel_branchless, d_data, blocks);
    cudaFree(d_data);
    
    return 0;
}
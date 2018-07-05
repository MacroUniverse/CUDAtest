#ifdef _MSC_VER
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#endif
#include <iostream>

using namespace std;

__global__
void add1(int *x, int thread)
{
	x[thread] += 1;
}

int main()
{
	int i, N = 3;
	int *x, *dev_x;
	cudaSetDevice(0);
	cudaSetDeviceFlags(cudaDeviceMapHost);
	cudaHostAlloc((void**)&x, N*sizeof(int),
		cudaHostAllocWriteCombined |
		cudaHostAllocPortable |
		cudaHostAllocMapped);
	for (i = 0; i < N; ++i) {
		x[i] = i;
	}
	cudaHostGetDevicePointer(&dev_x, x, 0);
	
	#pragma omp parallel for
	for (i = 0; i < N; ++i) {
		if (i != 0) {
			cudaSetDevice(i);
			cudaSetDeviceFlags(cudaDeviceMapHost);
		}
		add1<<<1,1>>>(dev_x, i);
		cudaThreadSynchronize();
	}

	cout << "the result is: " << x[0] << " " << x[1] << " " << x[2] << endl;
}
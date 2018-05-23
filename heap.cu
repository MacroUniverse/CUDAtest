#include <iostream>
#include <cstdio>
using namespace std;

__device__ double xmax = 3.14;
double xmax_;

__global__
void fun(int N)
{
	double *x = new double[N];
	double *y = new double[N];
	if (x) {
		x[N-1] = 3.1415926;
		y[N-1] = 2.7182818;
		//printf("x[N-1] = %f\n", x[N-1]);
	}
	else
		printf("heap overflow\n");
}

int main()
{
	int N = 1024;
	size_t heapsize;
	cudaDeviceSetLimit(cudaLimitMallocHeapSize, 41943040 + 96*1024*1024);
	cudaDeviceGetLimit(&heapsize, cudaLimitMallocHeapSize);
	cout << "heapsize = " << heapsize << endl;
	fun<<<1024*1024/256,256>>>(N);
	cudaDeviceSynchronize();
	xmax_ = 5.;
}

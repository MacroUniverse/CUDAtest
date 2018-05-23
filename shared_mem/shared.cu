// test the size of shared memory for each block

#include <iostream>
#include <cstdio>
using namespace std;

#define N 2500

__global__
void fun()
{
	__shared__ double x[N], y[N];

	for (int i=0; i<400; ++i)
	for (int j=0; j<N; ++j)
		y[j] += x[j];
}


int main()
{
	fun<<<1,1>>>();
	cudaDeviceSynchronize();
}

// test the size of shared memory for each block

#include <iostream>
#include <cstdio>
using namespace std;

#define N 100

__const__ int NN = 1;

__global__
void fun(double *py)
{
	printf("NN = %d\n", NN);
	double a[NN];
	*py = 0.;
	for (int i=0; i<1000000; ++i)
		*py += 3.1415927;
}


int main()
{
	double *py, y;
	int N0 = 13;
	cudaMemcpyToSymbol(NN, &N0, sizeof(int));
	cudaMalloc(&py, sizeof(double));
	fun<<<1,1>>>(py);
	cudaMemcpy(&y, py, sizeof(double), cudaMemcpyDeviceToHost);
	cout << "y = " << y << endl;
	cudaDeviceSynchronize();
}

#include <iostream>
#include <cstdio>
using namespace std;

__device__ double xmax = 3.14;
double xmax_;

__global__
void fun()
{
	printf(" xmax = %f\n", xmax);
}

int main()
{
	fun<<<1,1>>>();
	cudaDeviceSynchronize();
	xmax_ = 5.;
	cout << "xmax_ = " << xmax_ << endl;
}

#include <iostream>
#include <cstdio>
using namespace std;

struct data
{
	int i;
};

__device__ data devdata;

__device__ double xmax = 3.14;
double xmax_;

__global__
void fun()
{
	printf(" xmax = %f\n", xmax);
	devdata.i = 314;
	printf(" devdata.i = %d\n", devdata.i);
}

int main()
{
	fun<<<1,1>>>();
	cudaDeviceSynchronize();
	xmax_ = 5.;
	cout << "xmax_ = " << xmax_ << endl;
	data mydata;
	mydata.i = 100;
	cout << "mydata.i = " << mydata.i << endl;
}

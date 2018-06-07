#include <iostream>
#include <cstdio>

using namespace std;

__global__
void fun(int N)
{
	double *a = new double[N];
	a[N-1] = 3.1415926;
	printf("a[] = %f\n", a[N-1]);
	delete[] a;
}

int main()
{
	int N = 10;
	fun<<<1,10>>>(N);
	cudaDeviceSynchronize();

}

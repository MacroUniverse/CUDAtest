#include <iostream>

using namespace std;

__global__
void fun(double *a, long N)
{
	printf("inside fun()\n");
	printf("a[] = %f\n", a[N-1]);
}

int main()
{
	long i;
	long N = 2000000000;
	long size = N*sizeof(double);
	double *a = new double[N];
	double *a_d;

	cout << "hello" << endl;

	for(i=0; i<N; ++i)
		a[i] = 3.14159265358979323;

	cout << "assigned to a[]" << endl;

	cudaMalloc(&a_d, size);

	cout << "cudaMalloc(); done" << endl;
	cudaMemcpy(a_d, a, size, cudaMemcpyHostToDevice);
	cout << "cudaMemcpy(); done" << endl;
	fun<<<1,1>>>(a_d, N);
	cudaMemcpy(a, a_d, size, cudaMemcpyDeviceToHost);
	delete[] a;

	cudaFree(a_d);
}

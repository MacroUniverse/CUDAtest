#include <iostream>
#include <ctime>
#define N 512
using namespace std;


__global__ void add(double *a, double *b, double *c)
{
	c[blockIdx.x] = a[blockIdx.x] + b[blockIdx.x];
}

int main()
{
	double *a, *b, *c;
	double *d_a, *d_b, *d_c;
	int size = N * sizeof(double);
	clock_t clock1, clock2;
	clock1 = clock();

	cudaMalloc((void **)&d_a, size);
	cudaMalloc((void **)&d_b, size);
	cudaMalloc((void **)&d_c, size);

	a = new double[N] {1.};
	b = new double[N] {2.};
	c = new double[N} {3.};

	cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

	add<<<N,1>>>(d_a, d_b, d_c);

	cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);


	cout << "c[0] = " << a[0] << "  +  " << b[0] << "  =  " << c[0] << endl;


	
	clock2 = clock();
	cout << "clocks_per_sec : " << CLOCKS_PER_SEC << endl;
	cout << "time (ms) : " << 1000*(clock2 - clock1)/(double) CLOCKS_PER_SEC << endl;


	delete [] a; delete [] b; delete [] c;
	cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
}


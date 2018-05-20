#include <iostream>

using namespace std;


__global__
void add(double *x, double *y, int N)
{
	int i;
	for(i=0; i<N; ++i) {
		y[i] += x[i];
	}
}

int main()
{
	double *d_x, *d_y, *x, *y;
	int N = 1e6;
	int i, size = N*sizeof(double);
	cudaMalloc((void **)&d_x, size);
	cudaMalloc((void **)&d_y, size);
	x = new double[N];
	y = new double[N];
	for(i=0; i<N; ++i) {
		x[i] = 1.;
		y[i] = 2.;
	}
	cudaMemcpy(d_x, x, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_y, y, size, cudaMemcpyHostToDevice);

	add<<<1,1>>>(d_x, d_y, N);

	cudaMemcpy(y, d_y, size, cudaMemcpyDeviceToHost);

	cout << y[0] << y[1] << y[2] << y[3] << endl;

	delete [] x; delete [] y;
	cudaFree(d_x); cudaFree(d_y);
}

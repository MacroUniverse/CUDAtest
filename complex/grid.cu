#include <iostream>
#include <cmath>
#include "cuda_complex.hpp"

using namespace std;
typedef complex<double> Complex;

__global__
void add(Complex *x, Complex *y, int N)
{
	int i, ind, stride;
	ind = blockIdx.x*blockDim.x + threadIdx.x;
	stride = gridDim.x * blockDim.x;
	for(i=ind; i<N; i+=stride) {
		y[i] /= x[i];
	}
}

int main()
{
	Complex *d_x, *d_y, *x, *y;
	double err{0.};
	int N = 1e6;
	int i, size = N*sizeof(Complex);
	cudaMalloc((void **)&d_x, size);
	cudaMalloc((void **)&d_y, size);
	x = new Complex[N];
	y = new Complex[N];
	for(i=0; i<N; ++i) {
		x[i] = Complex(1.,1.);
		y[i] = Complex(2.,2.);
	}
	cudaMemcpy(d_x, x, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_y, y, size, cudaMemcpyHostToDevice);

	add<<<1,1>>>(d_x, d_y, N);

	cudaMemcpy(y, d_y, size, cudaMemcpyDeviceToHost);

	for (i=0; i<N; ++i) {
		err += abs(y[i]-2.);
	}
	cout << "err = " << err << endl;

	delete [] x; delete [] y;
	cudaFree(d_x); cudaFree(d_y);

}

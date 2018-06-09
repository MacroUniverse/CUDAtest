#include <iostream>
#include <cmath>

using namespace std;


__global__
void add(double *x, double *y, int N)
{
	int i, ind, stride;
	ind = blockIdx.x*blockDim.x + threadIdx.x;
	stride = gridDim.x * blockDim.x;
	for(i=ind; i<N; i+=stride) {
		++y[i];
		++x[i];
		++y[i];
		++x[i];
		++y[i];
		++x[i];
		++y[i];
		++x[i];
		++y[i];
		++y[i];
	}
}

int main()
{
	double *d_x, *d_y, *x, *y, err{0.};
	int N = 2e6;
	int i, size = N*sizeof(double);
	cudaMalloc((void **)&d_x, size);
	cudaMalloc((void **)&d_y, size);
	x = new double[N];
	y = new double[N];
	for(i=0; i<N; ++i) {
		x[i] = 3.1415;
		y[i] = 0.;
	}
	cudaMemcpy(d_x, x, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_y, y, size, cudaMemcpyHostToDevice);

	add<<<1280,64>>>(d_x, d_y, N);

	cudaMemcpy(y, d_y, size, cudaMemcpyDeviceToHost);

	for (i=0; i<N; ++i) {
		err += (y[i]-6.)*(y[i]-6.);
	}
	cout << "err = " << err  << endl;

	delete [] x; delete [] y;
	cudaFree(d_x); cudaFree(d_y);

}

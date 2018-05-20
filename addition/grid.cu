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
		y[i] += x[i];
	}
}

int main()
{
	double *d_x, *d_y, *x, *y, err{0.};
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

	add<<<20,512>>>(d_x, d_y, N);

	cudaMemcpy(y, d_y, size, cudaMemcpyDeviceToHost);

	for (i=0; i<N; ++i) {
		err += (y[i]-3.)*(y[i]-3.);
	}
	cout << "err = " << err  << endl;

	delete [] x; delete [] y;
	cudaFree(d_x); cudaFree(d_y);

}

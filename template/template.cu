#include "nr3plus.h"
#include "matsave.h"
using std::cout; using std::endl; using std::string;
using std::ifstream; using std::to_string;

#define H2D cudaMemcpyHostToDevice
#define D2H cudaMemcpyDeviceToHost
#define cpySym cudaMemcpyToSymbol

__global__
void kernel()
{
	printf("In kernel, block = %d, thread = %d\n", blockIdx.x, threadIdx.x);
}

int main()
{
	// cuda kernel call
	cout << "calling kernel..." << endl;
	kernel<<<2,2>>>();
	cudaDeviceSynchronize();
	cout << "done calling kernel\n" << endl;

	// write data file
	cout << "writting data file..." << endl;
	MATFile *pfile = matOpen("nrMat.mat", "w");
	MatDoub A;
	A.assign(2, 3, 0.);
	A[0][0] = 1.; A[0][1] = 3.; A[0][2] = 5.; A[1][2] = 11;
	matsave(A, "A", pfile);
	matClose(pfile);
	cout << "done writing data file" << endl;
}

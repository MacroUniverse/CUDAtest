#include "nr3.h"
#include "nr3plus.h"
using namespace std;
typedef int Int;
typedef double Doub;
typedef complex<double> Complex;

// set pointers in v[i][j] for 3D matrix
__global__
void setMat3DComplex(Complex ***v, Complex **v_0, Complex *v_00, const Int Ni, const Int Nj, const Int Nk)
{
	Int i,j;
	v[0] = v_0; v[0][0] = v_00;
	for(j=1; j<Nj; ++j) v[0][j] = v[0][j-1] + Nk;
	for(i=1; i<Ni; ++i) {
		v[i] = v[i-1] + Nj;
		v[i][0] = v[i-1][0] + Nj*Nk;
		for(j=1; j<Nj; ++j) v[i][j] = v[i][j-1] + Nk;
	}
}


// allocate a 3D matrix in GPU
// every 3D matrix need to have 3 pointers in the host
void cudaNewMat3DComplex(Complex ***&v, Complex **&v_0, Complex *&v_00, const Int Ni, const Int Nj, const Int Nk)
{
	cudaMalloc((void****)&v, Ni*sizeof(Complex**));
	cudaMalloc((void***)&v_0, Ni*Nj*sizeof(Complex*));
	cudaMalloc((void**)&v_00, Ni*Nj*Nk*sizeof(Complex));
	setMat3DComplex<<<1,1>>>(v, v_0, v_00, Ni, Nj, Nk);
}

// deallocate a 3D matrix
void cudaDeleteMat3DComplex(Complex ***&v, Complex **&v_0, Complex *&v_00)
{
	cudaFree(v); cudaFree(v_0); cudaFree(v_00);
}

// propagate the wave function in z direction
__global__
void cn1Dz(Complex ***psi)
{
	psi[0][0][0] = 3.1415926;
}

int main()
{
	Int i, j, k, size, Nx = 3, Ny = 3, Nz = 3;
	Mat3DComplex psi(Nx,Ny,Nz);
	Complex ***psi_d, **psi_d_0, *psi_d_00; 
	cudaNewMat3DComplex(psi_d, psi_d_0, psi_d_00, Nx, Ny, Nz);

	size = Nx*Ny*Nz*sizeof(Complex);

	for(i=0;i<Nx;++i)
	for(j=0;j<Ny;++j)
	for(k=0;k<Nz;++k)
		psi[i][j][k] = Complex(0.,0.);

	
	cout << "checking initialization of psi" << endl;
	cout << psi[0][0][0] << psi[0][0][1] << psi[0][1][0] << endl;

	cudaMemcpy(psi_d_00, psi[0][0], size, cudaMemcpyHostToDevice);
	
	cn1Dz<<<1,1>>>(psi_d);

	cudaMemcpy(psi[0][0], psi_d_00, size, cudaMemcpyDeviceToHost);

	cout << "after function call, psi = " << endl;
	cout << psi[0][0][0] << psi[0][0][1] << endl;

	cudaDeleteMat3DComplex(psi_d, psi_d_0, psi_d_00);
}
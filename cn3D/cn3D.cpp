#include "nr3.h"
#include "nr3plus.h"
using namespace std;

struct Cn3Dparam
{
	Complex var1, var2, var3;
};

// set pointers in v[i][j] for 3D matrix
__global__
void setMat3DComplex(Complex ***v, Complex **v_0, Complex *v_00, const Int Ni, const Int Nj, const Int Nk)
{
	Int i, j;
	v[0] = v_0; v[0][0] = v_00;
	for (j = 1; j<Nj; ++j) v[0][j] = v[0][j - 1] + Nk;
	for (i = 1; i<Ni; ++i) {
		v[i] = v[i - 1] + Nj;
		v[i][0] = v[i - 1][0] + Nj * Nk;
		for (j = 1; j<Nj; ++j) v[i][j] = v[i][j - 1] + Nk;
	}
}


// allocate a 3D matrix in GPU
// every 3D matrix need to have 3 pointers in the host
void cudaNewMat3DComplex(Complex ***&v, Complex **&v_0, Complex *&v_00, const Int Ni, const Int Nj, const Int Nk)
{
	cudaMalloc((void****)&v, Ni * sizeof(Complex**));
	cudaMalloc((void***)&v_0, Ni*Nj * sizeof(Complex*));
	cudaMalloc((void**)&v_00, Ni*Nj*Nk * sizeof(Complex));
	setMat3DComplex << <1, 1 >> >(v, v_0, v_00, Ni, Nj, Nk);
}

// deallocate a 3D matrix
void cudaDeleteMat3DComplex(Complex ***&v, Complex **&v_0, Complex *&v_00)
{
	cudaFree(v); cudaFree(v_0); cudaFree(v_00);
}

// test
__global__
void test(Complex ***psi, const Int Nx, const Int Ny, const Int Nz, const Cn3Dparam &param)
{
	Int i, j, k;
	for (i = 0; i<Nx; ++i)
	for (j = 0; j<Ny; ++j)
	for (k = 0; k<Nz; ++k)
		psi[i][j][k] += param.var1;
}

 //propagate the wave function in z direction
__global__
void cn1Dz(Complex ***psi, Complex ***V0, Complex *x, Complex *y, Complex *z, const Complex upper, 
	const Complex lower, const Int Nx, const Int Ny, const Int Nz)
{
	Int k;
	Doub bet, gam[Nz];
	Complex x[Nz]; // solution of tridiagonal matrix

	// create diagonal elements for tridiagonal matrix
	Complex *psi1 = psi[indx][indy];
	Double *V1 = V[indx][indy];
	for (k = 0; k < Nz; ++k)
		diag[k] = diag0; // + b * V

	// solve tridiagonal matrix
	x[0] = psi1[0] / (bet = diag[0]);
	for (k = 1; k < Nk; ++k) {
		gam[k] = upper0 / bet;
		bet = diag[k] - lower * gam[k];
		x[k] = (psi1[k] - lower * x[k - 1]) / bet;
	}
	for (k = Nk - 2; k >= 0; --k) {
		x[k] -= gam[k + 1] * x[k + 1];
	}

	// psi^(n+1) = x - psi^(n)
	for (k = 0; k < Nk; ++k)
		psi1[k] = x[k] - psi1[k];
}

int main()
{
	Int i, j, k, size, Nx = 100, Ny = 100, Nz = 100;
	Doub err{ 0. };
	Mat3DComplex psi(Nx, Ny, Nz);
	Cn3Dparam param;
	param.var1 = Complex(1., 1.); param.var2 = Complex(2., 2.); param.var3 = Complex(3., 3.);

	Complex ***psi_d, **psi_d_0, *psi_d_00;
	cudaNewMat3DComplex(psi_d, psi_d_0, psi_d_00, Nx, Ny, Nz);

	size = Nx * Ny*Nz * sizeof(Complex);

	for (i = 0; i<Nx; ++i)
		for (j = 0; j<Ny; ++j)
			for (k = 0; k<Nz; ++k)
				psi[i][j][k] = Complex(0., 0.);

	cudaMemcpy(psi_d_00, psi[0][0], size, cudaMemcpyHostToDevice);

	cn1Dz << <1, 1 >> >(psi_d, Nx, Ny, Nz, param);

	cudaMemcpy(psi[0][0], psi_d_00, size, cudaMemcpyDeviceToHost);

	for (i = 0; i<Nx; ++i)
		for (j = 0; j<Ny; ++j)
			for (k = 0; k<Nz; ++k)
				err += abs(psi[i][j][k] - Complex(1.1, 1.1));

	cout << "err =  " << err << endl;

	cudaDeleteMat3DComplex(psi_d, psi_d_0, psi_d_00);
}

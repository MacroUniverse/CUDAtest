#include "nr3plus.h"
using namespace std;

__device__ Int Nx, Nxprint, Ny, Nyprint, Nz, Nzprint, Nt, Ntprint,
	NFadeX1, NFadeX2, NFadeY1, NFadeY2, NFadeZ1, NFadeZ2, NDetecX1,
	NDetecX2, NDetecY1, NDetecY2, NDetecZ1, NDetecZ2, Npx, Npy, Npz,
	NE;
__device__ Doub xmin, xmax, ymin, ymax, zmin, zmax, tmin, tmax, dx,
	dy, dz, dt, fadeX1, fadeX2, fadeY1, fadeY2, fadeZ1, fadeZ2, xc,
	yc, zc, Asoft, asoft, E0x, sigmatx, omegax, lambdax, tcx, E0y,
	sigmaty, omegay, lambday, tcy, pxmin, pxmax, pymin, pymax, Emin,
	Emax;
__device__ Doub *x, *y, *z, *t;

struct Cn3Dparam
{
	Int Nx, Nxprint, Ny, Nyprint, Nz, Nzprint, Nt, Ntprint,
		NFadeX1, NFadeX2, NFadeY1, NFadeY2, NFadeZ1, NFadeZ2, NDetecX1,
		NDetecX2, NDetecY1, NDetecY2, NDetecZ1, NDetecZ2, Npx, Npy, Npz,
		NE;
	Doub xmin, xmax, ymin, ymax, zmin, zmax, tmin, tmax, dx,
		dy, dz, dt, fadeX1, fadeX2, fadeY1, fadeY2, fadeZ1, fadeZ2, xc,
		yc, zc, Asoft, asoft, E0x, sigmatx, omegax, lambdax, tcx, E0y,
		sigmaty, omegay, lambday, tcy, pxmin, pxmax, pymin, pymax, Emin,
		Emax;
	VecDoub x, y, z, t;
};

Cn3Dparam h;


// set pointers in v[i][j] for 3D matrix
__global__
void setMat3DComplex(Complex ***v, Complex **v_0, Complex *v_00, const Int Ni, const Int Nj, const Int Nk)
{
	Int ind = blockIdx.x*blockDim.x + threadIdx.x;
	if (ind < Ni)
		v[ind] = v_0 + Nj*ind;
	else if (ind < Ni*(Nj+1)) {
		Int j = ind - Ni;
		v_0[j] = v_00 + Nk*j;
	}
}

// allocate a 3D matrix in GPU
// every 3D matrix need to have 3 pointers in the host
void cudaNewMat3DComplex(Complex ***&v, Complex **&v_0, Complex *&v_00, const Int Ni, const Int Nj, const Int Nk)
{
	cudaMalloc((void****)&v, Ni*sizeof(Complex**));
	cudaMalloc((void***)&v_0, Ni*Nj*sizeof(Complex*));
	cudaMalloc((void**)&v_00, Ni*Nj*Nk*sizeof(Complex));
	setMat3DComplex<<<(Ni*(Nj+1)+255)/256,256>>>(v, v_0, v_00, Ni, Nj, Nk);
}

// deallocate a 3D matrix
void cudaDeleteMat3DComplex(Complex ***&v, Complex **&v_0, Complex *&v_00)
{
	cudaFree(v); cudaFree(v_0); cudaFree(v_00);
}

__global__
void devInitialize(Cn3Dparam h, Doub *x_d, Doub *y_d, Doub *z_d)
{
	xmin = h.xmin; xmax = h.xmax; Nx = h.Nx;
	ymin = h.ymin; ymax = h.ymax; Ny = h.Ny;
	zmin = h.zmin; zmax = h.zmax; Nz = h.Nz;
	tmin = h.tmin; tmax = h.tmax; Nt = h.Nt;

	x = x_d; y = y_d; z = z_d;
}

void Initialize(Mat3DComplex_O &psi, Complex ***&psi_d, Complex **&psi_d_0,
	Complex *&psi_d_00, Doub *&x_d, Doub *&y_d, Doub *&z_d)
{
	Int i, j, k;

	h.xmin = -5.; h.xmax = 5.; h.Nx = 11;
	h.ymin = -5.; h.ymax = 5.; h.Ny = 11;
	h.zmin = -5.; h.zmax = 5.; h.Nz = 11;
	h.tmin =  0.; h.tmax = 1.; h.Nt = 11;

	linspace(h.x,h.xmin,h.xmax,h.Nx);
	linspace(h.y,h.ymin,h.ymax,h.Ny);
	linspace(h.z,h.zmin,h.zmax,h.Nz);
	linspace(h.t,h.tmin,h.tmax,h.Nt);

	cudaMalloc((void**)&x_d, h.Nx*sizeof(Doub));
	cudaMalloc((void**)&y_d, h.Ny*sizeof(Doub));
	cudaMalloc((void**)&z_d, h.Nz*sizeof(Doub));
	cudaMemcpy(x_d, &h.x[0], h.Nx*sizeof(Doub), cudaMemcpyHostToDevice);
	cudaMemcpy(y_d, &h.y[0], h.Ny*sizeof(Doub), cudaMemcpyHostToDevice);
	cudaMemcpy(z_d, &h.z[0], h.Nz*sizeof(Doub), cudaMemcpyHostToDevice);

	cudaNewMat3DComplex(psi_d, psi_d_0, psi_d_00, h.Nx, h.Ny, h.Nz);

	psi.resize(h.Nx, h.Ny, h.Nz);

	for(i=0;i<h.Nx;++i)
	for(j=0;j<h.Ny;++j)
	for(k=0;k<h.Nz;++k)
		psi[i][j][k] = Complex(0., 0.);

	devInitialize<<<1,1>>>(h, x_d, y_d, z_d);

	
	cudaMemcpy(psi_d_00, psi[0][0], h.Nx*h.Ny*h.Nz*sizeof(Complex), cudaMemcpyHostToDevice);
}

// propagate the wave function in z direction
__global__
void cn1Dz(Complex ***psi)
{
	Int i,j,k;
	Doub temp;
	for(i=0; i<Nx; ++i)
	for(j=0; j<Ny; ++j)
	for(k=0; k<Nz; ++k) {
		temp = Ny*Nz*i + Nz*j + k;
		psi[i][j][k] += Complex(temp, temp);
	}
}

int main()
{
	Int i, j, k, size;
	Doub err{0.}, temp;
	Doub *x_d, *y_d, *z_d; // corresponds to h.x, h.y, h.z
	Mat3DComplex psi;
	Complex ***psi_d, **psi_d_0, *psi_d_00;
	cout << "in main()" << endl;

	Initialize(psi, psi_d, psi_d_0, psi_d_00, x_d, y_d, z_d);

	size = h.Nx*h.Ny*h.Nz*sizeof(Complex);

	
	//cudaDeviceSynchronize();

	cn1Dz<<<1,1>>>(psi_d);

	cudaMemcpy(psi[0][0], psi_d_00, size, cudaMemcpyDeviceToHost);

	for(i=0;i<h.Nx;++i)
	for(j=0;j<h.Ny;++j)
	for(k=0;k<h.Nz;++k) {
		temp = h.Ny*h.Nz*i + h.Nz*j + k;
		err += abs(psi[i][j][k] - Complex(temp,temp));
	}

	cout << "err =  " << err << endl;

	cudaDeleteMat3DComplex(psi_d, psi_d_0, psi_d_00);
}

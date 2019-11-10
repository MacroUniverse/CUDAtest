//Example 2. Application Using C and CUBLAS: 0-based indexing
//-----------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <complex>
#include <cuda_runtime.h>
#include "cublas_v2.h"
#define M 6
#define N 5
#define IDX2C(i,j,ld) (((j)*(ld))+(i))

using namespace std;

int main (void)
{
    cublasHandle_t handle;
    int i, j;
    cuDoubleComplex *devPtrA = 0, *devPtrX = 0, *devPtrY = 0;
	typedef complex<double> Comp;
    Comp *a = 0, *x = 0, *y = 0;
    a = (Comp *)malloc (M * N * sizeof(*a));
    x = (Comp *)malloc (N * sizeof(*x));
    y = (Comp *)malloc (M * sizeof(*y));
    for (i = 0; i < N; ++i)
	    x[i] = Comp(i+1, i+2);
    for (j = 0; j < N; ++j) {
        for (i = 0; i < M; i++) {
            a[IDX2C(i,j,M)] = Comp(i + j*M + 1, i + j*M + 2);
        }
    }
    cudaMalloc((void**)&devPtrA, M*N*sizeof(*a));
    cudaMalloc((void**)&devPtrX, N*sizeof(*a));
    cudaMalloc((void**)&devPtrY, M*sizeof(*a));

    cublasCreate(&handle);
    cublasSetMatrix(M, N, sizeof(*a), a, M, devPtrA, M);
    cublasSetMatrix(N, 1, sizeof(*x), x, M, devPtrX, M);
    cublasSetMatrix(M, 1, sizeof(*y), y, M, devPtrY, M);
    // ==== call gpu ====
    double alpha[2] = {1, 0};
    double beta[2] = {0, 0};
    cublasZgemv(handle, CUBLAS_OP_N, M, N, (cuDoubleComplex*)&alpha, devPtrA, M,
        devPtrX, 1, (cuDoubleComplex*)&beta, devPtrY, 1);
    // ==================
    cublasGetMatrix (M, N, sizeof(*a), devPtrA, M, a, M);
	cublasGetMatrix (N, 1, sizeof(*x), devPtrX, M, x, M);
	cublasGetMatrix (M, 1, sizeof(*y), devPtrY, M, y, M);
    cudaFree(devPtrA); cudaFree(devPtrX); cudaFree(devPtrY);
    cublasDestroy(handle);
	for (i = 0; i < N; ++i)
	    cout << x[i] << "  ";
	cout << endl;
	for (i = 0; i < M; i++) {
    	for (j = 0; j < N; ++j) {
            cout << a[IDX2C(i,j,M)] << "  ";
        }
        printf ("\n");
    }
	for (i = 0; i < M; ++i)
	    cout << y[i] << "  ";
	cout << endl;
    free(a);
    return EXIT_SUCCESS;
}


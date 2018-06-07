#include "matsave.h"
#include "nr3plus.h"
using namespace std;

// to write mat file
/* 
MATFile *pfile = matOpen("julia.mat", "w");
matsave(x, "x", pfile);
matClose(pfile);
*/

#define DIM 4000

__device__
int julia( int x, int y ) {
    int i;
    const float scale = 1.5;
    float jx = scale * (float)(DIM/2 - x)/(DIM/2);
    float jy = scale * (float)(DIM/2 - y)/(DIM/2);
    Complex c(-0.8, 0.156);
    Complex a(jx, jy);

    for (i=0; i<200; i++) {
        a = a * a + c;
        if (abs(a) > 31.62)
            return 0;
    }
    return 1;
}

__global__
void kernel( int *ptr ) {
    int x = blockIdx.x;
    int y = blockIdx.y;
    int juliaValue = julia( x, y );
    ptr[x + y * gridDim.x] = 255*juliaValue;
}

int main( void ) {
    int i, j, img_size = DIM*DIM*sizeof(int);
    MatInt bitmap(DIM, DIM);
    MatDoub x(DIM, DIM);
    int *dev_bitmap;

    cudaMalloc( (void**)&dev_bitmap, img_size );

    dim3 grid(DIM,DIM);
    kernel<<<grid,1>>>( dev_bitmap );

    cudaMemcpy( bitmap[0], dev_bitmap, img_size,
                        cudaMemcpyDeviceToHost );
    
    for (i = 0; i < DIM; ++i)
    for (j = 0; j < DIM; ++j) {
        x[i][j] = (Doub)bitmap[i][j];
    }
    MATFile *pfile = matOpen("julia.mat", "w");
    matsave(x, "julia", pfile);
    matClose(pfile);
    cudaFree( dev_bitmap );
}


#include "matsave.h"
#include "nr3plus.h"
using namespace std;
#define H2D cudaMemcpyHostToDevice
#define D2H cudaMemcpyDeviceToHost
#define DIM 1000

__device__
Int julia(Int x, Int y, float scale) {
    Int i;
    float jx = scale * (float)(DIM/2 - x)/(DIM/2);
    float jy = scale * (float)(DIM/2 - y)/(DIM/2);
    Complex c(-0.8, 0.15745);
    Complex a(jx, jy);

    for (i=0; i<200; i++) {
        a = a * a + c;
        if (abs(a) > 31.62)
            return 0;
    }
    return 1;
}

__global__
void kernel(Uchar *ptr, float scale) {
    Int indxy, ind = blockIdx.x*blockDim.x + threadIdx.x;
    Int stride = blockDim.x*gridDim.x;
    Int x,y;
    for(indxy = ind; indxy < DIM*DIM; indxy += stride){
        x = indxy%DIM; y = indxy/DIM;
        Int juliaValue = julia( x, y, scale);
        ptr[x + y * DIM] = (Uchar)(255*juliaValue);
    }
}

int main( void ) {
    int i, img_size = DIM*DIM*sizeof(Uchar);
    float scale = 1.5;
    string str;
    MatUchar bitmap(DIM, DIM);
    Uchar *dev_bitmap;

    cudaMalloc( (void**)&dev_bitmap, img_size );

    for (i = 0; i < 150; ++i){
        scale *= 0.95;
        kernel<<<320,32>>>( dev_bitmap, scale );
        cudaMemcpy(bitmap[0], dev_bitmap, img_size, D2H);
        str = to_string(i);
        MATFile *pfile = matOpen((str + ".julia.mat").c_str(), "w");
        matsave(bitmap, "julia", pfile);
        matClose(pfile);
    }
    
    cudaFree( dev_bitmap );
}

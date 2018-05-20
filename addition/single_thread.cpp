#include <iostream>
#include <cmath>
#include <ctime>

using namespace std;


void add(float *x, float *y, int N)
{
	int i,j,k;
	for(i=0; i<N; ++i) {
		y[i] /= x[i];
	}
}

int main()
{
	float  *x, *y, err{0.};
	int N = 1e6;
	int i,j,k, size = N*sizeof(float);
	time_t t1, t2;
	x = new float[N];
	y = new float[N];
	for(i=0; i<N; ++i) {
		x[i] = 1.;
		y[i] = 2.;
	}

	t1 = clock();
	for (k=0; k<100; ++k)
	for (j=0; j<100; ++j)
	add(x, y, N);
	t2 = clock();
	cout << "add() time (ms): " << (t2 - t1) / (double)CLOCKS_PER_SEC *1000 << endl;

	for (i=0; i<N; ++i) {
		err += (y[i]-2.)*(y[i]-2.);
	}
	cout << "err = " << err  << endl;

	delete [] x; delete [] y;
}

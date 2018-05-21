#include <iostream>
#include <cmath>
#include <complex>
#include <ctime>

typedef std::complex<double> Complex;
using namespace std;


void add(Complex *x, Complex *y, int N)
{
	int i,j,k;
	for(i=0; i<N; ++i) {
		y[i] /= x[i];
	}
}

int main()
{
	Complex  *x, *y;
	double err{0.};
	int N = 1e6;
	int i,j,k, size = N*sizeof(Complex);
	time_t t1, t2;
	x = new Complex[N];
	y = new Complex[N];
	for(i=0; i<N; ++i) {
		x[i] = Complex(1/sqrt(2),1/sqrt(2));
		y[i] = Complex(2.,2.);
	}

	t1 = clock();
	for (j=0; j<1000; ++j)
	add(x, y, N);
	t2 = clock();
	cout << "add() time (ms): " << (t2 - t1) / (double)CLOCKS_PER_SEC *1000 << endl;

	for (i=0; i<N; ++i) {
		err += abs(y[i]-Complex(2.,2.));
	}
	cout << "err = " << err  << endl;

	delete [] x; delete [] y;
}

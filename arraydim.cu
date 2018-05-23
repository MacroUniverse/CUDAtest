#include <iostream>
using namespace std;

__global__
void fun(const int N)
{
	double a[N];
	a[N-1] = N-1;
}

int main()
{
	int N = 10;
	fun<<<1,1>>>(N);
}

#include "nr3plus.h"
#include "matsave.h"
using std::cout; using std::endl; using std::string;
using std::ifstream; using std::to_string;

#define H2D cudaMemcpyHostToDevice
#define D2H cudaMemcpyDeviceToHost
#define cpySym cudaMemcpyToSymbol

// to write mat file
/* 
MATFile *pfile = matOpen("julia.mat", "w");
matsave(x, "x", pfile);
matClose(pfile);
*/

int main()
{
	cout << "hello!" << endl;
}
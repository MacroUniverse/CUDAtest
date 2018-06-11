This project should be the starting point for all future CUDA projects.

Two utilities are used:

1. the NR3 project

	Any file using nr3plus.h or nr3.h must have ".cu" extension. This is because nr3.h includes cu_complex.h, which has notations such as __device__ __host__.

	Update Note: nr3.h is modified to include cu_complex.h instead of <complex>, which has no std:: namespace, be very careful when updating. Not sure about nr3plus.h and nr3plus.cu, use github to compare before updating.

2. the Matfile project

	Edit Makefile to switch between binary mode and text mode, and set data precision.

	Update Note: matsave.cu has no change from matsave.cpp, just copy the latest matsave.cpp and matsave.h, and change .cpp to .cu.


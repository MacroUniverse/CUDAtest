# Makefile

exe = julia.x

# this project requires "MatFile_linux" github repository
sourcepath = ../../MatFile_linux/
libpath = ../../MatFile_linux/bin/

source = \
julia.cu \
nr3plus.cu \
matsave.cu

objects = $(source:.cu=.o)

compiler = nvcc

flags =  \
-arch=sm_60 \
-O3 \
-std=c++11 \
 -I $(sourcepath)
# -g
# -O3

libs = \
-Xcompiler \"-Wl,-rpath,$(libpath)\" \
-L$(libpath) \
-l mat \
-l mx
# -Wl,-rpath,$(libpath) \

$(exe):$(objects)
	$(compiler) -o $(exe) $(flags) $(objects) $(libs)

$(objects):$(source)
	$(compiler) -c $(flags) $(source)

# clean all except source
clean:
	rm -f *.o *.x *.gch Data/*.mat

# Makefile

exe = template.x

#========  settings for MatFile =================
ifeq (1,2)
    # binary mode
    MatPath = ../../MatFile_linux/
    MatCompile = -I $(MatPath) -D MATFILE_BINARY 
    MatLink = -Xcompiler \"-Wl,-rpath,$(MatPath)bin/\" -L$(MatPath)bin/ -l mat -l mx
else
    # text mode
    MatCompile = -D MATFILE_PRECISION=8
endif
#================================================

source = template.cu nr3plus.cu matsave.cu

objects = $(source:.cu=.o)

compiler = nvcc

flags =  -arch=sm_60 -O3 -std=c++11 
# -g -O3

$(exe):$(objects)
	$(compiler) -o $(exe) $(flags) $(objects) $(MatLink)

$(objects):$(source)
	$(compiler) -c $(flags) $(source) $(MatCompile) 

# clean all except source
clean:
	rm -f *.o *.x *.gch *.mat *.matt

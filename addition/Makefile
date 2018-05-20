# Makefile

exe = single_thread.x


# this project requires "MatFile_linux" github repository
#sourcepath = ../MatFile_linux/
#libpath = ../MatFile_linux/bin/


source = \
single_thread.cu

objects = $(source:.cu=.o)

#xsource = matsave.cpp

#xobjects = $(xsource:.cpp=.o)

compiler = nvcc

flags =  \
-O3 \
-std=c++11
#-I $(sourcepath)
# -g
# -O3

# what does this do? 
#-Wl,-rpath-link,$(libpath)

#libs = \
-Wl,-rpath,$(libpath) \
-L$(libpath) \
-l mat \
-l mx

$(exe):$(objects)
	$(compiler) -o $(exe) $(flags) $(objects) $(xobjects) $(libs)

$(objects):$(source)
	$(compiler) -c $(flags) $(source) $(sourcepath)$(xsource)

# must specify shared library directory
#run:
#	LD_LIBRARY_PATH=$(libpath) ./$(exe)

prof:
	nvprof ./$(exe)
# clean all except source
clean:
	rm -f *.o *.x *.gch


# Makefile

exe = cn2D.x


# this project requires "MatFile_linux" github repository
sourcepath = ../MatFile_linux/
libpath = ../MatFile_linux/bin/


source = \
cn2D.cpp \
cn2Dfun.cpp \
tridag.cpp \
interp_1d.cpp \
interp_2d.cpp

objects = $(source:.cpp=.o)

xsource = matsave.cpp

xobjects = $(xsource:.cpp=.o)

compiler = g++

flags =  \
-O3 \
-std=c++11 \
-I $(sourcepath)
# -g
# -O3

# what does this do? 
#-Wl,-rpath-link,$(libpath)

libs = \
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

# clean data files
clear:
	rm -f Data/*.mat

# clean all except source
clean:
	rm -f *.o *.x *.gch Data/*.mat


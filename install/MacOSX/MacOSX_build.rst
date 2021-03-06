Building on Mac OS X
--------------------

This procedure builds all components from scratch. If you've already
built GridLAB-D on your machine, please take note of the specific
GitHub branch requirements for TESP:

- feature/1146 for GridLAB-D
- develop for FNCS
- fncs-v8.3.0 for EnergyPlus

The Mac OS X build procedure is very similar to that for Linux,
and should be executed from the Terminal. For consistency among
platforms, this procedure uses gcc rather than clang.

When you finish the build, try RunExamples_.

Build GridLAB-D
~~~~~~~~~~~~~~~

Follow these directions:

::

 http://gridlab-d.shoutwiki.com/wiki/Mac_OSX/Setup

Install Python Packages, Java, updated GCC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

 cd /opt
 # may need sudo on the following steps to install for all users
 wget http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
 chmod +x Miniconda3-latest-Linux-x86_64.sh
 ./Miniconda3-latest-Linux-x86_64.sh
 conda update conda
 conda install pandas
 # tesp_support, including verification of PYPOWER dependency
 pip install tesp_support
 opf

 brew install gcc

 # also need Java, Cmake, autoconf, libtool

Checkout PNNL repositories from github
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

 mkdir ~/src
 cd ~/src
 git config --global (specify user.name, user.email, color.ui)
 git clone -b develop https://github.com/FNCS/fncs.git
 git clone -b feature/1146 https://github.com/gridlab-d/gridlab-d.git
 git clone -b fncs-v8.3.0 https://github.com/FNCS/EnergyPlus.git
 git clone -b master https://github.com/pnnl/tesp.git

FNCS with Prerequisites (installed to /usr/local)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

 cd ~/src
 wget --no-check-certificate http://download.zeromq.org/zeromq-4.1.3.tar.gz
 tar -xzf zeromq-4.1.3.tar.gz
 cd zeromq-4.1.3
 ./configure --without-libsodium 'CPP=gcc-7 -E' 'CXXPP=g++-7 -E' 'CC=gcc-7' 'CXX=g++-7'
 make
 sudo make install

 cd ..
 wget --no-check-certificate http://download.zeromq.org/czmq-3.0.2.tar.gz
 tar -xzf czmq-3.0.2.tar.gz
 cd czmq-3.0.2
 ./configure 'CPP=gcc-7 -E' 'CXXPP=g++-7 -E' 'CC=gcc-7' 'CXX=g++-7' 'CPPFLAGS=-Wno-format-truncation'
 make
 sudo make install

 cd ../fncs
 autoreconf -if
 ./configure 'CPP=gcc-7 -E' 'CXXPP=g++-7 -E' 'CC=gcc-7' 'CXX=g++-7' 'CXXFLAGS=-w -mmacosx-version-min=10.12' 'CFLAGS=-w -mmacosx-version-min=10.12'
 make
 sudo make install

 cd java
 mkdir build
 cd build
 cmake -DCMAKE_C_COMPILER="gcc-7" -DCMAKE_CXX_COMPILER="g++-7" ..
 make
 # copy jar and jni library to  tesp/examples/loadshed/java

GridLAB-D with Prerequisites (installed to /usr/local)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

 cd ~/src/gridlab-d
 autoreconf -isf

 cd third_party
 tar -xvzf xerces-c-3.1.1.tar.gz
 cd xerces-c-3.1.1
 ./configure 'CPP=gcc-7 -E' 'CXXPP=g++-7 -E' 'CC=gcc-7' 'CXX=g++-7' 'CXXFLAGS=-w' 'CFLAGS=-w'
 make
 sudo make install
 cd ../..

 ./configure --with-fncs=/usr/local 'CPP=gcc-7 -E' 'CXXPP=g++-7 -E' 'CC=gcc-7' 'CXX=g++-7' 'CXXFLAGS=-w' 'CFLAGS=-w'

 sudo make
 sudo make install
 # TODO - set the GLPATH?
 gridlabd --validate 

EnergyPlus with Prerequisites (installed to /usr/local)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

 sudo apt-get install libjsoncpp-dev
 cd ~/src/EnergyPlus
 mkdir build
 cd build
 cmake -DCMAKE_C_COMPILER="gcc-7" -DCMAKE_CXX_COMPILER="g++-7" ..
 make

 # Before installing, we need components of the public version, including but not limited 
	#   to the critical Energy+.idd file
 # The compatible public version is at https://github.com/NREL/EnergyPlus/releases/tag/v8.3.0
 # That public version should be installed to /usr/local/EnergyPlus-8-3-0 before going further

 sudo make install

 # Similar to the experience with Linux and Windows, this installation step wrongly puts
 #  the build products in /usr/local instead of /usr/local/bin and /usr/local/lib
 #  the following commands will copy FNCS-compatible EnergyPlus over the public version
 cd /usr/local
 cp energyplus-8.3.0 bin
 cp libenergyplusapi.8.3.0.dylib lib

 # if ReadVarsESO not found at the end of a simulation, try this
 /usr/local/EnergyPlus-8-3-0$ sudo ln -s PostProcess/ReadVarsESO ReadVarsESO

Build eplus_json
~~~~~~~~~~~~~~~~

::

 cd ~/src/tesp/src/energyplus
 # the following steps are also in go.sh
 autoheader
 aclocal
 automake --add-missing
 autoconf
 # edit configure.ac to use g++-7 on Mac
 ./configure
 make
 sudo make install



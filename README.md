a 2d Ising model simulator for Mac. 

- β	: the inverse temperature.
- m	: the average magnetization.

The size of the lattice is 1024x1024, 
and the boundary is fixed to be white. 

The x-range of the graph of the two-point function 
is from lattice separation 0 to 150.

- Uses [SMUGOpenCL](https://bitbucket.org/liscio/smugopencl-public) for OpenCL handling.
- Uses [SM2DGraphView](http://developer.snowmintcs.com/frameworks/sm2dgraphview/) for the graph.

__kernel void ising(
    const unsigned int size,
    __global int* spin,
    unsigned int parity,
    __global unsigned int* seed,
    __global float* weight)
{
    unsigned int j=get_global_id(0);
    unsigned int c=j/(size/2);
    unsigned int i=2*j+parity;
    if(c&1){
	i^=1;
    }
    unsigned int s=i/size;
    if(s==0 || s==size-1)
	return;
    unsigned int t = i % size;
    if(t==0 || t==size-1)
	return;
    int m=spin[i]*(spin[i+1]+spin[i-1]+spin[i+size]+spin[i-size]);
    seed[i]= 1664525*seed[i]+1013904223;
    float r=((float)(seed[i]))/UINT_MAX;
    if(weight[m+4]>r){
	spin[i]=-spin[i];
    }else{
	spin[i]=spin[i];
    }
}
/* __kernel void texture(
    unsigned int size,
    __global int*spin,
    __write_only image2d_t texture)
{
    int i=get_global_id(0);
    int2 coord=(int2)(i/size,i%size);
    uint4 color; 
    if(spin[i]==1){
	color=(uint4)(1,1,1,1);
    }else{
	color=(uint4)(0,0,0,1);
    }
    write_imageui(texture,coord,color); 
//  apparently it's not supported on my graphics card!
}*/
#version 330


layout(points) in;
layout (triangle_strip, max_vertices=20) out;

uniform sampler2D noise;
uniform mat4 m_pvm;
uniform float scale;
uniform int tesselation;
uniform float width;
uniform float altura;
uniform int SEED;

out Data {
    vec2 pos;
    vec2 TexCoords;
    vec4 square_normal;	
} DataOut;

//PERLIN NOISE 
//int SEED = 12;

int noise2(int x, int y)
{
    int hash[256] = int[256](208,34,231,213,32,248,233,56,161,78,24,140,71,48,140,254,245,255,247,247,40,
                     185,248,251,245,28,124,204,204,76,36,1,107,28,234,163,202,224,245,128,167,204,
                     9,92,217,54,239,174,173,102,193,189,190,121,100,108,167,44,43,77,180,204,8,81,
                     70,223,11,38,24,254,210,210,177,32,81,195,243,125,8,169,112,32,97,53,195,13,
                     203,9,47,104,125,117,114,124,165,203,181,235,193,206,70,180,174,0,167,181,41,
                     164,30,116,127,198,245,146,87,224,149,206,57,4,192,210,65,210,129,240,178,105,
                     228,108,245,148,140,40,35,195,38,58,65,207,215,253,65,85,208,76,62,3,237,55,89,
                     232,50,217,64,244,157,199,121,252,90,17,212,203,149,152,140,187,234,177,73,174,
                     193,100,192,143,97,53,145,135,19,103,13,90,135,151,199,91,239,247,33,39,145,
                     101,120,99,3,186,86,99,41,237,203,111,79,220,135,158,42,30,154,120,67,87,167,
                     135,176,183,191,253,115,184,21,233,58,129,233,142,39,128,211,118,137,139,255,
                     114,20,218,113,154,27,127,246,250,1,8,198,250,209,92,222,173,21,88,102,219);


    int tmp = hash[(y + SEED) % 256];
    return hash[(tmp + x) % 256];
}

float lin_inter(float x, float y, float s)
{
    return x + s * (y-x);
}

float smooth_inter(float x, float y, float s)
{
    return lin_inter(x, y, s * s * (3-2*s));
}

float noise2d(float x, float y)
{
    //highp int index = int(indexf);

    int x_int = int(x);
    int y_int = int(y);
    float x_frac = x - x_int;
    float y_frac = y - y_int;
    int s = noise2(x_int, y_int);
    int t = noise2(x_int+1, y_int);
    int u = noise2(x_int, y_int+1);
    int v = noise2(x_int+1, y_int+1);
    float low = smooth_inter(s, t, x_frac);
    float high = smooth_inter(u, v, x_frac);
    return smooth_inter(low, high, y_frac);
}

float perlin2d(vec2 position)
{
    float xa = position.x*0.1;//perlin_frequency;
    float ya = position.y*0.1;//perlin_frequency;
    float amp = 1.0;
    float fin = 0;
    float div = 0.0;

    int i;
    //4 is depth
    for(i=0; i<4; i++)
    {
        div += 256 * amp;
        fin += noise2d(xa, ya) * amp;
        amp /= 2;
        xa *= 2;
        ya *= 2;
    }

    return fin/div;
}
//////////////////////////////////


void main()
{    

    // Vertices
    //Parte de cima
    vec4 p[4];

    // Vertices~
    //Baixo
    vec4 j[4];


    // Normals
    vec4 n[4];

    vec4 pos = gl_in[0].gl_Position;

    //Calculara altura perlin noise
    float height = ceil(perlin2d(pos.xz)*altura)/10;

    // Certers refer to the position each
    // vertex of a square generated for 
    // each geometry shader
    vec2 centers[4];
    centers[0] = pos.xz + vec2(0,0);
    centers[1] = pos.xz + vec2(0,1);
    centers[2] = pos.xz + vec2(1,0);
    centers[3] = pos.xz + vec2(1,1);

    

    //float scale_x = 0.1;
    //float scale_z = 0.1;

    p[0] = vec4(((pos.x    )/tesselation)*width, height, ((pos.z    )/tesselation)*width, 1);
    p[1] = vec4(((pos.x    )/tesselation)*width, height, ((pos.z + 1)/tesselation)*width, 1);
    p[2] = vec4(((pos.x + 1)/tesselation)*width, height, ((pos.z    )/tesselation)*width, 1);
    p[3] = vec4(((pos.x + 1)/tesselation)*width, height, ((pos.z + 1)/tesselation)*width, 1);

    j[0] = vec4(((pos.x    )/tesselation)*width, height+0.1, ((pos.z    )/tesselation)*width, 1);
    j[1] = vec4(((pos.x    )/tesselation)*width, height+0.1, ((pos.z + 1)/tesselation)*width, 1);
    j[2] = vec4(((pos.x + 1)/tesselation)*width, height+0.1, ((pos.z    )/tesselation)*width, 1);
    j[3] = vec4(((pos.x + 1)/tesselation)*width, height+0.1, ((pos.z + 1)/tesselation)*width, 1);


    /*
    //Bottom
    for (int i = 0; i < 4; ++i)
    {
        float c  = height / tesselation;
        float x1 = height / tesselation;
        float x2 = height / tesselation;
        float z1 = height / tesselation;
        float z2 = height / tesselation;

        float x = ((x1-c)+(c-x2))*scale;
        float z = ((z1-c)+(c-z2))*scale;
        float y = sqrt(1-pow(x,2)-pow(z,2));
        n[i] = normalize(vec4(x,y,z,0));

	    gl_Position = m_pvm * (p[i]);
        DataOut.square_normal = -1*n[i]; // * m_normal
        DataOut.pos = centers[i];

        EmitVertex();
        if(i==0){
            DataOut.TexCoords =  vec2 (1,1);
        }
        else if (i==1){
            DataOut.TexCoords =  vec2(0,1);
        }
        else if (i==2){
            DataOut.TexCoords =  vec2(1,0);
        }
        else{
            DataOut.TexCoords =  vec2(0,0);
        }
    }
    EndPrimitive();
*/

    //Top
    for (int i = 0; i < 4; ++i)
    {

        
        float c  = height+0.1 / tesselation;
        float x1 = height+0.1 / tesselation;
        float x2 = height+0.1 / tesselation;
        float z1 = height+0.1 / tesselation;
        float z2 = height+0.1 / tesselation;

        float x = ((x1-c)+(c-x2))*scale;
        float z = ((z1-c)+(c-z2))*scale;
        float y = sqrt(1-pow(x,2)-pow(z,2));
        n[i] = normalize(vec4(x,y,z,0));

	    gl_Position = m_pvm * (j[i]);
        //DataOut.square_normal = normalize( vec4((c-x1)+(x2-c) , 1 , (c-z1)+(z2-c) , 0) );
        DataOut.square_normal = n[i]; // * m_normal
        DataOut.pos = centers[i];


        if(i==0){
            DataOut.TexCoords =  vec2(0,0);
        }
        else if (i==1){
            DataOut.TexCoords =  vec2(0,1);
        }
        else if (i==2){
            DataOut.TexCoords =  vec2(1,0);
        }
        else{
            DataOut.TexCoords =  vec2(1,1);
        }


        //DataOut.square_normal = vec4(0,1,0,0);
        EmitVertex();


    }
    EndPrimitive();
    
    //Back p(2,3) j(2,3)
    for (int i = 2; i < 4; ++i)
    {
        float c  = height+0.1 / tesselation;
        float x1 = height+0.1 / tesselation;
        float x2 = height+0.1 / tesselation;
        float z1 = height+0.1 / tesselation;
        float z2 = height+0.1 / tesselation;

        float x = ((x1-c)+(c-x2))*scale;
        float z = ((z1-c)+(c-z2))*scale;
        float y = sqrt(1-pow(x,2)-pow(z,2));
        n[i] = normalize(vec4(x,y,z,0));

	    gl_Position = m_pvm * (j[i]);
        
        DataOut.square_normal = n[i]; 
        DataOut.pos = centers[i];


        if (i==2){
            DataOut.TexCoords =  vec2(1,0);
        }
        else{
            DataOut.TexCoords =  vec2(1,1);
        }

        EmitVertex();       

    }
    for (int i = 2; i < 4; ++i)
    {
        float c  = height+0.1 / tesselation;
        float x1 = height+0.1 / tesselation;
        float x2 = height+0.1 / tesselation;
        float z1 = height+0.1 / tesselation;
        float z2 = height+0.1 / tesselation;

        float x = ((x1-c)+(c-x2))*scale;
        float z = ((z1-c)+(c-z2))*scale;
        float y = sqrt(1-pow(x,2)-pow(z,2));
        n[i] = normalize(vec4(x,y,z,0));

	    gl_Position = m_pvm * (p[i]);
        DataOut.square_normal = -n[i]; 
        DataOut.pos = centers[i];
        if (i==2){
            DataOut.TexCoords =  vec2(0,0);
        }
        else{
            DataOut.TexCoords =  vec2(0,1);
        }
        EmitVertex();


    }
EndPrimitive();  
    //Front p(0,2) j(0,2)
    for (int i = 0; i < 2; ++i)
    {
        float c  = height+0.1 / tesselation;
        float x1 = height+0.1 / tesselation;
        float x2 = height+0.1 / tesselation;
        float z1 = height+0.1 / tesselation;
        float z2 = height+0.1 / tesselation;

        float x = ((x1-c)+(c-x2))*scale;
        float z = ((z1-c)+(c-z2))*scale;
        float y = sqrt(1-pow(x,2)-pow(z,2));
        n[i] = normalize(vec4(x,y,z,0));

	    gl_Position = m_pvm * (j[i]);

        DataOut.square_normal = n[i]; 
        DataOut.pos = centers[i];
        if(i==0){
            DataOut.TexCoords =  vec2(1,1);
        }
        else{
            DataOut.TexCoords =  vec2(1,0);
        }        
        EmitVertex();
    }
    for (int i = 0; i < 2; ++i)
    {
        float c  = height+0.1 / tesselation;
        float x1 = height+0.1 / tesselation;
        float x2 = height+0.1 / tesselation;
        float z1 = height+0.1 / tesselation;
        float z2 = height+0.1 / tesselation;

        float x = ((x1-c)+(c-x2))*scale;
        float z = ((z1-c)+(c-z2))*scale;
        float y = sqrt(1-pow(x,2)-pow(z,2));
        n[i] = normalize(vec4(x,y,z,0));

	    gl_Position = m_pvm * (p[i]);

        DataOut.square_normal = n[i]; 
        DataOut.pos = centers[i];
        if(i==0){
            DataOut.TexCoords =  vec2(0,1);
        }
        else{
            DataOut.TexCoords =  vec2(0,0);
        }

        EmitVertex();


    }
EndPrimitive();  
    //Right p(1,3) j(1,3)
    for (int i = 1; i < 4; i=i+2)
    {
        float c  = height+0.1 / tesselation;
        float x1 = height+0.1 / tesselation;
        float x2 = height+0.1 / tesselation;
        float z1 = height+0.1 / tesselation;
        float z2 = height+0.1 / tesselation;

        float x = ((x1-c)+(c-x2))*scale;
        float z = ((z1-c)+(c-z2))*scale;
        float y = sqrt(1-pow(x,2)-pow(z,2));
        n[i] = normalize(vec4(x,y,z,0));

	    gl_Position = m_pvm * (j[i]);

        DataOut.square_normal = -1*n[i]; 
        DataOut.pos = centers[i];
        if(i==1){
            DataOut.TexCoords =  vec2(1,0);
        }
        else if (i==3){
            DataOut.TexCoords =  vec2(1,1);
        }
        EmitVertex();
        
    }
    for (int i = 1; i < 4; i=i+2)
    {
        float c  = height+0.1 / tesselation;
        float x1 = height+0.1 / tesselation;
        float x2 = height+0.1 / tesselation;
        float z1 = height+0.1 / tesselation;
        float z2 = height+0.1 / tesselation;

        float x = ((x1-c)+(c-x2))*scale;
        float z = ((z1-c)+(c-z2))*scale;
        float y = sqrt(1-pow(x,2)-pow(z,2));
        n[i] = normalize(vec4(x,y,z,0));
	    gl_Position = m_pvm * (p[i]);
        DataOut.square_normal = -1*n[i]; 
        DataOut.pos = centers[i];
        if (i==1){
            DataOut.TexCoords =  vec2(0,0);
        }
        else{
            DataOut.TexCoords =  vec2(0,1);
        }
        EmitVertex();


    }
EndPrimitive();  
    //Left p(0,3) j(1,3)
    for (int i = 0; i < 3; i=i+2)
    {
        float c  = height+0.1 / tesselation;
        float x1 = height+0.1 / tesselation;
        float x2 = height+0.1 / tesselation;
        float z1 = height+0.1 / tesselation;
        float z2 = height+0.1 / tesselation;

        float x = ((x1-c)+(c-x2))*scale;
        float z = ((z1-c)+(c-z2))*scale;
        float y = sqrt(1-pow(x,2)-pow(z,2));
        n[i] = normalize(vec4(x,y,z,0));

	    gl_Position = m_pvm * (j[i]);

        DataOut.square_normal = n[i]; 
        DataOut.pos = centers[i];
        if(i==0){
            DataOut.TexCoords =  vec2(1,0);
        }
        else if (i==2){
            DataOut.TexCoords =  vec2(1,1);
        }
        EmitVertex();



    }
    
    for (int i = 0; i < 3; i=i+2)
    {
        float c  = height+0.1 / tesselation;
        float x1 = height+0.1 / tesselation;
        float x2 = height+0.1 / tesselation;
        float z1 = height+0.1 / tesselation;
        float z2 = height+0.1 / tesselation;

        float x = ((x1-c)+(c-x2))*scale;
        float z = ((z1-c)+(c-z2))*scale;
        float y = sqrt(1-pow(x,2)-pow(z,2));
        n[i] = normalize(vec4(x,y,z,0));

	    gl_Position = m_pvm * (p[i]);

        DataOut.square_normal = n[i]; 
        DataOut.pos = centers[i];
        if (i==0){
            DataOut.TexCoords =  vec2(0,0);
        }
        else{
            DataOut.TexCoords =  vec2(0,1);
        }
        EmitVertex();


    }
    EndPrimitive();   
    

}


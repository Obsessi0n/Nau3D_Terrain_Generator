#version 420

uniform mat4 view_matrix;
uniform vec4 light_dir;
uniform vec4 diffuse;
uniform sampler2D noise;
uniform sampler2D stone;
uniform sampler2D snow;
uniform sampler2D grass;
uniform sampler2D Water;
uniform int tesselation;
uniform int TEXSEED;
uniform mat4 m_pvm;
in Data {
	vec2 pos;
	vec2 TexCoords;
    float water;
    vec3 normal;
	vec4 posicao;
} DataIn;


out vec4 colorOut;

//PERLIN NOISE 
//int semente = 12;

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
    int tmp = hash[(y + TEXSEED) % 256];
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
float noise2d(float x, float y){
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
    float xa = position.x*0.04;//perlin_frequency;
    float ya = position.y*0.04;//perlin_frequency;
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
	float intensity;
	vec3 n, l;
    vec4 diffuse;

	l = normalize(vec3(m_pvm * -light_dir));



	n = normalize(DataIn.normal);

	intensity = max(dot(n,l),0.0);




	float height = perlin2d(DataIn.posicao.xz);

    /*if(DataIn.water == 1){
        diffuse = texture(Water, DataIn.TexCoords);
    }
    else
    {
        */
    if(height<=0.25){
        diffuse = texture(stone, DataIn.TexCoords);

	}
    else if(height > 0.25 && height < 0.5){
        diffuse = texture(noise, DataIn.TexCoords);

	}
    	else if(height>= 0.5 && height <0.75){
        diffuse = texture(grass, DataIn.TexCoords);

	}
    else{
        diffuse = texture(snow, DataIn.TexCoords);
        
	}
	
    //}

    vec4 eColor = (intensity + 0.35) * diffuse;
	colorOut = vec4(vec3(eColor),0.1);




}
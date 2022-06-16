#version 420

uniform mat4 view_matrix;
uniform vec4 light_dir;
uniform vec4 diffuse;
uniform sampler2D noise;
uniform int tesselation;

in Data {
	vec2 pos;
	vec2 TexCoords;
	vec4 square_normal;
} DataIn;


out vec4 colorOut;


void main() 
{
	float intensity;
	vec3 n, l;

	l = normalize(vec3(view_matrix * -light_dir));
	n = normalize(DataIn.square_normal.xyz);
	intensity = max(dot(l,n),0.0);

	//colorOut = (height_color * intensity) + height_color * 0.2;

	vec4 eColor = texture(noise, DataIn.TexCoords)+intensity * 0.2;
	colorOut = eColor;

}
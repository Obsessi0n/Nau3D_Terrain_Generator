#version 330

uniform int tesselation;

void main () {

	vec4 pos;

	
	pos.x = gl_InstanceID / tesselation;
	pos.z = gl_InstanceID % tesselation;

	pos.y = 0; pos.w = 1;	
	//pos.xyz = pos.xyz * 0.15;
	
	
	gl_Position = pos;
}
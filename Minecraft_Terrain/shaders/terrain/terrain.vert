#version 330

uniform int tesselation;



out Data {
	vec3 normal;
}DataOut;
void main () {

	vec4 pos;

	pos.x = gl_InstanceID / tesselation;
	pos.z = gl_InstanceID % tesselation;
	pos.y = 0; pos.w = 1;		

	
	gl_Position = pos;
}
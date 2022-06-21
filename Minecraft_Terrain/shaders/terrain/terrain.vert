#version 330

uniform int tesselation;

///
uniform	mat4 m_pvm;
uniform	mat4 m_viewModel;
uniform	mat4 m_view;
uniform	mat3 m_normal;

uniform	vec4 l_dir;	   // global space

in vec4 position;	// local space
in vec3 normal;		// local space
in vec2 texCoord0;
///

out Data {
	vec2 texCoord;
	vec3 normal;	
}DataOut;


void main () {
	DataOut.texCoord = texCoord0;
	
	vec4 pos;

	pos.x = gl_InstanceID / tesselation;
	pos.z = gl_InstanceID % tesselation;
	pos.y = 0; pos.w = 1;		

	
	gl_Position = pos;
}
#version 330

uniform sampler2D tex;
uniform float shininess = 128;

in Data {
	vec2 texCoord;
} DataIn;

out vec4 colorOut;

void main() {

	// get texture color
	colorOut = texture(tex, DataIn.texCoord);
}
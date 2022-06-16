#version 420

uniform mat4 view_matrix;
uniform vec4 light_dir;
uniform vec4 diffuse;
uniform sampler2D noise;
uniform int tesselation;

in Data {
	vec2 pos;
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

	vec4 height_color;

	// Color constants:
	vec4 deep_water      = vec4(0.243, 0.376, 0.729,1);
	vec4 water           = vec4(0.368, 0.494, 1,1);
	vec4 land            = vec4(0.454, 0.662, 0.388,1);
	vec4 forest          = vec4(0.239, 0.501, 0.403,1);
	vec4 lower_mountain  = vec4(0.647, 0.745, 0.494,1);
	vec4 middle_mountain = vec4(0.772, 0.847, 0.729,1);
	vec4 high_mountain   = vec4(0.835, 0.827, 0.839,1);

	float height = texture(noise,DataIn.pos/tesselation).x;

	

	if(height < 0.1) // DEEP WATER
	{
		height_color = deep_water;
	}
	else if (height < 0.2) // WATER
	{
		height_color = mix(deep_water, water, (height - 0.1) * (1/0.1));
		
		//height_color = vec4(0.368, 0.494, 1,1);
	}
  	else if (height < 0.3) // LAND
	{
		height_color = mix(water, land, (height - 0.2) * (1/0.1));
		//height_color = vec4(0.454, 0.662, 0.388,1);
	}
  	else if (height< 0.5) // FOREST
	{
		height_color = mix(land, forest, (height - 0.3) * (1/0.2));
		//height_color = vec4(0.239, 0.501, 0.403,1);
	}
  	else if (height< 0.7) // LOWER MOUNTAIN
	{
		height_color = mix(forest, lower_mountain, (height - 0.5) * (1/0.2));
		//height_color = vec4(0.647, 0.745, 0.494,1);
	}
  	else if (height< 0.9) // MIDDLE MOUNTAIN
	{
		height_color = mix(lower_mountain, middle_mountain, (height - 0.7) * (1/0.2));
	  	//height_color = vec4(0.772, 0.847, 0.729,1);
	}
  	else // HIGH MOUNTAIN
	{
		height_color = mix(middle_mountain, high_mountain, (height - 0.9) * (1/0.1));
	  	//height_color = vec4(0.835, 0.827, 0.839,1);
	}
	
	//colorOut = (height_color * intensity) + height_color * 0.2;
	//vec4 eColor = texture(noise, DataIn.texCoord);
	//colorOut = eColor;

	//Dirt texture
	colorOut = texture(dirt, pos);
}
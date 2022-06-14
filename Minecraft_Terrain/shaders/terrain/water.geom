#version 330

layout(points) in;
layout (triangle_strip, max_vertices=4) out;

uniform mat4 m_pvm;
uniform int tesselation;
uniform float width;

void main()
{
    // Vertices
    vec4 p[4];
    // Normals
    vec4 n[4];

    vec4 pos = gl_in[0].gl_Position;

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

    p[0] = vec4(((pos.x    )/tesselation)*width, 0, ((pos.z    )/tesselation)*width, 1);
    p[1] = vec4(((pos.x    )/tesselation)*width, 0, ((pos.z + 1)/tesselation)*width, 1);
    p[2] = vec4(((pos.x + 1)/tesselation)*width, 0, ((pos.z    )/tesselation)*width, 1);
    p[3] = vec4(((pos.x + 1)/tesselation)*width, 0, ((pos.z + 1)/tesselation)*width, 1);

    
    
    for (int i = 0; i < 4; ++i)
    {
	    gl_Position = m_pvm * (p[i]);
        EmitVertex();
    }
    
    EndPrimitive();
}


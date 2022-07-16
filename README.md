# Nau3D Terrain_Generator

This project was produced for a subject (Visualização em Tempo Real) at Universidade of Minho 2021/2022.

The goal was to create a terraing generator using NAU3D (https://github.com/Nau3D/nau) that runs on top of OpenGL + Optix 7 (WIP) + Lua + ImGui.

We decided to create a terrain similar to Minecraft using vertex shadders, geometry shadders and fragment shadders.

We used the geometry shadders to draw a cube with 24 vertex and 6 faces, and we calculated it's height using perlin noise.

On the fragment shadder we used another perlin noise to decide what texture the cube should have.

All these parameters can be changed in runtime.

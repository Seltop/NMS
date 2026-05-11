#version 330 core

#include "/lib/settings.glsl"

in vec3 normal;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = vec4(normal * 0.5 + 0.5, 1.0);
}

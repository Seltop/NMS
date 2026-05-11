#version 330 core

#include "/lib/settings.glsl"

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;
uniform mat4 gbufferModelViewInverse;
uniform vec3 chunkOffset;

in vec3 vaPosition;
in vec3 vaNormal;

out vec3 normal;

void main() {
	normal = vec3(0.0);
	#ifdef RENDER_CLOUDS
		gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition + chunkOffset, 1.0);
		normal = normalize(mat3(gbufferModelViewInverse) * normalMatrix * normalize(vaNormal));
	#else 
		gl_Position = vec4(-2.0, -2.0, -2.0, 1.0);
	#endif
}

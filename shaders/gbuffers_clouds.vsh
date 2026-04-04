#version 330 compatibility

#include "/lib/settings.glsl"

uniform mat4 gbufferModelViewInverse;

out vec3 normal;

void main() {
	#ifdef RENDER_CLOUDS
		gl_Position = ftransform();
		normal = mat3(gbufferModelViewInverse) * gl_NormalMatrix * gl_Normal;
	#else 
		gl_Position = vec4(-1.0);
	#endif
}
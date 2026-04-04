#version 330 compatibility

#include "/lib/settings.glsl"

uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;

in vec2 texCoord;
in vec3 normal;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	vec4 baseColor = texture(gtexture, texCoord);
	if (baseColor.a < alphaTestRef) {
		discard;
	}
	#if NORMAL_SCALE == SCALE_NORM
		color = vec4(normal * 0.5 + 0.5, 1.0);
	#else 
		color = vec4(normal, 1.0);
	#endif
}
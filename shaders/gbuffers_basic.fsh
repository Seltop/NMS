#version 330 core

#include "/lib/settings.glsl"

uniform sampler2D gtexture;
uniform float alphaTestRef;

in vec2 texCoord;
in vec3 normal;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	vec4 baseColor = texture(gtexture, texCoord);
	if (baseColor.a < max(alphaTestRef, 0.001)) {
		discard;
	}
	color = vec4(normal * 0.5 + 0.5, 1.0);
}

#version 330 compatibility

uniform mat4 gbufferModelViewInverse;

out vec2 texCoord;
out vec3 normal;
out vec4 vertColor;

void main() {
	gl_Position = ftransform();
	texCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	normal = mat3(gbufferModelViewInverse) * gl_NormalMatrix * gl_Normal;
	vertColor = gl_Color;
}

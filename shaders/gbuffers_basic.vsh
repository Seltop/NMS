#version 330 core

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;
uniform mat4 textureMatrix;
uniform mat4 gbufferModelViewInverse;
uniform vec3 chunkOffset;

in vec3 vaPosition;
in vec3 vaNormal;
in vec2 vaUV0;

out vec2 texCoord;
out vec3 normal;

void main() {
	gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition + chunkOffset, 1.0);
	texCoord = (textureMatrix * vec4(vaUV0, 0.0, 1.0)).xy;
	normal = normalize(mat3(gbufferModelViewInverse) * normalMatrix * normalize(vaNormal));
}

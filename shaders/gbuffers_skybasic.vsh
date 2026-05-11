#version 330 core

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform int renderStage;

in vec3 vaPosition;

void main() {
    if (renderStage != MC_RENDER_STAGE_SKY) {
        gl_Position = vec4(-2.0, -2.0, -2.0, 1.0);
    } else {
        gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition, 1.0);
    }
}

#version 330 compatibility

uniform int renderStage;

void main() {
    if (renderStage != MC_RENDER_STAGE_SKY) {
        gl_Position = vec4(-1.0);
    } else {
        gl_Position = ftransform();
    }
}
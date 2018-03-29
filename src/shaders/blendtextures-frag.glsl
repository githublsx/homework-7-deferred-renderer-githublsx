#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform sampler2D u_frame2;
uniform float u_Time;
uniform float u_Radius;
uniform float u_Width;
uniform float u_Height;

// Interpolation between color and greyscale over time on left half of screen
void main() {

    out_Col = vec4(u_Radius * texture(u_frame2, fs_UV).rgb + texture(u_frame, fs_UV).rgb, 1.0);
}

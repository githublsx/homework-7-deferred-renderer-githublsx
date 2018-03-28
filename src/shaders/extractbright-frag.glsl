#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;
uniform float u_Radius;
uniform float u_Width;
uniform float u_Height;

// Interpolation between color and greyscale over time on left half of screen
void main() {
	vec3 color = texture(u_frame, fs_UV).xyz;
    float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
    if(brightness > 0.6)
    out_Col = vec4(color, 1.0);
}

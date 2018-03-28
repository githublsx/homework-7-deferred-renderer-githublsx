#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;


vec3 Uncharted2Tonemap(vec3 x)
{
	//http://filmicworlds.com/blog/filmic-tonemapping-operators/
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
	x *= 16.0;
   return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}


void main() {
	// TODO: proper tonemapping
	// This shader just clamps the input color to the range [0, 1]
	// and performs basic gamma correction.
	// It does not properly handle HDR values; you must implement that.

	vec3 color = texture(u_frame, fs_UV).xyz;
	color = Uncharted2Tonemap(color);
	//color = min(vec3(1.0), color);


	// gamma correction
	//color = pow(color, vec3(1.0 / 2.2));
	out_Col = vec4(color, 1.0);
}

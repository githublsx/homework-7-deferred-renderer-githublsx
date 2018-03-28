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
const float focus = 0.75;

//https://www.shadertoy.com/view/XdfGDH
float normpdf(in float x, in float sigma)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

// Interpolation between color and greyscale over time on left half of screen
void main() {
		
    //declare stuff
    const int mSize = 11;
    const int kSize = (mSize-1)/2;
    float kernel[mSize];
    vec3 blurcolor = vec3(0.0);
    float depth = 1.0 - texture(u_frame2, fs_UV).w;
    float dist = abs(depth - focus);
    
    //create the 1-D kernel
    float sigma = 10.0 * dist;
    float Z = 0.0;
    for (int j = 0; j <= kSize; ++j)
    {
        kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
    }
    
    //get the normalization factor (as the gaussian has been clamped)
    for (int j = 0; j < mSize; ++j)
    {
        Z += kernel[j];
    }
    
    //read out the texels
    for (int i=-kSize; i <= kSize; ++i)
    {
        for (int j=-kSize; j <= kSize; ++j)
        {
            blurcolor += kernel[kSize+j]*kernel[kSize+i]*texture(u_frame, (fs_UV * vec2(u_Width, u_Height)+vec2(float(i),float(j))) / vec2(u_Width, u_Height)).rgb;

        }
    }

    blurcolor /= (Z*Z);
    // vec3 originalcolor = texture(u_frame, fs_UV).xyz;
    // vec3 finalcolor = mix(originalcolor, blurcolor, dist);
    
    out_Col = vec4(blurcolor, 1.0);
}

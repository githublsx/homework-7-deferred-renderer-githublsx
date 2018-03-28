#version 300 es
precision highp float;

in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;
in vec2 fs_UV;
in vec4 fs_GlPos;

out vec4 fragColor[3]; // The data in the ith index of this array of outputs
                       // is passed to the ith index of OpenGLRenderer's
                       // gbTargets array, which is an array of textures.
                       // This lets us output different types of data,
                       // such as albedo, normal, and position, as
                       // separate images from a single render pass.

uniform sampler2D tex_Color;
uniform float u_Near;
uniform float u_Far;

void main() {
    // TODO: pass proper data into gbuffers
    // Presently, the provided shader passes "nothing" to the first
    // two gbuffers and basic color to the third.

    vec3 col = texture(tex_Color, fs_UV).rgb;

    // if using textures, inverse gamma correct
    col = pow(col, vec3(2.2));

    //fragColor[0] = vec4(fs_Nor.xyz, -fs_GlPos.z / fs_GlPos.w);
    fragColor[0] = vec4(fs_Nor.xyz, (-fs_Pos.z - u_Near) / (u_Far - u_Near));
    fragColor[1] = vec4(gl_FragCoord);
    fragColor[2] = vec4(col, 1.0);
}

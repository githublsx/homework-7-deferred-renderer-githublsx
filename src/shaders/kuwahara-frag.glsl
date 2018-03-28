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
	// vec3 color = texture(u_frame, fs_UV).xyz;
	// vec3 color2 = vec3(dot(color, vec3(0.2126, 0.7152, 0.0722)));
	// float t = sin(3.14 * u_Time) * 0.5 + 0.5;
	// t *= 1.0 - step(0.5, fs_UV.x);
	// color = mix(color, color2, smoothstep(0.0, 1.0, t));
	// out_Col = vec4(color.xzy, 1.0);


    int loopTimes = int(u_Radius);

	 vec2 src_size = vec2 (1.0 / u_Width, 1.0 / u_Height);
     float n = (u_Radius + 1.0) * (u_Radius + 1.0);

     int i; 
	 int j;

     vec3 m0 = vec3(0.0); vec3 m1 = vec3(0.0); vec3 m2 = vec3(0.0); vec3 m3 = vec3(0.0);
     vec3 s0 = vec3(0.0); vec3 s1 = vec3(0.0); vec3 s2 = vec3(0.0); vec3 s3 = vec3(0.0);
     vec3 c;

     for (int j = -loopTimes; j <= 0; ++j)  {
         for (int i = -loopTimes; i <= 0; ++i)  {
             c = texture(u_frame, fs_UV + vec2(i,j) * src_size).rgb;
             m0 += c;
             s0 += c * c;
         }
     }

     for (int j = -loopTimes; j <= 0; ++j)  {
         for (int i = 0; i <= loopTimes; ++i)  {
             c = texture(u_frame, fs_UV + vec2(i,j) * src_size).rgb;
             m1 += c;
             s1 += c * c;
         }
     }

     for (int j = 0; j <= loopTimes; ++j)  {
         for (int i = 0; i <= loopTimes; ++i)  {
             c = texture(u_frame, fs_UV + vec2(i,j) * src_size).rgb;
             m2 += c;
             s2 += c * c;
         }
     }

     for (int j = 0; j <= loopTimes; ++j)  {
         for (int i = -loopTimes; i <= 0; ++i)  {
             c = texture(u_frame, fs_UV + vec2(i,j) * src_size).rgb;
             m3 += c;
             s3 += c * c;
         }
     }


     float min_sigma2 = 100.0;
     m0 /= n;
     s0 = abs(s0 / n - m0 * m0);

     float sigma2 = s0.r + s0.g + s0.b;
     if (sigma2 < min_sigma2) {
         min_sigma2 = sigma2;
         out_Col = vec4(m0, 1.0);
     }

     m1 /= n;
     s1 = abs(s1 / n - m1 * m1);

     sigma2 = s1.r + s1.g + s1.b;
     if (sigma2 < min_sigma2) {
         min_sigma2 = sigma2;
         out_Col = vec4(m1, 1.0);
     }

     m2 /= n;
     s2 = abs(s2 / n - m2 * m2);

     sigma2 = s2.r + s2.g + s2.b;
     if (sigma2 < min_sigma2) {
         min_sigma2 = sigma2;
         out_Col = vec4(m2, 1.0);
     }
}

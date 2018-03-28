#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;
uniform float u_Radius;
uniform float u_Width;
uniform float u_Height;

//https://www.shadertoy.com/view/4djSRW
vec3 N31(float p) {
    //  3 out, 1 in... DAVE HOSKINS
   vec3 p3 = fract(vec3(p) * vec3(.1031,.11369,.13787));
   p3 += dot(p3, p3.yzx + 19.19);
   return fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

float SawTooth(float t) {
    return cos(t+cos(t))+sin(2.*t)*.2+sin(4.*t)*.02;
}

vec2 GetDrops(vec2 uv, float seed) {
    float t = u_Time;
    uv.y += t * 0.05;                               // make all uvs downwards
    uv *= vec2(40., 5.);
    vec2 id = floor(uv);                            // id to generate random vec3
    vec3 n = N31(id.x + (id.y+seed)*546.3524);      // random vec3
    vec2 bd = fract(uv);                            // 0 ~ 1 uv
    bd -= .5;								        // offset to center
    //float bdy = bd.y;
    bd.y*=4.;
    bd.x += (n.x-.5)*.6;                            // offset for x and y direction
    t += n.z * 6.;								    // make drops begin to slide down randomly
    float slide = SawTooth(t);
    bd.y += slide*2.;								// make drops slide down
    //bd.x += slide*0.5;
    float d = length(bd);							// distance to center of the drop
    vec2 normalbd = normalize(bd);
    float temp = -0.10 * normalbd.y + 0.20;
    //float temp = 0.2 * normalbd.y + -0.20;
    float mainDrop = smoothstep(temp, .1, d);
    return bd*mainDrop;
}

void main()
{
	vec2 uv = fs_UV;
    vec2 offs = vec2(0.);
    offs = GetDrops(uv*0.5, 1.);
    //offs += GetDrops2(uv*0.5, 1.);
    offs += GetDrops(uv*2., 25.);

    const vec2 lensRadius 	= vec2(1.5, 0.05);//vec2(0.65*1.5, 0.05);
    float dist = distance(uv.xy, vec2(0.5,0.5));
    float vigfin = pow(1.-smoothstep(lensRadius.x, lensRadius.y, dist),2.);
   
    offs *= vigfin*10.0;
    uv -= offs;


    out_Col = texture(u_frame, uv-offs);
	//fragColor = vec4(uv,0.5+0.5*sin(iTime),1.0);
}

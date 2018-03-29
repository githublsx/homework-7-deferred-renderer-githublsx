#version 300 es
precision highp float;

#define EPS 0.0001
#define PI 3.1415962

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb0;
uniform sampler2D u_gb1;
uniform sampler2D u_gb2;

uniform float u_Time;

uniform mat4 u_View;
uniform vec4 u_CamPos;   

uniform float u_Width;
uniform float u_Height;

const vec3 lightDir = normalize(vec3(1.0, 1.0, 1.0));

const vec3 BackColor	= vec3(0.0, 0.4, 0.58);
const vec3 CloudColor	= vec3(0.18,0.70,0.87);


float Func(float pX)
{
	return 0.6*(0.5*sin(0.1*pX) + 0.5*sin(0.553*pX) + 0.7*sin(1.2*pX));
}


float FuncR(float pX)
{
	return 0.5 + 0.25*(1.0 + sin(mod(40.0*pX, PI * 2.0)));
}


float Layer(vec2 pQ, float pT)
{
	vec2 Qt = 3.5*pQ;
	pT *= 0.5;
	Qt.x += pT;

	float Xi = floor(Qt.x);
	float Xf = Qt.x - Xi -0.5;

	vec2 C;
	float Yi;
	float D = 1.0 - step(Qt.y,  Func(Qt.x));

	// Disk:
	Yi = Func(Xi + 0.5);
	C = vec2(Xf, Qt.y - Yi ); 
	D =  min(D, length(C) - FuncR(Xi+ pT/80.0));

	// Previous disk:
	Yi = Func(Xi+1.0 + 0.5);
	C = vec2(Xf-1.0, Qt.y - Yi ); 
	D =  min(D, length(C) - FuncR(Xi+1.0+ pT/80.0));

	// Next Disk:
	Yi = Func(Xi-1.0 + 0.5);
	C = vec2(Xf+1.0, Qt.y - Yi ); 
	D =  min(D, length(C) - FuncR(Xi-1.0+ pT/80.0));

	return min(1.0, D);
}

vec3 BackgroundCol()
{
	//https://www.shadertoy.com/view/4t23RR
	// Setup:
	vec2 UV = 1.5 * fs_UV + 0.1 * vec2(-u_CamPos.x, -u_CamPos.y + 9.0);
	UV.x *=  u_Width /u_Height;
	
	// Render:
	vec3 Color= BackColor;

	for(float J=0.0; J<=0.4; J+=0.2)
	{
		// Cloud Layer: 
		float Lt =  u_Time*(0.5  + 2.0*J)*(1.0 + 0.1*sin(226.0*J)) + 17.0*J;
		vec2 Lp = vec2(0.0, 0.3+1.5*( J - 0.5));
		float L = Layer(UV + Lp, Lt);

		// Blur and color:
		float Blur = 4.0*(0.5*abs(2.0 - 5.0*J))/(11.0 - 5.0*J);

		float V = mix( 0.0, 1.0, 1.0 - smoothstep( 0.0, 0.01 +0.2*Blur, L ) );
		vec3 Lc=  mix( CloudColor, vec3(1.0), J);

		Color =mix(Color, Lc,  V);
	}

	return Color;
}

vec3 BackgroundCol2()
{
	//https://www.shadertoy.com/view/4dl3zn
	vec2 uv = fs_UV;
	uv.x *=  u_Width /u_Height;
	vec3 color = vec3(0.8 + 0.2*uv.y);

	// bubbles	
	for( int i=0; i<10; i++ )
	{
		// bubble seeds
		float pha =      sin(float(i)*546.13+1.0)*0.5 + 0.5;
		float siz = pow( sin(float(i)*651.74+5.0)*0.5 + 0.5, 4.0 );
		float pox =      sin(float(i)*321.55+4.1) * u_Width /u_Height;

		// buble size, position and color
		float rad = 0.4 + 0.2*siz;
		vec2  pos = vec2( pox, -1.0-rad + (2.0+2.0*rad)*mod(pha+0.1*u_Time*(0.2+0.8*siz),1.0));
		float dis = length( uv - pos );
		vec3  col = mix( vec3(0.94,0.3,0.0), vec3(0.1,0.4,0.8), 0.5+0.5*sin(float(i)*1.2+1.9));
		//    col+= 8.0*smoothstep( rad*0.95, rad, dis );
		
		// render
		float f = length(uv-pos)/rad;
		f = sqrt(clamp(1.0-f*f,0.0,1.0));
		color -= col.zyx *(1.0-smoothstep( rad*0.95, rad, dis )) * f;
	}

	// vigneting	
	color *= sqrt(1.5-0.5*length(uv));
	return color;
}

void main() { 
	// read from GBuffers
	vec4 gb0 = texture(u_gb0, fs_UV);//nor
	vec4 gb1 = texture(u_gb1, fs_UV);//pos
	vec4 gb2 = texture(u_gb2, fs_UV);//col

    vec3 nor = gb0.xyz;
	vec3 pos = gb1.xyz;
	vec3 col = gb2.xyz;

	float lambert = max(dot(lightDir, nor), 0.0);

//https://learnopengl-cn.readthedocs.io/zh/latest/05%20Advanced%20Lighting/01%20Advanced%20Lighting/
	//vec3 lightDir = normalize(lightPos - FragPos);
	vec3 viewDir = normalize(vec3(0.0) - pos);
	vec3 halfwayDir = normalize(lightDir + vec3(0.0) );
	float spec = pow(max(dot(nor, halfwayDir), 0.0), 10.0);
	float ambient = 0.1;


    float depth = 1.0 - gb0.w;
	// background	
	vec3 color = vec3(0.0); 
	if(depth == 0.0)
	{
		color = BackgroundCol();
	}
	else
	{
		color = col * (lambert + ambient + spec * 5.0) + spec * 0.1 * CloudColor + ambient * 0.75 * BackColor;
	}

	out_Col = vec4(color, 1.0);
	//out_Col = vec4(vec3(1.0 - gb0.w), 1.0);
}
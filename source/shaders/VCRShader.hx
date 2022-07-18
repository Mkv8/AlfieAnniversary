package shaders;

import haxe.Timer;
import flixel.system.FlxAssets.FlxShader;

class VCRShader extends FlxShader
{
	@:glFragmentSource('
#pragma header

uniform float iTime;

vec4 getVideo(vec2 uv)
{
	return flixel_texture2D(bitmap, uv);
}

float random(vec2 uv)
{
	return fract(sin(dot(uv, vec2(15.5151, 42.2561))) * 12341.14122 * sin(iTime * 0.03));
}

float noise(vec2 uv)
{
	vec2 i = floor(uv);
	vec2 f = fract(uv);

	float a = random(i);
	float b = random(i + vec2(1.0,0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0));

	vec2 u = smoothstep(0.0, 1.0, f);

	return mix(a,b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

vec2 fixvec2(float x, float y) {
	vec2 val = vec2(x, y);
	val.xy *= vec2(1280.0, 720.0);
	val.xy /= openfl_TextureSize.xy;
	return val;
}

void main()
{
	vec2 uv = openfl_TextureCoordv;
	vec4 video = getVideo(uv);

	video.r = getVideo(uv + fixvec2(0.001, 0.001)).x;//+0.05;
	video.g = getVideo(uv + fixvec2(0.000, -0.002)).y;//+0.05;
	video.b = getVideo(uv + fixvec2(-0.002, 0.000)).z;//+0.05;
	video.r += 0.08*getVideo(0.75*fixvec2(0.025, -0.027)+uv+fixvec2(0.001, 0.001)).x;
	video.g += 0.05*getVideo(0.75*fixvec2(-0.022, -0.02)+uv+fixvec2(0.000, -0.002)).y;
	video.b += 0.08*getVideo(0.75*fixvec2(-0.02, -0.018)+uv+fixvec2(-0.002, 0.000)).z;

	video = clamp(video*0.6+0.4*video*video*1.0, 0.0, 1.0);

	//gl_FragColor = mix(video, vec4(noise(uv * 75.0)), 0.05);
	gl_FragColor = video;

	//if(uv.x<0.0 || uv.x>1.0 || uv.y<0.0 || uv.y>1.0){
	//	gl_FragColor = vec4(0,0,0,0);
	//}
}')
	public function new()
	{
		super();

		this.iTime.value = [0.];
	}

	override function __updateGL() {
		super.__updateGL();

		this.iTime.value[0] = Timer.stamp()/1000;
	}
}

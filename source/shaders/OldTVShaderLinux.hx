package shaders;

import haxe.Timer;

import flixel.system.FlxAssets.FlxShader;

using StringTools;

class OldTVShaderLinux extends FlxShader {

@:glFragmentSource('#pragma header

#define id vec2(0.0, 1.0)
#define k 1103515245
#define PI 3.141592653
#define TAU PI * 2.0

uniform float iTime;

float rand(vec2 co){
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

//prng func, from https://stackoverflow.com/a/52207531
float hash(vec3 x) {
	x = floor(x);
	return (rand(vec2(x.y + x.x, x.z + x.x)) * (1.0/float(0xffffffff)));
}

void main() {
	bool flag = false;
	bool flag2 = false;

	vec2 uv = openfl_TextureCoordv;

	//picture offset
	float time = 2.0;
	float timeMod = 2.5;
	float repeatTime = 1.25;
	float lineSize = 50.0;
	float offsetMul = 0.01;
	float updateRate2 = 50.0;
	float uvyMul = 100.0;

	float realSize = lineSize / openfl_TextureSize.y / 2.0;
	float position = mod(iTime, timeMod) / time;
	float position2 = 99.0;
	if (iTime > repeatTime) {
		position2 = mod(iTime - repeatTime, timeMod) / time;
	}
	if (!(uv.y - position > realSize || uv.y - position < -realSize)) {
		uv.x -= hash(vec3(0.0, uv.y * uvyMul, iTime * updateRate2)) * offsetMul;
		flag = true;
	} else if (position2 != 99.0) {
		if (!(uv.y - position2 > realSize || uv.y - position2 < -realSize)) {
			uv.x -= hash(vec3(0.0, uv.y * uvyMul, iTime * updateRate2)) * offsetMul;
			flag = true;
		}
	}

	vec4 col = flixel_texture2D(bitmap, uv);

	//blur, from https://www.shadertoy.com/view/Xltfzj

	//for the black on the left
	if (uv.x < 0.0) {
		col = id.xxxy;
		flag = false;
		flag2 = true;
	}

	//randomized black shit and sploches
	float updateRate4 = 100.0;
	float uvyMul3 = 100.0;
	float cutoff2 = 0.92;
	float valMul2 = 0.007;

	float val2 = hash(vec3(uv.y * uvyMul3, 0.0, iTime * updateRate4));
	if (val2 > cutoff2) {
		float adjVal2 = (val2 - cutoff2) * valMul2 * (1.0 / (1.0 - cutoff2));
		if (uv.x < adjVal2) {
			col = id.xxxy;
			flag2 = true;
		} else {
			flag = true;
		}
	}

	//static
	if (!flag2) {
		float updateRate = 100.0;
		float mixPercent = 0.05;
		float i = hash(vec3(uv * openfl_TextureSize, iTime * updateRate));
		col = mix(col, vec4(i,i,i,i), mixPercent);
	}

	//white sploches
	float updateRate3 = 75.0;
	float uvyMul2 = 400.0;
	float uvxMul = 20.0;
	float cutoff = 0.95;
	float valMul = 0.7;
	float falloffMul = 0.7;

	if (flag) {
		float val = hash(vec3(uv.x * uvxMul, uv.y * uvyMul2, iTime * updateRate3));
		if (val > cutoff) {
			float offset = hash(vec3(uv.y * uvyMul2, uv.x * uvxMul, iTime * updateRate3));
			float adjVal = (val - cutoff) * valMul * (1.0 / (1.0 - cutoff));
			adjVal -= abs((uv.x * uvxMul - (floor(uv.x * uvxMul) + offset)) * falloffMul);
			adjVal = clamp(adjVal, 0.0, 1.0);
			col = vec4(mix(col.rgb, id.yyy, adjVal), col.a);
		}
	}

	gl_FragColor = col;
}')
	public function new()
	{
		super();

		this.iTime.value = [0.];
	}

	override function __updateGL() {
		super.__updateGL();

		this.iTime.value[0] = Conductor.songPosition/1000 *0.6;
	}
}
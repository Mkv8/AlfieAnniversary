package shaders;

import flixel.system.FlxAssets.FlxShader;

class FlashShader extends FlxShader
{
	@:glFragmentSource('
#pragma header

float Bayer2(vec2 a) {
	a = floor(a);
	return fract(a.x / 2.0 + a.y * a.y * 0.75);
}

#define Bayer4(a)   (Bayer2 (0.5 *(a)) * 0.25 + Bayer2(a))
#define Bayer8(a)   (Bayer4 (0.5 *(a)) * 0.25 + Bayer2(a))
#define Bayer16(a)  (Bayer8 (0.5 *(a)) * 0.25 + Bayer2(a))
#define Bayer32(a)  (Bayer16(0.5 *(a)) * 0.25 + Bayer2(a))
#define Bayer64(a)  (Bayer32(0.5 *(a)) * 0.25 + Bayer2(a))

uniform float uApply;
uniform float uColor;

void main()
{
	vec2 uv = openfl_TextureCoordv;
	vec2 fragCoord = openfl_TextureCoordv * openfl_TextureSize.xy;

	float dithering = (Bayer64(fragCoord / 2.0) * 2.0 - 1.0) * 0.5;

	//uApply = iMouse.x / iResolution.x;

	if(uApply + dithering < 0.5) {
		gl_FragColor = texture2D(bitmap, uv);
	} else {
		gl_FragColor = vec4(uColor);
	}
}')

	public function new() {
		super(); this.uApply.value = [0.0];this.uColor.value = [1.0];
	}

	public var apply(get, set):Float;

	function get_apply() {
		return this.uApply.value[0];
	}
	function set_apply(val:Float) {
		return this.uApply.value[0] = val;
	}

public var color(get, set):Float;

	function get_color() {
		return this.uColor.value[0];
	}
	function set_color(val:Float) {
		return this.uColor.value[0] = val;
	}
}
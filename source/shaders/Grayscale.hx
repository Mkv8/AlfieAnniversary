package shaders;

import flixel.system.FlxAssets.FlxShader;

class Grayscale extends FlxShader {
	@:glFragmentSource('
#pragma header
uniform float uApply;
void main() {
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
	gl_FragColor = mix(color, vec4(vec3(gray), color.a), uApply);
}')

	public function new() {
		super(); this.uApply.value = [1.0];
	}

public var apply(get, set):Float;

	function get_apply() {
		return this.uApply.value[0];
	}
	function set_apply(val:Float) {
		return this.uApply.value[0] = val;
	}
} 
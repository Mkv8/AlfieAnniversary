package shaders;

import flixel.system.FlxAssets.FlxShader;

class TransparentHudShader extends FlxShader
{
	@:glFragmentSource('
#pragma header

vec4 custom_texture2D(sampler2D bitmap,vec2 coord){
	vec4 c=texture2D(bitmap,coord);
	c.rgb += vec3(1/255);
	if(c.a < 0.8) c.a = 0.0; // Force full alpha
	if(!hasTransform){return c;}

	if(c.a==0.0){return vec4(0.0,0.0,0.0,0.0);}

	if(!hasColorTransform){return c*openfl_Alphav;}

	//if(c.a >= 0.5) c.a = 1.0; // Force full alpha

	c=vec4(c.rgb/c.a,c.a);

	mat4 cm=mat4(0);
	cm[0][0]=openfl_ColorMultiplierv.x;
	cm[1][1]=openfl_ColorMultiplierv.y;
	cm[2][2]=openfl_ColorMultiplierv.z;
	cm[3][3]=openfl_ColorMultiplierv.w;

	c=clamp(openfl_ColorOffsetv+(c*cm),0.0,1.0);

	if(c.a>0.0){
		return vec4(c.rgb*c.a*openfl_Alphav,c.a*openfl_Alphav);
	}
	return vec4(0.0,0.0,0.0,0.0);
}

void main()
{
	vec4 base = custom_texture2D(bitmap, openfl_TextureCoordv);

	gl_FragColor = base;
}')
	public function new()
	{
		super();
	}
}
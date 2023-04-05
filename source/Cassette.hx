package;

import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

class Cassette extends FlxSprite {
	public var difficultySpr:FlxSprite;
	public var isUnlocked = false;
	public var exVisible = true;
	public var targetItem:Int = 0;
	public var visTargetItem:Int = 0;
	public var exAlpha:Float = 1;

	public var defaultX:Float = 0;
	public var defaultY:Float = 0;

	public function new(weekName:String, isUnlocked:Bool = true) {
		super();

		this.isUnlocked = isUnlocked;

		loadGraphic(Paths.image('cassettes/' + weekName));

		difficultySpr = new FlxSprite();
		difficultySpr.frames = Paths.getSparrowAtlas('cassettes/difficulty');
		for(diff in ["easy", "normal", "hard", "ex"]) {
			difficultySpr.animation.addByPrefix(diff, diff.toUpperCase(), 24);
		}
		difficultySpr.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySpr.animation.play("normal");
		difficultySpr.moves = false;

		antialiasing = ClientPrefs.globalAntialiasing;

		//moves = false;

		//difficultySpr.centerOrigin();
		centerOrigin();
		screenCenter(X);
		y = 450;

		var of = 800;

		offset.y += of;
		y += of;
		origin.y += of;

		Debugger.registerClass(Cassette);

		defaultX = x;
		defaultY = y;
	}

	public var force = true;

	static var angleD:Float = 33;

	var colorL:Float = 1;
	var diffAlpha:Float = 1;

	override function update(elapsed:Float) {
		super.update(elapsed);

		var wantedAlpha = 1;
		if(targetItem == 0 && !isUnlocked) {
			wantedAlpha = 1;
			//glow.alpha = FlxMath.lerp(1, 0.5, Conductor.getBeatPhase());
		} else {
			wantedAlpha = 0;
		}
		var wantedColor:Float = 1;
		if(targetItem == 0) {
			wantedColor = 1;
		} else {
			wantedColor = 0.7;
		}

		var wantedAngle:Float = 0;//(FlxG.width / 2) - (width / 2);
		wantedAngle += angleD * visTargetItem;

		colorL = FlxMath.lerp(colorL, wantedColor, CoolUtil.boundTo(elapsed * 0.17 * 60, 0, 1));
		angle = FlxMath.lerp(angle, wantedAngle, CoolUtil.boundTo(elapsed * 0.17 * 60, 0, 1));
		diffAlpha = FlxMath.lerp(diffAlpha, wantedAlpha, CoolUtil.boundTo(elapsed * 0.17 * 60, 0, 1));

		if(force) angle = wantedAngle;
		if(force) diffAlpha = wantedAlpha;
		if(force) colorL = wantedColor;

		color = FlxColor.fromRGBFloat(colorL, colorL, colorL);

		visible = (angle >= -180 && angle < 180) && exVisible;

		force = false;

		difficultySpr.update(elapsed);
	}

	override function draw() {
		var oAlpha = alpha;
		alpha *= exAlpha;

		difficultySpr.x = x;
		difficultySpr.y = y;
		difficultySpr.origin = origin;
		difficultySpr.offset = offset;
		difficultySpr.scale = scale;
		difficultySpr.width = width;
		difficultySpr.height = height;
		difficultySpr.angle = angle;
		difficultySpr.visible = visible;
		difficultySpr.color = color;
		difficultySpr.alpha = alpha * diffAlpha;
		super.draw();
		difficultySpr.draw();

		alpha = oAlpha;
	}

	override function destroy() {
		super.destroy();
		difficultySpr.destroy();

		Debugger.unregisterObject(FlxStringUtil.getClassName(Cassette, true));
	}
}
package;

import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;

class Cassette extends FlxSprite {
	var difficultySpr:FlxSprite;
	public var isUnlocked = false;
	public var exVisible = true;
	public var targetItem:Int = 0;
	public var visTargetItem:Int = 0;
	public var exAlpha:Float = 1;

	public var defaultX:Float = 0;
	public var defaultY:Float = 0;

	public var weekName:String = "";

	public function new(weekName:String, isUnlocked:Bool = true, showDifficulty:Bool = true) {
		super();

		this.weekName = weekName;

		this.isUnlocked = isUnlocked;

		var cassetteImage = weekName;

		if(!isUnlocked) {
			cassetteImage = "missing";
		}

		loadGraphic(Paths.image('cassettes/' + cassetteImage));

		if(isUnlocked && showDifficulty) {
			loadDifficulty();
		}

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

	public function loadDifficulty() {
		if(difficultySpr != null) return;

		difficultySpr = new FlxSprite();
		difficultySpr.frames = Paths.getSparrowAtlas('cassettes/difficulty');
		for(diff in ["easy", "normal", "hard", "ex"]) {
			difficultySpr.animation.addByPrefix(diff, diff.toUpperCase(), 24);
		}
		difficultySpr.animation.play("normal");
		difficultySpr.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySpr.moves = false;
	}

	public function unlock() {
		var off = offset.copyTo(FlxPoint.weak());
		var orig = origin.copyTo(FlxPoint.weak());

		loadGraphic(Paths.image('cassettes/' + weekName));

		if(difficultySpr != null) difficultySpr.exists = true;
		diffAlpha = 1;
		this.isUnlocked = true;

		offset.copyFrom(off);
		origin.copyFrom(orig);
	}

	public function lock() {
		var off = offset.copyTo(FlxPoint.weak());
		var orig = origin.copyTo(FlxPoint.weak());

		loadGraphic(Paths.image('cassettes/missing'));

		if(difficultySpr != null) difficultySpr.exists = false;
		this.isUnlocked = false;
		diffAlpha = 0;

		offset.copyFrom(off);
		origin.copyFrom(orig);
	}

	public function updateDifficulty(diff:String) {
		if(difficultySpr != null)
			difficultySpr.animation.play(diff);
	}

	public var force = true;

	static var angleD:Float = 33;
	public var selectAngleOffset:Float = 0;

	var shakeOffset:FlxPoint = new FlxPoint();
	var colorL:Float = 1;
	var diffAlpha:Float = 1;

	public var shakeDuration:Float = 0;
	var timer:Float = 0;
	var shakeDistance:Float = 10;

	override function update(elapsed:Float) {
		super.update(elapsed);

		var wantedAlpha = 1;
		if(targetItem == 0 && isUnlocked) {
			wantedAlpha = 1;
		} else {
			wantedAlpha = 0;
		}
		var wantedColor:Float = 1;
		if(targetItem == 0) {
			wantedColor = 1;
		} else {
			wantedColor = 0.7;
		}

		var wantedAngle:Float = 0;
		wantedAngle += angleD * visTargetItem;

		wantedAngle += selectAngleOffset * visTargetItem;//FlxMath.signOf(visTargetItem);

		colorL = FlxMath.lerp(colorL, wantedColor, CoolUtil.boundTo(elapsed * 0.17 * 60, 0, 1));
		angle = FlxMath.lerp(angle, wantedAngle, CoolUtil.boundTo(elapsed * 0.17 * 60, 0, 1));
		diffAlpha = FlxMath.lerp(diffAlpha, wantedAlpha, CoolUtil.boundTo(elapsed * 0.17 * 60, 0, 1));

		if(force) angle = wantedAngle;
		if(force) diffAlpha = wantedAlpha;
		if(force) colorL = wantedColor;

		color = FlxColor.fromRGBFloat(colorL, colorL, colorL);

		visible = (angle >= -180 && angle < 180) && exVisible;

		force = false;

		if(shakeDuration > 0) {
			shakeDuration -= elapsed;
			if(shakeDistance > 0) {
				timer += elapsed;
				while(timer > 1/30) {
					shakeOffset.set(
						FlxG.random.float(-shakeDistance, shakeDistance),
						FlxG.random.float(-shakeDistance, shakeDistance)
					);
					timer -= 1/30;
				}
			}
		}

		if(shakeDuration <= 0) {
			shakeOffset.set();
		}

		if(difficultySpr != null) difficultySpr.update(elapsed);
	}

	override function draw() {
		var oAlpha = alpha;
		alpha *= exAlpha;

		x += shakeOffset.x;
		y += shakeOffset.y;

		if(difficultySpr != null) {
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
		}
		super.draw();
		if(difficultySpr != null)
			difficultySpr.draw();

		x -= shakeOffset.x;
		y -= shakeOffset.y;

		alpha = oAlpha;
	}

	override function destroy() {
		super.destroy();
		if(difficultySpr != null) difficultySpr.destroy();

		Debugger.unregisterObject(FlxStringUtil.getClassName(Cassette, true));
	}
}
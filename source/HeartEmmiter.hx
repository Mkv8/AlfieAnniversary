package;

import flixel.math.FlxRect;
import ColorSwap;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;

using StringTools;

class HeartEmmiter extends FlxSpriteGroup
{
    public var timer:FlxTimer;
	public function new(x:Float,y:Float)
	{
		super(x,y);
	}

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function generate(howlong:Float,times:Int) {
        timer = new FlxTimer().start(howlong, function(tmr:FlxTimer)
        {
            for (i in 0...5)
            {
                var h = new Heart(FlxG.random.float(0.9, 1.2),FlxG.random.int(1, 5),new FlxPoint(this.x,this.y));
                add(h);
            }
        }, times);
    }
}

class Heart extends FlxSprite
{
    public var point:FlxPoint = null;
    public function new(size:Float,type:Int,p:FlxPoint)
    {
        super(p.x,p.y + (ClientPrefs.downScroll ? 400 : -500));

        loadGraphic(Paths.image(Std.string(type)));
        scale.set(size,size);
        velocity.y = ClientPrefs.downScroll ? FlxG.random.int(-400, -500) : FlxG.random.int(400, 500);
        point = p;
        multi = FlxG.random.float(1, 3);
        point.x = p.x - FlxG.random.int(-50, 50);
        morerandomnessidfklmao = FlxG.random.bool() ? 1 : -1;
    }

    var time = 0.0;
    var multi = 0.0;
    var morerandomnessidfklmao = 1;
    override function update(elapsed:Float)
    {
        if (time == -1)
            return;
        time += elapsed * multi;
        x = point.x + Math.cos(time) * 225 * morerandomnessidfklmao;

        super.update(elapsed);

        if (time > 30)
        {
            time = -1;
            kill();
            destroy();
        }
    }
}



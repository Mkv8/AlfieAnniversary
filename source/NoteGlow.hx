package;

import flixel.math.FlxRect;
import ColorSwap;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import editors.ChartingState;

using StringTools;


class NoteGlow extends FlxSprite
{
	var n:Note;
	public function new(note:Note)
	{
		super();
		loadGraphic(Paths.image("nglow/" + Std.string(note.noteData)));
		setGraphicSize(Std.int(this.width * 0.775 * 0.9));
		n = note;
		alpha = 0;
	}

	override function update(elapsed:Float)
	{
		setPosition(n.x -44,n.y -52);
		if (!n.alive)
			alpha = 0;
		super.update(elapsed);
	}
}

package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

/**
 * i spent so many fucking hours trying to re-invent this so it could be a font
 * it was litteraly so easy
 * but it looks cool
 * 
 * Feel free to take the code here and use it yourself.
 */
class AlphabetTyped extends FlxSpriteGroup
{
	public var actualText:FlxText;

	public var targetY:Float = 0;
	public var isMenuItem:Bool = false;

	public var text:String = "";

	public function new(x:Float, y:Float, text:String = "", isFancy:Bool = false)
	{

		super(x, y);

		this.text = text;

		actualText = new FlxText(0, 0, 0, "\n" + text);
		actualText.setFormat(Paths.font("menuBUTTONS.ttf"), 40);
		actualText.y -= actualText.size;
		add(actualText);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.30);
			x = FlxMath.lerp(x, (targetY * 20) + 90, 0.30);
		}

		super.update(elapsed);
	}
}

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class Scripts {
	public static var luaScripts:Array<String> = [ //LOAD LUA SCRIPTS HERE - TORMENTED
        "
        enabled = false
        function onBeatHit()
            if enabled then
                debugPrint('luaScript Loaded From Haxe Successfully')
            end
        end
        ",
        "function onCreate()
            print 'hi person who somehow open the game by the cmd'
        end",
	]; // we dont use lua though - ADA
}
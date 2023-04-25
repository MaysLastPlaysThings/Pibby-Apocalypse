package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import openfl.Lib;

using StringTools;

class PibbyOptionsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Pibby Apocalypse';
		rpcTitle = 'Pibby Settings Menu'; //for Discord Rich Presence

        var option:Option = new Option('Shaders', //Name
            'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.', //Description
            'shaders', //Save data variable name
            'bool', //Variable type
            true); //Default value
        addOption(option);

		var option:Option = new Option('Health Drain', //Name
			'If unchecked, opponent will not drain your health.', //Description
			'healthDrain', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

        var option:Option = new Option('Screen Shake', //Name
            'If unchecked, your screen will not glitch and shake.', //Description
            'screenGlitch', //Save data variable name
            'bool', //Variable type
            true); //Default value
        addOption(option);

        var option:Option = new Option('Death Gore', //Name
            "If unchecked, deaths won't have gore and will be replaced with the normal deaths (NOT ADDED)", //Description
            'gore', //Save data variable name
            'bool', //Variable type
            true); //Default value
        addOption(option);

		super();
    }
}
package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

using StringTools;

class PACreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	var shaderIntensity:Float;

	var bg:FlxSprite;
	var creditsText:FlxText;

	var pibbyFNF:Shaders.Pibbified;

	override function create()
	{
		FlxG.game.filtersEnabled = true;
		pibbyFNF = new Shaders.Pibbified();

		FlxG.game.setFilters([new ShaderFilter(pibbyFNF)]);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		openfl.Lib.application.window.title = "Pibby: Apocalypse - Credits";

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('pacredits/bg'));
		add(bg);
		bg.screenCenter();

		creditsText = new FlxText(20, 20, 0, "CREDITS", 30);
		creditsText.setFormat(Paths.font("menuBUTTONS.ttf"), 54, FlxColor.WHITE, LEFT);
		add(creditsText);
		
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.random.int(0, 1) < 0.01) 
			{
				shaderIntensity = FlxG.random.float(0.2, 0.3);
			}

		if(ClientPrefs.shaders) {
			pibbyFNF.glitchMultiply.value[0] = shaderIntensity;
			pibbyFNF.uTime.value[0] += elapsed;
		}
		
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				FlxG.sound.playMusic(Paths.music('freakyMenu_${Main.funnyMenuMusic}'));
				quitting = true;
			}
			super.update(elapsed);
	}

	override function beatHit() {
		super.beatHit();
		if (curBeat % 4 == 0) {
			switch(FlxG.random.int(0, 10)) {
				case 10:
					creditsText.text = 'CREDITS (Forteni = Fortnite)';
				case 1:
					creditsText.text = 'CREDITS';
			}
		}
	}

	override function destroy() {
		super.destroy();
		FlxG.game.setFilters([]);
	}
}
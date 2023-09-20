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

import haxe.Json;

import flixel.input.mouse.FlxMouseEvent;

using StringTools;

// CreditsData: name, icon, description, youtube, twitter, quote, role
typedef CreditsData = {
	people:Array<Dynamic>
}

class PACreditsState extends MusicBeatState
{
	var curSelected:Int = 0;

	var creditData:CreditsData;

	private var shaderIntensity:Float;

	private var people:Array<Dynamic> = []; // push people to this depending on the role
	var bg:FlxSprite;
	var creditsText:FlxText;
	var currentGroup:FlxText;

	var quoteText:FlxText;

	var pibbyFNF:Shaders.Pibbified;
	var creditSpr:FlxSprite;

	function getCreditJson(path:String):CreditsData {
		var json:String = null;

		json = File.getContent(Paths.json(path));

		if (json != null && json.length > 0) {
			return cast Json.parse(json);
		}

		return null;
	}

	override function create()
	{
		FlxG.game.filtersEnabled = true;
		pibbyFNF = new Shaders.Pibbified();

		creditData = getCreditJson('credits');
		people = creditData.people;

		if (ClientPrefs.shaders) FlxG.game.setFilters([new ShaderFilter(pibbyFNF)]);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		openfl.Lib.application.window.title = "Pibby: Apocalypse - Credits";

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('pacredits/bg'));
		add(bg);
		bg.screenCenter();

		creditsText = new FlxText(20, 20, 0, "< CREDITS", 30);
		creditsText.setFormat(Paths.font("menuBUTTONS.ttf"), 54, FlxColor.WHITE, LEFT);
		add(creditsText);

		currentGroup = new FlxText(0, 0, 0, "", 70);
		currentGroup.setFormat(Paths.font("menuBUTTONS.ttf"), 70, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		currentGroup.borderSize = 1.5;
		currentGroup.screenCenter();
		add(currentGroup);

		quoteText = new FlxText(20, 0, 0, "", 20);
		quoteText.setFormat(Paths.font("menuBUTTONS.ttf"), 20, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		quoteText.borderSize = 1.5;
		quoteText.screenCenter();
		add(quoteText);

		currentGroup.x -= 600;
		quoteText.x -= 600;

		currentGroup.y -= 35;
		quoteText.y += 35;

		creditSpr = new FlxSprite(0, 0);
		add(creditSpr);
		creditSpr.scale.set(0.4, 0.4);
		creditSpr.updateHitbox();
		creditSpr.screenCenter();
		creditSpr.x -= 80;
		creditSpr.y -= 800;

		var twitter:FlxSprite = new FlxSprite(0, 0, Paths.image('pacredits/twitter'));
		add(twitter);
		twitter.alpha = 0.6;
		FlxMouseEvent.add(twitter, function(spr:FlxSprite) {
			CoolUtil.browserLoad('https://' + people[curSelected][4]);
		}, null, function(spr:FlxSprite) {
			FlxTween.tween(spr, {alpha: 1}, 0.15);
		}, function(spr:FlxSprite) {
			FlxTween.tween(spr, {alpha: 0.6}, 0.25);
		});

		var youtube:FlxSprite = new FlxSprite(0, 0, Paths.image('pacredits/youtube'));
		add(youtube);
		youtube.alpha = 0.6;
		FlxMouseEvent.add(youtube, function(spr:FlxSprite) {
			CoolUtil.browserLoad('https://' + people[curSelected][3]);
		}, null, function(spr:FlxSprite) {
			FlxTween.tween(spr, {alpha: 1}, 0.15);
		}, function(spr:FlxSprite) {
			FlxTween.tween(spr, {alpha: 0.6}, 0.25);
		});

		twitter.scale.x = 0.3;
		youtube.scale.x = 0.08;

		twitter.scale.y = 0.3;
		youtube.scale.y = 0.08;

		twitter.updateHitbox();
		youtube.updateHitbox();

		youtube.setPosition(150, FlxG.height - 130);
		twitter.setPosition(youtube.x - youtube.width, youtube.y);

		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		creditSpr.loadGraphic(Paths.image('pacreditarts/' + people[curSelected][1] + FlxG.random.int(1, 2)));

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

		if (controls.UI_LEFT_P) {
			changeSelection(-1);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		if (controls.UI_RIGHT_P) {
			changeSelection(1);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
	}

	var targetY:Float;

	function changeSelection(thing:Int) {
		curSelected += thing;

		if (curSelected < 0)
			curSelected = people.length - 1;
		if (curSelected >= people.length)
			curSelected = 0;

		if (people != null) {
			quoteText.text = people[curSelected][0] + ' - ' + people[curSelected][2] + '\n"' + people[curSelected][5] + '"';
		}

		currentGroup.text = people[curSelected][6];
	}

	override function destroy() {
		super.destroy();
		FlxG.game.setFilters([]);
	}
}
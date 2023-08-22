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

using StringTools;

typedef CreditsData = {
	directors:Array<Dynamic>,
	composers:Array<Dynamic>,
	coders:Array<Dynamic>,
	artists:Array<Dynamic>,
	charters:Array<Dynamic>,
	animators:Array<Dynamic>,
	misc:Array<Dynamic>
}

class PACreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	var creditData:CreditsData;

	private var shaderIntensity:Float;

	private var roleSections:Array<String> = [
		"DIRECTORS",
		"COMPOSERS",
		"CODERS",
		"ARTISTS",
		"CHARTERS",
		"ANIMATORS",
		"MISCELLANEOUS"
	];

	private var people:Array<Dynamic> = []; // push people to this depending on the role

	var currentRole:Int = 0;

	var bg:FlxSprite;
	var creditsText:FlxText;
	var currentGroup:FlxText;

	var quoteText:FlxText;

	var creditGrp:FlxTypedGroup<FlxSprite>;

	var pibbyFNF:Shaders.Pibbified;

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

		creditGrp = new FlxTypedGroup<FlxSprite>();

		creditsText = new FlxText(20, 20, 0, "< CREDITS", 30);
		creditsText.setFormat(Paths.font("menuBUTTONS.ttf"), 54, FlxColor.WHITE, LEFT);
		add(creditsText);

		currentGroup = new FlxText(0, 60, 0, "", 70);
		currentGroup.setFormat(Paths.font("menuBUTTONS.ttf"), 70, FlxColor.WHITE, LEFT);
		currentGroup.screenCenter(X);
		add(currentGroup);

		quoteText = new FlxText(20, 150, 0, "", 30);
		quoteText.setFormat(Paths.font("menuBUTTONS.ttf"), 54, FlxColor.WHITE, LEFT);
		add(quoteText);

		for (i in 0... people.length) {
			var creditSpr = new FlxSprite(0, 0).loadGraphic(Paths.image('pacredits/people/' + roleSections[currentRole] + '/' + people[i][1] + '/' + people[i][1]));
			creditSpr.screenCenter();
			creditSpr.x = creditSpr.pixels.width + 30;
			creditGrp.add(creditSpr);
			creditSpr.ID = i;
		}
		
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		currentGroup.text = roleSections[currentRole];

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

		if (controls.UI_UP_P) {
			changeRole(-1);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		if (controls.UI_DOWN_P) {
			changeRole(1);
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

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
			quoteText.text = people[curSelected][0] + '\n' + people[curSelected][5];
		}

		for (item in creditGrp.members)
		{
			item.alpha = 0;

			if (item.ID == curSelected)
			{
				item.alpha = 1;
				item.screenCenter(X);
			}
		}
	}

	function changeRole(thing:Int) {
		currentRole += thing;

		if (currentRole < 0)
			currentRole = roleSections.length - 1;
		if (currentRole >= roleSections.length)
			currentRole = 0;

		// ada understanding json files jumpscare
		for (i in 0... roleSections.length) {
			switch(roleSections[i]) {
				case 'DIRECTORS':
					people.splice(0, people.length);
					people = creditData.directors;
				case 'CODERS':
					people.splice(0, people.length);
					people = creditData.coders;
			}
		}
	}

	override function destroy() {
		super.destroy();
		FlxG.game.setFilters([]);
	}
}
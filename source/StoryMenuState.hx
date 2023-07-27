package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import WeekData;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var storyModeText:FlxText;
	var bgSprite:FlxSprite;

	var logoFinn:FlxSprite;
	var logoGumball:FlxSprite;

	private static var curWeek:Int = 0;

	var curSelected:Int = -1;

	var grpWeekCharacters:FlxTypedGroup<FlxSprite>;

	var shaderIntensity:Float;
	var pibbyFNF:Shaders.Pibbified;

	var optionShit:Array<String> = [
		'finn',
		'gumball'
	];

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.game.filtersEnabled = true;
		pibbyFNF = new Shaders.Pibbified();

		if (ClientPrefs.shaders) FlxG.game.setFilters([new ShaderFilter(pibbyFNF)]);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("🏠 | In the Story Menu", null);
		#end


		bgSprite = new FlxSprite().loadGraphic(Paths.image('storymenu/thing'));
		add(bgSprite);
		bgSprite.screenCenter();

		storyModeText = new FlxText(0, 0, 0, "STORY MODE");
		storyModeText.setFormat(Paths.font("menuBUTTONS.ttf"), 65);
		storyModeText.y -= storyModeText.size;
		add(storyModeText);

		grpWeekCharacters = new FlxTypedGroup<FlxSprite>();
		add(grpWeekCharacters);

		for (i in 0...optionShit.length)
			{
				var characters:FlxSprite = new FlxSprite().loadGraphic(Paths.image('storymenu/' + optionShit[i]));
				characters.ID = i;
				grpWeekCharacters.add(characters);
				characters.antialiasing = ClientPrefs.globalAntialiasing;
				switch(i) {
					case 0:
						characters.setPosition(-55, 150);
					case 1:
						characters.setPosition(625, 150);
				}
				//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				characters.updateHitbox();
			}

		logoFinn = new FlxSprite(-150, -80).loadGraphic(Paths.image('storymenu/corruptiontime'));
		logoFinn.scale.set(0.45, 0.45);
		add(logoFinn);

		logoGumball = new FlxSprite();
		logoGumball.scale.set(0.29, 0.29);
		logoGumball.frames = Paths.getSparrowAtlas('storymenu/theGlitch');
		logoGumball.animation.addByPrefix('idle', 'theGlitch glitching', 24, true);
		logoGumball.animation.play('idle');
		logoGumball.screenCenter().x += 340; // got throughts.......
		logoGumball.y -= 140;
		add(logoGumball);

		changeItem();

		// Need to make sure the filters are disabled teehee
		FlxG.game.filtersEnabled = false;
		PlayState.isStoryMode = true;
	}

	var selectedSomethin:Bool = false;

	override function update( elapsed : Float )
		{
			if (FlxG.random.int(0, 1) < 0.01) 
				{
					shaderIntensity = FlxG.random.float(0.2, 0.3);
				}
	
			if(ClientPrefs.shaders) {
				pibbyFNF.glitchMultiply.value[0] = shaderIntensity;
				pibbyFNF.uTime.value[0] += elapsed;
			}

			if (controls.UI_LEFT_P)
			{
				changeItem(-1);
			}
	
			if (controls.UI_RIGHT_P)
			{
				changeItem(1);
			}

			if (!selectedSomethin)
				{
					if (controls.BACK)
						{
							selectedSomethin = true;
							FlxG.sound.play(Paths.sound('cancelMenu'));
							MusicBeatState.switchState(new MainMenuState());
						}
				}

			if (controls.ACCEPT)
			{
				onSelect();
			}
		}

		// Nevermind that's dumb lmao
		var gumballSong = ['Childs-Play', 'My-Amazing-World', 'Retcon'/*, 'Forgotten-World*/]; // idk if thats part of the gumball week honestly
		var finnSong = ['Suffering-Siblings']; // for now cus i dont get the order lmao

		// if someone has a better version of this pls commit it cus this code sucks lmao
		function onSelect() 
		{
			var songArray:Array<String> = [];
			var arrayLength = curSelected == 0 ? finnSong : gumballSong;
			
			for (stuff in 0...arrayLength.length)
			songArray.push(arrayLength[stuff]);

			try
				{
					PlayState.storyPlaylist = songArray;
					PlayState.isStoryMode = true;

					PlayState.storyDifficulty = 1;
		
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
					PlayState.campaignScore = 0;
					PlayState.campaignMisses = 0;

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							LoadingState.loadAndSwitchState(new PlayState(), true);
							FreeplayState.destroyFreeplayVocals();
						});
				}
				catch(e:Dynamic)
				{
					trace('ERROR! $e');
					return;
				}
		}

		function changeItem(huh:Int = 0)
			{
				curSelected += huh;

				trace(curSelected);
		
				if (curSelected >= grpWeekCharacters.length)
					curSelected = 0;
				if (curSelected < 0)
					curSelected = grpWeekCharacters.length - 1;
		
				grpWeekCharacters.forEach(function(spr:FlxSprite)
				{
					spr.alpha = 1;

					if (spr.ID == curSelected)
					{
						spr.alpha = 0.7;
						spr.centerOffsets();
					}
				});
			}		
}

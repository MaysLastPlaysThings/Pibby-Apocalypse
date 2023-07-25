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

using StringTools;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var storyModeText:FlxText;
	var bgSprite:FlxSprite;

	var logoFinn:FlxSprite;
	var logoGumball:FlxSprite;

	private static var curWeek:Int = 0;

	var grpWeekCharacters:FlxTypedGroup<FlxSprite>;

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

		bgSprite = new FlxSprite().loadGraphic(Paths.image('storymenu/thing'));
		add(bgSprite);
		bgSprite.screenCenter();

		logoFinn = new FlxSprite(25, FlxG.height - 95).loadGraphic(Paths.image('storymenu/corruptiontime'));
		add(logoFinn);

		logoGumball = new FlxSprite(475, FlxG.height - 95);
		logoGumball.frames = Paths.getSparrowAtlas('storymenu/theGlitch');
		logoGumball.animation.addByPrefix('idle', 'theGlitch glitching', 24, true);
		logoGumball.animation.play('idle');
		add(logoGumball);

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
						characters.setPosition(0, 150);
					case 1:
						characters.setPosition(440, 150);
				}
				//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				characters.updateHitbox();
			}

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
				changeSelection(-1);
			}
	
			if (controls.UI_RIGHT_P)
			{
				changeSelection(1);
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
		}

		function changeItem(huh:Int = 0)
			{
				curSelected += huh;
		
				if (curSelected >= optionShit.length)
					curSelected = 0;
				if (curSelected < 0)
					curSelected = optionShit.length - 1;
		
				optionShit.forEach(function(spr:FlxSprite)
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

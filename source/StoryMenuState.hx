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

	var storyModeText : FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var difficultySelectors:FlxGroup;

	var loadedWeeks:Array<WeekData> = [];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		storyModeText = new FlxText(0, 0, 0, "STORY MODE");
		storyModeText.setFormat(Paths.font("menuBUTTONS.ttf"), 65);
		storyModeText.y -= storyModeText.size;
		add(storyModeText);



		// Need to make sure the filters are disabled teehee
		FlxG.game.filtersEnabled = false;
		PlayState.isStoryMode = true;

	}

	var selectedSomethin:Bool = false;

	override function update( elapsed : Float )
		{
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
}

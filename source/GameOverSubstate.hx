package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class GameOverSubstate extends MusicBeatSubstate
{
	public var boyfriend:Boyfriend;
	public var boyfriend2: Boyfriend;
	public var pobby:Character;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = true;
	var playingDeathSound:Bool = false;
	var defaultCamZoom = 0.7;

	var stageSuffix:String = "";
    var allowedtoContinue:Bool = false;

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';
	public static var soundLibraryStart = null;

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
		soundLibraryStart = null;
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		PlayState.instance.setOnLuas('inGameOver', true);
		Conductor.songPosition = 0;

		var blackness = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 4, FlxColor.BLACK);
		blackness.scrollFactor.set();
		add(blackness);

		boyfriend = new Boyfriend(x, y, characterName);
		boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
		add(boyfriend);

		pobby = new Boyfriend(x, y, "pibby-dead");
		pobby.x += (pobby.positionArray[0] + 1800);
		pobby.y += (pobby.positionArray[1] + 480);
		pobby.alpha = 0.0001;
		pobby.scale.set(1, 1);
		add(pobby);

        camX = boyfriend.getGraphicMidpoint().x;
        camY = boyfriend.getGraphicMidpoint().y;
        camY -= boyfriend.height/3;

        switch(characterName) {
			default:
				pobby.alpha = 0.0001;
            case "jake_death":
                camX += 50;
                camY += 400;
            case "gumdead":
                camX -= 420;
			case "deathscreen":
				pobby.alpha = 1;
				camY += 260;
				camX -= 300;
         }

		camFollow = new FlxPoint(boyfriend.getGraphicMidpoint().x, boyfriend.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName, soundLibraryStart));
		Conductor.changeBPM(100);
		FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		if (characterName != "jake_death")
		{
			boyfriend.playAnim('firstDeath');
			pobby.playAnim('firstDeath');
		}
		else
			jakeDeath(x, y);

        // hi nebula was here :3

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(camX, camY);
		add(camFollowPos);
		FlxG.camera.follow(camFollowPos, LOCKON, 1);

        FlxG.camera.snapToTarget();

		#if mobile // ja to ficano puto ja mermao
		addVirtualPad(NONE, A_B);
		addVirtualPadCamera(false);
		#end
	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);
		FlxG.camera.zoom = defaultCamZoom;

		if (controls.ACCEPT && allowedtoContinue)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;
			PlayState.chartingMode = false;

			WeekData.loadTheFirstEnabledMod();
			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('fpmenu'));
			PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
		}

		if (boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name == 'firstDeath')
		{
			if(boyfriend.animation.curAnim.curFrame >= 12 && !isFollowingAlready)
			{
				updateCamera = false;
				isFollowingAlready = true;
			}

			if (boyfriend.animation.curAnim.finished && !playingDeathSound)
			{
				if (characterName == "jake_death" && boyfriend2.animation.curAnim == null)
				{
					playingDeathSound = true;
					boyfriend.alpha = 0;
					boyfriend2.alpha = 1;
					boyfriend2.playAnim("deathLoop");
				}

				if (PlayState.SONG.stage == 'tank')
				{
					playingDeathSound = true;
					coolStartDeath(0.2);
					
					var exclude:Array<Int> = [];
					//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

					FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25, exclude)), 1, false, null, true, function() {
						if(!isEnding)
						{
							FlxG.sound.music.fadeIn(0.2, 1, 4);
						}
					});
				}
				else if (characterName == "jake_death")
					{
						coolStartDeath(null, 0.5);
					}
				else
				{
					coolStartDeath();
				}
				boyfriend.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	function jakeDeath(x: Float, y: Float)
	{
		boyfriend.playAnim('firstDeath');

		boyfriend2 = new Boyfriend(x, y, "jake_loop");
		boyfriend2.x += boyfriend.positionArray[0];
		boyfriend2.y += boyfriend.positionArray[1];
		boyfriend2.alpha = 0.0001;

		add(boyfriend2);
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1, ?yieldTime: Float = 0):Void
	{
		new FlxTimer().start(yieldTime, function(tmr:FlxTimer)
			{
				//FlxG.sound.music = null;
				allowedtoContinue = true;
				if (characterName == 'pibby-dead') {
					FlxTween.tween(this, {defaultCamZoom: 1.3}, 10, {ease: FlxEase.quadInOut});
				}
				trace(loopSoundName);
				FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
			});
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if (characterName == "jake_death")
				boyfriend2.playAnim('deathConfirm', true);
			else
			{
				boyfriend.playAnim('deathConfirm', true);
				pobby.playAnim('deathConfirm', true);
			}
			if (pobby.alpha == 1 && pobby.animation.curAnim.name == 'deathConfirm' && pobby.animation.curAnim.finished) {
				pobby.alpha = 0.0001;
				if (boyfriend.animation.curAnim.finished) boyfriend.alpha = 0.0001;
			}
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}

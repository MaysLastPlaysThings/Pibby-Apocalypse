package;

import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import flixel.ui.FlxBar;
import WeekData;
#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var pibbyFNF:Shaders.Pibbified;

	var dogeTxt:FlxText;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var songText:FlxTypeText;
	var artistText:FlxTypeText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var threatLerp:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

    var noHeroIntro:FlxSprite;

    var resetSecretTimer:FlxTimer;
    var isResetTimerRunning:Bool = false;

    var pressed:Float = 0;

	var shaderIntensity:Float;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var threatPercent:Int;
    var glitchFWFNF:FlxRuntimeShader = if (!ClientPrefs.lowQuality) new FlxRuntimeShader(RuntimeShaders.fwGlitch, null, 100) else new FlxRuntimeShader(RuntimeShaders.fwGlitchtrash, null, 100);

	var bg:FlxSprite;
    var arrowL:FlxSprite;
    var arrowR:FlxSprite;
    var arrows:FlxSprite;
	var image:FlxSprite;
    var stagebox:FlxSprite;
	var stagebox_L:FlxSprite;
	var stagebox_R:FlxSprite;
	var threat:FlxSprite;
	var levelBarBG:FlxSprite;
	var levelBar:FlxBar;
	var gradient:FlxSprite;

	var bloomFNF:FlxRuntimeShader = if (!ClientPrefs.lowQuality) new FlxRuntimeShader(RuntimeShaders.dayybloomshader, null, 100) else new FlxRuntimeShader(RuntimeShaders.dayybloomshadertrash, null, 100);

	var canPress = false;
	var saveY:Float;
	var saveHeroY:Float;

    var allowGlitch:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		FlxG.camera.filtersEnabled = true;
		pibbyFNF = new Shaders.Pibbified();

		if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(pibbyFNF)]);

		Conductor.bpm = 100;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("🗺️ | In Freeplay", null);
		#end

		openfl.Lib.application.window.title = "Pibby: Apocalypse - Freeplay";

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), song[3]);
			}
		}
		#if desktop
		WeekData.loadTheFirstEnabledMod();
		#end

		// fuck you nulls
		new FlxTimer().start(0.5, grah -> canPress = true);

		bg = new FlxSprite();
        bg.frames = Paths.getSparrowAtlas('fpmenu/background');
        bg.animation.addByPrefix('idle', 'background idle', 30, true);
        bg.animation.play('idle');
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);
        bg.screenCenter();
        
        saveY = FlxG.camera.y;

		threat = new FlxSprite().loadGraphic(Paths.image('fpmenu/threatLevel'));
		threat.antialiasing = ClientPrefs.globalAntialiasing;
		add(threat);
		threat.screenCenter();

		image = new FlxSprite().loadGraphic(Paths.image('fpmenu/stage/' + songs[curSelected].songName));
		image.antialiasing = ClientPrefs.globalAntialiasing;
		add(image);
		image.screenCenter();

        stagebox = new FlxSprite().loadGraphic(Paths.image('fpmenu/stageBox'));
		stagebox.antialiasing = ClientPrefs.globalAntialiasing;
        add(stagebox);
        stagebox.screenCenter();

		if (!ClientPrefs.lowQuality)
			{
				stagebox_L = new FlxSprite().loadGraphicFromSprite(stagebox);
				stagebox_L.alpha = 0.6;
				add(stagebox_L);
				stagebox_L.x = stagebox.x - 500;
				stagebox_L.setGraphicSize(Std.int(stagebox_L.width * 0.45));

				stagebox_R = new FlxSprite().loadGraphicFromSprite(stagebox);
				stagebox_R.alpha = 0.6;
				add(stagebox_R);
				stagebox_R.x = stagebox.x + 500;
				stagebox_R.setGraphicSize(Std.int(stagebox_R.width * 0.45));

				arrowL = new FlxSprite().loadGraphic(Paths.image('fpmenu/arrowL'));
				arrowL.antialiasing = ClientPrefs.globalAntialiasing;
				add(arrowL);
				arrowL.scale.set(4, 4);
				arrowL.blend = ADD;
				if (ClientPrefs.shaders) arrowL.shader = bloomFNF;
				arrowL.screenCenter();

				arrowR = new FlxSprite().loadGraphic(Paths.image('fpmenu/arrowR'));
				arrowR.antialiasing = ClientPrefs.globalAntialiasing;
				add(arrowR);
				arrowR.scale.set(4, 4);
				arrowR.blend = ADD;
				if (ClientPrefs.shaders) arrowR.shader = bloomFNF;
				arrowR.screenCenter();
			}

		songText = new FlxTypeText(image.x, image.y + 35, Std.int(FlxG.width * 1), "");
		songText.antialiasing = ClientPrefs.globalAntialiasing;
		songText.setFormat(Paths.font("mum.ttf"), 64, FlxColor.WHITE, CENTER);
		if (!ClientPrefs.lowQuality) songText.blend = ADD;
		if (ClientPrefs.shaders) songText.shader = bloomFNF;
		add(songText);

		artistText = new FlxTypeText(songText.x, songText.y + 80, Std.int(FlxG.width * 1), "");
		artistText.antialiasing = ClientPrefs.globalAntialiasing;
		artistText.setFormat(Paths.font("type.ttf"), 36, FlxColor.WHITE, CENTER);
		if (!ClientPrefs.lowQuality) artistText.blend = ADD;
		if (ClientPrefs.shaders) artistText.shader = bloomFNF;
		add(artistText);

		levelBarBG = new FlxSprite(threat.x + 630, threat.y + 510).loadGraphic(Paths.image('fpmenu/threatBarBG'));
		levelBarBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(levelBarBG);

		levelBar = new FlxBar(levelBarBG.x + 4, levelBarBG.y + 4, LEFT_TO_RIGHT, Std.int(levelBarBG.width - 8), Std.int(levelBarBG.height - 8), this,
			'threatLerp', 0, 100);
		levelBar.scrollFactor.set();
		levelBar.createFilledBar(0x00000000, FlxColor.WHITE, true);
		levelBar.antialiasing = ClientPrefs.globalAntialiasing;
		add(levelBar);

		if (!ClientPrefs.lowQuality) {
			gradient = new FlxSprite(0, 0, Paths.image('gradient', 'shared'));
			gradient.screenCenter();
			gradient.setGraphicSize(Std.int(gradient.width * 0.75));
			gradient.alpha = 0;
			gradient.antialiasing = ClientPrefs.globalAntialiasing;
			add(gradient);

			FlxTween.tween(gradient, {alpha: 1}, 1, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
		}

		dogeTxt = new FlxText(0, FlxG.height - 50, 0, "♪ Now Playing: Freeplay Theme - By Doge ♪", 8);
		dogeTxt.setFormat(Paths.font("mum.ttf"), 24, FlxColor.WHITE, LEFT);
		dogeTxt.alpha = 0;
		dogeTxt.antialiasing = ClientPrefs.globalAntialiasing;
		add(dogeTxt);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		/*for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.isMenuItem = true;
			songText.targetY = i - curSelected;
			songText.antialiasing = ClientPrefs.globalAntialiasing;

			var maxWidth = 980;
			if (songText.width > maxWidth)
			{
				songText.scaleX = maxWidth / songText.width;
			}
			songText.snapToPosition();

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			icon.antialiasing = ClientPrefs.globalAntialiasing;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}*/
		WeekData.setDirectoryFromWeek();

        noHeroIntro = new FlxSprite(-200, -400);
        noHeroIntro.frames = Paths.getSparrowAtlas('noherocutscenefirst', 'shared');
        noHeroIntro.animation.addByPrefix('finnJumpscareMomento', 'play003', 24, true);
        noHeroIntro.animation.play('finnJumpscareMomento',true);
        noHeroIntro.scrollFactor.set();

        add(noHeroIntro);
        saveHeroY = noHeroIntro.y;
        noHeroIntro.alpha = 0.001;

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;

		if(curSelected >= songs.length) curSelected = 0;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();

		FlxTween.tween(dogeTxt, {alpha: 1}, 1.5, {
			ease: FlxEase.quadInOut, 
			startDelay: 2,
			onComplete: 
			function (twn:FlxTween)
				{
					FlxTween.tween(dogeTxt, {alpha: 0}, 1.5, {
						ease: FlxEase.quadInOut, startDelay: 2});
				}
		});

    #if mobile
    addVirtualPad(UP_LEFT_RIGHT, A_B);
    #end

		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, threatLevel:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color, threatLevel));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	var gradientSineThing:Float = 0;
    var shaderStuff:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(ClientPrefs.shaders) {
            if (allowGlitch) {
                shaderStuff += elapsed;
            }else{
                shaderStuff = 0;
            }
			pibbyFNF.glitchMultiply.value[0] = shaderIntensity;
			pibbyFNF.uTime.value[0] += elapsed;
            glitchFWFNF.setFloat('iTime', shaderStuff);
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		gradientSineThing += 180 * elapsed;

		bg.animation.play('idle');

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (songs.length > 1)
		{
			if (leftP)
			{
				if (!ClientPrefs.lowQuality) FlxTween.tween(arrowL, {alpha: 0.4}, 0.1, {
					ease: FlxEase.quadInOut,
					onComplete: 
					function (twn:FlxTween)
						{
							FlxTween.tween(arrowL, {alpha: 1}, 0.1, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										arrowL.alpha = 1;
									}});
						}});
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (rightP)
			{
				if (!ClientPrefs.lowQuality) FlxTween.tween(arrowR, {alpha: 0.4}, 0.1, {
					ease: FlxEase.quadInOut,
					onComplete: 
					function (twn:FlxTween)
						{
							FlxTween.tween(arrowR, {alpha: 1}, 0.1, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										arrowR.alpha = 1;
									}});
						}});
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_DOWN)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeDiff();
			}
		}

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		threatLerp = FlxMath.lerp(threatLerp, threatPercent, CoolUtil.boundTo(elapsed * 4, 0, 1));

		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.playMusic(Paths.music('freakyMenu_${Main.funnyMenuMusic}'));
		}

		if (accepted && canPress)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeekName = WeekData.getWeekFileName();

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			
            LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);

        if (controls.UI_UP_P) {
            pressed += 1;
            var funnyNum:Int = 20;
            noHeroIntro.alpha += pressed/40;
            FlxG.camera.y += funnyNum;
            noHeroIntro.y -= funnyNum;
            var fuckNum:Int;
            allowGlitch = true;
            new FlxTimer().start(0.35, function(tmr:FlxTimer) {
                allowGlitch = false;
            });
            if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(pibbyFNF), new ShaderFilter(glitchFWFNF)]);
            var gameObjects = [bg, arrowL, arrowR, arrows, image, stagebox, stagebox_L, stagebox_R, threat, levelBarBG, gradient];
            for(index in 0...gameObjects.length){
                fuckNum = Std.int(100*pressed);
                if (gameObjects[index] != null && gameObjects[index].exists) {
                    gameObjects[index].offset.x = 0 + FlxG.random.int(-fuckNum, fuckNum);
                    gameObjects[index].offset.y = 0 + FlxG.random.int(-fuckNum, fuckNum);
                }else{
                    continue;
                }
            }
            FlxG.sound.music.volume -= pressed/10;
            FlxG.sound.play(Paths.sound('glitchhit', 'shared'),10*pressed);
            if (!isResetTimerRunning) {
                resetSecretTimer = new FlxTimer().start(3, function(tmr:FlxTimer) {
                    pressed = 0;
                    FlxTween.tween(noHeroIntro, {alpha: 0.001}, 0.25, {ease: FlxEase.quadInOut});
                    if (ClientPrefs.shaders) FlxG.camera.setFilters([new ShaderFilter(pibbyFNF)]);
                    FlxG.camera.y = saveY;
                    noHeroIntro.y = saveHeroY;
                    var gameObjects = [bg, arrowL, arrowR, arrows, image, stagebox, stagebox_L, stagebox_R, threat, levelBarBG, gradient];
                    for(index in 0...gameObjects.length){
                        if (gameObjects[index] != null && gameObjects[index].exists) {
                            gameObjects[index].offset.x = 0;
                            gameObjects[index].offset.y = 0;
                        }else{
                            continue;
                        }
                    }
                    FlxG.sound.music.volume = 1;
                    isResetTimerRunning = false;
                });
            }
            isResetTimerRunning = true;
            if (pressed == 8) {
                persistentUpdate = false;
                var songLowercase:String = Paths.formatToSongPath("No-Hero-Remix");
                var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
    
                PlayState.SONG = Song.loadFromJson(poop, songLowercase);
                PlayState.isStoryMode = false;
                PlayState.storyDifficulty = curDifficulty;
                PlayState.storyWeekName = 'finn';
                
                LoadingState.loadAndSwitchState(new PlayState());
    
                FlxG.sound.music.volume = 0;
                destroyFreeplayVocals();
            }
        }

		Conductor.bpm = 100; // in case the code sucks and stays with the bpm

		// todo: fix this
		stagebox.y = 3 + Math.sin(Conductor.songPosition/600)*((FlxG.height * 0.015));
		image.y = 3 + Math.sin(Conductor.songPosition/600)*((FlxG.height * 0.015));
		if (!ClientPrefs.lowQuality && arrowL != null) arrowL.y = 290 + Math.sin(Conductor.songPosition/600)*((FlxG.height * 0.065));
		if (!ClientPrefs.lowQuality && arrowR != null) arrowR.y = 290 + Math.sin(Conductor.songPosition/600)*((FlxG.height * 0.065));
	}

	override function beatHit() {
		super.beatHit();
	}

	override function stepHit() {
		super.stepHit();
		if (FlxG.random.int(0, 1) < 0.01) 
			{
				shaderIntensity = FlxG.random.float(0.2, 0.3);
			}
			
			if (ClientPrefs.shaders)
			pibbyFNF.glitchMultiply.value[0] = shaderIntensity;
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	override function destroy() {
		super.destroy();

		FlxG.camera.setFilters([]);
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		/*for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}*/

		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}

		artistText.alpha = 0;

		songText.revive();
		songText.resetText(songs[curSelected].songName.toUpperCase());
		songText.start(0.1, true);
		songText.alpha = 1;
		songText.completeCallback = function() {
			artistText.alpha = 1;
			artistText.revive();
			artistText.resetText(CoolUtil.getSongArtist(songs[curSelected].songName).toUpperCase());
			artistText.start(0.05, true);
		};

		image.loadGraphic(Paths.image('fpmenu/stage/' + songs[curSelected].songName));

		threatPercent = songs[curSelected].threatLevel;

		levelBar.updateBar();
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var threatLevel:Int = 0;

	public function new(song:String, week:Int, songCharacter:String, color:Int, threatLevel:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
		this.threatLevel = threatLevel;
	}
}
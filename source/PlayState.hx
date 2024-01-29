package;

import flixel.addons.text.FlxTypeText;
import Achievements;
import Conductor.Rating;
import DialogueBoxPsych;
import FunkinLua;
import Note.EventNote;
import Scripts;
import Section.SwagSection;
import Shaders.WiggleEffectType;
import Song.SwagSong;
import StageData;
import animateatlas.AtlasFrameMaker;
import editors.CharacterEditorState;
import editors.ChartingState;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.animation.FlxAnimationController;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxAxes;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.ds.StringMap;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.events.KeyboardEvent;
import openfl.filters.BitmapFilter;
import openfl.system.System;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;
#if desktop
import Discord.DiscordClient;
#end
#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
import hxcodec.VideoHandler;
import hxcodec.VideoSprite;
#end

class PlayState extends MusicBeatState
{
	var noteRows:Array<Array<Array<Note>>> = [[],[]];

	var channelBG:FlxSprite;
	var channelTxt:FlxText;

	public var midSongVideo:#if VIDEOS_ALLOWED VideoSprite #else Dynamic #end;
	public var cheatingVideo:#if VIDEOS_ALLOWED VideoSprite #else Dynamic #end;

	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	var canShakeNote:Bool; // fix for CAWM

  //if (ClientPrefs.shaders){
	var crtFNF:FlxRuntimeShader;
	var mawFNF:Shaders.MAWVHS;
    var ntscFNF:Shaders.NtscShader;
    var distortFNF:FlxRuntimeShader;
    var distortCAWMFNF:FlxRuntimeShader;
	var distortDadFNF:FlxRuntimeShader;
	var invertFNF:Shaders.InvertShader;
    var glowfnf:FlxRuntimeShader;
	var pibbyFNF:Shaders.Pibbified;
	var chromFNF:FlxRuntimeShader;
	var pincFNF:Shaders.PincushionShader;
	var blurFNF:Shaders.BlurShader;
	var blurFNFZoomEdition:FlxRuntimeShader;
	var blurFNFZoomEditionHUD: FlxRuntimeShader;
	var glitchFWFNF:FlxRuntimeShader; // here's where i follow scissor's concept n stuff
  //}

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartSaves:Map<String, FlxSave> = new Map();
	#end

    var shakeShit:Int = 0;
    var camTween:FlxTween;
    var camTween2:FlxTween;

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

    var cappedHealth:Int = 2;
    var isAppleLOL:Bool = false;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyWeekName : String = 'vcr';
	public static var storyDifficulty:Int = 1;

    var numberIntro:FlxSprite;
	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

    var jake:Character;
	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

    public var cameraOnDad:Bool = false;

    public var angleshit:Float = 1;
    public var anglevar:Float = 1;

	var bfIntro:Character;
	var pibbyIntro:Character;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

    public var jakeSings:Bool = false;
    public var pibbySings:Bool = false;

    public var allScripts:Array<ScriptConstructor> = [];
	private var strumLine:FlxSprite;
	var blackie:FlxSprite;
	var white:FlxSprite;
	var warning:FlxSprite;

    var fuckyouDadY:Float;
    var fuckyouDadX:Float;

	//Handles the new epic mega sexy cam code that i've done
	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

    var _scriptMap:Map<String, HScript.Script> = new Map<String, HScript.Script>();
    public function getScript(n:String)return _scriptMap.get(n);
    public function getScriptVar(n:String, f:String)return getScript(n).get(f);

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

    var fullPibbyHealthbar:Bool = false; // forces it to display the 100% animation
	var pibbyHealthbar:FlxSprite;

    var pibbyHealth:FlxSprite;
    
	//finn week shit
	var finnT:FlxSprite;
	var finnBarThing:FlxSprite;

	// for no hero
	var noHeroIntro:FlxSprite;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	public var boyfriendColor : FlxColor;
	public var dadColor : FlxColor;
    public var gfColor : FlxColor;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = true;

	var glitchShaderIntensity:Float;
    var distortIntensity:Float;
	var dadGlitchIntensity:Float;
    var abberationShaderIntensity:Float;
	var blurIntensity:Float;

    var animOffsetValue:Float = 20;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;
	public var lyricTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
    public var iconP3:HealthIcon;
	public var iconPibby:HealthIcon;
	public var iconJake:HealthIcon;
	public var camHUD:FlxCamera;
	public var camOverlay:FlxCamera;
	public var camGame:FlxCamera;
	public var camVoid:FlxCamera;
	public var camOther:FlxCamera;
	public var camCard:FlxCamera;
	public var cameraSpeed:Float = 1;
	public var cameraBumpTween : FlxTween;
	public var cameraHUDBumpTween : FlxTween;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	public var dodgeMisses:Int = 0;
	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	var flickerTween:FlxTween;

	// for da blammed lights
	var theBlackness:FlxSprite;
	var theWhiteness:FlxSprite;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	private var dodgeAnimations:Array<String> = ['dodgeLEFT', 'dodgeDOWN', 'dodgeUP', 'dodgeRIGHT'];
	private var shootAnimations:Array<String> = ['shootLEFT', 'shootDOWN', 'shootUP', 'shootRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;
	var fakeSongLength:Float = 0;

	//title card
	public var card:TitleCard;

	public var cinematicdown:FlxSprite;
	public var cinematicup:FlxSprite;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	// "jason fucking use pibbySing" 
	// SHUT UP MAN IT TOOK ME HOURS TO REALIZE HOW TO FIX THIS FOR MAW BEFORE DISCOVERING THAT VAR
	var hiCameraPleaseFocusOnGfPleaseAndThankYou = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	private var largeKey: String = "";
	#end

	var touhouBG:FlxSprite;
	var cnlogo:BGSprite;

	//gumball vars
	var void:BGSprite;
	var house:BGSprite;
	var rock:BGSprite;
	var rock2:BGSprite;
	var rock3:BGSprite;
	var rock4:BGSprite;
	var wtf:BGSprite;

    var defaultIconP2x:Float;
	
	//finn var
	var light:BGSprite;
	var dark:BGSprite;
	var bulb:BGSprite;

	var completeDarkness : FlxSprite;

	var camShitforReveal: FlxSprite;

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

    var beatShaderAmount:Float = 0.05;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	public var focusedCharacter:Character;
	var precacheList:Map<String, String> = new Map<String, String>();
	
	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo sprite object
	public static var lastCombo:FlxSprite;
	// stores the last combo score objects in an array
	public static var lastScore:Array<FlxSprite> = [];
	public static var stage:ScriptConstructor;

    var defaultOpponentStrum:Array<{x:Float, y:Float}> = [];
    var defaultPlayerStrum:Array<{x:Float, y:Float}> = [];

	var healthDrain:Bool = ClientPrefs.healthDrain;

	override public function create()
	{
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		FlxG.game.filtersEnabled = true;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed', 1);

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		controlArray = [
			'NOTE_LEFT',
			'NOTE_DOWN',
			'NOTE_UP',
			'NOTE_RIGHT'
		];

		//Ratings
		ratingsData.push(new Rating('sick')); //default rating

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		rating.noteSplash = false;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		rating.noteSplash = false;
		ratingsData.push(rating);

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camVoid = new FlxCamera();
		camGame = new FlxCamera();
		camOverlay = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camCard = new FlxCamera();
		camOverlay.bgColor.alpha = 0;
		camHUD.bgColor.alpha = 0;
		camHUD.alpha = 0;
		camOther.bgColor.alpha = 0;
		camCard.bgColor.alpha = 0;

		FlxG.cameras.add(camVoid, false);
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camOverlay, false);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		FlxG.cameras.add(camCard, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];
    #end

		cnlogo = new BGSprite('cnlogo', 990, 600, 0, 0);
		cnlogo.setGraphicSize(Std.int(cnlogo.width * 0.17));
		cnlogo.updateHitbox();
		if(ClientPrefs.downScroll) cnlogo.y -= 530;
        cnlogo.alpha = 0.5;
		cnlogo.cameras = [camCard];

		var leDate = Date.now();
		if (leDate.getHours() >= 17 && leDate.getHours() <= 24) {
			cnlogo.loadGraphic(Paths.image('aslogo'));
			cnlogo.x = 1046.5;
			cnlogo.y = 660;
			cnlogo.setGraphicSize(Std.int(cnlogo.width * 0.09));
			cnlogo.updateHitbox();
			if(ClientPrefs.downScroll) cnlogo.y -= 530;
			trace(cnlogo.y);
		}

		if (leDate.getHours() >= 1 && leDate.getHours() <= 6) {
			cnlogo.loadGraphic(Paths.image('aslogo'));
			cnlogo.x = 1046.5;
			cnlogo.y = 660;
			cnlogo.setGraphicSize(Std.int(cnlogo.width * 0.09));
			cnlogo.updateHitbox();
			if(ClientPrefs.downScroll) cnlogo.y -= 530;
		}

		if (leDate.getHours() >= 6 && leDate.getHours() <= 17) {
			cnlogo.loadGraphic(Paths.image('cnlogo'));
			cnlogo.x = 990;
			cnlogo.y = 600;
			cnlogo.setGraphicSize(Std.int(cnlogo.width * 0.17));
			cnlogo.updateHitbox();
			if(ClientPrefs.downScroll) cnlogo.y -= 530;
		}

		// video precachinggggggg
		Paths.video('Cheating_is_a_sin');

    #if desktop
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);
		
    curStage = SONG.stage;
    stage = new ScriptConstructor('stages/${curStage}','stage');
      @:privateAccess {
       stage.script.scriptInterpreter.curExpr.line = 0;
        }
        _scriptMap.set(curStage, stage.script);
        allScripts.push(stage);
        add(stage);
        SONG.stage = curStage;

        var daPath:String = 'assets/stages/${curStage}/scripts';
            var files:Array<String> = Assets.list().filter(text -> text.contains(daPath));
            if (files.length > 0) {
                for (file in files) {
                    var lastIndex:Int = file.lastIndexOf(".");
                    var fileFixed:String = file;
                    if (lastIndex != -1) {
                        var fileFixed:String = file.substr(0, lastIndex);
                        trace('Currently loading additional script ${file}');
                        var daScript:ScriptConstructor = new ScriptConstructor('', fileFixed);
                        _scriptMap.set(file, daScript.script);
                        allScripts.push(daScript);
                        add(daScript);
                    }
                }
            }

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
			trace('Could not find the stage file for ${curStage}');
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'newschool':
				var lockersnshit : BGSprite = new BGSprite('school/Ilustracion_sin_titulo-1', 0, 0, 1, 1);
				lockersnshit.setGraphicSize(Std.int(lockersnshit.width * 1.3));
				lockersnshit.updateHitbox();
				add(lockersnshit);
		}

		switch(Paths.formatToSongPath(SONG.song))
		{
			case 'stress':
				GameOverSubstate.characterName = 'bf-holding-gf-dead';
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		canShakeNote = ClientPrefs.screenGlitch;

		add(gfGroup); //Needed for blammed lights
		add(dadGroup);
		add(boyfriendGroup);

		//logos
		switch (storyWeekName)
		{
			case 'finn':
				add(cnlogo);

			case 'gumball':
				add(cnlogo);

			default: // the nothing
		}

        for (hScript in allScripts) {
		    add(hScript.foreground);
        }

		switch(curStage)
		{
			case 'newschool':
				var wall : BGSprite = new BGSprite('school/Ilustracion_sin_titulo-2', 0, 200, 1.2, 1.2);
				wall.setGraphicSize(Std.int(wall.width * 1.1));
				wall.updateHitbox();
                var lighting : BGSprite = new BGSprite('school/Ilustracion_sin_titulo-3', 0, 0, 1, 1);
				lighting.setGraphicSize(Std.int(lighting.width * 1.3));
				lighting.updateHitbox();
				completeDarkness = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
				//add(completeDarkness);
				completeDarkness.cameras = [camHUD];
				add(lighting);
				add(wall);
		}
		
		if (SONG.song == "No Hero Remix")
		{
			noHeroIntro = new FlxSprite(-200, -400);
			noHeroIntro.frames = Paths.getSparrowAtlas('noherocutscenefirst', 'shared');
			noHeroIntro.animation.addByPrefix('finnJumpscareMomento', 'play', 24, true);
			noHeroIntro.cameras = [camOther];
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		/*#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));

		for(mod in Paths.getGlobalMods())
			foldersToCheck.insert(0, Paths.mods(mod + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file, false));
						filesPushed.push(file);
					}
				}
			}
		}
		#end*/


		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1)
		{
			gfVersion = 'gf';
			switch(Paths.formatToSongPath(SONG.song))
			{
				case 'stress':
					gfVersion = 'pico-speaker';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);

            gfColor = FlxColor.fromRGB(gf.healthColorArray[0], gf.healthColorArray[1], gf.healthColorArray[2]);
		}

        if(SONG.song == 'Suffering Siblings'){
			jake = new Character(100, -90, "jake");
			startCharacterPos(jake, true);
		    dadGroup.add(jake);
		}

		dad = new Character(0, 0, ClientPrefs.killyourself && SONG.song == 'Suffering Siblings' ? 'finn-sus' : SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);
		dadColor = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);
		boyfriendColor = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		Conductor.songPosition = -5000 / Conductor.songPosition;

		channelTxt = new FlxText(-400, 90, FlxG.width, "", 20);
		channelTxt.setFormat(Paths.font('vcr.ttf'), 56, FlxColor.LIME, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		channelTxt.scrollFactor.set();
		channelTxt.borderSize = 1.25;

		cinematicdown = new FlxSprite().makeGraphic(FlxG.width, 100, FlxColor.BLACK);
		cinematicdown.scrollFactor.set();
		cinematicdown.setPosition(0, FlxG.height);
		add(cinematicdown);

		cinematicup = new FlxSprite().makeGraphic(FlxG.width, 100, FlxColor.BLACK);
		cinematicup.scrollFactor.set();
		cinematicup.setPosition(0, -100);
		add(cinematicup);

		blackie = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackie.scrollFactor.set();
		blackie.alpha = 0;
		add(blackie);

		switch (SONG.song)
			{
				case 'Retcon':
					// blackie.alpha = 1;
					defaultCamZoom = 1.18;
					// using getScript shit returns null (tragic) or either i suck using it
					boyfriend.color = 0xff969494;
					dad.color = boyfriend.color;
					gf.color = boyfriend.color;
			}

            // WHY ISTHIS ALWAYS LOADED??
        if(SONG.song.toLowerCase() == 'mindless'){
            finnT = new FlxSprite();
            finnT.x = -260;
            finnT.y = -180;
            finnT.frames = Paths.getSparrowAtlas('characters/Finn_Transformation', null, true); // btw to make smth utilise GPU you add true as its final argument, and if GPU caching is on it'll put it in VRAM
            finnT.animation.addByPrefix('cutscene', 'FINN-CUTSCENE', 24, false);
            finnT.alpha = 0.0001;
            finnT.scrollFactor.set();
            add(finnT);
        }

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font(storyWeekName + '.ttf'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		timeBarBG.sprTracker = timeBar;
		add(timeBar);
		add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}
		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();

		// camera shit fix for children play
		if (curStage == 'school') cameraSpeed = 50;

		camFollowPos = new FlxObject(0, 0, 1, 1);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);
		
		camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
		camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
		camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
        insert(members.indexOf(opponentStrums) + 1, channelTxt);

		if (Assets.exists(Paths.txt(SONG.song.replace(' ', '-') + "/info")))
			{
				trace('woo');
				card = new TitleCard(0, 200, SONG.song.replace(' ', '-'));
				card.cameras = [camOther];
				add(card);
			}

		FlxG.fixedTimestep = false;

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;
		//healthBarBG.alpha = 1;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		healthBarBG.sprTracker = healthBar;
		//healthBar.alpha = 1;
		add(healthBar);

		pibbyHealthbar = new FlxSprite();
        if(ClientPrefs.shaders)
		    pibbyHealthbar.frames = Paths.getSparrowAtlas('healthbar/healthbarShader', null, true);
        else
            pibbyHealthbar.frames = Paths.getSparrowAtlas('healthbar/healthbar', null, true);

        pibbyHealthbar.scale.set(1, 1);
        pibbyHealthbar.updateHitbox();
        for(i in 0...41){
            var indiceStart = i * 3;
            var animFrames = [indiceStart, indiceStart + 1, indiceStart + 2]; 
           	pibbyHealthbar.animation.addByIndices('${CoolUtil.snap((i/40)*100, 2.5)}Percent', "healthbar", animFrames, "", 12, true);
        }
        
        pibbyHealthbar.animation.play("50Percent",true); // 50% damage, cus hp starts at half (1 / 2)
        if(ClientPrefs.shaders)pibbyHealthbar.shader = new Shaders.GreenReplacementShader();

		pibbyHealthbar.x = 65; 
        
        add(pibbyHealthbar);
        
		finnBarThing = new FlxSprite();
		finnBarThing.y = 565;
		finnBarThing.x = 197;
        if(storyWeekName != 'gumball'){
		    finnBarThing.frames = Paths.getSparrowAtlas('healthbar/iconbar', null, true);
            finnBarThing.animation.addByPrefix('idle2', 'Icons Bar 2', 24, true);
            finnBarThing.animation.addByPrefix('idle3', 'Icons Bar 1', 24, true);
            finnBarThing.animation.addByPrefix('idle1', 'Icons Bar 3', 24, true);
            finnBarThing.animation.play('idle3');
        }
		finnBarThing.scrollFactor.set();
		finnBarThing.alpha = ClientPrefs.healthBarAlpha;
		if(ClientPrefs.downScroll) finnBarThing.y = 0.12;
		add(finnBarThing);

		if (storyWeekName == "gumball") {
			finnBarThing.visible = false;
            //pibbyHealthbar.visible = false;
			healthBar.visible = false;
            healthBarBG.visible = false;
		}

		if (gf != null)
		{
			iconP3 = new HealthIcon(gf.healthIcon, true);
			iconP3.y = healthBar.y - 112;
			iconP3.visible = !ClientPrefs.hideHud;
			iconP3.alpha = ClientPrefs.healthBarAlpha;
			add(iconP3);
		}

		if (SONG.song == "Suffering Siblings")
		{
			iconPibby = new HealthIcon(gf.healthIcon, true);
			iconPibby.y = healthBar.y - 77;
			iconPibby.visible = !ClientPrefs.hideHud;
			iconPibby.alpha = ClientPrefs.healthBarAlpha;
			add(iconPibby);

			iconJake = new HealthIcon("jake", false);
			iconJake.y = healthBar.y - 77;
			iconJake.visible = !ClientPrefs.hideHud;
			iconJake.alpha = ClientPrefs.healthBarAlpha;
			add(iconJake);
		}

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);

		reloadHealthBarColors();

		pibbyHealthbar.y = iconP1.y + 50;

		if (ClientPrefs.downScroll)
			pibbyHealthbar.y = iconP1.y + 50;

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font(storyWeekName + '.ttf'), 20, boyfriendColor, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		lyricTxt = new FlxText(0, healthBarBG.y - 72, FlxG.width, "", 20);
		lyricTxt.setFormat(Paths.font(storyWeekName + '.ttf'), 48, dadColor, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		lyricTxt.scrollFactor.set();
		lyricTxt.borderSize = 1.25;
		lyricTxt.alpha = 0;
		if(ClientPrefs.downScroll) {
			lyricTxt.y = healthBarBG.y + 72;
		}
		add(lyricTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font(storyWeekName + '.ttf'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		warning = new FlxSprite();
		warning.frames = Paths.getSparrowAtlas('lowHP/gradient');
		warning.animation.addByPrefix('warn', 'idle', 24, true);
		warning.scale.set(0.95, 0.85);
		warning.screenCenter();
		warning.alpha = 0;
		add(warning);

		blackie.cameras = [camOther];
		warning.cameras = [camOther];
		cinematicdown.cameras = [camOverlay];
		cinematicup.cameras = [camOverlay];
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
        if (gf != null) iconP3.cameras = [camHUD];
		if (SONG.song == "Suffering Siblings") {
			iconJake.cameras = [camHUD];
			iconPibby.cameras = [camHUD];
		}
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		lyricTxt.cameras = [camOther];
		finnBarThing.cameras = [camHUD];
        pibbyHealthbar.cameras = [camHUD];
        if(SONG.song.toLowerCase() == 'mindless')finnT.cameras = [camHUD];
		channelTxt.cameras = [camOther];

   #if mobile
   addMobileControls(false);
   mobileControls.visible = false;
   #end

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(Asset2File.getPath(luaToLoad), false));
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.getPreloadPath('custom_events/' + event + '.lua');
			if(OpenFlAssets.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(Asset2File.getPath(luaToLoad), false));
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');

		if (PauseSubState.songName != null) {
			precacheList.set(PauseSubState.songName, 'music');
		} else if(ClientPrefs.pauseMusic != 'None') {
			precacheList.set(Paths.formatToSongPath(ClientPrefs.pauseMusic), 'music');
		}

		precacheList.set('alphabet', 'image');

		#if desktop	
		switch(SONG.song.replace('-', ' '))
		{
			case "Mindless" | "Brotherly Love" | "Blessed By Swords" | "Suffering Siblings":
				largeKey = "adventuretimeothers";
			case "Come Along With Me":
				largeKey = "cawm";
			case "Childs Play":
				largeKey = "childsplay";
			case "Forgotten World":
				largeKey = "forgottenworld";
			case "My Amazing World":
				largeKey = "maw";
			case "Retcon":
				largeKey = "retcon";
			default:
				largeKey = "https://i.imgur.com/j1NOFU9.gif";
		}

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), null, null, largeKey);
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		callOnLuas('onCreatePost', []);
        for (hScript in allScripts) {
            hScript.onCreatePost();
        }

        FlxG.mouse.visible = false;

        if (gf != null) {
            // for retcon cus yeah you get the point
            iconP3.visible = (SONG.song == 'Retcon');
        }
		timeTxt.setFormat(Paths.font(storyWeekName + '.ttf'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

    if (ClientPrefs.shaders){
		pibbyFNF = new Shaders.Pibbified();
		ntscFNF = new Shaders.NtscShader();
		mawFNF = new Shaders.MAWVHS();
		crtFNF = new FlxRuntimeShader(RuntimeShaders.monitor, null, 100);
		distortFNF = new FlxRuntimeShader(RuntimeShaders.distort, null, 100);
        distortCAWMFNF = new FlxRuntimeShader(RuntimeShaders.distort, null, 100);
        glowfnf = new FlxRuntimeShader(RuntimeShaders.glowy, null, 100);
		distortDadFNF = new FlxRuntimeShader(RuntimeShaders.distort, null, 100);
		invertFNF = new Shaders.InvertShader();
		chromFNF = new FlxRuntimeShader(RuntimeShaders.chromShader, null, 100);
		pincFNF = new Shaders.PincushionShader();
		blurFNF = new Shaders.BlurShader();
		blurFNFZoomEdition = new FlxRuntimeShader(RuntimeShaders.blurZoom, null, 100);
		blurFNFZoomEditionHUD = new FlxRuntimeShader(RuntimeShaders.blurZoom, null, 100);
		glitchFWFNF = new FlxRuntimeShader(RuntimeShaders.fwGlitch, null, 100);
		camVoid.setFilters([new ShaderFilter(pincFNF)]);

        distortDadFNF.setFloat("negativity", 0.0);
        distortFNF.setFloat("negativity", 0.0);
        distortCAWMFNF.setFloat("negativity", 0.0);

        distortFNF.setFloat("binaryIntensity", 1000.0);
        distortCAWMFNF.setFloat("binaryIntensity", 1000.0);
    }
 
		if(ClientPrefs.shaders) {
			camHUD.setFilters([new ShaderFilter(pibbyFNF),new ShaderFilter(chromFNF)]);
			camGame.setFilters([new ShaderFilter(pibbyFNF),new ShaderFilter(chromFNF)]);
            for (i in 0...opponentStrums.length) {
                opponentStrums.members[i].shader = distortFNF;
            }
		}
		if(ClientPrefs.shaders) {
			chromFNF.setFloat('aberration', -0.5);
		}

		super.create();
		//garbage collection :trol:
		System.gc();

		switch (SONG.song.replace('-', ' '))
			{
				case 'My Amazing World':
					gf.alpha = 0;
					moveCamera(true);
					// blackie.alpha = 1;
					camGame.fade(FlxColor.BLACK, 0.000001);
					camHUD.alpha = 0;
					defaultCamZoom = 1.7;
					if (ClientPrefs.gore) {
                        GameOverSubstate.characterName = 'gumdead';
						GameOverSubstate.deathSoundName = 'new_gumball_death';
						GameOverSubstate.endSoundName = 'gfgumballrevive';
                    }
				case 'Retcon': 
					if (ClientPrefs.gore) {
                        GameOverSubstate.characterName = 'gumdead';
						GameOverSubstate.deathSoundName = 'new_gumball_death';
						GameOverSubstate.endSoundName = 'gfgumballrevive';
                    }
				case 'Forgotten World':
					addCharacterToList('darwinfw', 0);
					#if VIDEOS_ALLOWED
					midSongVideo.bitmap.playVideo(Paths.video('forgottenscene'));
					midSongVideo.bitmap.finishCallback = null;
					midSongVideo.bitmap.stop();
					midSongVideo.cameras = [camHUD];
					#end
					GameOverSubstate.characterName = 'darwindeath';
					GameOverSubstate.deathSoundName = 'glitchhit';
					GameOverSubstate.endSoundName = 'gameOverEnd';
					// blackie.alpha = 1;
					camGame.fade(FlxColor.BLACK, 0.000001);
					camHUD.alpha = 0;
					healthBar.visible = false;
					healthBarBG.visible = false;
					pibbyHealthbar.visible = false;
					iconP1.visible = false; 
					iconP2.visible = false;
					scoreTxt.visible = false;
				case "Child's Play":
					// blackie.alpha = 1;
					healthDrain = false;
					for (i in 0...opponentStrums.length) opponentStrums.members[i].shader = null;
					if (ClientPrefs.gore) {
                        GameOverSubstate.characterName = 'gumdead';
						GameOverSubstate.deathSoundName = 'new_gumball_death';
						GameOverSubstate.endSoundName = 'gfgumballrevive';
                    }
				case 'Blessed by Swords':
					iconP1.changeIcon("pibby");
					addCharacterToList('finn-slash', 1);
                        GameOverSubstate.characterName = 'pibby-dead';
						GameOverSubstate.deathSoundName = 'glitchhit';
						GameOverSubstate.soundLibraryStart = 'shared';
						GameOverSubstate.endSoundName = 'gameOverEnd';
				case 'Brotherly Love': 
                    if (ClientPrefs.gore) {
					    /*GameOverSubstate.characterName = 'bf-dead-jake';
						GameOverSubstate.deathSoundName = 'bfjakedeath';*/

						// im sorry but i fucking hate how badly the spritesheet was exported to even look buggy asf so yeah too bad L for jake
						GameOverSubstate.characterName = 'jake_death';
						GameOverSubstate.deathSoundName = 'bfjakedeath';
						GameOverSubstate.endSoundName = 'gffinnrevive';
                    }
				case 'Suffering Siblings':
					addCharacterToList('finn-sword', 1);
                    if (ClientPrefs.gore) {
					    //GameOverSubstate.characterName = (FlxG.random.bool() ? 'bf-dead-jake' : 'bf-dead-finn');
						GameOverSubstate.characterName = 'deathscreen';
						GameOverSubstate.deathSoundName = 'glitchhit';
						GameOverSubstate.soundLibraryStart = 'shared';
						GameOverSubstate.endSoundName = 'gameOverEnd';

						/*if (GameOverSubstate.characterName == 'bf-dead-jake')
							GameOverSubstate.deathSoundName = 'bfjakedeath';
						else
							GameOverSubstate.deathSoundName = 'bffinndeath';*/
                    }
				case 'Mindless':
					addCharacterToList('finn-sword', 1);
					addCharacterToList('finn-slash', 1);
					camGame.fade(FlxColor.BLACK, 0.0001);
					finnBarThing.alpha = 0.0001;
					dad.alpha = 0.0001;
					iconP2.alpha = 0.0001;
					iconP1.alpha = 0.0001;
					scoreTxt.alpha = 0.0001;

					for (i in 0...opponentStrums.length) {
						opponentStrums.members[i].alpha = 0;
					}

                    if (ClientPrefs.gore) {
					    GameOverSubstate.characterName = 'bf-dead-finn';
						GameOverSubstate.deathSoundName = 'bffinndeath';
						GameOverSubstate.endSoundName = 'gffinnrevive';
                    }
				case 'Come Along With Me':
					for (i in 0...opponentStrums.length) {
						opponentStrums.members[i].shader = null;
					}
					// I cant be bothered, so I threw it in preload, if you have an issue with it kiss my ass k thx :3
					camShitforReveal = new FlxSprite(0, 0).loadGraphic(Paths.image('CameraShtuff'));
					camShitforReveal.screenCenter(XY);
					camShitforReveal.cameras = [camOther];
					add(camShitforReveal);

					camGame.fade(FlxColor.BLACK, 0.000001);
					camHUD.alpha = 0;
					iconP2.alpha = 0.0001;
					iconP1.alpha = 0.0001;
					boyfriend.color = 0x859791FF;
					finnBarThing.alpha = 0.0001;
					scoreTxt.alpha = 1;
                    pibbyHealthbar.alpha = 0.0001;
					boyfriendGroup.visible = false;
					addCharacterToList('finn-sword', 1);
					addCharacterToList('finncawm_reveal', 1);
					addCharacterToList('bfcawn', 0);
					addCharacterToList('finncawn', 1);
					if (ClientPrefs.shaders)
					{
						FlxG.camera.pushFilter("blurMoment", new ShaderFilter(blurFNFZoomEdition));
						camHUD.pushFilter("blurMoment2", new ShaderFilter(blurFNFZoomEditionHUD));
					blurFNFZoomEdition.setFloat('posX', 0.5);
					blurFNFZoomEdition.setFloat('posY', 0.5);
					blurFNFZoomEdition.setFloat('focusPower', 6);

					blurFNFZoomEditionHUD.setFloat('posX', 0.5);
					blurFNFZoomEditionHUD.setFloat('posY', 0.5);
					blurFNFZoomEditionHUD.setFloat('focusPower', 2);
					}

                    if (ClientPrefs.gore) {
					    GameOverSubstate.characterName = 'bf-dead-finn';
						GameOverSubstate.deathSoundName = 'bffinndeath';
						GameOverSubstate.endSoundName = 'gffinnrevive';
                    }
				case 'No Hero Remix': 
					camGame.fade(FlxColor.BLACK, 0.000001);
					camHUD.alpha = 0;
					healthBar.visible = false;
					healthBarBG.visible = false;
					iconP2.color = 0x000000;
					scoreTxt.visible = false;
					finnBarThing.alpha = 0.001;
					GameOverSubstate.characterName = 'assbf';
					GameOverSubstate.endSoundName = 'gffinnrevive';
			}

		cacheCountdown();
		cachePopUpScore();
		for (key => type in precacheList)
		{
			//trace('Key $key is type $type');
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		Paths.clearUnusedMemory();
		
		CustomFadeTransition.nextCamera = camOther;

		theBlackness = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			theBlackness.alpha = 0;
			theBlackness.scrollFactor.set();
		addBehindGF(theBlackness);

		theWhiteness = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
			theWhiteness.alpha = 0;
			theWhiteness.scrollFactor.set();
		addBehindGF(theWhiteness);
	}
						
	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 100)
	{
		if(!ClientPrefs.shaders) return false;

		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

        #if none
		var foldersToCheck:Array<String> = [Paths.mods('shaders/')];
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/shaders/'));
		#else
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('shaders/')];
		#end

		for (folder in foldersToCheck)
		{
			#if desktop
			if(FileSystem.exists(folder))
			#else
			if(OpenFlAssets.exists(folder))
			#end
			{
				var frag:String = folder + name + '.frag';
				var vert:String = folder + name + '.vert';
				var found:Bool = false;
				#if desktop
				if(FileSystem.exists(frag))
				{
					frag = File.getContent(frag);
					found = true;
				}
				else frag = null;

				if (FileSystem.exists(vert))
				{
					vert = File.getContent(vert);
					found = true;
				}
				else vert = null;
				#else
				if(OpenFlAssets.exists(frag))
				{
					frag = Assets.getText(frag);
					found = true;
				}
				else frag = null;
	
				if (OpenFlAssets.exists(vert))
				{
					vert = Assets.getText(vert);
					found = true;
				}
				else vert = null;
				#end

				if(found)
				{
					runtimeShaders.set(name, [frag, vert]);
					//trace('Found shader $name!');
					return true;
				}
			}
		}
		FlxG.log.warn('Missing shader $name .frag AND .vert files!');
		return false;
	}
	#end

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes) note.resizeByRatio(ratio);
			for (note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		if(generatedMusic)
		{
			if(vocals != null) vocals.pitch = value;
			FlxG.sound.music.pitch = value;
		}
		playbackRate = value;
		FlxAnimationController.globalSpeed = value;
		trace('Anim speed: ' + FlxAnimationController.globalSpeed);
		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000 * value;
		setOnLuas('playbackRate', playbackRate);
		return value;
	}

	public function addTextToDebug(text:String, color:FlxColor) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup, color));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(dadColor, boyfriendColor);

		timeBar.createFilledBar(0xFF000000, dadColor);
		timeBar.updateBar();
		healthBar.updateBar();
        if(ClientPrefs.shaders){
            var shader:Shaders.GreenReplacementShader = cast pibbyHealthbar.shader;
            shader.colour = boyfriendColor;
        }
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';

		luaFile = Paths.getPreloadPath(luaFile);
		if(Assets.exists(luaFile)) {
			doPush = true;
		}

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(Asset2File.getPath(luaFile), false));
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function youCheatedRah()
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video('Cheating_is_a_sin');
		if(!FileSystem.exists(filepath))
		{
			FlxG.log.warn('Couldnt find video file!!');
			MusicBeatState.switchState(new FreeplayState());
			return;
		}

		cheatingVideo.camera = camOther;
		cheatingVideo.playVideo(filepath);
		cheatingVideo.bitmap.canSkip = false;
		cheatingVideo.scale.set(0.705, 0.705);
		cheatingVideo.x -= 300;
		cheatingVideo.y -= 170;
		cheatingVideo.openingCallback = () -> {
			persistentUpdate = false;
			camOther.fade(0x000000, 3, true);
		}
		cheatingVideo.finishCallback = function()
		{
			persistentUpdate = true;
			lime.app.Application.current.window.alert('Our game, our rules' + '.' + '\n- Finn');
			Sys.exit(0);
		}
		#else
		FlxG.log.warn('Platform not supported!');
		MusicBeatState.switchState(new FreeplayState());
		return;
		#end
	}
	
	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		if(!FileSystem.exists(filepath))
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:VideoHandler = new VideoHandler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			startAndEnd();
			return;
		}
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		introAssets.set('default', ['ready', 'set', 'go']);
		introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

		var introAlts:Array<String> = introAssets.get('default');
		if (isPixelStage) introAlts = introAssets.get('pixel');
		
		for (asset in introAlts)
			Paths.image(asset);
		

		if(isPixelStage) {
		Paths.sound('intro3-pixel');
		Paths.sound('intro2-pixel');
		Paths.sound('intro1-pixel');
		Paths.sound('introGo-pixel');
		} else { // fix of the dumb error
		Paths.sound('3');
		Paths.sound('2');
		Paths.sound('1');
		Paths.sound('go');
		}
	}

	private function cameraBump( isFinal : Bool = false ) : Void
	{

		if (ClientPrefs.camZooms) FlxG.camera.zoom += 0.1;
		if (ClientPrefs.camZooms) camHUD.zoom += 0.1;

		// why this vars exist they don't do anything special :sobs:
		cameraBumpTween = FlxTween.tween(FlxG.camera, {zoom : isFinal ? defaultCamZoom : FlxG.camera.zoom - 0.05}, 0.4, {ease: FlxEase.quartOut});
		cameraHUDBumpTween = FlxTween.tween(camHUD, {zoom : isFinal ? 1 : camHUD.zoom - 0.05}, 0.4, {ease: FlxEase.quartOut});

		if (isFinal) {
			camHUD.alpha = (SONG.song == 'Suffering Siblings' || SONG.song == 'No Hero Remix' || SONG.song == 'Come Along With Me' || storyWeekName == 'gumball' ? 0 : 1);

            if (ClientPrefs.flashing) {
			    camHUD.flash(FlxColor.WHITE, 0.25);
            }
		}
	}

	var introCharacter = 'bf_intro';
	public function startCountdown():Void
    {
     #if mobile
     mobileControls.visible = true;
     #end
 
        if (SONG.player1.contains('newbf')) {
			switch (SONG.song)
			{
				case "Child's Play" | 'My Amazing World': introCharacter = 'bf_intro_gumball';
				case 'Retcon': introCharacter = 'bf_intro_but_retcon';
				case 'Mindless' | "Blessed by Swords" | 'Brotherly Love' | 'Suffering Siblings': introCharacter = 'bf_intro_finn';
				default: introCharacter = 'bf_intro';
			}
			trace('current bf intro char: $introCharacter');
            bfIntro = new Boyfriend(0, 0, introCharacter); //SOMEONE PLEASE FIX THE BF INTRO SCALING (I TRIED BUT PSYCH SCALING DOESNT GET ACCURATE ENOUGH)
			// news flash the bf intro scaling is fixed yay!!!!
            startCharacterPos(bfIntro);
            boyfriend.alpha = 0;

            bfIntro.playAnim('Go', true);
            bfIntro.specialAnim = true;
			if (SONG.song == 'Retcon') bfIntro.color = 0xff969494;
		}

        if (gf != null && gf.curCharacter.startsWith('pibby')) {
            pibbyIntro = new Boyfriend(-68.55, -76.15, 'pibby_intro');
            startCharacterPos(pibbyIntro);
            boyfriendGroup.add(pibbyIntro);
            if (gf != null)
                gf.alpha = 0;
            
            pibbyIntro.playAnim('Go', true);
            pibbyIntro.specialAnim = true;
        }

        if (SONG.player1.contains('newbf'))
            boyfriendGroup.add(bfIntro);

        var numberIntro:FlxSprite = new FlxSprite();
        numberIntro.screenCenter();
        numberIntro.x -= 200;
        numberIntro.y -= 200;
        numberIntro.frames = Paths.getSparrowAtlas('Numbers', 'shared', true);
        numberIntro.alpha = 0.0001;
        numberIntro.cameras = [camOverlay];
        
        numberIntro.animation.addByPrefix('3', '3', 30, false);
        numberIntro.animation.addByPrefix('2', '2', 30, false);
        numberIntro.animation.addByPrefix('1', '1', 30, false);
        numberIntro.animation.addByPrefix('Go', 'Go', 30, false);
        
        numberIntro.animation.finishCallback = (name) -> {numberIntro.visible = false;}
        add(numberIntro);

        //introGroup.add(numberIntro);
    
        if(startedCountdown) {
            callOnLuas('onStartCountdown', []);
            return;
        }

        for (hScript in allScripts) {
            hScript.onStartCountdown();
        }

        inCutscene = false;
        var ret:Dynamic = callOnLuas('onStartCountdown', [], false);
        if(ret != FunkinLua.Function_Stop) {
            generateStaticArrows(0);
            generateStaticArrows(1);
            for (i in 0...playerStrums.length) {
                setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
                setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
                defaultPlayerStrum.push({x: playerStrums.members[i].x, y: playerStrums.members[i].y});
            }
            for (i in 0...opponentStrums.length) {
                setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
                setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
                defaultOpponentStrum.push({x: opponentStrums.members[i].x, y: opponentStrums.members[i].y});
                //if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
            }

            startedCountdown = true;
            Conductor.songPosition = (-0.67 * 5) * 1000;
            setOnLuas('startedCountdown', true);
            callOnLuas('onCountdownStarted', []);

            var swagCounter:Int = 0;

            if(startOnTime < 0) startOnTime = 0;

            if (startOnTime > 0) {
                clearNotesBefore(startOnTime);
                setSongTime(startOnTime - 350);
                return;
            }
            else if (skipCountdown)
            {
                setSongTime(0);
                return;
            }

            startTimer = new FlxTimer().start(0.67, function(tmr:FlxTimer)
            {
                switch (swagCounter)
                {
                    case 0:
                        /**
                        for (sprite in introGroup)
                            sprite.animation.play('2');
                        cameraBump();
                        **/
                        cameraBump();
                        numberIntro.alpha = 1;
                        if (bfIntro != null)
                            {
                                if (SONG.player1.contains('newbf')) {
                                    bfIntro.playAnim('3', true);
                                    bfIntro.specialAnim = true;
                                }

                                if (gf != null && gf.curCharacter.startsWith('pibby')) {
                                    pibbyIntro.playAnim('3', true);
                                    pibbyIntro.specialAnim = true;
								}
								
								if (gf != null && gf.curCharacter.startsWith('darwin'))
									gf.dance((FlxG.random.bool(25)) ? 'idle-blink' : 'idle');

								// goes back to the default speed
								if (curStage == 'school') cameraSpeed = 1;
                            }
						
						numberIntro.animation.play('3');
                        FlxG.sound.play(Paths.sound('3'), 0.6);
                    case 1:
                        /**
                        for (sprite in introGroup)
                            sprite.animation.play('2');
                        cameraBump();
                        **/
                        cameraBump();
                        if (bfIntro != null)
                            {
                                if (SONG.player1.contains('newbf')) {
                                    bfIntro.playAnim('2', true);
                                    bfIntro.specialAnim = true;
                                }

                                if (gf != null && gf.curCharacter.startsWith('pibby')) {
                                    pibbyIntro.playAnim('2', true);
                                    pibbyIntro.specialAnim = true;
                                }

								if (gf != null && gf.curCharacter.startsWith('darwin'))
									gf.dance((FlxG.random.bool(25)) ? 'idle-blink' : 'idle');
                            }
						numberIntro.visible = true;
						numberIntro.animation.play('2');
						numberIntro.offset.set(-85, -58);
                        FlxG.sound.play(Paths.sound('2'), 0.6);
                    case 2:
                        /**
                        for (sprite in introGroup)
                            sprite.animation.play('2');
                        cameraBump();
                        **/
                        cameraBump();
                        if (bfIntro != null)
                            {
                                if (SONG.player1.contains('newbf')) {
                                    bfIntro.playAnim('1', true);
                                    bfIntro.specialAnim = true;
                                }
                                if (gf != null && gf.curCharacter.startsWith('pibby')) {
                                    pibbyIntro.playAnim('1', true);
                                    pibbyIntro.specialAnim = true;
								}

								if (gf != null && gf.curCharacter.startsWith('darwin'))
									gf.dance((FlxG.random.bool(25)) ? 'idle-blink' : 'idle');
                            }
						numberIntro.visible = true;
						numberIntro.animation.play('1');
						numberIntro.offset.set(-72, -47);
                        FlxG.sound.play(Paths.sound('1'), 0.6);
                    case 3:
                        /**
                        for (sprite in introGroup)
                            sprite.animation.play('2');
                        cameraBump();
                        **/
                        cameraBump(true);
                        if (bfIntro != null)
                            {
                                if (SONG.player1.contains('newbf')) {
                                    bfIntro.playAnim('Go', true);
                                    bfIntro.specialAnim = true;
                                }

                                if (gf != null && gf.curCharacter.startsWith('pibby')) {
                                    pibbyIntro.playAnim('Go', true);
                                    pibbyIntro.specialAnim = true;
                                }

								if (gf != null && gf.curCharacter.startsWith('darwin'))
									gf.dance((FlxG.random.bool(25)) ? 'idle-blink' : 'idle');
                                
							    numberIntro.visible = true;
                                numberIntro.animation.play('Go');
                                numberIntro.offset.set(98, -15);
                            }
						numberIntro.visible = true;
						numberIntro.animation.play('Go');
						numberIntro.offset.set(98, -15);
                        FlxG.sound.play(Paths.sound('go'), 0.6);
                    case 4:
                        if (SONG.player1.contains('newbf')) {
                            boyfriend.alpha = 1;
                            bfIntro.alpha = 0;
                        }
                        if (gf != null && gf.curCharacter.startsWith('pibby')) {
                            gf.alpha = 1;
                            pibbyIntro.alpha = 0;
                        }
                        numberIntro.alpha = 0;
                }

                notes.forEachAlive(function(note:Note) {
                    if(ClientPrefs.opponentStrums || note.mustPress)
                    {
                        note.copyAlpha = false;
                        if(ClientPrefs.middleScroll && !note.mustPress) {
                            note.alpha *= 0.35;
                        }
                    }
                });
                callOnLuas('onCountdownTick', [swagCounter]);
                for (hScript in allScripts) {
                    hScript.onCountdownTick(swagCounter);
                }

                swagCounter += 1;
            }, 5);
        }
    }

	public function addBehindGF(obj:FlxObject)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxObject)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad (obj:FlxObject)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	var randomSeed : FlxRandom = new FlxRandom();

	public function updateScore(miss:Bool = false)
	{
		scoreTxt.text = 'Score: ' + songScore
		+ ' | Combo Breaks: ' + songMisses
		+ ' | Rank: '
		+ (ratingName != '?' ? '$ratingFC - ${Highscore.floorDecimal(ratingPercent * 100, 2)}%' : '');

		if(ClientPrefs.scoreZoom && !miss && !cpuControlled)
		{
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.angle = randomSeed.int(-2, 2, [-1, 0, 1]);
			scoreTxtTween = FlxTween.tween(scoreTxt, {angle: 0}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}
		callOnLuas('onUpdateScore', [miss]);
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			vocals.pitch = playbackRate;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.pitch = playbackRate;
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		fakeSongLength = songLength;
		switch(SONG.song)
		{
			case "Retcon":
				fakeSongLength = 150290;

            case "Child's Play":
                fakeSongLength = 152000;
		}
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength, largeKey);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
        for (hScript in allScripts) {
		    hScript.onSongStart();
        }
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		var sognArtist:String = CoolUtil.getSongArtist(curSong);

		openfl.Lib.application.window.title = "Pibby: Apocalypse - " + curSong + " - Composed by " + sognArtist;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.pitch = playbackRate;
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		#if VIDEOS_ALLOWED
		midSongVideo = new VideoSprite();
		add(midSongVideo);
		#end

		notes = new FlxTypedGroup<Note>();
		add(notes);

		#if VIDEOS_ALLOWED
		cheatingVideo = new VideoSprite();
		add(cheatingVideo);
		#end

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		if (OpenFlAssets.exists(file)) {
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.row = Conductor.secsToRow(daStrumTime);
				if(noteRows[gottaHitNote?0:1][swagNote.row]==null)
					noteRows[gottaHitNote?0:1][swagNote.row]=[]; // holy shit my code -neb 
				noteRows[gottaHitNote ? 0 : 1][swagNote.row].push(swagNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
		  case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
         addCharacterToList(newCharacter, charType);
		}
		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i),
					onComplete: 
					function (twn:FlxTween)
						{
							babyArrow.alpha = 1;
						}});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

            if(camTween != null) {
                camTween.active = false;
            }
            if(camTween2 != null) {
                camTween2.active = false;
            }
			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

            if(camTween != null) {
                camTween.active = true;
            }
            if(camTween2 != null) {
                camTween2.active = true;
            }
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);
            for (hScript in allScripts) {
			    hScript.onResume();
            }

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset, largeKey);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), null, null, largeKey);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
    {
        #if desktop
        if (health > 0 && !paused)
        {
            if (Conductor.songPosition > 0.0)
            {
                DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset, largeKey);
            }
            else
            {
                DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), null, null, largeKey);
            }
        }
        #end

        super.onFocus();
    }
    

	override public function onFocusLost():Void
    {
        #if desktop
        if (health > 0 && !paused)
        {
            DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter(), null, null, largeKey);
        }
        #end
        super.onFocusLost();
    }

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		FlxG.sound.music.pitch = playbackRate;
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			vocals.pitch = playbackRate;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;
	var shaderStuff:Float = 0;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/
		callOnLuas('onUpdate', [elapsed]);
        
		if (storyWeekName != 'gumball')
            if (curBeat % 1 == 0)
                finnBarThing.animation.play('idle${(2 - dodgeMisses) + 1}');

        var healthPercent = health * 0.5; // i would do / 2 but iirc multiplication is more optimized than division in alot of cases
        var damagePercent = 1 - healthPercent;

        if(fullPibbyHealthbar)
            pibbyHealthbar.animation.play('100Percent'); // full bar
        else
            pibbyHealthbar.animation.play('${CoolUtil.snap(damagePercent * 100, 2.5)}Percent'); // snaps to multiples of 2.5


        if (health > cappedHealth) {
            health = cappedHealth;
        }

		if(ClientPrefs.shaders) {
			shaderStuff += elapsed;

            chromFNF.setFloat('aberration', abberationShaderIntensity); // error in this shader/line
			pibbyFNF.glitchMultiply.value[0] = glitchShaderIntensity;
            distortFNF.setFloat('binaryIntensity', distortIntensity);
            distortCAWMFNF.setFloat('binaryIntensity', distortIntensity);
			distortDadFNF.setFloat('binaryIntensity', dadGlitchIntensity);
			pibbyFNF.uTime.value[0] += elapsed;
			mawFNF.iTime.value[0] += elapsed;
			blurFNF.amount.value[0] = blurIntensity;
			glitchFWFNF.setFloat('iTime', shaderStuff);

            var shaders = [distortDadFNF, distortCAWMFNF]; // maybe put this somewhere else as like a "distortShaders" array? esp since its used multiple times in the code
            // its fine rn tho so w/e
            for(idx in 0...distortShaderTimes.length){
                distortShaderTimes[idx] -= elapsed;
                if(distortShaderTimes[idx] < 0)distortShaderTimes[idx] = 0;
                if(distortShaderTimes[idx] == 0){
                    shaders[idx].setFloat("negativity", 0.0);
                    if(idx == 0){
                        if(dad.shader == shaders[idx])dad.shader = null;
                        if(jake != null && jake.shader == shaders[idx])jake.shader = null;
                    }
                }
            }
		}

        switch (SONG.song) //where we kill gf schweizer :(
            // thers probably a better way to do this tbh -neb
		{
			case "Child's Play":
				if (gf != null)	gf.alpha = 0;
			case "Forgotten World":
				if (gf != null)	gf.alpha = 0;
			case "No Hero Remix": 
				if (gf != null)	gf.alpha = 0;
		}

		if (SONG.song.toLowerCase().replace('-', ' ') == 'No Hero Remix')
			iconP2.shake(0.11, 8, 1);

		glitchShaderIntensity = FlxMath.lerp(glitchShaderIntensity, 0, CoolUtil.boundTo(elapsed * 7, 0, 1));
        abberationShaderIntensity = FlxMath.lerp(abberationShaderIntensity, 0, CoolUtil.boundTo(elapsed * 6, 0, 1));

		var charAnimOffsetX:Float = 0;
		var charAnimOffsetY:Float = 0;
		if(focusedCharacter!=null){
			if(focusedCharacter.animation.curAnim!=null && !isCameraOnForcedPos){
				switch (focusedCharacter.animation.curAnim.name.substring(4)){
					case 'UP' | 'UP-alt' | 'UPmiss':
						charAnimOffsetY -= animOffsetValue;
					case 'DOWN' | 'DOWN-alt' |  'DOWNmiss':
						charAnimOffsetY += animOffsetValue;
					case 'LEFT' | 'LEFT-alt' | 'LEFTmiss':
						charAnimOffsetX -= animOffsetValue;
					case 'RIGHT' | 'RIGHT-alt' | 'RIGHTmiss':
						charAnimOffsetX += animOffsetValue;
				}
			}
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed * playbackRate, 0, 1);
            camFollowPos.setPosition(
				FlxMath.lerp(camFollowPos.x, camFollow.x + charAnimOffsetX, lerpVal),
				FlxMath.lerp(camFollowPos.y, camFollow.y + charAnimOffsetY, lerpVal)
			);
            var angleLerp:Float = CoolUtil.boundTo(CoolUtil.boundTo(elapsed * 2.4 / 0.4, 0, 1) * cameraSpeed * playbackRate, 0, 1);
            camGame.angle = FlxMath.lerp(camGame.angle, 0 + charAnimOffsetX / 30, angleLerp);
			if(!startingSong && !endingSong && boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		setOnLuas('curDecStep', curDecStep);
		setOnLuas('curDecBeat', curDecBeat);
        for (hScript in allScripts) {
		    hScript.update(elapsed);
        }

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE #if mobile || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
		{
            for (hScript in allScripts) {
			    hScript.onPause();
            }
			var ret:Dynamic = callOnLuas('onPause', [], false);	
			if(ret != FunkinLua.Function_Stop) {
				openPauseMenu();
			}
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

        if (gf != null)
		{
			var mult:Float = FlxMath.lerp(0.8, iconP3.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			iconP3.scale.set(mult, mult);
			iconP3.updateHitbox();
			//iconP3.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP3.scale.x) / 2 - iconOffset;
		} 

 		if (storyWeekName == "gumball" || SONG.song == 'No Hero Remix') {
			iconP1.x = 530;
            iconP2.x = 50;
			if (gf != null)
                iconP3.x = 530 + 75;
			scoreTxt.y = healthBar.y + 40;
			scoreTxt.x = pibbyHealthbar.x - 350;
        } 
		else		
		{
            iconP1.x = 614;
            iconP2.x = 513;
            if (gf != null)
                iconP3.x = 614 + 100;
            healthBar.visible = false;
            healthBarBG.visible = false;
			pibbyHealthbar.visible = false;
        }


		if (SONG.song == "Suffering Siblings")
		{
			var mult:Float = FlxMath.lerp(0.8, iconPibby.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			iconPibby.scale.set(mult, mult);
			iconPibby.updateHitbox();
			iconPibby.x = 964;
			
			var mult2:Float = FlxMath.lerp(0.8, iconJake.scale.x, CoolUtil.boundTo(1 - (elapsed * 9 * playbackRate), 0, 1));
			iconJake.scale.set(mult2, mult2);
			iconJake.updateHitbox();
			iconJake.x = 163;
		}

		//iconP1.x = 614;
		defaultIconP2x = 513;

		if (health > 2) {
            health = 2;
        }else if (healthBar.percent < 20){
            if (ClientPrefs.shaders) iconP1.shader = distortFNF;
			if (gf != null)
			{
				if (ClientPrefs.shaders) iconP3.shader = distortFNF;
				iconP3.playAnim(iconP3.char + 'losing', false, false);
			}
			if (SONG.song == "Suffering Siblings")
				{
					if (ClientPrefs.shaders) iconPibby.shader = distortFNF;
					iconPibby.playAnim(iconPibby.char + 'losing', false, false);
				}
			iconP1.playAnim(iconP1.char + 'losing', false, false);
        } else {
			if (gf != null)
			{
				iconP3.shader = null;
				iconP3.playAnim(iconP3.char + 'neutral', false, false);
			}
			if (SONG.song == "Suffering Siblings")
				{
					iconPibby.shader = null;
					iconPibby.playAnim(iconPibby.char + 'neutral', false, false);
				}
            iconP1.shader = null;
			iconP1.playAnim(iconP1.char + 'neutral', false, false);
        }

        if (healthBar.percent > 80){
			if (SONG.song == "Suffering Siblings")
				{
					if (ClientPrefs.shaders) iconJake.shader = distortFNF;
					iconJake.playAnim(iconJake.char + 'losing', false, false);
				}
				if (ClientPrefs.shaders) iconP2.shader = distortFNF;
			iconP2.playAnim(iconP2.char + 'losing', false, false);
        }else{
			if (SONG.song == "Suffering Siblings")
				{
					iconJake.shader = null;
					iconJake.playAnim(iconJake.char + 'neutral', false, false);
				}
            iconP2.shader = null;
			iconP2.playAnim(iconP2.char + 'neutral', false, false);
        }

        // maybe we should allow this if they enter a special debug code on like the title screen or sum shit, instead of #if debugging it
        // just for people who wanna make custom stuff w/ the mod
        
        if(Main.debug) {
            if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
                persistentUpdate = false;
                paused = true;
                cancelMusicFadeTween();
                MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
            }
            if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
            {
				openChartEditor();
            }
            if (FlxG.keys.justPressed.NINE && !endingSong && !inCutscene) {
                SONG.validScore = false;
                cpuControlled = !cpuControlled;
                botplayTxt.visible = cpuControlled;
            }
        }
		else
		{
			if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
				canPause = false;
				FlxTween.tween(FlxG.sound.music, {pitch: 0.001}, 6, {onComplete: e -> FlxG.sound.music.stop()});
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.6}, 6);
				FlxTween.tween(camHUD, {alpha: 0}, 5);
				FlxTween.tween(vocals, {pitch: 0.001}, 6, {onComplete: e -> vocals.stop()});
				FlxG.sound.music.fadeOut(6.5);
				vocals.fadeOut(6.5);
				FlxG.camera.fade(FlxColor.BLACK, 6, false, () -> {
					FlxG.sound.music.stop();
					new FlxTimer().start(2, e -> youCheatedRah());
				});
            }
            if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
            {
				canPause = false;
				FlxTween.tween(FlxG.sound.music, {pitch: 0.001}, 6, {onComplete: e -> FlxG.sound.music.stop()});
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.6}, 6);
				FlxTween.tween(camHUD, {alpha: 0}, 5);
				FlxTween.tween(vocals, {pitch: 0.001}, 6, {onComplete: e -> vocals.stop()});
				FlxG.sound.music.fadeOut(6.5);
				vocals.fadeOut(6.5);
				FlxG.camera.fade(FlxColor.BLACK, 6, false, () -> {
					FlxG.sound.music.stop();
					new FlxTimer().start(2, e -> youCheatedRah());
				});
            }
            if (FlxG.keys.justPressed.NINE && !endingSong && !inCutscene) {
				canPause = false;
				FlxTween.tween(FlxG.sound.music, {pitch: 0.001}, 6, {onComplete: e -> FlxG.sound.music.stop()});
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.6}, 6);
				FlxTween.tween(camHUD, {alpha: 0}, 5);
				FlxTween.tween(vocals, {pitch: 0.001}, 6, {onComplete: e -> vocals.stop()});
				FlxG.sound.music.fadeOut(6.5);
				vocals.fadeOut(6.5);
				FlxG.camera.fade(FlxColor.BLACK, 6, false, () -> {
					FlxG.sound.music.stop();
					new FlxTimer().start(2, e -> youCheatedRah());
				});
            }
			if (FlxG.keys.justPressed.SIX && !endingSong && !inCutscene) {
				canPause = false;
				FlxTween.tween(FlxG.sound.music, {pitch: 0.001}, 6, {onComplete: e -> FlxG.sound.music.stop()});
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.6}, 6);
				FlxTween.tween(camHUD, {alpha: 0}, 5);
				FlxTween.tween(vocals, {pitch: 0.001}, 6, {onComplete: e -> vocals.stop()});
				FlxG.sound.music.fadeOut(6.5);
				vocals.fadeOut(6.5);
				camOther.fade(FlxColor.BLACK, 6, false, () -> {
					FlxG.sound.music.stop();
					new FlxTimer().start(2, e -> youCheatedRah());
				});
            }
		}

		
		if (startedCountdown)
		{
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;
		}

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else
		{
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / fakeSongLength);

					var songCalc:Float = (fakeSongLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125 * camZoomingDecay * playbackRate), 0, 1));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (dodgeMisses >= 3) // incase it somehow gets to 4 by some bug
			{
				health = 0;
				doDeathCheck(true);
			}

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;
				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				if(!boyfriend.curCharacter.contains('newbf') || boyfriend.animation.curAnim.finished) // so that newbf will always finish his directional poses, because they return to idle and it looks cool :)
                    boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}

			if(startedCountdown)
			{
				var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
				notes.forEachAlive(function(daNote:Note)
				{
					var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
					if(!daNote.mustPress) strumGroup = opponentStrums;

					var strumX:Float = strumGroup.members[daNote.noteData].x;
					var strumY:Float = strumGroup.members[daNote.noteData].y;
					var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
					var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
					var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
					var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

					strumX += daNote.offsetX;
					strumY += daNote.offsetY;
					strumAngle += daNote.offsetAngle;
					strumAlpha *= daNote.multAlpha;

					if (strumScroll) //Downscroll
					{
						//daNote.y = (strumY + 0.45 * (Conductor.so.2ngPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}
					else //Upscroll
					{
						//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
						daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
					}

					var angleDir = strumDirection * Math.PI / 180;
					if (daNote.copyAngle)
						daNote.angle = strumDirection - 90 + strumAngle;

					if(daNote.copyAlpha) {
						if(!daNote.mustPress) {
							if(!daNote.gfNote) {
								daNote.alpha = strumAlpha;
							}else{
								daNote.alpha = 0;
							}
						}
					}

					if(daNote.copyX)
						daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

					if(daNote.copyY)
					{
						daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

						//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
						if(strumScroll && daNote.isSustainNote)
						{
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
								} else {
									daNote.y -= 19;
								}
							}
							daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
						}
					}

					if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
					{
						opponentNoteHit(daNote);
					}

					if(!daNote.blockHit && daNote.mustPress && cpuControlled && daNote.canBeHit) {
						if(daNote.isSustainNote) {
							if(daNote.canBeHit) {
								goodNoteHit(daNote);
							}
						} else if(daNote.strumTime <= Conductor.songPosition || daNote.isSustainNote) {
							goodNoteHit(daNote);
						}
					}

					var center:Float = strumY + Note.swagWidth / 2;
					if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
						(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						if (strumScroll)
						{
							if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}

					// Kill extremely late notes and cause misses
					if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
					{
						if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}
			else
			{
				notes.forEachAlive(function(daNote:Note)
				{
					daNote.canBeHit = false;
					daNote.wasGoodHit = false;
				});
			}
		}
		checkEventNote();

		if(Main.debug){
            if(!endingSong && !startingSong) {
                if (FlxG.keys.justPressed.ONE) {
                    SONG.validScore = false;
                    KillNotes();
                    FlxG.sound.music.onComplete();
                }
                if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
                    SONG.validScore = false;
                    setSongTime(Conductor.songPosition + 10000);
                    clearNotesBefore(Conductor.songPosition);
                }
            }
        }

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
        for (hScript in allScripts) {
            hScript.onUpdatePost(elapsed);
        }

        //iconP2.x = defaultIconP2x + FlxG.random.float(-glitchShaderIntensity, glitchShaderIntensity);
        iconP2.y = healthBar.y - 75 + FlxG.random.float(-glitchShaderIntensity, glitchShaderIntensity);
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 1 / 1000 chance for Gitaroo Man easter egg
		/*if (FlxG.random.bool(0.1))
		{
			// gitaroo man easter egg
			cancelMusicFadeTween();
			MusicBeatState.switchState(new GitarooPause());
		}
		else {*/
		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		//}

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter(), null, null, largeKey);
		#end
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
            FlxG.camera.setFilters([]);
            for (hScript in allScripts) {
			    hScript.onGameOver();
            }
			var ret:Dynamic = callOnLuas('onGameOver', [], false);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				boyfriendGroup.alpha = 0.00001;
				gfGroup.alpha = 0.00001;
				dadGroup.alpha = 0.00001;
				for (allCams in FlxG.cameras.list)
					allCams.alpha = 0;

				camGame.alpha = 1;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				// persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}

				FlxG.camera.zoom = 0.7;
				defaultCamZoom = 0.7;

				// emergency for ficks
				var emergencyBlackness = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 4, FlxColor.BLACK);
					emergencyBlackness.scrollFactor.set();
				add(emergencyBlackness);

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
                DiscordClient.changePresence("Game Over - " + detailsText, SONG.song, iconP2.getCharacter(), null, null, largeKey);
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
        for (hScript in allScripts) {
            hScript.onEvent(eventName, value1, value2);
        }
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
					abberationShaderIntensity = beatShaderAmount;
				}

			case 'Set Chromatic Amount':
				if(ClientPrefs.shaders) {
					var val1:Int = Std.parseInt(value1);
					chromFNF.setFloat('aberration', val1);
				}

            case 'Cinematics':
                var val2:Float = Std.parseFloat(value2);
                if (value1.toLowerCase() == 'on') {
                    FlxTween.tween(cinematicup, { y: 0}, val2, {ease: FlxEase.cubeOut});
                    FlxTween.tween(cinematicdown, { y: FlxG.height - 100}, val2, {ease: FlxEase.cubeOut});
                }
				else {
                    FlxTween.tween(cinematicup, { y: -100}, val2, {ease: FlxEase.cubeOut});
                    FlxTween.tween(cinematicdown, { y: FlxG.height}, val2, {ease: FlxEase.cubeOut});
                }

			case 'Apple Filter':
				if (value1.toLowerCase() == 'on') {
                    if(touhouBG!=null){
                        trace("DO NOT BAD APPLE TWICE!!");
                        return;
                    }
                    if (ClientPrefs.shaders && !ClientPrefs.lowQuality) camGame.pushFilter("glow",new ShaderFilter(glowfnf)); //xd
					if (value2.toLowerCase() == 'black') {
						touhouBG = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						boyfriend.colorTransform.blueOffset = 255;
						boyfriend.colorTransform.redOffset = 255;
						boyfriend.colorTransform.greenOffset = 255;
						dad.colorTransform.blueOffset = 255;
						dad.colorTransform.redOffset = 255;
						dad.colorTransform.greenOffset = 255;
						if (gf != null) {
                            gf.colorTransform.blueOffset = 255;
                            gf.colorTransform.redOffset = 255;
                            gf.colorTransform.greenOffset = 255; 
                        }
						touhouBG.scrollFactor.set();
						addBehindGF(touhouBG);
					} else {
						touhouBG = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
						boyfriend.color = FlxColor.BLACK;
						dad.color = FlxColor.BLACK;
						if (gf != null) gf.color = FlxColor.BLACK;
						touhouBG.scrollFactor.set();
						addBehindGF(touhouBG);
					}
				}
				else{
                    if(touhouBG==null)return; // ficks
                    isAppleLOL = false;
                    if (ClientPrefs.shaders && !ClientPrefs.lowQuality) camGame.removeFilter("glow");
					touhouBG.alpha = 0;
					touhouBG.kill();
					touhouBG = null;
					reloadHealthBarColors();
					boyfriend.colorTransform.blueOffset = 0;
					boyfriend.colorTransform.redOffset = 0;
					boyfriend.colorTransform.greenOffset = 0;
					dad.colorTransform.blueOffset = 0;
					dad.colorTransform.redOffset = 0;
					dad.colorTransform.greenOffset = 0;
					if (gf != null) {
                        gf.colorTransform.blueOffset = 0;
                        gf.colorTransform.redOffset = 0;
                        gf.colorTransform.greenOffset = 0; 
                    }
					boyfriend.color = FlxColor.WHITE;
					dad.color = FlxColor.WHITE;
					if (gf != null) {
					    gf.color = FlxColor.WHITE; 
                    }
				}

			case 'Goofy Ahh Blammed Lights':
				var chars:Array<Character> = [boyfriend, gf, dad];

				if (value1 == 'on')
				{
					FlxTween.tween(theBlackness, {alpha: 1}, 0.7);
				
					for (i in 0...chars.length) {
						FlxTween.color(chars[i], 0.7, FlxColor.WHITE, 0xff31a2fd, {ease: FlxEase.quadInOut});
					}
				} 
				
				if (value1 == 'off') {
					FlxTween.tween(theBlackness, {alpha: 0}, 0.7);
					theBlackness.kill();

					for (i in 0...chars.length) {
						FlxTween.color(chars[i], 0.7, 0xff31a2fd, FlxColor.WHITE, {ease: FlxEase.quadInOut});
					}
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					var val1:Float = Std.parseFloat(value1);
					var val2:Float = Std.parseFloat(value2);
					if(Math.isNaN(val1)) val1 = 0;
					if(Math.isNaN(val2)) val2 = 0;

					isCameraOnForcedPos = false;
					if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
						camFollow.x = val1;
						camFollow.y = val2;
						isCameraOnForcedPos = true;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
                if (ClientPrefs.screenGlitch) {
                    var valuesArray:Array<String> = [value1, value2];
                    var targetsArray:Array<FlxCamera> = [camGame, camHUD];
                    for (i in 0...targetsArray.length) {
                        var split:Array<String> = valuesArray[i].split(',');
                        var duration:Float = 0;
                        var intensity:Float = 0;
                        if(split[0] != null) duration = Std.parseFloat(split[0].trim());
                        if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
                        if(Math.isNaN(duration)) duration = 0;
                        if(Math.isNaN(intensity)) intensity = 0;

                        if(duration > 0 && intensity != 0) {
                            targetsArray[i].shake(intensity, duration);
                        }
                    }
                }


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
							addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
                iconP3.changeIcon(gf.healthIcon);
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2 / playbackRate, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Set Property':
				var killMe:Array<String> = value1.split('.');
				if(killMe.length > 1) {
					FunkinLua.setVarInArray(FunkinLua.getPropertyLoopThingWhatever(killMe, true, true), killMe[killMe.length-1], value2);
				} else {
					FunkinLua.setVarInArray(this, value1, value2);
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
            for (hScript in allScripts) {
			    hScript.onMoveCamera('gf');
            }
			return;
		}

		if (!SONG.notes[curSection].mustHitSection)
		{
            moveCamera(true);
            callOnLuas('onMoveCamera', ['dad']);
            for (hScript in allScripts) {
                hScript.onMoveCamera('dad');
            }
		}
		else
		{
            moveCamera(false);
            callOnLuas('onMoveCamera', ['boyfriend']);
            for (hScript in allScripts) {
                hScript.onMoveCamera('boyfriend');
            }
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
            cameraOnDad = true;
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
            cameraOnDad = false;
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
	  #if mobile
	  mobileControls.visible = false;
	  #end
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

        for (hScript in allScripts) {
		    hScript.onEndSong();
        }
		var ret:Dynamic = callOnLuas('onEndSong', [], false);
		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}
			playbackRate = 1;

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					WeekData.loadTheFirstEnabledMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu_${Main.funnyMenuMusic}'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				WeekData.loadTheFirstEnabledMod();
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('fpmenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}


	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function cachePopUpScore()
	{
		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		if (isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		Paths.image(pixelShitPart1 + "sick" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "good" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "bad" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "shit" + pixelShitPart2);
		Paths.image(pixelShitPart1 + "combo" + pixelShitPart2);
		
		for (i in 0...10) {
			Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2);
		}
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(note, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.increase();
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating.image + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;

		insert(members.indexOf(strumLineNotes), rating);
		
		if (!ClientPrefs.comboStacking)
		{
			if (lastRating != null) lastRating.kill();
			lastRating = rating;
		}

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
		{
			insert(members.indexOf(strumLineNotes), comboSpr);
		}
		if (!ClientPrefs.comboStacking)
		{
			if (lastCombo != null) lastCombo.kill();
			lastCombo = comboSpr;
		}
		if (lastScore != null)
		{
			while (lastScore.length > 0)
			{
				lastScore[0].kill();
				lastScore.remove(lastScore[0]);
			}
		}
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];
			
			if (!ClientPrefs.comboStacking)
				lastScore.push(numScore);

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (strumsBlocked[daNote.noteData] != true && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && !daNote.blockHit)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else{
					callOnLuas('onGhostTap', [key]);
					if (canMiss) {
						noteMissPress(key);
					}
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var parsedHoldArray:Array<Bool> = parseKeys();

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var parsedArray:Array<Bool> = parseKeys('_P');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] && strumsBlocked[i] != true)
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (startedCountdown && !boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (strumsBlocked[daNote.noteData] != true && daNote.isSustainNote && parsedHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.blockHit) {
					goodNoteHit(daNote);
				}
			});

			if (boyfriend.animation.curAnim != null && boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				if(!boyfriend.curCharacter.contains('newbf') || boyfriend.animation.curAnim.finished) // so that newbf will always finish his directional poses, because they return to idle and it looks cool :)
                    boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode || strumsBlocked.contains(true))
		{
			var parsedArray:Array<Bool> = parseKeys('_R');
			if(parsedArray.contains(true))
			{
				for (i in 0...parsedArray.length)
				{
					if(parsedArray[i] || strumsBlocked[i] == true)
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	private function parseKeys(?suffix:String = ''):Array<Bool>
	{
		var ret:Array<Bool> = [];
		for (i in 0...controlArray.length)
		{
			ret[i] = Reflect.getProperty(controls, controlArray[i] + suffix);
		}
		return ret;
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
        for (hScript in allScripts) {
            hScript.noteMiss(daNote);
        }
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		combo = 0;
		health -= daNote.missHealth * healthLoss;
		
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		if (daNote.dodgeNote)
			{
				dodgeMisses++;
			}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations)
		{
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);

		// am i even doing this well??? idk man
		switch(daNote.noteType) {
			case 'Sword': 
				if(boyfriend.animation.getByName('hurt') != null && dad.animation.getByName('attack') != null) {
					trace('skill issue');

					FlxG.camera.shake(0.01, 0.2);

					boyfriend.playAnim('hurt', true);
					boyfriend.specialAnim = true;

					dad.playAnim('attack', true);
					dad.specialAnim = true;
				}

			case 'Glitch': 
				health += 0.0475;
				FlxG.camera.shake(0.01, 0.2);
				if (songMisses > 0) songMisses--;
		}
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.ghostTapping) return; //fuck it

		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
		callOnLuas('noteMissPress', [direction]);
	}
    
    // vv in place of FlxTimer because that shid SUCKS!!
    var distortShaderTimes:Array<Float> = [0,0];

	function opponentNoteHit(note:Note):Void
	{
        var glitching = false;
		if (note.noteType == 'Glitch Note' || note.noteType == 'Both Char Glitch') {
            glitching = true;
            if(!note.isSustainNote){
                for (i in 0...opponentStrums.length) {
                    opponentStrums.members[i].x = defaultOpponentStrum[i].x + FlxG.random.int(-8, 8);
                    opponentStrums.members[i].y = defaultOpponentStrum[i].y + FlxG.random.int(-8, 8);
                }
                boyfriendColor = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]); //WHAT THE FUCK
                if (ClientPrefs.shaders)
                    {
                        dadGlitchIntensity = FlxG.random.float(-1, -0.5);
                        var shaders = [distortDadFNF, distortCAWMFNF];
                        if(dad.shader == null)dad.shader = distortDadFNF;
                        for(idx in 0...shaders.length){
                            var shader = shaders[idx];
                            shader.setFloat("negativity", 1.0);
                            distortShaderTimes[idx] = (note.sustainLength > 0 ? note.sustainLength/1000 : 0) + FlxG.random.float(0.0475, 0.085);
                        }
                    }
            }
		}

        jakeSings = false;
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			if(!note.gfNote) {
                if (healthDrain) {
                    if (health > 0.1) {
						switch (SONG.song)
						{
							case "Child's Play":
								health -= 0.0075;
							case "My Amazing World":
								health -= 0.0150;
							case "Retcon":
								health -= 0.0175;
							case "Forgotten World":
								health -= 0.02;
							case "Mindless":
								health -= 0.03;
							case "Blessed by Swords":
								health -= 0.0325;
							case "Brotherly Love":
								health -= 0.025;
							case "Suffering Siblings":
								health -= 0.035;
							case "Come Along With Me":
								health -= 0.0225;
						}
                    }
                }
            }

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if (note.gfNote) {
				char = gf;
                jakeSings = true;	
			}
			else if(note.char2note) {
				char = jake;
                jakeSings = true;
			}
			else if(note.bothCharSing) {
				char = jake;
                jakeSings = true;
			}
			else if (note.noteType == 'Second Char Glitch' || note.noteType == 'Both Char Glitch') {
				char = jake;
                jakeSings = true;
                glitching = true;
                if(!note.isSustainNote){
                    for (i in 0...opponentStrums.length) {
                        opponentStrums.members[i].x = defaultOpponentStrum[i].x + FlxG.random.int(-8, 8);
                        opponentStrums.members[i].y = defaultOpponentStrum[i].y + FlxG.random.int(-8, 8);
                    }
                        
                    if (ClientPrefs.shaders)
                    {
                        dadGlitchIntensity = FlxG.random.float(-1, -0.5);
                        var shaders = [distortDadFNF, distortCAWMFNF];
                        if(jake.shader == null)jake.shader = distortDadFNF;
                        for (idx in 0...shaders.length)
                        {
                            var shader = shaders[idx];
                            shader.setFloat("negativity", 1.0);
                        distortShaderTimes[idx] = (note.sustainLength > 0 ? note.sustainLength/1000 : 0) + FlxG.random.float(0.0475, 0.085);
                        }
                    }
                    
                }
		}

        if(!glitching){
            for(idx in 0...distortShaderTimes.length)
                distortShaderTimes[idx] = 0; // remove the glitching
        }

			if(char != null)
			{
				char.holdTimer = 0;
                if (cameraOnDad) {
                    if (jakeSings) {
                        focusedCharacter=jake;
                    }else{
                        focusedCharacter=dad;
                    }
                }

				// TODO: maybe move this all away into a seperate function
					if (!note.isSustainNote && noteRows[note.mustPress ? 0 : 1][note.row] != null && noteRows[note.mustPress ? 0 : 1][note.row].length > 1)
					{
						// potentially have jump anims?
						var chord = noteRows[note.mustPress ? 0 : 1][note.row];
						var animNote = chord[0];
						var realAnim = singAnimations[Std.int(Math.abs(animNote.noteData))] + altAnim;
						if (char.mostRecentRow != note.row)
							char.playAnim(realAnim, true);

						if (note != animNote)
							if (!note.gfNote) {
								if (health > 0.5) {
                                    if (healthDrain) {
                                        health -= FlxG.random.float(0.075, 0.2);
                                    }
								}
                                if (ClientPrefs.screenGlitch) {
                                    if (FlxG.random.float(0, 1) < 0.5) {
                                        camGame.shake(FlxG.random.float(0.015, 0.02), FlxG.random.float(0.075, 0.125));
                                    } else{
                                        camHUD.shake(FlxG.random.float(0.015, 0.02), FlxG.random.float(0.075, 0.125));
                                        for (i in 0...opponentStrums.length) {
                                            if (canShakeNote)
											{
												opponentStrums.members[i].x = defaultOpponentStrum[i].x + FlxG.random.int(-8, 8);
												opponentStrums.members[i].y = defaultOpponentStrum[i].y + FlxG.random.int(-8, 8);
											}
                                        }
                                    }
                                }
							}

						char.mostRecentRow = note.row;
					}
					else if (note.bothCharSing)
						{
							dad.playAnim(animToPlay, true);
							jake.playAnim(animToPlay, true);
						}
					else
						char.playAnim(animToPlay, true);
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}

		if(!note.gfNote) {
			StrumPlayAnim(true, Std.int(Math.abs(note.noteData)), time);
		}
		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
        for (hScript in allScripts) {
            hScript.opponentNoteHit(notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote);
        }
        if (!note.gfNote) {
			if (!note.isSustainNote) {
				if (FlxG.random.int(0, 1) == 0) {
					glitchShaderIntensity = FlxG.random.float(0.2, 0.7);
				}
			}
		}
		
		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}
		    boyfriendColor = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);
			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				if(!note.noMissAnimation)
				{
					switch(note.noteType) {
						case 'Hurt Note': //Hurt note
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('hurt', true);
								boyfriend.specialAnim = true;
							}

						case 'Sword': 
							if(boyfriend.animation.getByName('hurt') != null && dad.animation.getByName('attack') != null) {
								boyfriend.playAnim('dodge', true);
								boyfriend.specialAnim = true;
								dad.playAnim('attack', true);
								dad.specialAnim = true;

								//trace('no skill issue');

								FlxG.camera.shake(0.01, 0.2);
							}

						case 'Glitch': 
							if(boyfriend.animation.getByName('hurt') != null) {
								boyfriend.playAnim('dodge', true);
								boyfriend.specialAnim = true;
								FlxG.sound.play(Paths.sound('glitchhit', 'shared'), 0.3);

								//trace('skill issue glitch edition');
							}
					}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
			}

			health += note.hitHealth * healthGain;

            if (!note.gfNote) {
                reloadHealthBarColors();
                iconP1.changeIcon(boyfriend.healthIcon);
                scoreTxt.color = boyfriendColor;
                if(gf != null) {
                    iconP3.changeIcon(gf.healthIcon);
                }
            }else{
                if (gf != null && gf.healthIcon == 'gf') {
                    reloadHealthBarColors();
                    scoreTxt.color = boyfriendColor;
                    iconP1.changeIcon(boyfriend.healthIcon);
                    if (gf != null) iconP3.changeIcon(gf.healthIcon);
                }else{
                    healthBar.createFilledBar(dadColor, gfColor);
                    healthBar.updateBar();
                    scoreTxt.color = gfColor;
                    if(ClientPrefs.shaders){
                        var shader:Shaders.GreenReplacementShader = cast pibbyHealthbar.shader;
                        shader.colour = gfColor;
                    }
					if (storyWeekName != "finn") {
                    if (gf != null) iconP1.changeIcon(gf.healthIcon);
                    if (iconP3 != null) iconP3.changeIcon(boyfriend.healthIcon); }
                }
            }

			if(!note.noAnimation) {
                if (!cameraOnDad) {
                    if (pibbySings) {
                        if (gf != null) {
                            focusedCharacter=gf;
                        }else{
                            focusedCharacter=boyfriend;
                        }
                    }else{
						/*if (SONG.notes[Std.int(curStep / 16)] != null && SONG.notes[Std.int(curStep / 16)].gfSection && gf != null)
							focusedCharacter = gf;
						else*/ // this shit doesn't work im gonna kms
                        	focusedCharacter = boyfriend;
                    }
                }
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];
				var dodgeAnim:String = dodgeAnimations[Std.int(Math.abs(note.noteData))];
				var shootAnim:String = shootAnimations[Std.int(Math.abs(note.noteData))];

				if (note.dodgeNote && boyfriend.curCharacter != 'bfsword') // when bfsword he parries
					{
						boyfriend.playAnim(dodgeAnim, true);
						boyfriend.specialAnim = true;
						boyfriend.holdTimer = 0;
					}

				else if (note.attackNote)
					{
						boyfriend.playAnim(shootAnim, true);
						boyfriend.specialAnim = true;
						boyfriend.holdTimer = 0;
					}

				else if (note.gfNote)
				{
					if(gf != null)
					{
                        pibbySings = true;		
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
                    pibbySings = false;
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)), time);
			} else {
				var spr = playerStrums.members[note.noteData];
				if(spr != null)
				{
					spr.playAnim('confirm', true);
				}
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
            for (hScript in allScripts) {
                hScript.goodNoteHit(notes.members.indexOf(note), leData, leType, isSus);
            }

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = 0;
		var sat:Float = 0;
		var brt:Float = 0;
		if (data > -1 && data < ClientPrefs.arrowHSV.length)
		{
			hue = ClientPrefs.arrowHSV[data][0] / 360;
			sat = ClientPrefs.arrowHSV[data][1] / 100;
			brt = ClientPrefs.arrowHSV[data][2] / 100;
			if(note != null) {
				skin = note.noteSplashTexture;
				hue = note.noteSplashHue;
				sat = note.noteSplashSat;
				brt = note.noteSplashBrt;
			}
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	override function destroy() {
		for (lua in luaArray) {
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];

		#if hscript
		if(FunkinLua.hscript != null) FunkinLua.hscript = null;
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		FlxAnimationController.globalSpeed = 1;
		FlxG.sound.music.pitch = 1;
		FlxG.game.setFilters([]);
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		var blackFNF:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackFNF.scrollFactor.set();
		blackFNF.alpha = 0;
		blackFNF.cameras = [camOverlay];
		add(blackFNF);

		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > (20 * playbackRate)))
		{
			resyncVocals();
		}

        for (hScript in allScripts) {
		    hScript.onStepHit(curStep);
        }

		if (ClientPrefs.shaders)
        	distortIntensity = FlxG.random.float(4, 6);

		switch (SONG.song)
			{
				case 'Blessed by Swords':
					switch (curStep)
					{
                        case 1:
                            FlxTween.tween(boyfriend, {alpha: 0.5}, 0.5);
						case 496:
							camHUD.alpha = 0;
							camGame.alpha = 0;
						case 524:
							camGame.alpha = 1;
							camHUD.alpha = 1;
							if (ClientPrefs.flashing) {
								camOther.flash(FlxColor.WHITE, 1);
							}
					}
				case 'Come Along With Me':
					switch (curStep)
					{
						case 1:
							FlxTween.tween(camHUD, {alpha: 0}, 1, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										camHUD.alpha = 0;
									}
							});
						iconP1.alpha = 0;
						case 36:
							camGame.fade(FlxColor.BLACK, 5, true);
							for (i in 0...opponentStrums.length) {
								opponentStrums.members[i].visible = false;
								opponentStrums.members[i].alpha = 0;
							}
							for (i in 0...playerStrums.length) {
								playerStrums.members[i].visible = false;
								playerStrums.members[i].alpha = 0;
							}
						case 128:
							camHUD.alpha = 1;
							if (ClientPrefs.flashing) {
								camOther.flash(FlxColor.WHITE, 1);
							}
							for (i in 0...opponentStrums.length) {
								opponentStrums.members[i].visible =	true;
								opponentStrums.members[i].alpha = 1;
							}
						case 186:
							for (i in 0...playerStrums.length) {
								playerStrums.members[i].visible = true;
								playerStrums.members[i].alpha =	0.0001;
								FlxTween.tween(playerStrums.members[i], {alpha: 1}, 0.5, {
									ease: FlxEase.linear,
									onComplete:
									function (twn:FlxTween)
										{
											playerStrums.members[i].alpha = 1;
										}
								});
							}
						case 378:
							FlxTween.tween(camHUD, {alpha: 0}, 0.25, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										camHUD.alpha = 0;
									}
							});
							defaultCamZoom = 1.35;
						case 384:
							if (ClientPrefs.shaders) {
								for (i in 0...opponentStrums.length) {
									if (ClientPrefs.shaders) opponentStrums.members[i].shader = distortFNF;
								dad.shader = distortCAWMFNF;
							}
							
						}
							defaultCamZoom = 0.9;
							if (ClientPrefs.flashing) {
								camOther.flash(FlxColor.WHITE, 1);
							}
								FlxTween.tween(camHUD, {alpha: 1}, 0.25, {
									ease: FlxEase.linear,
									onComplete:
									function (twn:FlxTween)
										{
											camHUD.alpha = 1;
										}
								});
						case 608:
         for (character in dadGroup){
            if (Reflect.getProperty(character, "curCharacter") == "finncawm_start_new"){
             character.alpha = 0;
                }
             }
 
            for (character in dadGroup){
            if (Reflect.getProperty(character, "curCharacter") == "finnanimstuff"){
             character.alpha = 1;
             dad.alpha = 1;
            }
          }
							FlxTween.tween(theBlackness, {alpha: 1}, 0.6, {ease: FlxEase.sineInOut});
						// I love timing shit.
						case 628:
							if (ClientPrefs.flashing) {
								camOther.flash(FlxColor.WHITE, 0.3);
							}
						case 640:
                            FlxTween.tween(pibbyHealthbar, {alpha: 1}, 0.25, {ease: FlxEase.quadInOut});
                            FlxTween.tween(finnBarThing, {alpha: 1}, 0.25, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										finnBarThing.alpha = 1;
                                        FlxTween.tween(iconP1, {alpha: 1}, 0.15, {ease: FlxEase.quadInOut});
                                        FlxTween.tween(iconP2, {alpha: 1}, 0.15, {ease: FlxEase.quadInOut});
                                       
									}
							});
           for (character in dadGroup){
            if (Reflect.getProperty(character, "curCharacter") == "finnanimstuff"){
             character.alpha = 0;
             dad.alpha = 1;
           }
         }
							triggerEventNote('Change Character', '1', 'finncawm_reveal');
			            for (character in dadGroup){
            if (Reflect.getProperty(character, "curCharacter") == "finncawm_reveal"){
             character.alpha = 1;
             dad.alpha = 1;
            }
          }
						defaultCamZoom = 0.75;

							if (!ClientPrefs.lowQuality)
								{
									var vig:FlxSprite = new FlxSprite().loadGraphic(Paths.image('vignette'));
									vig.scrollFactor.set();
									vig.cameras = [camOther];
									vig.screenCenter();
									add(vig);
								}
							// im pretty sure i could just use camera._filters.remove(filter) but just in case
							if (ClientPrefs.shaders){
							blurFNFZoomEdition.setFloat('focusPower', 0);
							blurFNFZoomEditionHUD.setFloat('focusPower', 0);
							}
							FlxTween.tween(theBlackness, {alpha: 0}, 0.6, {ease: FlxEase.sineInOut});
                iconP1.alpha = 1;
						case 656:
							defaultCamZoom = 0.85;
						case 672:
							defaultCamZoom = 0.75;
						case 720:
							defaultCamZoom = 0.9;
						case 736:
							defaultCamZoom = 0.85;
						case 848:
							FlxG.camera.fade(FlxColor.BLACK, 3.52);
						case 896:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							FlxG.camera.fade(FlxColor.BLACK, 0.0000001, true);
							boyfriendGroup.visible = true;
							dad.x = DAD_X - 200;
							dad.y = DAD_Y - 0;
                            fuckyouDadX = dad.x;
                            fuckyouDadY = dad.y;
						case 960:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 1024:
							FlxTween.tween(camGame, {zoom: 0.9}, 0.75, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.9;
									}});
						case 1032:
							camHUD.alpha = 0;
							FlxTween.tween(camGame, {zoom: 1}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1;
									}});
						case 1034:
							FlxTween.tween(camGame, {zoom: 1.1}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.1;
									}});
						case 1036:
							FlxTween.tween(camGame, {zoom: 1.2}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.2;
									}});
						case 1040:
							camHUD.alpha = 1;
							defaultCamZoom = 0.8;
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 1280:
							if (ClientPrefs.flashing) {
							    camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 1520:
							FlxG.camera.fade(FlxColor.BLACK, 1.18);
							/*FlxTween.tween(camGame, {alpha: 0}, 1.18, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										camGame.alpha = 0;
									}});*/
							FlxTween.tween(camGame, {zoom: 1.1}, 1.18, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.1;
									}});
						case 1535: 
							boyfriendGroup.visible = false;
							FlxG.camera.fade(FlxColor.BLACK, 10, true);
						case 1536:
						    if (ClientPrefs.flashing) {
							    camOverlay.flash(FlxColor.WHITE, 2.5);
							}
							dad.x = DAD_X + 260;
							dad.y = DAD_Y + 250;
							triggerEventNote('Change Character', '1', 'finncawm_start_new');

							defaultCamZoom += 0.35; // black border fix

							cameraSpeed = 50;
							new FlxTimer().start(0.0461, a -> cameraSpeed = 1);
						case 1648: 
							triggerEventNote('Change Character', '1', 'finncawm_reveal');
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 0.3);
							}
						case 1664:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							triggerEventNote('Change Character', '1', 'finn-sword-sha');
							dad.x = fuckyouDadX;
							dad.y = fuckyouDadY;
							boyfriendGroup.visible = true;
						case 1775:
							FlxTween.tween(blackie, {alpha: 1}, 1);
							for (i in 0...opponentStrums.length) {
								FlxTween.tween(opponentStrums.members[i], {alpha: 0}, 1);
							}
						case 1792:
							if (ClientPrefs.flashing) {
								camOther.flash(FlxColor.WHITE, 1.33);
							}
							blackie.alpha = 0;
							theBlackness.alpha = 1;
							addBehindBF(blackie);
							addBehindDad(blackie);
							triggerEventNote('Change Character', '1', 'finncawn');
							triggerEventNote('Change Character', '0', 'bfcawn');
							dad.cameras = [camHUD];
							boyfriend.cameras = [camHUD];
							boyfriend.angle = 180;
							dad.setPosition(80, FlxG.height + 100);
							boyfriend.setPosition(750, -340);
							FlxTween.tween(boyfriend, {y: 40}, 1, {ease: FlxEase.sineInOut});
							FlxTween.tween(dad, {y: 260}, 1, {ease: FlxEase.sineInOut});
							canShakeNote = false;

							for (i in 0...opponentStrums.length) {
								FlxTween.tween(playerStrums.members[i], {alpha: 1}, 1.15, {onStart: goofyAhh -> {
									timeBar.alpha = 0;
									timeBarBG.alpha = 0;
									timeTxt.alpha = 1;
									timeTxt.screenCenter(X);
									scoreTxt.alpha = 0;
                                    finnBarThing.alpha = 0;
                                    iconP1.alpha = 0;
                                    pibbyHealthbar.alpha = 0;
                                    iconP2.alpha = 0;
									if (!ClientPrefs.middleScroll) {
										if (!ClientPrefs.downScroll) {
									playerStrums.forEach(yeah -> {
										FlxTween.tween(yeah, {x: yeah.x - 620}, 2.1, {ease: FlxEase.quadInOut});
									});
								}}}});
							}
						case 2176:
							for (i in 0...playerStrums.length) {
								FlxTween.tween(playerStrums.members[i], {alpha: 0}, 6.34, {
									ease: FlxEase.linear,
									onComplete:
									function (twn:FlxTween)
										{
											playerStrums.members[i].alpha = 0;
										}
								});
							}
							FlxTween.tween(botplayTxt, {alpha: 0}, 6.34, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										botplayTxt.alpha = 0;
									}
							});
							FlxTween.tween(timeBar, {alpha: 0}, 6.34, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										timeBar.alpha = 0;
									}
							});
							FlxTween.tween(timeTxt, {alpha: 0}, 6.34, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										timeTxt.alpha = 0;
									}
							});
							FlxTween.tween(timeBarBG, {alpha: 0}, 6.34, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										timeBarBG.alpha = 0;
									}
							});
							for (i in 0...opponentStrums.length) {
								FlxTween.tween(opponentStrums.members[i], {alpha: 0}, 6.34, {
									ease: FlxEase.linear,
									onComplete:
									function (twn:FlxTween)
										{
											opponentStrums.members[i].alpha = 0;
										}
								});
							}
						case 2432:
							blackie.alpha = 1;
							dad.cameras = [camHUD];
							boyfriend.cameras = [camHUD];
							triggerEventNote('Change Character', '1', 'finncawn');
							triggerEventNote('Change Character', '0', 'bfcawn');
							boyfriend.angle = 180;
							dad.setPosition(400, 730);
							boyfriend.setPosition(800, 640);

							addBehindBF(blackie);
							addBehindDad(blackie);
					}
				case 'Mindless':
					switch (curStep)
					{
						case 1:
							camGame.fade(FlxColor.BLACK, 4.42, true);
						case 256:
							FlxTween.tween(camGame, {zoom: 1.8}, 2.83, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
									}
							});
							FlxTween.tween(blackie, {alpha: 1}, 2.83, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										blackie.alpha = 1;
									}
							});
						case 298:
							dad.alpha = 1;
							FlxTween.tween(blackie, {alpha: 0}, 0.25, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										blackie.alpha = 0;
									}
							});
						case 300:
							for (i in 0...opponentStrums.length) {
								FlxTween.tween(opponentStrums.members[i], {alpha: 1}, 0.7, {
									ease: FlxEase.linear,
									onComplete:
									function (twn:FlxTween)
										{
											opponentStrums.members[i].alpha = 1;
										}
								});
							}
							FlxTween.tween(camGame, {zoom: 1.1}, 1.1, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
									}
							});
						case 320:
							FlxTween.tween(finnBarThing, {alpha: 1}, 0.75, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										finnBarThing.alpha = 1;
									}
							});
							FlxTween.tween(iconP2, {alpha: 1}, 0.75, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										iconP2.alpha = 1;
									}
							});
							FlxTween.tween(iconP1, {alpha: 1}, 0.75, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										iconP1.alpha = 1;
									}
							});
							FlxTween.tween(scoreTxt, {alpha: 1}, 0.75, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										scoreTxt.alpha = 1;
									}
							});
						case 1568:
							FlxTween.tween(blackFNF, {alpha: 1}, 0.4, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										blackFNF.alpha = 1;
										new FlxTimer().start(3.1, function(tmr:FlxTimer)
										{
											blackFNF.alpha = 0;
										});
									}
							});
						case 1577:
							finnT.alpha = 1;
							finnT.animation.play('cutscene');
						case 1616:
							blackFNF.alpha = 0;
							camOther.flash(FlxColor.WHITE, 1);
							finnT.alpha = 0.0001;
						case 3712:
							camOther.fade(FlxColor.BLACK, 2.5, false);
					}
				case "Child's Play":
                    switch (curStep)
					{
						case 1:
							blackie.alpha = 0;
							camHUD.alpha = 1;
							camOther.fade(FlxColor.BLACK, 10.67, true);
						case 64:
							FlxTween.tween(camGame, {zoom: 1.4}, 9.33, {
								ease: FlxEase.smoothStepInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
									}
							});
						case 128:
							defaultCamZoom = 1.2;
						case 256: 
							for (i in 0...opponentStrums.length) {
								if (ClientPrefs.shaders) opponentStrums.members[i].shader = distortFNF;
							}
						case 352:
							FlxTween.tween(camGame, {zoom: 1.4}, 5.33, {
								ease: FlxEase.smoothStepInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
										camGame.alpha = 0;
										camHUD.alpha = 0;
									}
							});
						case 400:
							moveCamera(true);
						case 410:
							defaultCamZoom = 1.2;
						case 416:
							healthDrain = ClientPrefs.healthDrain;
							health = 1;
							camGame.alpha = 1;
							camHUD.alpha = 1;
							if (ClientPrefs.flashing) {
								camOther.flash(FlxColor.WHITE, 1);
							}
						case 672:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 928:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 1198:
                            triggerEventNote('Cinematics', 'on', '3');
                            FlxTween.tween(this, {fakeSongLength: 198390}, 3);
							FlxTween.tween(camGame, {zoom: 1.5}, 3, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
                                        if (ClientPrefs.flashing) {
                                            camOverlay.flash(FlxColor.WHITE, 1);
                                        }
                                        if (healthDrain) {
                                            health = 0.1;
                                        }
                                        triggerEventNote('Apple Filter', 'on', 'black');
										defaultCamZoom = 1.4;
									}
							});

                        case 1456:
							FlxTween.tween(this, {fakeSongLength: songLength}, 1.92);
						case 1472:
							defaultCamZoom = 1.2;
                            if (ClientPrefs.flashing) {
                                camOverlay.flash(FlxColor.WHITE, 1.5);
                            }
                           triggerEventNote('Apple Filter', 'off', 'black');
						case 1728:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 1984:
							triggerEventNote('Cinematics', 'off', '2');
						case 2192:
							FlxTween.tween(camGame, {zoom: 1.4}, 6.63, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
										camGame.alpha = 0;
										camHUD.alpha = 0;
									}
							});
                    }
				case 'Forgotten World':
					switch (curStep)
					{
						case 1:
							boyfriend.y += 42;
							triggerEventNote('Camera Follow Pos', '1520', '970');
							triggerEventNote('Cinematics', 'on', '10.11');
							camHUD.alpha = 0;
							triggerEventNote('Apple Filter', 'on', 'white');
							camGame.fade(FlxColor.BLACK, 0.000001, true);
							camOther.fade(FlxColor.BLACK, 10.11, true);
						case 256:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							triggerEventNote('Cinematics', 'off', '1.5');
							triggerEventNote('Camera Follow Pos', '', '');
							camHUD.alpha = 1;
						case 497:
							defaultCamZoom = 0.75;
						case 501:
							defaultCamZoom = 0.9;
						case 505:
							defaultCamZoom = 1.1;
						case 514:
                            //camGame.removeLatestFilter();
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1.5);
							}
							defaultCamZoom = 0.7;
							// dad.y += 50;
						case 515:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1.5);
							}
							triggerEventNote('Apple Filter', 'off', 'white');
						case 562:
							defaultCamZoom = 0.85;
						case 578:
							defaultCamZoom = 0.7;
						case 627:
							defaultCamZoom = 0.95;
						case 643:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							defaultCamZoom = 0.7;
						case 756:
							FlxTween.tween(camGame, {zoom: 0.8}, 1, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.7;
									}});
						case 772:
							triggerEventNote('Cinematics', 'on', '1');
						case 788:
							defaultCamZoom = 0.95;
						case 803:
							FlxTween.tween(camGame, {zoom: 0.8}, 0.075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.8;
									}});
						case 805:
							FlxTween.tween(camGame, {zoom: 0.7}, 0.075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.7;
									}});
						case 854:
							defaultCamZoom = 0.95;
						case 868:
							FlxTween.tween(camGame, {zoom: 0.8}, 0.075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.8;
									}});
						case 870:
							FlxTween.tween(camGame, {zoom: 0.7}, 0.075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.7;
									}});
						case 902:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							triggerEventNote('Cinematics', 'off', '1');
							defaultCamZoom = 1;
						case 967:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 1032:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 1180:
							#if VIDEOS_ALLOWED
							canPause = false; // due to the cool part been literally a video we prevent the player to pause on that part

              pibbyHealthbar.alpha = 0;
							midSongVideo.bitmap.canSkip = false;
							midSongVideo.bitmap.playVideo(Paths.video('forgottenscene'));
							midSongVideo.bitmap.finishCallback = () -> { 
								canPause = true;
								blackie.alpha = 0;
								blackie.visible = false;
							};
							#end
						case 1190:
							defaultCamZoom = 0.7;
                            cappedHealth = 1;
                            health = 0.5;
						case 1440:
                            triggerEventNote('Cinematics', 'on', '1');
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
                            pibbyHealthbar.alpha = 1;
                            
							#if VIDEOS_ALLOWED
							midSongVideo.destroy();
							blackie.alpha = 0;
							blackie.visible = false;
							#end

                        if (ClientPrefs.shaders) 
                            playerStrums.forEach(strum -> strum.shader = distortFNF);

                        boyfriend.color = 0xbababa;
                        dad.color = 0xbababa;
                        

                        if (!ClientPrefs.lowQuality)
                        {
                            var vig:FlxSprite = new FlxSprite().loadGraphic(Paths.image('vignette'));
                            vig.scrollFactor.set();
                            vig.cameras = [camOther];
                            vig.screenCenter();
                            add(vig);
                        }
                    case 1706:
							triggerEventNote('Cinematics', 'off', '1');
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							defaultCamZoom = 0.8;
						case 1822:
							defaultCamZoom = 0.85;
						case 1830:
							defaultCamZoom = 0.9;
						case 1838:
							triggerEventNote('Cinematics', 'on', '1');
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							defaultCamZoom = 1;
						case 1972:
							triggerEventNote('Cinematics', 'off', '1');
							defaultCamZoom = 0.7;
						case 1988:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}

							if (ClientPrefs.shaders)
								{
									@:privateAccess
									{
										camGame._filters.push(new ShaderFilter(glitchFWFNF));
									}
								}
						case 2038:
							defaultCamZoom = 0.85;
						case 2055:
							defaultCamZoom = 0.7;
						case 2105:
							defaultCamZoom = 0.95;
						case 2121:
							defaultCamZoom = 0.9;
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 2255:
							defaultCamZoom = 1;
						case 2389:
							if (ClientPrefs.flashing) {
								camOther.flash(FlxColor.WHITE, 1);
							}
                            fullPibbyHealthbar = true; // FORCE THE PIBBY HEALTH BAR TO FILL
							camGame.alpha = 0;
							camHUD.alpha = 0;
						case 2610:
							FlxTween.tween(camHUD, {alpha: 1}, 1, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										camHUD.alpha = 1;
									},
								onStart: daTween -> {
									timeBar.alpha = 0;
									timeTxt.alpha = 0;
									timeBarBG.alpha = 0;
									playerStrums.forEach(playerNotes -> playerNotes.alpha = 0);
								}
							});
						case 2715:
							if (ClientPrefs.flashing) {
								camOther.flash(FlxColor.WHITE, 1);
							}
							camHUD.alpha = 0;
					}
				case 'My Amazing World':
					switch (curStep)
					{
						case 1:
							triggerEventNote('Cinematics', 'on', '9.6');
							camHUD.alpha = 1;
							camGame.fade(0x101010, 0.000001, true);
							camOther.fade(FlxColor.BLACK, 9.6, true);
							FlxTween.tween(camGame, {zoom: 1.1}, 9.6, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
									}
							});
						case 128:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 240:
							defaultCamZoom = 1;
						case 246:
							defaultCamZoom = 1.1;
						case 252:
							defaultCamZoom = 1.2;
						case 256:
							triggerEventNote('Cinematics', 'off', '0.4');
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 384:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 492:
							defaultCamZoom = 1;
						case 498:
							defaultCamZoom = 1.1;
						case 504:
							defaultCamZoom = 1.2;
						case 512:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
							triggerEventNote('Apple Filter', 'on', 'white');
							triggerEventNote('Cinematics', 'on', '1.2');
						case 768:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 1008:
							triggerEventNote('Cinematics', 'off', '0.6');	
						case 1024:
						triggerEventNote('Apple Filter', 'off', 'white');
						camGame.zoom = 1.7;
							triggerEventNote('Cinematics', 'on', '4.8');
							camOther.fade(FlxColor.BLACK, 4.8, true);
							FlxTween.tween(camGame, {zoom: 1.1}, 9.6, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
									}
							});
						case 1080:
							triggerEventNote('Cinematics', 'off', '1');
						case 1280:
							defaultCamZoom = 1.3;
							triggerEventNote('Cinematics', 'on', '0.6');
						case 1296:
							defaultCamZoom = 1.1;
						case 1424:
							FlxTween.tween(camGame, {zoom: 1.8}, 9.6, {
								ease: FlxEase.linear,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
									}
							});
						case 1520:
							gf.alpha = 1;
							boyfriend.alpha = 0.3;
						case 1552:
							FlxTween.tween(lyricTxt, {alpha: 1}, 0.05, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										lyricTxt.alpha = 1;
									}
							});

							lyricTxt.color = FlxColor.fromRGB(255, 120, 75);
							camGame.alpha = 0;
							lyricTxt.text = 'GUMBALL!';
						case 1560:
							lyricTxt.color = FlxColor.fromRGB(82, 165, 235);
							lyricTxt.text = 'D';
							new FlxTimer().start(0.01875, function(tmr:FlxTimer) {
								lyricTxt.text = 'D-D';
								new FlxTimer().start(0.0375, function(tmr:FlxTimer) {
									lyricTxt.text = 'D-D-D';
									new FlxTimer().start(0.01875, function(tmr:FlxTimer) {
										lyricTxt.text = 'D-D-D-D';
										new FlxTimer().start(0.01875, function(tmr:FlxTimer) {
											lyricTxt.text = 'D-D-D-D-D';
											new FlxTimer().start(0.01875, function(tmr:FlxTimer) {
												lyricTxt.text = 'D-D-D-D-D-D';
												new FlxTimer().start(0.01875, function(tmr:FlxTimer) {
													lyricTxt.text = 'DARWIN?';
												});
											});
										});
									});
								});
							});
						case 1568:
							GameOverSubstate.characterName = 'darwindeath';
							GameOverSubstate.deathSoundName = 'glitchhit';
							GameOverSubstate.soundLibraryStart = 'shared';
							GameOverSubstate.endSoundName = 'gameOverEnd';
							hiCameraPleaseFocusOnGfPleaseAndThankYou = true;
							lyricTxt.text = '';
							camGame.alpha = 1;
							iconP3.visible = true;
							triggerEventNote('Apple Filter', 'on', 'white');
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
							triggerEventNote('Cinematics', 'on', '1');
							FlxTween.tween(camGame, {zoom: 0.9}, 9.6, {
								ease: FlxEase.linear,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
									}
							});
						case 1824:
							triggerEventNote('Apple Filter', 'off', 'white');
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
							triggerEventNote('Cinematics', 'off', '1');
						case 1696:
							moveCamera(true);
                            for (hScript in allScripts) {
							    hScript.onMoveCamera('dad');
                            }
						case 1952:
							moveCamera(true);
                            for (hScript in allScripts) {
							    hScript.onMoveCamera('dad');
                            }
						case 2016:
							moveCamera(true);
                            for (hScript in allScripts) {
							    hScript.onMoveCamera('dad');
                            }
						case 2064:
							moveCamera(true);
                            for (hScript in allScripts) {
							    hScript.onMoveCamera('dad');
                            }
						case 2080:
							for (i in 0...opponentStrums.length) {
								opponentStrums.members[i].alpha = 0;
							}
							if (ClientPrefs.flashing)
								camOther.flash(FlxColor.WHITE, 1.75);
							triggerEventNote('Cinematics', 'on', '1.8');
							triggerEventNote('Apple Filter', 'on', 'white');
							boyfriend.alpha = 0;
						case 2112:
							FlxTween.tween(lyricTxt, {alpha: 1}, 0.05, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										lyricTxt.alpha = 1;
									}
							});
							lyricTxt.text = 'THE DARKNESS...';
							new FlxTimer().start(0.675, function(tmr:FlxTimer) {
								FlxTween.tween(lyricTxt, {alpha: 0}, 0.05, {
									ease: FlxEase.linear,
									onComplete:
									function (twn:FlxTween)
										{
											lyricTxt.alpha = 0;
										}
								});
							});
							moveCamera(true);
                            for (hScript in allScripts) {
							    hScript.onMoveCamera('dad');
                            }
						case 2128:
							FlxTween.tween(lyricTxt, {alpha: 1}, 0.05, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										lyricTxt.alpha = 1;
									}
							});
							lyricTxt.text = "IT'S CALLING ME...";
							new FlxTimer().start(0.565, function(tmr:FlxTimer) {
								FlxTween.tween(lyricTxt, {alpha: 0}, 0.05, {
									ease: FlxEase.linear,
									onComplete:
									function (twn:FlxTween)
										{
											lyricTxt.alpha = 0;
										}
								});
							});
						case 2144:
							lyricTxt.text = '';
							iconP3.visible = false;
							changeChannel(1);
							for (i in 0...opponentStrums.length) {
								opponentStrums.members[i].alpha = 1;
							}
							lyricTxt.text = "";
							defaultCamZoom = 0.8;
							triggerEventNote('Apple Filter', 'off', 'white');
							dad.x += 150;
							if(ClientPrefs.shaders) {
                            camOther.setFilters([new ShaderFilter(pibbyFNF),new ShaderFilter(chromFNF),new ShaderFilter(crtFNF)]);
							camHUD.setFilters([new ShaderFilter(pibbyFNF),new ShaderFilter(chromFNF),new ShaderFilter(crtFNF)]);
							camOverlay.setFilters([new ShaderFilter(crtFNF)]);
							camGame.setFilters([new ShaderFilter(pibbyFNF),new ShaderFilter(chromFNF),new ShaderFilter(crtFNF),new ShaderFilter(mawFNF)]);
							}
							if (ClientPrefs.flashing)
								camOther.flash(FlxColor.WHITE, 1);
							triggerEventNote('Cinematics', 'off', '1');
							dad.y += 30;
						case 2176:
							changeChannel(2);
							FlxTween.tween(camGame, {zoom: 1.1}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.1;
									}});
						case 2208:
							changeChannel(3);
							FlxTween.tween(camGame, {zoom: 0.8}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.8;
									}});
						case 2272:
							changeChannel(1);
						case 2304:
							changeChannel(2);
							FlxTween.tween(camGame, {zoom: 1.1}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.1;
									}});
						case 2336:
							changeChannel(3);
							FlxTween.tween(camGame, {zoom: 0.8}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.8;
									}});
						case 2400:
							changeChannel(1);
							camGame.zoom = 1.7;
							triggerEventNote('Cinematics', 'on', '4.8');
							camGame.fade(FlxColor.BLACK, 4.8, true); // so player can see the hud
							FlxTween.tween(camGame, {zoom: 1.1}, 4.8, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
									}
							});
						case 2432:
							changeChannel(2);
						case 2464:
							changeChannel(3);
							FlxTween.tween(camGame, {zoom: 0.8}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.8;
									}});
							triggerEventNote('Cinematics', 'off', '1');
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 2528:
							changeChannel(1);
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 2560:
							changeChannel(2);
							FlxTween.tween(camGame, {zoom: 1.1}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.1;
									}});
						case 2592:
							changeChannel(3);
							FlxTween.tween(camGame, {zoom: 0.8}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.8;
									}});
						case 2604:
							changeChannel(1);
						case 2624:
							changeChannel(2);
							FlxTween.tween(camGame, {zoom: 1.1}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.1;
									}});
						case 2632:
							changeChannel(3);
							FlxTween.tween(camGame, {zoom: 0.8}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.8;
									}});
						case 2640:
							changeChannel(1);
						case 2648:
							changeChannel(2);
							FlxTween.tween(camGame, {zoom: 1.1}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.1;
									}});
						case 2656:
                            for (hScript in allScripts) {
							    hScript.onMoveCamera('boyfriend');
                            }
							changeChannel(3);
							defaultCamZoom = 1.3; // black jumpscare on shaders off so here's a fix
						case 2672:
							defaultCamZoom = 1.4;
						case 2678:
							defaultCamZoom = 1.5;
						case 2684:
							defaultCamZoom = 1.6;
						case 2688:
							iconP3.visible = true;
							changeChannel(0);
							boyfriend.alpha = 1;
							defaultCamZoom = 0.7;
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);

							camHUD.setFilters([]);
							camOverlay.setFilters([]);
                            camOther.setFilters([]);
							camGame.setFilters([]);

							boyfriend.x += 160;
							boyfriend.y += 70;
							dad.y -= 30;
					}
				case 'Retcon':
					switch (curStep)
					{
						case 1:
							moveCamera(true);
							blackie.alpha = 0;
							defaultCamZoom = 1.3;
                            triggerEventNote('Cinematics', 'on', '18.525');
							camOther.fade(FlxColor.BLACK, 18.525, true);
							FlxTween.tween(camGame, {zoom: 0.9}, 18.525, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.9;
									}
							});

						case 248:
							camFollow.x = 1050;
							camFollow.y = ( (dad.y + opponentCameraOffset[1]) + (boyfriend.y + boyfriendCameraOffset[1]) ) / 2;
                            isCameraOnForcedPos = true;
							FlxTween.tween(camGame, {zoom: 0.7}, 0.675, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.7;
									}
							});
							triggerEventNote('Cinematics', 'off', '0.675');
							FlxTween.tween(camHUD, {alpha: 1}, 2, {ease: FlxEase.cubeOut});
						case 256:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
							defaultCamZoom = 0.7;
							isCameraOnForcedPos = false;
						case 384:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 512:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 1024:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 1152:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 1280:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 1408:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 1520:
							FlxTween.tween(blackFNF, {alpha: 1}, 1.15, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										blackFNF.alpha = 1;
										new FlxTimer().start(0.001, function(tmr:FlxTimer)
										{
											blackFNF.alpha = 0;
											defaultCamZoom = 0.7;
										});
									}
							});
							FlxTween.tween(camGame, {zoom: 1.6}, 1.15, {
								ease: FlxEase.linear,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.6;
									}
							});
						case 1536:
							blackFNF.alpha = 0;
							defaultCamZoom = 0.7;
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 1664:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 1792:
							defaultCamZoom = 1.2;
						case 1816:
							camHUD.alpha = 0;
							FlxTween.tween(camGame, {zoom: 1.25}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.25;
									}});
						case 1818:
							FlxTween.tween(camGame, {zoom: 1.3}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.3;
									}});
						case 1820:
							FlxTween.tween(camGame, {zoom: 1.4}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.4;
									}});
						case 1824:
							camHUD.alpha = 1;
							defaultCamZoom = 0.7;
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 1920:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 2048:
							if (ClientPrefs.flashing)
								camOverlay.flash(FlxColor.WHITE, 1);
						case 2064:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							glitchShaderIntensity = 2;
                            if (ClientPrefs.screenGlitch) {
							    camHUD.shake(FlxG.random.float(0.025, 0.1), FlxG.random.float(0.075, 0.125));
                            }
							fakeSongLength = songLength;
							triggerEventNote('Apple Filter', 'on', 'white');
					}
				case 'Brotherly Love':
					switch (curStep)
					{
						case 1:
							defaultCamZoom = 1.2;
						case 506:
							camHUD.angle = 0;
							camGame.angle = 0;
							camHUD.x = 0;
							camGame.x = 0;
							camGame.scroll.y = 0;
						case 890:
							camHUD.angle = 0;
							camGame.angle = 0;
							camHUD.x = 0;
							camGame.x = 0;
							camGame.scroll.y = 0;
						case 1013:
							if (ClientPrefs.flashing) 
			    				camHUD.fade(FlxColor.BLACK, 0.9, false, function() {
									camHUD.fade(FlxColor.BLACK, 0.2, true);
								});
						case 1440:
							if (ClientPrefs.flashing) 
			    				camHUD.fade(FlxColor.WHITE, 6, false, function() {
									camHUD.fade(FlxColor.WHITE, 0.75, true);
								});
						case 1520:
							camGame.alpha = 0;
						case 1536:
							camGame.alpha = 1;
						case 1792:
							camHUD.angle = 0;
							camGame.angle = 0;
							camHUD.x = 0;
							camGame.x = 0;
							camGame.scroll.y = 0;
						case 3337:
							camHUD.angle = 0;
							camGame.angle = 0;
							camHUD.x = 0;
							camGame.x = 0;
							camGame.scroll.y = 0;
						case 3328:
							FlxTween.tween(camHUD, {alpha: 0}, 1, {
								ease: FlxEase.linear,
								onComplete: 
								function (twn:FlxTween)
									{
										camHUD.alpha = 0;
									}
							});
							FlxG.camera.fade();
					}
				case 'Suffering Siblings':
					switch (curStep)
					{
						case 1:
							// so like for a second where after the flash the camera movement still transitions
							// so here's a really tiny fix (idk how to elaborate this)
							cameraSpeed = 50;
							FlxTween.tween(camGame, {zoom: 0.7}, 0.00075, {
								ease: FlxEase.linear,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 0.7;
									}
							});
							triggerEventNote('Camera Follow Pos', '1830', '1100');
							camHUD.alpha = 0;
							triggerEventNote('Cinematics', 'on', '0.00075');
							camOther.fade(FlxColor.BLACK, 9.33, true, () -> cameraSpeed = 2);
						case 128:
							triggerEventNote('Camera Follow Pos', '', '');
							triggerEventNote('Cinematics', 'off', '1');
							camHUD.alpha = 1;
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							defaultCamZoom = 0.9;
						case 240:
							FlxTween.tween(camGame, {zoom: 1.2}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.2;
									}});
						case 244:
							FlxTween.tween(camGame, {zoom: 1.3}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.3;
									}});
						case 248:
							FlxTween.tween(camGame, {zoom: 1.4}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.4;
									}});
						case 252:
							FlxTween.tween(camGame, {zoom: 1.3}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.3;
									}});
						case 256:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							defaultCamZoom = 1.1;
						case 369:
							defaultCamZoom = 1.15;
						case 376:
							defaultCamZoom = 1.2;
						case 378:
							defaultCamZoom = 1.3;
						case 379:
							defaultCamZoom = 1.25;
						case 384:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							defaultCamZoom = 1.1;
						case 448:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 508:
							defaultCamZoom = 1.3;
						case 512:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							defaultCamZoom = 0.9;
						case 536:
							defaultCamZoom = 0.95;
						case 540:
							defaultCamZoom = 1.025;
						case 544:
							defaultCamZoom = 1.1;
						case 552:
							defaultCamZoom = 1.3;
						case 559:
							defaultCamZoom = 1.1;
						case 576:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 600:
							defaultCamZoom = 0.95;
						case 604:
							defaultCamZoom = 1.025;
						case 608:
							defaultCamZoom = 1.1;
						case 616:
							defaultCamZoom = 1.3;
						case 624:
							defaultCamZoom = 1.1;
						case 640:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 768:
							triggerEventNote('Cinematics', 'on', '1');
						case 1024:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							triggerEventNote('Cinematics', 'off', '1');
						case 1038:
							defaultCamZoom = 1.1;
						case 1056:
							defaultCamZoom = 0.9;
						case 1072:
							FlxTween.tween(camGame, {zoom: 1.1}, 1.34, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
									}
							});
						case 1088:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							defaultCamZoom = 0.9;
						case 1120:
							defaultCamZoom = 1.15;
						case 1137:
							defaultCamZoom = 1.2;
						case 1144:
							defaultCamZoom = 1.3;
						case 1146:
							defaultCamZoom = 1.4;
						case 1149:
							defaultCamZoom = 1.25;
						case 1152:
							defaultCamZoom = 0.9;
						case 1270:
							defaultCamZoom = 1.15;
						case 1273:
							defaultCamZoom = 1.2;
						case 1276:
							defaultCamZoom = 1.3;
						case 1280:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							defaultCamZoom = 0.9;
						case 1306:
							defaultCamZoom = 1.2;
						case 1312:
							defaultCamZoom = 0.9;
						case 1320:
							defaultCamZoom = 1.1;
						case 1324:
							defaultCamZoom = 1;
						case 1328:
							defaultCamZoom = 0.9;
						case 1376:
							defaultCamZoom = 1.3;
						case 1390:
							defaultCamZoom = 1.1;
						case 1408:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							triggerEventNote('Cinematics', 'on', '1');
						case 1536:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 1656:
							defaultCamZoom = 1.2;
						case 1660:
							defaultCamZoom = 1.3;
						case 1664:
							defaultCamZoom = 1.3;
							camGame.alpha = 0;
							camHUD.alpha = 0;
							triggerEventNote('Cinematics', 'off', '1');
						case 1696:
							FlxTween.tween(camGame, {zoom: 0.9}, 10.67, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
									}
							});
							camHUD.alpha = 1;
							camHUD.fade(FlxColor.BLACK, 10.67, true);
							triggerEventNote('Cinematics', 'on', '0.6');
							camGame.alpha = 1;
							dad.alpha = 0.3;
							boyfriend.alpha = 0.3;
						case 1832:
							FlxTween.tween(dad, {alpha: 1}, 0.25, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										dad.alpha = 1;
									}
							});
						case 1952:
							triggerEventNote('Cinematics', 'off', '1');
						case 1958:
							defaultCamZoom = 1.2;
						case 1968:
							defaultCamZoom = 0.9;
						case 1974:
							defaultCamZoom = 1.1;
						case 1978:
							defaultCamZoom = 1;
						case 1984:
							defaultCamZoom = 0.9;
						case 1990:
							defaultCamZoom = 1;
						case 1998:
							defaultCamZoom = 1.2;
						case 2006:
							defaultCamZoom = 0.9;
						case 2049:
							triggerEventNote('Camera Follow Pos', '1830', '1100');
							FlxTween.tween(camGame, {zoom: 0.8}, 1.65, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = defaultCamZoom;
									}
							});
						case 2062:
							for (i in 0...opponentStrums.length) {
								FlxTween.tween(opponentStrums.members[i], {alpha: 0}, 1, {
									ease: FlxEase.linear,
									onComplete:
									function (twn:FlxTween)
										{
											opponentStrums.members[i].alpha = 0;
										}
								});
							}
						case 2064:
							FlxTween.tween(boyfriend, {alpha: 1}, 0.25, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										boyfriend.alpha = 1;
									}
							});
						case 2066:
							triggerEventNote('Camera Follow Pos', '1830', '1100');
						case 2071:
							defaultCamZoom = 0.9;
							if (ClientPrefs.flashing){
								camOverlay.flash(FlxColor.WHITE, 0.5);
							}
						case 2080:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							triggerEventNote('Camera Follow Pos', '1830', '1100');
							gf.alpha = 0.0001;
							jake.alpha = 0.0001;
							theBlackness.alpha = 1;
							defaultCamZoom = 0.65;

						case 2140:
							boyfriend.playAnim('reload', true);
							boyfriend.specialAnim = true;
						case 2336:
							for (i in 0...opponentStrums.length) {
								FlxTween.tween(opponentStrums.members[i], {alpha: 1}, 1, {
									ease: FlxEase.linear,
									onComplete:
									function (twn:FlxTween)
										{
											opponentStrums.members[i].alpha = 1;
										}
								});
							}
							defaultCamZoom = 0.9;

             for (character in dadGroup){
             if (Reflect.getProperty(character, "curCharacter") == "finn-hurting") {
             character.alpha = 0;
                }
             }

             triggerEventNote('Change Character', '1', 'finn-sword');

            for (character in dadGroup){
            if (Reflect.getProperty(character, "curCharacter") == "finn-sword"){
             character.alpha = 1;
             dad.alpha = 1;
            }
          }
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 2.5);
							}
							gf.alpha = 1;
							jake.alpha = 1;
							theBlackness.alpha = 0;
						case 2368:
							FlxTween.tween(this, {abberationShaderIntensity: 0.1}, 2.67, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										FlxTween.tween(this, {abberationShaderIntensity: beatShaderAmount}, 1, {
											ease: FlxEase.quadInOut,
											onComplete: 
											function (twn:FlxTween)
												{
													abberationShaderIntensity = beatShaderAmount;
												}});
									}});
					    case 2372:
							gf.playAnim('cmon', true);
							gf.specialAnim = true;
						case 2374:
							FlxTween.tween(lyricTxt, {alpha: 1}, 0.05, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										lyricTxt.alpha = 1;
									}
							});
							lyricTxt.text = "COME ON";
							new FlxTimer().start(0.917, function(tmr:FlxTimer) {
								lyricTxt.text = "W";
								new FlxTimer().start(0.083, function(tmr:FlxTimer) {
									lyricTxt.text = "WA";
									new FlxTimer().start(0.083, function(tmr:FlxTimer) {
										lyricTxt.text = "WA";
									});
									new FlxTimer().start(0.083, function(tmr:FlxTimer) {
										lyricTxt.text = "WAAA";
									});
									new FlxTimer().start(0.083, function(tmr:FlxTimer) {
										lyricTxt.text = "WAAAA";
									});
									new FlxTimer().start(0.083, function(tmr:FlxTimer) {
										lyricTxt.text = "WAAAAA";
									});
									new FlxTimer().start(0.083, function(tmr:FlxTimer) {
										lyricTxt.text = "WAAAAAA";
									});
									new FlxTimer().start(0.083, function(tmr:FlxTimer) {
										lyricTxt.text = "WAAAAAAA";
									});
									new FlxTimer().start(0.083, function(tmr:FlxTimer) {
										lyricTxt.text = "WAAAAAAAA";
									});
									new FlxTimer().start(0.083, function(tmr:FlxTimer) {
										lyricTxt.text = "WAAAAAAAAA";
									});
									new FlxTimer().start(0.083, function(tmr:FlxTimer) {
										lyricTxt.text = "WAAAAAAAAAA";
									});
									new FlxTimer().start(0.083, function(tmr:FlxTimer) {
										lyricTxt.text = "WAAAAAAAAAAH";
									});
									new FlxTimer().start(0.083, function(tmr:FlxTimer) {
										lyricTxt.text = "WAAAAAAAAAAH!";
									});
								});
							});
						case 2400:
							lyricTxt.text = "";
							defaultCamZoom = 1.1;
							triggerEventNote('Camera Follow Pos', '', '');
							moveCamera(false);
						case 2448:
							FlxTween.tween(camGame, {zoom: 1.2}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.2;
									}});
						case 2452:
							FlxTween.tween(camGame, {zoom: 1.3}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.3;
									}});
						case 2456:
							FlxTween.tween(camGame, {zoom: 1.4}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.4;
									}});
						case 2460:
							FlxTween.tween(camGame, {zoom: 1.3}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.3;
									}});
						case 2464:
							defaultCamZoom = 0.9;
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							triggerEventNote('Cinematics', 'on', '1');
						case 2592:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 2720:
							triggerEventNote('Cinematics', 'off', '0.6');
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 2784:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 2848:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 2912:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 2976:
							triggerEventNote('Cinematics', 'on', '0.6');
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1.5);
							}
						case 3008:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 3040:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1.5);
							}
						case 3088:
							FlxTween.tween(camGame, {zoom: 1.2}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.2;
									}});
						case 3092:
							FlxTween.tween(camGame, {zoom: 1.3}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.3;
									}});
						case 3096:
							FlxTween.tween(camGame, {zoom: 1.4}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.4;
									}});
						case 3100:
							FlxTween.tween(camGame, {zoom: 1.3}, 0.00075, {
								ease: FlxEase.quadInOut,
								onComplete: 
								function (twn:FlxTween)
									{
										defaultCamZoom = 1.3;
									}});
						case 3104:
							triggerEventNote('Cinematics', 'on', '1');
							defaultCamZoom = 0.9;
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 3168:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 3228:
							defaultCamZoom = 1.3;
						case 3232:
							defaultCamZoom = 0.9;
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 3256:
							defaultCamZoom = 0.95;
						case 3260:
							defaultCamZoom = 1.025;
						case 3264:
							defaultCamZoom = 1.1;
						case 3272:
							defaultCamZoom = 1.3;
						case 3279:
							defaultCamZoom = 1.1;
						case 3296:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
						case 3320:
							defaultCamZoom = 0.95;
						case 3324:
							defaultCamZoom = 1.025;
						case 3328:
							defaultCamZoom = 1.1;
						case 3336:
							defaultCamZoom = 1.3;
						case 3344:
							defaultCamZoom = 1.1;
						case 3360:
							camGame.alpha = 0;
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 1);
							}
							dad.alpha = 0.0001;
							jake.alpha = 0.0001;
						case 3392:
							camGame.alpha = 1;
							defaultCamZoom = 0.7;
							if (ClientPrefs.flashing){
								camOverlay.flash(FlxColor.WHITE, 0.4);
							}
							triggerEventNote('Apple Filter', 'on', 'black');
						case 3776:
							if (ClientPrefs.flashing) {
								camOverlay.flash(FlxColor.WHITE, 0.5);
							}
							blackFNF.alpha = 1;
						case 3791:
							FlxTween.tween(camHUD, {alpha: 0}, 3, {
								ease: FlxEase.linear,
								onComplete:
								function (twn:FlxTween)
									{
										camHUD.alpha = 0;
									}
							});
					}

				case 'No Hero Remix':
					switch (curStep)
					{
						case 1:
							if (noHeroIntro != null) {
							add(noHeroIntro);
							noHeroIntro.animation.play('finnJumpscareMomento');
							}

						case 32: 
							camGame.fade(FlxColor.BLACK, 0.000001, true);
							camHUD.alpha = 1;
							remove(noHeroIntro);
							noHeroIntro.destroy();
							noHeroIntro = null;
							if (ClientPrefs.flashing) camGame.flash (FlxColor.WHITE, 1);
							triggerEventNote('Cinematics', 'on', '1.3');
							triggerEventNote('Apple Filter', 'on', 'white');

						case 96: 
							FlxTween.tween(camGame, {zoom: 1.24}, 6.7, {ease: FlxEase.sineInOut, onComplete: _->
								FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.sineInOut})
							});

						case 176 | 180 | 184: camGame.zoom += 0.05;

						case 192:
							triggerEventNote('Cinematics', 'off', '1');
							triggerEventNote('Apple Filter', 'off', 'white');
							if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1);
							FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
							iconP2.color = 0xFFFFFF;

						case 294 | 422 | 646 | 774 | 1110: 
							defaultCamZoom = 1;
							camGame.zoom = 1;

						case 298 | 426 | 650 | 778 | 1114: 
							defaultCamZoom = 1.1;
							camGame.zoom = 1.1;

						case 302 | 430 | 656 | 784 | 1118: 
							defaultCamZoom = 0.8;
							// if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1);

						case 306 | 434: 
							defaultCamZoom = 1;
							camGame.zoom = 1.1;

						case 310 | 438: 
							defaultCamZoom = 1.1;
							camGame.zoom = 1.1;
							//if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1);

						case 320 | 724: 
							defaultCamZoom = 0.85;
							if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1);

						case 368 | 400: 
							defaultCamZoom += 0.15; 

						case 384 | 416:
							defaultCamZoom -= 0.15;

						case 448: 
							defaultCamZoom = 0.85;
							FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.sineInOut});

						case 460:
							defaultCamZoom = 1.45;

						case 464: 
							defaultCamZoom = 0.9;
							FlxTween.tween(camHUD, {alpha: 1}, 1.5, {ease: FlxEase.sineInOut});
							if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1);
							FlxG.camera.filtersEnabled = false;
							camHUD.filtersEnabled = false;
							if (ClientPrefs.shaders) opponentStrums.forEach(yeah -> yeah.shader = null);
							timeTxt.font = Paths.font('vcr.ttf');
							if (cnlogo != null) cnlogo.alpha = 0;
							animOffsetValue = 0;
							// camGame.enableAngleFix = false;

						case 592: 
							if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1);
							FlxG.camera.filtersEnabled = true;
							camHUD.filtersEnabled = true;
							timeTxt.font = Paths.font('finn.ttf');
							pibbyHealthbar.alpha = 1;
							if (ClientPrefs.shaders) opponentStrums.forEach(yeah -> yeah.shader = distortFNF);
							if (cnlogo != null) cnlogo.alpha = 0.5;
							animOffsetValue = 20;
							// camGame.enableAngleFix = true;

						case 720: 
							defaultCamZoom = 1.05;

						case 848:
							FlxTween.tween(camHUD, {alpha: 0}, 0.7, {ease: FlxEase.sineInOut});
							triggerEventNote('Goofy Ahh Blammed Lights', 'on', '');

						case 869: 
							camHUD.alpha = 1;
							camHUD.zoom += 1;

						case 880: 
							defaultCamZoom = 1.25;
							if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1);
							triggerEventNote('Goofy Ahh Blammed Lights', 'off', '');

						case 982: 
							defaultCamZoom = 1.35;

						case 986: 
							defaultCamZoom = 1.45;

						case 990: 
							defaultCamZoom = 1.55;
							// if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1);

						case 994: 
							defaultCamZoom = 1.25;
							
						case 998: 
							defaultCamZoom = 1.35;

						case 1008: 
							defaultCamZoom = 0.86;
							if (ClientPrefs.flashing) camGame.flash(FlxColor.WHITE, 1);

						case 1126: 
							defaultCamZoom = 1;

						case 1136: 
							FlxTween.tween(camGame, {zoom: 0.84}, 4, {ease: FlxEase.sineInOut, onComplete: woo -> defaultCamZoom = 0.84});

						case 1264: 
							camGame.fade(FlxColor.BLACK, 0.55);
							FlxTween.tween(camHUD, {alpha: 0.001}, 0.5, {ease: FlxEase.sineInOut});

					}
			}


		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);

        if (ClientPrefs.killyourself && camZooming) {
            if (curStep % 4 == 0) {
                FlxTween.tween(camHUD, {y: -12}, Conductor.stepCrochet * 0.002, {
                    ease: FlxEase.circOut,
                });
                FlxTween.tween(camGame.scroll, {y: 12}, Conductor.stepCrochet * 0.002, {
                    ease: FlxEase.sineIn,
                });
            }
            if (curStep % 4 == 2) {
                FlxTween.tween(camHUD, {y: 0}, Conductor.stepCrochet * 0.002, {
                    ease: FlxEase.sineIn,
                });
                FlxTween.tween(camGame.scroll, {y: 0}, Conductor.stepCrochet * 0.002, {
                    ease: FlxEase.sineIn,
                });
            }
        }
	}

	var lastBeatHit:Int = -1;

    public function runLuaCode(string:String) {
        luaArray.push(new FunkinLua(Asset2File.getPath(string), true));
    }

	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) return;

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

        for (hScript in allScripts) {
		    hScript.onBeatHit(curBeat);
        }

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);
        if (gf != null) 
			{
				iconP3.scale.set(1, 1);
				iconP3.updateHitbox();
			}
		
		if (SONG.song == "Suffering Siblings")
			{
				iconPibby.scale.set(1, 1);
				iconPibby.updateHitbox();
				iconJake.scale.set(1, 1);
				iconJake.updateHitbox();
			}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance((FlxG.random.bool(25) && gf.animation.curAnim.finished && (gf.curCharacter == 'darwin-noremote' || gf.curCharacter == 'darwinretcon')) ? 'idle-blink' : 'idle');
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			// idk why is the blinking slower it has the same setup smh
			boyfriend.dance((FlxG.random.bool(25) && boyfriend.animation.curAnim.finished && (boyfriend.curCharacter == 'darwin-noremote' || boyfriend.curCharacter == 'darwinretcon')) ? 'idle-blink' : 'idle');
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}
			
			if (jake != null) {
		if (curBeat % jake.danceEveryNumBeats == 0 && jake.animation.curAnim != null && !jake.animation.curAnim.name.startsWith('sing') && !jake.stunned)
			{
				jake.dance();
			}}

		lastBeatHit = curBeat;

		switch (SONG.song)
			{
				case 'Brotherly Love':
					if (curStep >= 256 && curStep <= 496)
						{
							if (curBeat % 1 == 0)
								{
                                    if (ClientPrefs.camZooms)
									{
										abberationShaderIntensity = beatShaderAmount;
										FlxG.camera.zoom += 0.015 * camZoomingMult;
										camHUD.zoom += 0.03 * camZoomingMult;
									}
									if (curStep % 4 == 0) {
										FlxTween.tween(camHUD, {y: -12}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.circOut,
										});
										FlxTween.tween(camGame.scroll, {y: 12}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.sineIn,
										});
									}
									if (curStep % 4 == 2) {
										FlxTween.tween(camHUD, {y: 0}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.sineIn,
										});
										FlxTween.tween(camGame.scroll, {y: 0}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.sineIn,
										});
									}
									if (curBeat % 2 == 0) {
										angleshit = anglevar;
									}else {
										angleshit = -anglevar;
									}
									camHUD.angle = angleshit * 1.5;
									camGame.angle = angleshit * 1.5;
									FlxTween.tween(camHUD, {angle: angleshit}, Conductor.stepCrochet * 0.002, {
										ease: FlxEase.circOut,
									});
									FlxTween.tween(camGame, {angle: angleshit}, Conductor.stepCrochet * 0.002, {
										ease: FlxEase.circOut,
									});
									FlxTween.tween(camHUD, {x: -angleshit*2}, Conductor.crochet * 0.001, {
										ease: FlxEase.linear,
									});
									FlxTween.tween(camGame, {x: -angleshit*2}, Conductor.crochet * 0.001, {
										ease: FlxEase.linear,
									});
								}
						}
						if (curStep >= 512 && curStep <= 880)
							{
								if (curBeat % 1 == 0)
									{
										if (ClientPrefs.camZooms)
											{
												abberationShaderIntensity = beatShaderAmount;
												FlxG.camera.zoom += 0.015 * camZoomingMult;
												camHUD.zoom += 0.03 * camZoomingMult;
											}
										if (curStep % 4 == 0) {
											FlxTween.tween(camHUD, {y: -12}, Conductor.stepCrochet * 0.002, {
												ease: FlxEase.circOut,
											});
											FlxTween.tween(camGame.scroll, {y: 12}, Conductor.stepCrochet * 0.002, {
												ease: FlxEase.sineIn,
											});
										}
										if (curStep % 4 == 2) {
											FlxTween.tween(camHUD, {y: 0}, Conductor.stepCrochet * 0.002, {
												ease: FlxEase.sineIn,
											});
											FlxTween.tween(camGame.scroll, {y: 0}, Conductor.stepCrochet * 0.002, {
												ease: FlxEase.sineIn,
											});
										}
										if (curBeat % 2 == 0) {
											angleshit = anglevar;
										}else {
											angleshit = -anglevar;
										}
										camHUD.angle = angleshit * 1.5;
										camGame.angle = angleshit * 1.5;
										FlxTween.tween(camHUD, {angle: angleshit}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.circOut,
										});
										FlxTween.tween(camGame, {angle: angleshit}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.circOut,
										});
										FlxTween.tween(camHUD, {x: -angleshit*2}, Conductor.crochet * 0.001, {
											ease: FlxEase.linear,
										});
										FlxTween.tween(camGame, {x: -angleshit*2}, Conductor.crochet * 0.001, {
											ease: FlxEase.linear,
										});
									}
							}	
						if (curStep >= 1536 && curStep <= 1792)
						{
							if (curBeat % 1 == 0)
								{
                                    if (ClientPrefs.camZooms)
										{
											abberationShaderIntensity = beatShaderAmount;
											FlxG.camera.zoom += 0.015 * camZoomingMult;
											camHUD.zoom += 0.03 * camZoomingMult;
										}
									if (curStep % 4 == 0) {
										FlxTween.tween(camHUD, {y: -12}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.circOut,
										});
										FlxTween.tween(camGame.scroll, {y: 12}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.sineIn,
										});
									}
									if (curStep % 4 == 2) {
										FlxTween.tween(camHUD, {y: 0}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.sineIn,
										});
										FlxTween.tween(camGame.scroll, {y: 0}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.sineIn,
										});
									}
									if (curBeat % 2 == 0) {
										angleshit = anglevar;
									}else {
										angleshit = -anglevar;
									}
									camHUD.angle = angleshit * 1.5;
									camGame.angle = angleshit * 1.5;
									FlxTween.tween(camHUD, {angle: angleshit}, Conductor.stepCrochet * 0.002, {
										ease: FlxEase.circOut,
									});
									FlxTween.tween(camGame, {angle: angleshit}, Conductor.stepCrochet * 0.002, {
										ease: FlxEase.circOut,
									});
									FlxTween.tween(camHUD, {x: -angleshit*2}, Conductor.crochet * 0.001, {
										ease: FlxEase.linear,
									});
									FlxTween.tween(camGame, {x: -angleshit*2}, Conductor.crochet * 0.001, {
										ease: FlxEase.linear,
									});
								}
						}
					if (curStep >= 2304 && curStep <= 3327)
						{
							if (curBeat % 1 == 0)
								{
                                    if (ClientPrefs.camZooms)
									{
										abberationShaderIntensity = beatShaderAmount;
										FlxG.camera.zoom += 0.015 * camZoomingMult;
										camHUD.zoom += 0.03 * camZoomingMult;
									}
									if (curStep % 4 == 0) {
										FlxTween.tween(camHUD, {y: -12}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.circOut,
										});
										FlxTween.tween(camGame.scroll, {y: 12}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.sineIn,
										});
									}
									if (curStep % 4 == 2) {
										FlxTween.tween(camHUD, {y: 0}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.sineIn,
										});
										FlxTween.tween(camGame.scroll, {y: 0}, Conductor.stepCrochet * 0.002, {
											ease: FlxEase.sineIn,
										});
									}
									if (curBeat % 2 == 0) {
										angleshit = anglevar;
									}else {
										angleshit = -anglevar;
									}
									camHUD.angle = angleshit * 1.5;
									camGame.angle = angleshit * 1.5;
									FlxTween.tween(camHUD, {angle: angleshit}, Conductor.stepCrochet * 0.002, {
										ease: FlxEase.circOut,
									});
									FlxTween.tween(camGame, {angle: angleshit}, Conductor.stepCrochet * 0.002, {
										ease: FlxEase.circOut,
									});
									FlxTween.tween(camHUD, {x: -angleshit*2}, Conductor.crochet * 0.001, {
										ease: FlxEase.linear,
									});
									FlxTween.tween(camGame, {x: -angleshit*2}, Conductor.crochet * 0.001, {
										ease: FlxEase.linear,
									});
								}
						}
				case 'Suffering Siblings':
					if (curStep >= 256 && curStep <= 508)
						{
							if (curBeat % 1 == 0 && ClientPrefs.camZooms)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 512 && curStep <= 639 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 640 && curStep <= 767 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 768 && curStep <= 1023 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1024 && curStep <= 1136 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1280 && curStep <= 1392 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1408 && curStep <= 1664 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1952 && curStep <= 2324 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 2464 && curStep <= 2968 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 3104 && curStep <= 3223 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 3232 && curStep <= 3360 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
				case 'Mindless':
					if (curStep >= 320 && curStep <= 3712 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
				case 'Come Along With Me':
					if (curStep >= 832 && curStep <= 888 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 896 && curStep <= 1024 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1040 && curStep <= 1264 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1280 && curStep <= 1520 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1792 && curStep <= 2176 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
				case "Child's Play":
					if (curStep >= 672 && curStep <= 1183 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1472 && curStep <= 1984 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
				case 'Forgotten World':
					if (curStep >= 514 && curStep <= 772 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 902 && curStep <= 1163 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1440 && curStep <= 1822 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1838 && curStep <= 1972 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1988 && curStep <= 2255 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
				case 'My Amazing World':
					if (curStep >= 1 && curStep <= 256 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 256 && curStep <= 495 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 512 && curStep <= 1079 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1080 && curStep <= 1280 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0 && ClientPrefs.camZooms)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >=1824 && curStep <= 2080 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 2144 && curStep <= 2400 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 2464 && curStep <= 2656 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
				case 'Retcon':
					if (curStep >= 256 && curStep <= 512 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 512 && curStep <= 752 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1024 && curStep <= 1271 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1280 && curStep <= 1520 && ClientPrefs.camZooms)
						{
							if (curBeat % 2 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1536 && curStep <= 1791 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}
					if (curStep >= 1816 && curStep <= 2048 && ClientPrefs.camZooms)
						{
							if (curBeat % 1 == 0)
								{
                                    abberationShaderIntensity = beatShaderAmount;
									FlxG.camera.zoom += 0.015 * camZoomingMult;
									camHUD.zoom += 0.03 * camZoomingMult;
								}
						}

				case 'No Hero Remix':
					// rest of the zoom events are on the song json because haxe hates me
					if ((curStep >= 192 && curStep < 296) || (curStep >= 320 && curStep < 424) || (curStep >= 592 && curStep < 648) ||
						(curStep >= 592 && curStep < 645) || (curStep >= 656 && curStep < 719) || (curStep >= 725 && curStep < 773))
					{
						if (curBeat % 1 == 0 && ClientPrefs.camZooms)
						{
							abberationShaderIntensity = beatShaderAmount;
							FlxG.camera.zoom += .035 * camZoomingMult;
							camHUD.zoom += .053 * camZoomingMult;
						}
					}
			}

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);

		if (hiCameraPleaseFocusOnGfPleaseAndThankYou && gf != null)
			focusedCharacter = gf;

        if(ClientPrefs.killyourself && camZooming) { //FOR THE FUNNY
            if (curBeat % 2 == 0) {
                angleshit = anglevar;
            }else {
                angleshit = -anglevar;
            }
            camHUD.angle = angleshit * 3;
            camGame.angle = angleshit * 3;
            FlxTween.tween(camHUD, {angle: angleshit}, Conductor.stepCrochet * 0.002, {
                ease: FlxEase.circOut,
            });
            FlxTween.tween(camGame, {angle: angleshit}, Conductor.stepCrochet * 0.002, {
                ease: FlxEase.circOut,
            });
            FlxTween.tween(camHUD, {x: -angleshit*8}, Conductor.crochet * 0.001, {
                ease: FlxEase.linear,
            });
            FlxTween.tween(camGame, {x: -angleshit*8}, Conductor.crochet * 0.001, {
                ease: FlxEase.linear,
            });
        }
	}

	public function changeChannel(number:Int)
		{
			switch (number)
				{
					case 0:
						channelTxt.text = "AV";
					case 1:
						channelTxt.text = "CH 06";
					case 2:
						channelTxt.text = "CH 02";
					case 3:
						channelTxt.text = "CH 03";
				}
			}

	override function sectionHit()
	{
		super.sectionHit();

		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
			{
				moveCameraSection();
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms)
			{
                abberationShaderIntensity = beatShaderAmount;
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[curSection].bpm);
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnLuas('altAnim', SONG.notes[curSection].altAnim);
			setOnLuas('gfSection', SONG.notes[curSection].gfSection);
		}
		
		setOnLuas('curSection', curSection);
		callOnLuas('onSectionHit', []);
	}

	public function callOnLuas(event:String, args:Array<Dynamic>, ignoreStops = true, exclusions:Array<String> = null):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			var ret:Dynamic = script.call(event, args);
			if(ret == FunkinLua.Function_StopLua && !ignoreStops)
				break;
			
			// had to do this because there is a bug in haxe where Stop != Continue doesnt work
			var bool:Bool = ret == FunkinLua.Function_Continue;
			if(!bool && ret != 0) {
				returnVal = ret;
			}
		}
		#end
		//trace(event, returnVal);
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', [], false);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "PFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce -Ghost
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}
}

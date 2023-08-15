package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import flixel.FlxSprite;
import openfl.text.TextFormat;
import openfl.text.TextField;
import Macro;
import HScript.ScriptManager;
using flixel.util.FlxSpriteUtil;


//crash handler stuff
#if CRASH_HANDLER
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import Discord.DiscordClient;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

// stuff for optimization
#if cpp
import cpp.NativeGc;
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
import openfl.system.System;
import openfl.utils.AssetCache;
import openfl.Assets;

using StringTools;

class Main extends Sprite
{
	var sprite:FlxSprite;
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = /*LoadingStuffLmao*/ TitleState; // The FlxState the game starts with.
    // Loading screen doesnt do anything except inflate the memory lol
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;
	public static var funnyMenuMusic = 1;
    var buildDate:TextField;

    public static var debug:Bool = #if debug true #else false #end;


	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		#if windows
		CppAPI.darkMode();
     	#end
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);

			#if desktop
			Gc.enable(true);
			#end

			//FlxG.signals.focusLost.add(()->gc()); // they don't know
			// ^ what is wrong with you
             
			FlxG.signals.preGameStart.add(() -> funnyMenuMusic = FlxG.random.bool(5) ? 2 : 1);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
	
		ClientPrefs.loadDefaultKeys();
		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));

		ScriptManager.init();
		InputFormatter.loadKeys();
		FlxSprite.defaultAntialiasing = ClientPrefs.globalAntialiasing;

		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}
		#end

        buildDate = new TextField();
        buildDate.x = 10;
        buildDate.y = 650;

        var date = Macro.getBuildDate();
        buildDate.selectable = false;
        buildDate.mouseEnabled = false;
        buildDate.defaultTextFormat = new TextFormat("_sans", 24, 0x9E9191);
        buildDate.autoSize = LEFT;
        buildDate.multiline = false;
        buildDate.text = Macro.getBuildDate() + " Dev Build";
        addChild(buildDate);

		FlxG.autoPause = false;
		FlxG.mouse.visible = true;
		sprite = new FlxSprite().loadGraphic(Paths.image('cursor/mouse (1)'));

		FlxG.mouse.load(sprite.pixels);

		addEventListener(Event.ENTER_FRAME, update);
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

    @:noCompletion private override function __update(transformOnly:Bool, updateChildren:Bool):Void
        {
            super.__update(transformOnly, updateChildren);
            buildDate.y = lime.app.Application.current.window.height - 70;
        }

	private function update(e:Event):Void
		{
			sprite = new FlxSprite().loadGraphic(Paths.image('cursor/mouse (' + FlxG.random.int(1, 10) + ')'));
			FlxG.mouse.load(sprite.pixels);
		}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "PsychEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end

    // that optimizeGame function stank up the whole mod so im removing it fuck you
}

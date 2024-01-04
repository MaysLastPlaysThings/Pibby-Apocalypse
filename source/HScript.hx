import flixel.math.FlxPoint;
import flixel.addons.display.FlxRuntimeShader;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import haxe.ds.StringMap;
import haxe.Exception;
import Paths;
import PlayState;
import Conductor;
import hscript.*;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import openfl.display.BlendMode;
import openfl.utils.Assets;

using StringTools;

// Manages all scripts that pass through this, basically just the master location of everything.
class ScriptManager {

	// Base Constants and Variables
	public static var expressions : StringMap<Dynamic>;

	public static var scriptParser : Parser = new Parser();

	public static function init() {
		expressions = new StringMap<Dynamic>();

		// Setup all of the stuff that we will need for our stuff
		expressions.set("Paths", Paths);
        expressions.set("FlxG", FlxG);
		expressions.set("FlxTween", FlxTween);
		expressions.set("FlxEase", FlxEase);
		expressions.set("FlxSprite", FlxSprite);
		expressions.set("FlxBasic", FlxBasic);
		expressions.set("FlxTimer", FlxTimer);
        expressions.set("ClientPrefs", ClientPrefs);
		expressions.set("FlxRuntimeShader", FlxRuntimeShader);
		expressions.set("RuntimeShaders", _Shaders);
		expressions.set("newShader", function(fragFile:String = null, vertFile:String = null)
		{ // returns a FlxRuntimeShader but with file names lol
			var runtime:FlxRuntimeShader = null;

			try
			{
				runtime = new FlxRuntimeShader(fragFile == null ? null : Paths.getContent(Paths.shaderFragment(fragFile)),
					vertFile == null ? null : Paths.getContent(Paths.shaderVertex(vertFile)));
			}
			catch (e:Dynamic)
			{
				trace("Shader compilation error:" + e.message);
			}

			return runtime == null ? new FlxRuntimeShader() : runtime;
		});

        

		
		expressions.set("importClass", function(className:String, ?traceImports:Bool) //thanks troll engine :D
            {
                // importClass("flixel.util.FlxSort") should give you FlxSort.byValues, etc
                // whereas importClass("scripts.Globals.*") should give you Function_Stop, Function_Continue, etc
                // i would LIKE to do like.. flixel.util.* but idk if I can get everything in a namespace
                var classSplit:Array<String> = className.split(".");
                var daClassName = classSplit[classSplit.length-1]; // last one
    
                if (daClassName == '*'){
                    var daClass = Type.resolveClass(className);
    
                    while(classSplit.length > 0 && daClass==null){
                        daClassName = classSplit.pop();
                        daClass = Type.resolveClass(classSplit.join("."));
                        if(daClass!=null) break;
                    }
                    if(daClass!=null){
                        for(field in Reflect.fields(daClass)){
                            expressions.set(field, Reflect.field(daClass, field));
                            
                            if (traceImports == true) trace('Imported: $field, $daClass');
                        }
                    }else{
                        FlxG.log.error('Could not import class $className');
                        if (traceImports == true) trace('Could not import class $className');
                    }
                }else{
                    var daClass = Type.resolveClass(className);
                    expressions.set(daClassName, daClass);
                    if (traceImports == true) trace('Imported: $daClassName, $daClass');
                }
            });

		// FlxColor is an abstract so you can't pass it to hscript
		expressions.set("FlxColor", {
			// These aren't part of FlxColor but i thought they could be useful
			// honestly we should replace source/flixel/FlxColor.hx or w/e with one with these funcs

			toRGBArray: (color:FlxColor) ->
			{
				return [color.red, color.green, color.blue];
			},
			lerp: (from:FlxColor, to:FlxColor, ratio:Float) ->
			{
				return FlxColor.fromRGBFloat(FlxMath.lerp(from.redFloat, to.redFloat, ratio), FlxMath.lerp(from.greenFloat, to.greenFloat, ratio),
					FlxMath.lerp(from.blueFloat, to.blueFloat, ratio), FlxMath.lerp(from.alphaFloat, to.alphaFloat, ratio));
			},

			////
			set_hue: (color:FlxColor, hue:Float) ->
			{
				color.hue = hue;
				return color;
			},
			set_saturation: (color:FlxColor, saturation:Float) ->
			{
				color.saturation = saturation;
				return color;
			},
			set_brightness: (color:FlxColor, brightness:Float) ->
			{
				color.brightness = brightness;
				return color;
			},

			fromCMYK: FlxColor.fromCMYK,
			fromHSL: FlxColor.fromHSL,
			fromHSB: FlxColor.fromHSB,
			fromInt: FlxColor.fromInt,
			fromRGBFloat: FlxColor.fromRGBFloat,
			fromString: FlxColor.fromString,
			fromRGB: FlxColor.fromRGB,

			TRANSPARENT: 0x00000000,
			WHITE: 0xFFFFFFFF,
			GRAY: 0xFF808080,
			BLACK: 0xFF000000,

			GREEN: 0xFF008000,
			LIME: 0xFF00FF00,
			YELLOW: 0xFFFFFF00,
			ORANGE: 0xFFFFA500,
			RED: 0xFFFF0000,
			PURPLE: 0xFF800080,
			BLUE: 0xFF0000FF,
			BROWN: 0xFF8B4513,
			PINK: 0xFFFFC0CB,
			MAGENTA: 0xFFFF00FF,
			CYAN: 0xFF00FFFF,
		});
		// Same for FlxPoint
		expressions.set("FlxPoint", {
			get: FlxPoint.get,
			weak: FlxPoint.weak
		});

		expressions.set("Math", Math);
		expressions.set("Paths", Paths);
		expressions.set("Std", Std);
        expressions.set("Paths", Paths);
		expressions.set("Conductor", Conductor);

		// Just basically tells me (Aaron), if my shit is working or not.
		for (string => value in expressions) {
			trace('Added in ${string}, with the library ${value}');
		}
		// Allows for the parsing of types with local variables, exceptions, function arguments, etc...
		scriptParser.allowTypes = true;
	}
	
	public static function loadScript(path : String, ?library : String, ?additionalParamaters : StringMap<Dynamic>):Script {
		var newScript : Script = null;
		if (Assets.exists(path)) {
			trace('Currently loading script path ${path}');
			try { scriptParser.parseString(Assets.getText(path), path); } catch( e : Dynamic ) { trace(e); return null; }
			newScript = new Script(scriptParser.parseString(Assets.getText(path), path), additionalParamaters);
			return newScript;
		} else {
			trace('The path ${path}, is not a valid path');
			return newScript;
		}
	}
}

// A base class that is used for new Scripts to be ran!
class Script {
	// Base Constants and Variables
	var scriptInterpreter : Interp;


	public function new(content : Expr, ?additionalParamaters : StringMap<Dynamic>) {
		scriptInterpreter = new Interp();

		for (key in ScriptManager.expressions.keys()) {
			scriptInterpreter.variables.set(key, ScriptManager.expressions.get(key));
		}

		// If there is additional paramaters that you want to provide that aren't already in here just do this ig idk lol
		if (additionalParamaters != null) {
			for (key in additionalParamaters.keys()) {
				scriptInterpreter.variables.set(key, additionalParamaters.get(key));
			}
		}

        try{
		    scriptInterpreter.execute(content);
        }catch(e:Dynamic){
            trace("hscript error on execute: " + e.message);
        }
	}

	// This is our way of getting a field
	public function get(field : String):Dynamic
		return scriptInterpreter.variables.get(field);

	// This is our way of setting a field
	public function set(field : String, value : Dynamic)
		return scriptInterpreter.variables.set(field, value);

	// Checking if a field exists or not
	public function exists(field : String):Bool
		return scriptInterpreter.variables.exists(field);
}

/**
class FakeClasses {
    public static var map  : Map<String, Dynamic> = [];
}
**/

// i hate haxe sometimes
@:noCompletion
class _Shaders {	
	public static var fwGlitch = RuntimeShaders.fwGlitch;
	public static var file = RuntimeShaders.file;
	public static var blurZoom = RuntimeShaders.blurZoom;
	public static var dayybloomshader = RuntimeShaders.dayybloomshader;
	public static var distort = RuntimeShaders.distort;
	public static var monitor = RuntimeShaders.monitor;
	public static var pixel = RuntimeShaders.pixel;
}

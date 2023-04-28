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
import flash.display.BlendMode;

using StringTools;

// Manages all scripts that pass through this, basically just the master location of everything.
class ScriptManager {

	// Base Constants and Variables
	public static var expressions : StringMap<Dynamic>;

	public static var scriptParser : Parser = new Parser();

	public static function init() {
		expressions = new StringMap<Dynamic>();

		// Setup all of the stuff that we will need for our stuff
		expressions.set("FlxG", FlxG);
		expressions.set("FlxTween", FlxTween);
		expressions.set("FlxEase", FlxEase);
		expressions.set("FlxSprite", FlxSprite);
		expressions.set("FlxBasic", FlxBasic);
		expressions.set("FlxTimer", FlxTimer);
        expressions.set("ClientPrefs", ClientPrefs);
		
		/**
		expressions.set("importClass", Reflect.makeVarArgs(function(classes:Array<Dynamic>):Void {
            for (i in classes) {
                importClass(Std.string(i));
            }
        }));
		**/

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
		if (FileSystem.exists(path)) {
			trace('Currently loading script path ${path}');
			try { scriptParser.parseString(File.getContent(path), path); } catch( e : Dynamic ) { trace(e); return null; }
			newScript = new Script(scriptParser.parseString(File.getContent(path), path), additionalParamaters);
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
		scriptInterpreter.execute(content);
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

package;

import haxe.Json;
import haxe.format.JsonParser;
import haxe.io.Bytes;
import haxe.io.Encoding;
import Song;
import openfl.utils.Assets;
using StringTools;

// The data that should be inside of the JSON structure
typedef StageFile = {
	var directory:String;
	var defaultZoom:Float;
	var isPixelStage:Bool;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
	var hide_girlfriend:Bool;

	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;
}

class StageData {
	public static var forceNextDirectory : String = null;

	// Load directory function
	public static function loadDirectory(SONG:SwagSong) {
		var stage : String = SONG.stage != null ? SONG.stage : 'stage';
		var stageFile : StageFile = getStageFile(stage);

		forceNextDirectory = stageFile == null ? '' : stageFile.directory;
	}

	// Return stage data
	public static function getStageFile(stage:String) : StageFile {
		var path : String = 'assets/stages/${stage}/stage.json';
		var rawJson : String = null;

		if ( Assets.exists(path) ) 
			rawJson = Assets.getText(path);
		else
			rawJson = null;

		return cast Json.parse(rawJson);
	}
}

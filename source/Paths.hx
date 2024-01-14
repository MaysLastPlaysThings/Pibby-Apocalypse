package;

import flixel.system.FlxAssets;
import animateatlas.AtlasFrameMaker;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.Json;

import flash.media.Sound;
import openfl.display3D.textures.Texture;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> =
	[
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/shared/music/breakfast.$SOUND_EXT',
		'assets/shared/music/tea-time.$SOUND_EXT',
	];
	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory() {
        trace("clearing unused memory");
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key)
				&& !dumpExclusions.contains(key)) {
				// get rid of it
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null) {
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
                    trace("removing " + key);
                    if (uniqueRAMImages.contains(key))uniqueRAMImages.remove(key);
                    if (uniqueVRMImages.contains(key))uniqueVRMImages.remove(key);
				}
			}
		}

        trace("--images in RAM after memory clear--");
		for (shit in uniqueRAMImages)
            trace(shit);

		trace("--images in VRAM after memory clear--");
		for (shit in uniqueVRMImages)
			trace(shit);
        trace("----");
		getExpectedMemory();
		// run the garbage collector for good measure lmfao
		System.gc();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];
	public static function clearStoredMemory(?cleanUnused:Bool = false) {
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key)) {
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
                if (uniqueRAMImages.contains(key))uniqueRAMImages.remove(key);
                if (uniqueVRMImages.contains(key))uniqueVRMImages.remove(key);
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys()) {
			if (!localTrackedAssets.contains(key)
			&& !dumpExclusions.contains(key) && key != null) {
				//trace('test: ' + dumpExclusions, key);
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		openfl.Assets.cache.clear("songs");
		getExpectedMemory();
	}

	static public var currentModDirectory:String = '';
	static public var currentLevel:String;
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		var returnPath = '$library:assets/$library/$file';
		return returnPath;
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}
	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}
	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function video(key:String)
	{
		return Generic.returnPath() + 'assets/videos/$key.$VIDEO_EXT';
	}

	static public function truevideo(key:String)
	{
		return 'assets/videos/$key.$VIDEO_EXT';
	}

	static public function sound(key:String, ?library:String):Sound
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Sound
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	inline static public function voices(song:String):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
	}

	inline static public function inst(song:String):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
	}

	inline static public function image(key:String, ?library:String, ?throwToGPU:Bool = false, ?prefix:String = null):FlxGraphic
	{
		// streamlined the assets process more
		var returnAsset:FlxGraphic = returnGraphic(key, library, throwToGPU, prefix);
		return returnAsset;
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		return Assets.getText(getPath(key, TEXT)); //mariomaestro
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{

		if(OpenFlAssets.exists(getPath(key, type))) {
			return true;
		}
		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, throwToGPU:Bool = false, ?prefix:String = 'images'):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(image(key, library, throwToGPU, prefix), file('$prefix/$key.xml', library));
	}


	inline static public function getPackerAtlas(key:String, ?library:String, ?throwToGPU:Bool = false)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function formatToSongPath(path:String) {
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];


    public static var uniqueRAMImages:Array<String> = [];
    public static var uniqueVRMImages:Array<String> = [];
    
	public static var expectedMemoryBytes:Float = 0;

    static function getExpectedMemory(){
        if(Main.debug){
            expectedMemoryBytes = 0;

            var processed:Array<FlxGraphic> =[];

            @:privateAccess
            for (key in FlxG.bitmap._cache.keys())
            {
                var obj = FlxG.bitmap._cache.get(key);
                if (processed.contains(obj) || uniqueVRMImages.contains(key))continue;
                expectedMemoryBytes += obj.width * obj.height * 4;
                processed.push(obj);
            }
            for (key in currentTrackedAssets.keys())
            {
                var obj = currentTrackedAssets.get(key);
                if (processed.contains(obj) || uniqueVRMImages.contains(key))continue;
                expectedMemoryBytes += obj.width * obj.height * 4;
                processed.push(obj);
            }
            processed = null;
        }
    }

	public static function returnGraphic(key:String, ?library:String, throwToGPU:Bool = false, ?prefix:String = 'images')
    {
		if (!ClientPrefs.useGPUCaching)
			throwToGPU = false;

		var path = getPath('$prefix/$key.png', IMAGE, library);
        var bitmap:BitmapData = null;

        if(currentTrackedAssets.exists(path)){
			if (throwToGPU && !uniqueVRMImages.contains(path)){
				if (!localTrackedAssets.contains(path) && !dumpExclusions.contains(path))
				{
					// get rid of it
					var obj = currentTrackedAssets.get(path);
					@:privateAccess
					if (obj != null)
					{
						openfl.Assets.cache.removeBitmapData(path);
						FlxG.bitmap._cache.remove(path);
						obj.destroy();
						currentTrackedAssets.remove(path);
						if (uniqueRAMImages.contains(path))uniqueRAMImages.remove(path);
                        if (uniqueVRMImages.contains(path))uniqueVRMImages.remove(path);
					}
				}
            }else{
				localTrackedAssets.push(path);
				return currentTrackedAssets.get(path);
            }
        }
        
        if(OpenFlAssets.exists(path, IMAGE))
			bitmap = OpenFlAssets.getBitmapData(path);
        
        if(bitmap != null){
            if(throwToGPU){
				// based on what smokey learnt + my own research
				// should be fine? idk lole
				var tex:Texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, false);
				tex.uploadFromBitmapData(bitmap);
				// free mem
				bitmap.dispose();
				bitmap.disposeImage();
                // push shit
				bitmap = BitmapData.fromTexture(tex);
                if (!uniqueVRMImages.contains(path))uniqueVRMImages.push(path);
				uniqueRAMImages.remove(path);
            }else{
				if (!uniqueRAMImages.contains(path))uniqueRAMImages.push(path);
                
				uniqueVRMImages.remove(path);
            }

			@:privateAccess
			var grafic = FlxGraphic.createGraphic(bitmap, key, false, false);
			grafic.persist = true;
			grafic.destroyOnNoUse = false;
			localTrackedAssets.push(path);
			currentTrackedAssets.set(path, grafic);
			getExpectedMemory();
			return grafic;
        }
        return null;
    }

	inline static public function modsShaderFragment(key:String, ?library:String)
		#if MODS_ALLOWED
		return modFolders('shaders/' + key + '.frag');
		#else
		return getPreloadPath('shaders/' + key + '.frag');
		#end
	inline static public function modsShaderVertex(key:String, ?library:String)
		#if MODS_ALLOWED
		return modFolders('shaders/' + key + '.vert');
		#else
		return getPreloadPath('shaders/' + key + '.vert');
		#end

	inline static public function getContent(asset:String):Null<String>
	{
		if (Assets.exists(asset))
			return Assets.getText(asset);
		
		return null;
	}
	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(path:String, key:String, ?library:String) {
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		// trace(gottenPath);
		if(!currentTrackedSounds.exists(gottenPath))
		{
			var folder:String = '';
			if(path == 'songs') folder = 'songs:';
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		}
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	#if MODS_ALLOWED
	inline static public function mods(key:String = '') {
		return 'mods/' + key;
	}

	inline static public function modsFont(key:String) {
		return modFolders('fonts/' + key);
	}

	inline static public function modsJson(key:String) {
		return modFolders('data/' + key + '.json');
	}

	inline static public function modsVideo(key:String) {
		return modFolders('videos/' + key + '.' + VIDEO_EXT);
	}

	inline static public function modsSounds(path:String, key:String) {
		return modFolders(path + '/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsImages(key:String) {
		return modFolders('images/' + key + '.png');
	}

	inline static public function modsXml(key:String, ?prefix:String='images') {
		return modFolders('$prefix/' + key + '.xml');
	}

	inline static public function modsTxt(key:String) {
		return modFolders('images/' + key + '.txt');
	}

	static public function modFolders(key:String) {
		if(currentModDirectory != null && currentModDirectory.length > 0) {
			var fileToCheck:String = mods(currentModDirectory + '/' + key);
			if(FileSystem.exists(fileToCheck)) {
				return fileToCheck;
			}
		}

		for(mod in getGlobalMods()){
			var fileToCheck:String = mods(mod + '/' + key);
			if(FileSystem.exists(fileToCheck))
				return fileToCheck;

		}
		return 'mods/' + key;
	}

	public static var globalMods:Array<String> = [];

	static public function getGlobalMods()
		return globalMods;

	static public function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods = [];
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var list:Array<String> = CoolUtil.coolTextFile(path);
			for (i in list)
			{
				var dat = i.split("|");
				if (dat[1] == "1")
				{
					var folder = dat[0];
					var path = Paths.mods(folder + '/pack.json');
					if(FileSystem.exists(path)) {
						try{
							var rawJson:String = File.getContent(path);
							if(rawJson != null && rawJson.length > 0) {
								var stuff:Dynamic = Json.parse(rawJson);
								var global:Bool = Reflect.getProperty(stuff, "runsGlobally");
								if(global)globalMods.push(dat[0]);
							}
						} catch(e:Dynamic){
							trace(e);
						}
					}
				}
			}
		}
		return globalMods;
	}

	static public function getModDirectories():Array<String> {
		var list:Array<String> = [];
		var modsFolder:String = mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder)) {
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		return list;
	}
	#end
}

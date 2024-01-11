package;


import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.ds.StringMap;
import HScript.Script;
import HScript.ScriptManager;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxBasic;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import sys.io.File;
import flixel.util.FlxColor;

enum abstract AssetType(String) to String {
    var IMAGE = 'image';
    var ATLAS = 'atlas';
    var SOUND = 'sound';
    var TEXT = 'text';
}

class ScriptConstructor extends FlxTypedGroup<FlxBasic>
{
    // Attach some metadata to the new Stage
    public var script:Script;
    public var foreground : FlxTypedGroup<FlxBasic>;

    // Incase you aren't aware already of what this is gonna do, its basically just gonna allow for hscript functionality with stages lol.
    public function new(dir:String, file:String)
    {
        super();

        foreground = new FlxTypedGroup<FlxBasic>();

        var additionalParams : StringMap<Dynamic> = new StringMap<Dynamic>();
        additionalParams.set('add', add);
        additionalParams.set('stage', this);
        additionalParams.set('foreground', foreground);
        additionalParams.set('PlayState', PlayState.instance);
        additionalParams.set('retrieveAsset', function(path : String, assetType : AssetType, ?useGPU:Bool):Dynamic {
            // this is retarded lol
            switch (assetType) {
                case IMAGE:
					return Paths.returnGraphic(path, null, useGPU == null ? false : useGPU, dir);
                case ATLAS:
					return Paths.getSparrowAtlas(path, null, useGPU == null ? true : useGPU, dir);
                case SOUND:
                    var daLibrary:String = null; // not tested cus why tf are we using sound in the first place
                    if (StringTools.endsWith(path, '_shared')) daLibrary = 'shared';
                
                    return Paths.sound(path, daLibrary);
                case TEXT:
                    return Paths.getContent('assets/$dir/$path');
            }
        });

        additionalParams.set('runLuaCode', function(code:String) {
            PlayState.instance.runLuaCode(code);
        });

        additionalParams.set('triggerEvent', function(name:String, arg1:Dynamic, arg2:Dynamic) {
            var value1:String = arg1;
            var value2:String = arg2;
            PlayState.instance.triggerEventNote(name, value1, value2);
        });

        additionalParams.set('debugPrint', function(text:String) {
            PlayState.instance.addTextToDebug(text, FlxColor.RED);
        });

		additionalParams.set('getScript', PlayState.instance.getScript);
		additionalParams.set('getScriptVar', PlayState.instance.getScriptVar);

        script = ScriptManager.loadScript('assets/${dir}/${file}.hx', null, additionalParams); // Change the file extension here to change what file extension scripts use.

        try{
            if (script != null && script.exists("onCreate"))
                script.get("onCreate")();
        }catch(e:Dynamic){
            trace(e);
        }
    }

    override function update(elapsed:Float) 
        {
            super.update(elapsed);
            if (script != null && script.exists("onUpdate"))
                script.get("onUpdate")(elapsed);
        }

    public function onCreatePost()
        if (script != null && script.exists("onCreatePost"))
            script.get("onCreatePost")();

    public function onUpdatePost(elapsed:Float)
        if (script != null && script.exists("onUpdatePost"))
            script.get("onUpdatePost")(elapsed);

    public function onEvent(event:String, value1:String, value2:String)
        if (script != null && script.exists("onEvent"))
            script.get("onEvent")(event, value1, value2);

    public function opponentNoteHit(index:Int, dir:Float, noteType:String, isSus:Bool)
        if (script != null && script.exists("opponentNoteHit"))
            script.get("opponentNoteHit")(index, dir, noteType, isSus);

    public function goodNoteHit(index:Int, dir:Float, noteType:String, isSus:Bool)
        if (script != null && script.exists("goodNoteHit"))
            script.get("goodNoteHit")(index, dir, noteType, isSus);

    public function noteMiss(note:Note)
        if (script != null && script.exists("noteMiss"))
            script.get("noteMiss")(note);

    public function onStepHit(curStep : Int)
        if (script != null && script.exists("onStepHit"))
            script.get("onStepHit")(curStep);
    
    public function onBeatHit(curBeat : Int)
        if (script != null && script.exists("onBeatHit"))
            script.get("onBeatHit")(curBeat);
    public function onStartCountdown()
        if (script != null && script.exists("onStartCountdown"))
            script.get("onStartCountdown")();
    public function onSongStart()
        if (script != null && script.exists("onSongStart"))
            script.get("onSongStart")();
    public function onEndSong()
        if (script != null && script.exists("onEndSong"))
            script.get("onEndSong")();
    public function onPause()
        if (script != null && script.exists("onPause"))
            {
                script.get("onPause")();
                FlxTween.globalManager.forEach(function( tween : FlxTween ) {
                    tween.active = false;
                });
            }
    public function onResume()
        if (script != null && script.exists("onResume"))
            {
                script.get("onResume")();
                FlxTween.globalManager.forEach(function( tween : FlxTween ) {
                    tween.active = true;
                });
            }
    public function onGameOver()
        if (script != null && script.exists("onGameOver"))
            script.get("onGameOver")();
    public function onMoveCamera(focus : String)
        if (script != null && script.exists("onMoveCamera"))
            script.get("onMoveCamera")(focus);
    public function onCountdownTick(counter : Int)
        if (script != null && script.exists("onCountdownTick"))
            script.get("onCountdownTick")(counter);
}
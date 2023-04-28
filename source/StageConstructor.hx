package;


import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.ds.StringMap;
import HScript.Script;
import HScript.ScriptManager;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;
import flixel.FlxG;
import sys.io.File;
import flixel.util.FlxColor;

@:enum abstract AssetType(String) to String {
    var IMAGE = 'image';
    var SOUND = 'sound';
}

class StageConstructor extends FlxTypedGroup<FlxBasic>
{
    // Attach some metadata to the new Stage
    var newStage : Script;
    public var foreground : FlxTypedGroup<FlxBasic>;


    // Incase you aren't aware already of what this is gonna do, its basically just gonna allow for hscript functionality with stages lol.
    public function new(currentStage : String)
    {
        super();

        foreground = new FlxTypedGroup<FlxBasic>();

        var additionalParams : StringMap<Dynamic> = new StringMap<Dynamic>();
        additionalParams.set('add', add);
        additionalParams.set('stage', this);
        additionalParams.set('foreground', foreground);
        additionalParams.set('PlayState', PlayState.instance);
        additionalParams.set('retrieveAsset', function(path : String, assetType : AssetType) {
            switch (assetType) {
                case IMAGE:
                    var newGraphic : FlxGraphic = FlxG.bitmap.add(BitmapData.fromBytes(File.getBytes('assets/stages/${currentStage}/${path}')), false, 'assets/stages/${currentStage}/${path}');
                    newGraphic.persist = true;
                    return newGraphic;
                case SOUND:
                    // SOUNDS ARE NOT DONE, RETURNS NULL
                    return null;
            }
        });

        additionalParams.set('debugPrint', function(text:String) {
            PlayState.instance.addTextToDebug(text, FlxColor.RED);
        });

        newStage = ScriptManager.loadScript('assets/stages/${currentStage}/stage.hxs', null, additionalParams);

        if (newStage != null)
            newStage.get("onCreate")();
    }

    override function update(elapsed:Float) 
        {
            super.update(elapsed);
            if (newStage != null && newStage.exists("onUpdate"))
                newStage.get("onUpdate")(elapsed);
        }

    public function onCreatePost()
        if (newStage != null && newStage.exists("onCreatePost"))
            newStage.get("onCreatePost")();

    public function onUpdatePost(elapsed:Float)
        if (newStage != null && newStage.exists("onUpdatePost"))
            newStage.get("onUpdatePost")(elapsed);

    public function onEvent(event:String, value1:String, value2:String)
        if (newStage != null && newStage.exists("onEvent"))
            newStage.get("onEvent")(event, value1, value2);

    public function opponentNoteHit(index:Int, dir:Float, noteType:String, isSus:Bool)
        if (newStage != null && newStage.exists("opponentNoteHit"))
            newStage.get("opponentNoteHit")(index, dir, noteType, isSus);

    public function goodNoteHit(index:Int, dir:Float, noteType:String, isSus:Bool)
        if (newStage != null && newStage.exists("goodNoteHit"))
            newStage.get("goodNoteHit")(index, dir, noteType, isSus);

    public function noteMiss(note:Note)
        if (newStage != null && newStage.exists("noteMiss"))
            newStage.get("noteMiss")(note);

    public function onStepHit(curStep : Int)
        if (newStage != null && newStage.exists("onStepHit"))
            newStage.get("onStepHit")(curStep);
    
    public function onBeatHit(curBeat : Int)
        if (newStage != null && newStage.exists("onBeatHit"))
            newStage.get("onBeatHit")(curBeat);
    public function onStartCountdown()
        if (newStage != null && newStage.exists("onStartCountdown"))
            newStage.get("onStartCountdown")();
    public function onSongStart()
        if (newStage != null && newStage.exists("onSongStart"))
            newStage.get("onSongStart")();
    public function onEndSong()
        if (newStage != null && newStage.exists("onEndSong"))
            newStage.get("onEndSong")();
    public function onPause()
        if (newStage != null && newStage.exists("onPause"))
            newStage.get("onPause")();
    public function onResume()
        if (newStage != null && newStage.exists("onResume"))
            newStage.get("onResume")();
    public function onGameOver()
        if (newStage != null && newStage.exists("onGameOver"))
            newStage.get("onGameOver")();
    public function onMoveCamera(focus : String)
        if (newStage != null && newStage.exists("onMoveCamera"))
            newStage.get("onMoveCamera")(focus);
    public function onCountdownTick(counter : Int)
        if (newStage != null && newStage.exists("onCountdownTick"))
            newStage.get("onCountdownTick")(counter);
}
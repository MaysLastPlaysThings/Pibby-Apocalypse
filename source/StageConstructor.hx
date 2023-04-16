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

@:enum abstract AssetType(String) to String {
    var IMAGE = 'image';
    var SOUND = 'sound';
}

class StageConstructor extends FlxTypedGroup<FlxBasic>
{
    // Attach some metadata to the new Stage
    var newStage : Script;
    var foreground : FlxTypedGroup<FlxBasic>;


    // Incase you aren't aware already of what this is gonna do, its basically just gonna allow for hscript functionality with stages lol.
    public function new(currentStage : String)
    {
        super();

        foreground = new FlxTypedGroup<FlxBasic>();

        var additionalParams : StringMap<Dynamic> = new StringMap<Dynamic>();
        additionalParams.set('add', add);
        additionalParams.set('stage', this);
        additionalParams.set('foreground', foreground);
        additionalParams.set('PlayState', PlayState);
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

        newStage = ScriptManager.loadScript('assets/stages/${currentStage}/stage.hxs', null, additionalParams);

        if (newStage != null)
            newStage.get("onCreate")();
    }

    override function update(elapsed:Float) 
        {
            super.update(elapsed);
            if (newStage.exists("onUpdate"))
                newStage.get("onUpdate")(elapsed);
        }

    public function onStep(curStep : Int)
        if (newStage.exists("onStep"))
            newStage.get("onStep")(curStep);
    
    public function onBeat(curBeat : Int)
        if (newStage.exists("onBeat"))
            newStage.get("onBeat")(curBeat);
    
}
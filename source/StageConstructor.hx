package;

import haxe.ds.StringMap;
import HScript.Script;
import HScript.ScriptManager;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;

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
        additionalParams.set('retrieveAsset', function(path : String) {
            return 'assets/stages/${currentStage}/${path}';
        });

        newStage = ScriptManager.loadScript('assets/stages/${currentStage}/${currentStage}.hxs', null, additionalParams);

        if (newStage != null)
            newStage.get("onCreate")();
    }

    override function update(elapsed : Float) 
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
package;

import flixel.text.FlxText;
import openfl.Assets;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.addons.text.FlxTypeText;
import flixel.FlxG;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

#if VIDEOS_ALLOWED
import hxcodec.VideoHandler;
import hxcodec.VideoSprite;
#end

using StringTools;

class CheatingState extends MusicBeatState
{
    public var inCutscene:Bool = false;

    override public function create() 
    {
        trace('cheating moment');

        startVideo('Cheating_is_a_sin');

        super.create();   
    }

	public function startVideo(name:String)
        {
            #if VIDEOS_ALLOWED
            inCutscene = true;
    
            var filepath:String = Paths.video(name);
      
            if(!FileSystem.exists(filepath))
            {
                FlxG.log.warn('Couldnt find video file: ' + name);
                MusicBeatState.switchState(new FreeplayState());
                return;
            }

            var video:VideoHandler = new VideoHandler();
            video.playVideo(filepath);
            video.finishCallback = function()
            {
                //#if windows
                lime.app.Application.current.window.alert('Our game, our rules\n- Finn', 'Cheating is not allowed!');
                Sys.exit(1);
                //#end

                return;
            }
            #else
            FlxG.log.warn('Platform not supported!');
            MusicBeatState.switchState(new FreeplayState());
            return;
            #end
        }
}

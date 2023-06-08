package;

#if sys
import sys.io.File;
#end

import lime.utils.Assets;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;
using flixel.util.FlxSpriteUtil;

class TitleCard extends FlxSpriteGroup
{
    
    var size:Float = 0;
    var fontSize:Int = 24;

    public function new(_x:Float, _y:Float, _song:String, ?_num:Int = -1)
        {
            super(_x, _y);

            var songColor:FlxColor;
            songColor = FlxColor.fromRGB(178, 241, 255);

            var songOutline:FlxColor;
            songOutline = FlxColor.fromRGB(229, 117, 255);

            var addToPath = "";
            if (_num != -1)
            {
                addToPath = "" + _num;
            }

            var pulledText:String = Assets.getText(Paths.txt(_song.replace(' ', '-') + "/info" + addToPath));
            pulledText += '\n';
            var splitText:Array<String> = [];

            splitText = pulledText.split('\n');
            splitText.resize(5);
            

            var songTxt:FlxText = new FlxText(0, 0, 0, "", 32);
            songTxt.screenCenter();
            songTxt.setFormat(Paths.font("pibby.ttf"), 32, songColor, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, songOutline);

            var infoTxt1:FlxText = new FlxText(0, 30, 0, "", 24);
            infoTxt1.setFormat(Paths.font("pibby.ttf"), 24, songColor, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, songOutline);

            var infoTxt2:FlxText = new FlxText(0, 60, 0, "", 24);
            infoTxt2.setFormat(Paths.font("pibby.ttf"), 24, songColor, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, songOutline);

            var infoTxt3:FlxText = new FlxText(0, 90, 0, "", 24);
            infoTxt3.setFormat(Paths.font("pibby.ttf"), 24, songColor, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, songOutline);

            var infoTxt4:FlxText = new FlxText(0, 120, 0, "", 24);
            infoTxt4.setFormat(Paths.font("pibby.ttf"), 24, songColor, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, songOutline);
        

            songTxt.text = splitText[0];
            infoTxt1.text = splitText[1];
            infoTxt2.text = splitText[2];
            infoTxt3.text = splitText[3];
            infoTxt4.text = splitText[4];

            trace(songTxt.text);
    
            songTxt.updateHitbox();
            infoTxt1.updateHitbox();
            infoTxt2.updateHitbox();
            infoTxt3.updateHitbox();
            infoTxt4.updateHitbox();
    
            size = infoTxt1.fieldWidth;


            var bg = new FlxSprite(fontSize/-2, fontSize/-2).makeGraphic(Math.floor(size + 24), Std.int(songTxt.height + infoTxt1.height + infoTxt2.height + infoTxt3.height + infoTxt4.height + 15), FlxColor.BLACK);
            bg.height = songTxt.height + infoTxt1.height + infoTxt2.height + infoTxt3.height + infoTxt4.height;
            bg.alpha = 0.47;

            
            songTxt.text += "\n";
            infoTxt1.text += "\n";
            infoTxt2.text += "\n";
            infoTxt3.text += "\n";
    
    
            add(bg);
            add(songTxt);
            add(infoTxt1);
            add(infoTxt2);
            add(infoTxt3);
            add(infoTxt4);
    
    
            x -= size;
            visible = false;

        }

    public function start()
        {
            alpha = 1;

            FlxTween.tween(this, {x: x + size + (24 / 2)}, 1, {ease: FlxEase.quintInOut, onComplete: function(twn:FlxTween) {
                FlxTween.tween(this, {x: x - size - 50}, 1, {ease: FlxEase.quintInOut, startDelay: 2, onComplete: function(twn:FlxTween) { 
                    this.destroy(); 
                }});
            }});
        }
}
package;

import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import lime.app.Application;
import flixel.ui.FlxBar;
import haxe.Json;
import flixel.util.FlxCollision;
#if windows
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception; //funi
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if (cpp && mobile)
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
#end
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;

// don't ask is just for path reasons
enum PreloadType {
    atlas;
    image;
    imagealt;
    music;
    actualmusic;
    actualmusicalt;
    charXML;
    sound;
    soundalt;
}

class LoadingStuffLmao extends MusicBeatState {    
    //var loadText:FlxText;
    var loadBar:FlxBar;

    public var isMenu:Bool = false; // for reasons

    var assetStack:Map<Dynamic, PreloadType> = [
        //Preload UI stuff
        'healthBar' => PreloadType.image,
        'spotlight' => PreloadType.image,
        'timeBar' => PreloadType.image,
        'smoke' => PreloadType.image,
        'healthbar/iconbar' => PreloadType.image,

        //Icons cause why not?
        'icons/icon-zero' => PreloadType.imagealt,
        'icons/icon-bf' => PreloadType.imagealt,
        'icons/icon-gf' => PreloadType.imagealt,
        'icons/icon-pibby' => PreloadType.imagealt,
        'icons/icon-jake' => PreloadType.imagealt,
        'icons/icon-finn' => PreloadType.imagealt,
        'icons/icon-gumball' => PreloadType.imagealt,
        'icons/icon-gumball_fake' => PreloadType.imagealt,
        'icons/icon-darwin' => PreloadType.imagealt,
        'icons/icon-finnbad' => PreloadType.imagealt,

        //Preload assets for better loading time
        'go' => PreloadType.image, 
        'ready' => PreloadType.image, 
        'set' => PreloadType.image,  
        'shit' => PreloadType.image, 
        'eventArrow' => PreloadType.image,  
        'good' => PreloadType.image,  
        'sick' => PreloadType.image,   
        'cnlogo' => PreloadType.image, 
        'gradient' => PreloadType.image,  
        'noherocutscenefirst' => PreloadType.image,      

        //Preload the entire character roster ig
        'bf' => PreloadType.atlas,
        'bf-dead' => PreloadType.atlas,
        'bfsword' => PreloadType.atlas,
        'finn-hurting' => PreloadType.atlas,
        'finn-sword-sha' => PreloadType.atlas,
        'jake' => PreloadType.atlas,
        'finncawm_reveal' => PreloadType.atlas,
        'finnanimstuff' => PreloadType.atlas,
        'finncawm_start_new' => PreloadType.atlas,
        'bf_intro' => PreloadType.atlas,
        'bfcawm' => PreloadType.atlas,
        'bf-dead-finn' => PreloadType.atlas,
        'bf-dead-jake' => PreloadType.atlas,
        'bffinndeath' => PreloadType.atlas,
        'cumball' => PreloadType.atlas, // the name.....
        'darwin' => PreloadType.atlas,
        'darwinfw' => PreloadType.atlas,
        'darwinretcon' => PreloadType.atlas,
        'finncawm' => PreloadType.atlas,
        'finncawm2' => PreloadType.atlas,
        'finn-open' => PreloadType.atlas,
        'finn-open2' => PreloadType.atlas,
        'finn-R' => PreloadType.atlas,
        'finn-slash' => PreloadType.atlas,
        'finn-sus' => PreloadType.atlas,
        'finn-sword' => PreloadType.atlas,
        'gf' => PreloadType.atlas,
        'gumball' => PreloadType.atlas,
        'newbf' => PreloadType.atlas,
        'num_intro' => PreloadType.atlas,
        'pibby_intro' => PreloadType.atlas,
        'pibbyP1' => PreloadType.atlas,
        'pibby-sus' => PreloadType.atlas,
        'falsefinn' => PreloadType.atlas,
        'noherofinn' => PreloadType.atlas,

        //Preload character PNG and XML
        'BOYFRIEND' => PreloadType.charXML,
        'BOYFRIEND_DEAD' => PreloadType.charXML,
        'GF_assets' => PreloadType.charXML,
        'BFSwordUp' => PreloadType.charXML,
        'Finn-hurting' => PreloadType.charXML,
        'Jake' => PreloadType.charXML,
        'Fake_Finn' => PreloadType.charXML,
        'finn_reveal' => PreloadType.charXML,
        'FinnAnim' => PreloadType.charXML,
        'bfdeathfinn' => PreloadType.charXML,
        'bfjakedeath' => PreloadType.charXML,
        'cartoon_bf_Gun' => PreloadType.charXML,
        'COME_ALONG_BF' => PreloadType.charXML,
        'COME_ALONG_Finn' => PreloadType.charXML,
        'Cumball' => PreloadType.charXML,
        'Darwin' => PreloadType.charXML,
        'Darwind' => PreloadType.charXML,
        'darwin-fw' => PreloadType.charXML,
        'darwin-noremote' => PreloadType.charXML,
        'Finn_Transformation' => PreloadType.charXML,
        'Finn-CN' => PreloadType.charXML,
        'Finn-Impostor' => PreloadType.charXML,
        'Finn-Slash' => PreloadType.charXML,
        'Finn-sword' => PreloadType.charXML,
        'Finn-sword-shader' => PreloadType.charXML,
        'pibby' => PreloadType.charXML,
        'Pibby_Intro' => PreloadType.charXML,
        'Pibby-tripulannt' => PreloadType.charXML,
        'BF-Intro' => PreloadType.charXML,
        'CAWM_FINN' => PreloadType.charXML,
        'assbf' => PreloadType.charXML,
        'finnfalse' => PreloadType.charXML,
        'midfin' => PreloadType.charXML,
        'badfinn' => PreloadType.charXML,

        //Menu stuff
        'pibymenu/BACKGROUND' => PreloadType.atlas,
        'pibymenu/discord' => PreloadType.imagealt,
        'pibymenu/Options' => PreloadType.imagealt,

        //songs
        'My-Amazing-World' => PreloadType.music,
        'No-Hero-Remix' => PreloadType.music,
        'Brotherly-Love' => PreloadType.music,
        'Suffering-Siblings' => PreloadType.music,
        'Blessed-By-Swords' => PreloadType.music,
        'Childs-Play' => PreloadType.music,
        'Come-Along-With-Me' => PreloadType.music,
        'Forgotten-World' => PreloadType.music,
        'Mindless' => PreloadType.music,
        'Retcon' => PreloadType.music,

        // sounds
        'confirmMenu' => PreloadType.sound,
        'cancelMenu' => PreloadType.sound,
        'scrollMenu' => PreloadType.sound,
        'missnote1' => PreloadType.soundalt,
        'missnote2' => PreloadType.soundalt,
        'missnote3' => PreloadType.soundalt,
        'intro1' => PreloadType.soundalt,
        'intro2' => PreloadType.soundalt,
        'intro3' => PreloadType.soundalt,
        'introGo' => PreloadType.soundalt,
        'hitsound' => PreloadType.soundalt,
        'Metronome_Tick' => PreloadType.soundalt,
        'fnf_loss_sfx' => PreloadType.soundalt,
        'clickText' => PreloadType.soundalt,
        'dialogue' => PreloadType.soundalt,

        // music but they not the songs
        'freakyMenu_1' => PreloadType.actualmusicalt,
        'freakyMenu_2' => PreloadType.actualmusicalt,
        'offsetSong' => PreloadType.actualmusicalt,
        'breakfast' => PreloadType.actualmusic,
        'gameOver' => PreloadType.actualmusic,
        'gameOverEnd' => PreloadType.actualmusic,
        'tea-time' => PreloadType.actualmusic,
        'fpmenu' => PreloadType.actualmusic,
        'creditsmenu' => PreloadType.actualmusic,

        // freeplay
        'fpmenu/arrowL' => imagealt,
        'fpmenu/arrowR' => imagealt,
        'fpmenu/arrows' => imagealt,
        'fpmenu/background' => imagealt,
        'fpmenu/stageBox' => imagealt,
        'fpmenu/threatBarBG' => imagealt,
        'fpmenu/threatLevel' => imagealt,
        'fpmenu/stage/Blessed by Swords' => imagealt,
        'fpmenu/stage/Brotherly Love' => imagealt,
        "fpmenu/stage/Child's Play" => imagealt,
        'fpmenu/stage/Come Along With Me' => imagealt,
        'fpmenu/stage/Forgotten World' => imagealt,
        'fpmenu/stage/Mindless' => imagealt,
        'fpmenu/stage/My Amazing World' => imagealt,
        'fpmenu/stage/Retcon' => imagealt,
        'fpmenu/stage/Suffering Siblings' => imagealt,
    ];
    var maxCount:Int;

    public static var preloadedAssets:Map<String, FlxGraphic>;
    //var backgroundGroup:FlxTypedGroup<FlxSprite>;
    var bg:FlxSprite;

    public var newClass:Any;

    public function new(?e:Bool = false, ?switchClass:FlxState)
        {
            this.isMenu = e;
            this.newClass = switchClass;

            super();
        }

    override public function create() {
        super.create();

        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;

        FlxG.camera.alpha = 0;

        maxCount = Lambda.count(assetStack);
        trace(maxCount);
        FlxG.mouse.visible = false;

        FlxG.autoPause = false;

        preloadedAssets = new Map<String, FlxGraphic>();

        bg = new FlxSprite().loadGraphic(Paths.image('loading/loading'+FlxG.random.int(1,2)));
		bg.screenCenter(X);
		add(bg);

        FlxTween.tween(bg, {alpha: 1}, 1.5, {ease: FlxEase.expoOut});

        // new FlxTimer().start(2, e->refresh(folderLength.length), 0);
    
        FlxTween.tween(FlxG.camera, {alpha: 1}, 0.5, {
            onComplete: function(tween:FlxTween){
                Thread.create(function(){
                    assetGenerate();
                });
            }
        });

        //loadText = new FlxText(FlxG.width/3, FlxG.height - 170, 1000, 'LOADING!');
        //loadText.setFormat(Paths.font("menuBUTTONS.ttf"), 58, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        //loadText.autoSize = false;
        //loadText.alignment = FlxTextAlign.CENTER;
        //loadText.screenCenter(X);
        //loadText.antialiasing = ClientPrefs.globalAntialiasing;
        //add(loadText);
        //loadText.alpha = 1;

        loadBar = new FlxBar(0, 960 - 20, LEFT_TO_RIGHT, 1280, 20, this,
        'storedPercentage', 0, 1);
        loadBar.alpha = 0;
        loadBar.createFilledBar(0xFF2E2E2E, FlxColor.WHITE);
        add(loadBar);

        //FlxTween.tween(loadText, {alpha: 1}, 0.5, {startDelay: 0.5});
        FlxTween.tween(loadBar, {alpha: 1, y: 960 - 20}, 0.5, {startDelay: 0.5});
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }

    var isRefreshing:Bool = false;

    var storedPercentage:Float = 0;

    function assetGenerate() {
        //
        var countUp:Int = 0;
        for (i in assetStack.keys()) {
            trace('calling asset $i');

            FlxGraphic.defaultPersist = true;
            switch(assetStack[i]) {
                case PreloadType.imagealt:
                    var menuShit:FlxGraphic = FlxG.bitmap.add(Paths.image(i));
                    preloadedAssets.set(i, menuShit);
                    trace('menu asset is loaded');

                case PreloadType.image:
                    var savedGraphic:FlxGraphic = FlxG.bitmap.add(Paths.image(i, 'shared'));
                    preloadedAssets.set(i, savedGraphic);
                    trace(savedGraphic + ', yeah its working');

                case PreloadType.charXML:
                    var savedGraphic:FlxGraphic = FlxG.bitmap.add(Paths.image('characters/$i', 'shared'));
                    var otherGraphic:FlxGraphic = FlxG.bitmap.add(Paths.xml('characters/$i', 'shared'));
                    preloadedAssets.set(i, savedGraphic);
                    preloadedAssets.set(i, otherGraphic);
                    trace(savedGraphic + ', yeah its working');
                    trace(otherGraphic + ', yeah its working too');


                case PreloadType.atlas:
                    var preloadedCharacter:Character = new Character(FlxG.width / 2, FlxG.height / 2, i);
                    preloadedCharacter.visible = false;
                    add(preloadedCharacter);
                    trace('character loaded ${preloadedCharacter.frames}');

                case PreloadType.music:
                    var savedInst:FlxGraphic = FlxG.bitmap.add(Paths.inst(i));
                    var savedVocals:FlxGraphic = FlxG.bitmap.add(Paths.voices(i));
                    preloadedAssets.set(i, savedInst);
                    preloadedAssets.set(i, savedVocals);
                    trace('loaded vocals of $savedVocals');
                    trace('loaded instrumental of $savedInst');

                case PreloadType.sound:
                    var savedSound:FlxGraphic = FlxG.bitmap.add('assets/preload/sounds/$i.${Paths.SOUND_EXT}');
                    preloadedAssets.set(i, savedSound);
                    trace('loaded sound (default) $savedSound');

                case PreloadType.soundalt:
                    var savedSound:FlxGraphic = FlxG.bitmap.add('assets/shared/sounds/$i.${Paths.SOUND_EXT}');
                    preloadedAssets.set(i, savedSound);
                    trace('loaded sound (shared folder) $savedSound');

                case PreloadType.actualmusic:
                    var savedSound:FlxGraphic = FlxG.bitmap.add('assets/shared/music/$i.${Paths.SOUND_EXT}');
                    preloadedAssets.set(i, savedSound);
                    trace('loaded ACTUAL music (shared folder) $savedSound');

                case PreloadType.actualmusicalt:
                    var savedSound:FlxGraphic = FlxG.bitmap.add('assets/preload/music/$i.${Paths.SOUND_EXT}');
                    preloadedAssets.set(i, savedSound);
                    trace('loaded music (preload folder) $savedSound');
            }
            FlxGraphic.defaultPersist = false;

            //loadText.text = 'LOADING: ${Highscore.floorDecimal(storedPercentage * 100, 2)}%';

            FlxG.stage.window.title = 'Pibby: Apocalypse - Loading... ${Highscore.floorDecimal(storedPercentage * 100, 2)}%';
        
            countUp++;
            storedPercentage = countUp/maxCount;
            if(countUp == maxCount)
            {
                //loadText.text = 'LOADING: 100.00%'; // its actually at 100% is just a bug i swear
                FlxG.stage.window.title = 'Pibby: Apocalypse - Done!';
            }
        }

        ///*
        FlxTween.tween(FlxG.camera, {alpha: 0}, 0.5, {startDelay: 1,
            onComplete: function(tween:FlxTween){
                    MusicBeatState.switchState(isMenu ? newClass : new TitleState());
            }});
            }
        }
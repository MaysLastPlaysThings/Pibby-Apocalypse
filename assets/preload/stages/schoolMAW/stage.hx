var background;
var wall;
var vignette;
var vignette2;
var light;
var ch1;
var ch2;
var ch3;

// the thingies that yeah they cool totally 102%
var daGloop;
var daGloop2;
var daGloop3;
var daGloop4;
var daGloop5;

//PENNY MY BELOVED - schweizer
var penny;

// SHADERS GRAH!!!!!! - jason 
var pixel;

var void;
var house;
var rock;
var rock2;
var rock3;
var rock4;
var wtf;
var glitch;
var stupidFix;

var charColors = [0xff969494, 0xBFE5BA]; // default, glitch part
var houseColors = [0x8f8f8f, 0x9ADA91]; // also with rock3 and rock4
var rockColors = [0xbababa, 0xB8D4B5]; // only for the rock the characters are on
var coolThingColors = [0xc4c0c0, 0xC1CEAA]; // wtf - forgor, 2023

function onCreate()
{
    pixel = new FlxRuntimeShader(RuntimeShaders.pixel, null, 100);
    pixel.setFloat('size', 10);

    background = new flixel.FlxSprite(0, 0);
    background.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-1', 'image'));
    background.setGraphicSize(Std.int(background.width * 1.3));
    background.antialiasing = ClientPrefs.globalAntialiasing;
    background.scrollFactor.set(1, 1);
    background.updateHitbox();

    wall = new flixel.FlxSprite(-200, 200);
    wall.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-2', 'image'));
    wall.setGraphicSize(Std.int(wall.width * 1.1));
    wall.antialiasing = ClientPrefs.globalAntialiasing;
    wall.scrollFactor.set(1, 1);
    wall.updateHitbox();

    ch1 = new flixel.FlxSprite(100, 150);
    ch1.loadGraphic(retrieveAsset('images/channels/chn1', 'image'));
    ch1.setGraphicSize(Std.int(ch1.width * 1));
    ch1.antialiasing = ClientPrefs.globalAntialiasing;
    ch1.scrollFactor.set(1, 1);
    ch1.updateHitbox();

    ch2 = new flixel.FlxSprite(125, -20);
    ch2.loadGraphic(retrieveAsset('images/channels/chn2', 'image'));
    ch2.setGraphicSize(Std.int(ch2.width * 1));
    ch2.antialiasing = ClientPrefs.globalAntialiasing;
    ch2.scrollFactor.set(1, 1);
    ch2.updateHitbox();

    ch3 = new flixel.FlxSprite(100, 150);
    ch3.loadGraphic(retrieveAsset('images/channels/chn3', 'image'));
    ch3.setGraphicSize(Std.int(ch1.width * 1));
    ch3.antialiasing = ClientPrefs.globalAntialiasing;
    ch3.scrollFactor.set(1, 1);
    ch3.updateHitbox();
    ch3.scale.x += 0.2; // just in case....

    if (!ClientPrefs.lowQuality)
    {
        daGloop = new flixel.FlxSprite();
        daGloop.x = 50;
        daGloop.y = 110;
        daGloop.scale.set(1.5, 1.5);
        daGloop.frames = retrieveAsset('images/topgoop', 'atlas');
        daGloop.animation.addByPrefix('topey', 'gooey', 24, false);
        if (ClientPrefs.shaders) daGloop.shader = pixel;

        daGloop2 = new flixel.FlxSprite();
        daGloop2.x = 1450;
        daGloop2.y = 110;
        daGloop2.scale.set(1.5, 1.5);
        daGloop2.frames = retrieveAsset('images/secondtopgoop', 'atlas');
        daGloop2.animation.addByPrefix('topey2', 'gooey', 24, false);
        if (ClientPrefs.shaders) daGloop2.shader = pixel;

        daGloop4 = new flixel.FlxSprite();
        daGloop4.x = 910;
        daGloop4.y = 300;
        daGloop4.scale.set(1.7, 1.7);
        daGloop4.frames = retrieveAsset('images/droplet', 'atlas');
        daGloop4.animation.addByPrefix('dropey', 'gooey', 24, false);
        if (ClientPrefs.shaders) daGloop4.shader = pixel;

        daGloop5 = new flixel.FlxSprite();
        daGloop5.x = 715;
        daGloop5.y = 595;
        daGloop5.scale.set(1.7, 1.7);
        daGloop5.frames = retrieveAsset('images/sinkgoop', 'atlas');
        daGloop5.animation.addByPrefix('sinkey', 'gooey', 24, false);
        if (ClientPrefs.shaders) daGloop5.shader = pixel;

        penny = new flixel.FlxSprite();
        penny.x = 800;
        penny.y = 220;
        penny.scale.set(1.3, 1.3);
        penny.frames = retrieveAsset('images/penny', 'atlas');
        penny.animation.addByPrefix('idle', 'idle', 6, true);

        light = new flixel.FlxSprite(-500, 50);
        light.loadGraphic(retrieveAsset('images/light', 'image'));
        light.setGraphicSize(Std.int(light.width * 1));
        light.antialiasing = ClientPrefs.globalAntialiasing;
        light.scrollFactor.set(1, 1);
        light.updateHitbox();

        vignette = new flixel.FlxSprite(0, 0);
        vignette.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-3', 'image'));
        vignette.setGraphicSize(Std.int(vignette.width * 1.3));
        vignette.antialiasing = ClientPrefs.globalAntialiasing;
        vignette.scrollFactor.set(1, 1);
        vignette.updateHitbox();

        vignette2 = new flixel.FlxSprite(0, 0);
        vignette2.loadGraphic(retrieveAsset('images/188_sin_titulo11_20230523094718', 'image'));
        vignette2.setGraphicSize(Std.int(vignette2.width * 1.3));
        vignette2.antialiasing = ClientPrefs.globalAntialiasing;
        vignette2.scrollFactor.set(1, 1);
        vignette2.updateHitbox();
    }

    void = new flixel.FlxSprite(0, -200);
    void.frames = retrieveAsset('images/void/void', 'atlas');
    void.animation.addByPrefix('idle', 'idle', 24, true);
    void.animation.play('idle');
    void.setGraphicSize(Std.int(void.width * 1.7));
    void.antialiasing = ClientPrefs.globalAntialiasing;
    void.scrollFactor.set(0.6, 0.6);
    void.updateHitbox();
    add(void);

    house = new flixel.FlxSprite(0, -200);
    house.loadGraphic(retrieveAsset('images/void/Ilustracion_sin_titulo-2', 'image'));
    house.setGraphicSize(Std.int(house.width * 2.5));
    house.antialiasing = ClientPrefs.globalAntialiasing;
    house.scrollFactor.set(0.85, 0.85);
    house.updateHitbox();
    house.color = houseColors[0];

    rock = new flixel.FlxSprite(0, -200);
    rock.loadGraphic(retrieveAsset('images/void/Ilustracion_sin_titulo-3', 'image'));
    rock.setGraphicSize(Std.int(rock.width * 2.5));
    rock.antialiasing = ClientPrefs.globalAntialiasing;
    rock.scrollFactor.set(1, 1);
    rock.updateHitbox();
    rock.color = rockColors[0];

    if (!ClientPrefs.lowQuality)
    {
        rock2 = new flixel.FlxSprite(0, -200);
        rock2.loadGraphic(retrieveAsset('images/void/Ilustracion_sin_titulo-4', 'image'));
        rock2.setGraphicSize(Std.int(rock2.width * 2.5));
        rock2.antialiasing = ClientPrefs.globalAntialiasing;
        rock2.scrollFactor.set(1.1, 1.1);
        rock2.updateHitbox();

        rock3 = new flixel.FlxSprite(0, -200);
        rock3.loadGraphic(retrieveAsset('images/void/Ilustracion_sin_titulo-5', 'image'));
        rock3.setGraphicSize(Std.int(rock3.width * 2.5));
        rock3.antialiasing = ClientPrefs.globalAntialiasing;
        rock3.scrollFactor.set(0.9, 0.9);
        rock3.updateHitbox();
        rock3.color = houseColors[0];

        rock4 = new flixel.FlxSprite(0, -200);
        rock4.loadGraphic(retrieveAsset('images/void/Ilustracion_sin_titulo-6', 'image'));
        rock4.setGraphicSize(Std.int(rock4.width * 2.5));
        rock4.antialiasing = ClientPrefs.globalAntialiasing;
        rock4.scrollFactor.set(0.85, 0.85);
        rock4.updateHitbox();
        rock4.color = houseColors[0];

        wtf = new flixel.FlxSprite(0, -200);
        wtf.loadGraphic(retrieveAsset('images/void/Ilustracion_sin_titulo-7', 'image'));
        wtf.setGraphicSize(Std.int(wtf.width * 2.5));
        wtf.antialiasing = ClientPrefs.globalAntialiasing;
        wtf.scrollFactor.set(1, 1);
        wtf.updateHitbox();
        wtf.color = coolThingColors[0];
    }

    tweenLoopAngle(house, 4, -4, 6, 6);
    if (!ClientPrefs.lowQuality) tweenLoopAngle(rock, -0.5, 0.5, 2.5, 2.5);
    if (!ClientPrefs.lowQuality) tweenLoopAngle(rock2, -2, 1.2, 2.5, 2.5);
    if (!ClientPrefs.lowQuality) tweenLoopAngle(rock3, 360, 0, 30, 30);
    if (!ClientPrefs.lowQuality) tweenLoopAngle(wtf, 2, -2, 5, 5);

    if (!ClientPrefs.lowQuality) 
    {
        FlxTween.tween(rock4, {angle: 360}, 30, {
        ease: FlxEase.sineInOut
        });
    }

    if (!ClientPrefs.lowQuality) stupidFix = FlxTween.tween(wtf, {y: wtf.y}, 1);

    add(background);
    if (!ClientPrefs.lowQuality) add(daGloop5);
    if (!ClientPrefs.lowQuality) add(daGloop4);
    if (!ClientPrefs.lowQuality) add(penny);
    if (!ClientPrefs.lowQuality) foreground.add(wall);
    if (!ClientPrefs.lowQuality) foreground.add(daGloop);
    if (!ClientPrefs.lowQuality) foreground.add(daGloop2);
    if (!ClientPrefs.lowQuality) foreground.add(vignette);
    if (!ClientPrefs.lowQuality) foreground.add(vignette2);
    if (!ClientPrefs.lowQuality) foreground.add(light);

}

function onSongStart()
{
    PlayState.camZooming = true;
}

function onMoveCamera(focus:String)
    {
        if (focus == 'dad')
            PlayState.defaultCamZoom = 1.2;
        else
            PlayState.defaultCamZoom = 0.9;
    }

function onEvent(event:String, value1:String, value2:String)
    {
     if (event == 'Apple Filter')
        {
             if (value1 == 'on') 
            {
                if (!ClientPrefs.lowQuality) wall.alpha = 0.0001;
                if (!ClientPrefs.lowQuality) vignette2.alpha = 0.0001; 
                if (!ClientPrefs.lowQuality) vignette.alpha = 0.0001; 
                if (!ClientPrefs.lowQuality) light.alpha = 0.0001; 
                if (!ClientPrefs.lowQuality) daGloop.alpha = 0.0001;
                if (!ClientPrefs.lowQuality) daGloop2.alpha = 0.0001;
            }
             else if (value1 == 'off')
            {
                if (!ClientPrefs.lowQuality) wall.alpha = 1;
                if (!ClientPrefs.lowQuality) vignette2.alpha = 1;
                if (!ClientPrefs.lowQuality) vignette.alpha = 1;
                if (!ClientPrefs.lowQuality) light.alpha = 1;
                if (!ClientPrefs.lowQuality) daGloop.alpha = 1;
                if (!ClientPrefs.lowQuality) daGloop2.alpha = 1;
            }
        }
    }

function onSongStart()
    {
                PlayState.dad.x = 300;
                PlayState.dad.y = 450;
    }

function onStepHit(curStep:Int)
    {
        if (curStep == 2144)
            {
                PlayState.triggerEventNote('Camera Follow Pos', '940', '720');
                if (!ClientPrefs.lowQuality) wall.visible = false;
                if (!ClientPrefs.lowQuality) vignette2.visible = false; 
                if (!ClientPrefs.lowQuality) vignette.visible = false;
                background.visible = false;
                if (!ClientPrefs.lowQuality) light.visible = false;
                if (!ClientPrefs.lowQuality) daGloop5.visible = false;
                if (!ClientPrefs.lowQuality) daGloop4.visible = false;
                if (!ClientPrefs.lowQuality) daGloop2.visible = false;
                if (!ClientPrefs.lowQuality) daGloop.visible = false;
                if (!ClientPrefs.lowQuality) penny.visible = false;
                add(ch1);
                PlayState.gf.y = 720;
            }
        if (curStep == 2176)
            {
                ch1.visible = false;
                add(ch2);
            }
        if (curStep == 2208)
            {
                ch2.visible = false;
                add(ch3);
            }
        if (curStep == 2272)
            {
                ch3.visible = false;
                ch1.visible = true;
            }
        if (curStep == 2304)
            {
                ch1.visible = false;
                ch2.visible = true;
            }
        if (curStep == 2336)
            {
                ch2.visible = false;
                ch3.visible = true;
            }
        if (curStep == 2400)
            {
                ch3.visible = false;
                ch1.visible = true;
            }
        if (curStep == 2432)
            {
                ch1.visible = false;
                ch2.visible = true;
            }
        if (curStep == 2464)
            {
                ch2.visible = false;
                ch3.visible = true;
            }
        if (curStep == 2528)
            {
                ch3.visible = false;
                ch1.visible = true;
            }
        if (curStep == 2560)
            {
                ch1.visible = false;
                ch2.visible = true;
            }
        if (curStep == 2592)
            {
                ch2.visible = false;
                ch3.visible = true;
            }
        if (curStep == 2604)
            {
                ch3.visible = false;
                ch1.visible = true;
            }
        if (curStep == 2624)
            {
                ch1.visible = false;
                ch2.visible = true;
            }
        if (curStep == 2632)
            {
                ch2.visible = false;
                ch3.visible = true;
            }
        if (curStep == 2640)
            {
                ch3.visible = false;
                ch1.visible = true;
            }
        if (curStep == 2648)
            {
                ch1.visible = false;
                ch2.visible = true;
            }
        if (curStep == 2656)
            {
                PlayState.triggerEventNote('Camera Follow Pos', '', '');
                ch2.visible = false;
                ch3.visible = true;
            }
        if (curStep == 2688)
            {
                add(void);
                add(glitch);
                if (!ClientPrefs.lowQuality) add(rock4);
                if (!ClientPrefs.lowQuality) add(rock3);
                if (!ClientPrefs.lowQuality) add(rock2);
                add(house);
                add(rock);
                if (!ClientPrefs.lowQuality) add(wtf);

                ch1.visible = false;
                ch2.visible = false;
                ch3.visible = false;
                PlayState.gf.x = 1670;
                PlayState.gf.y = 900;
                PlayState.dad.x = 900;
                PlayState.dad.y = 740;
                PlayState.boyfriend.x = 1570;
                PlayState.boyfriend.y = 800;
                PlayState.boyfriend.color = charColors[0];
                PlayState.dad.color = charColors[0];
                PlayState.gf.color = charColors[0];
            }
    }

function tweenLoopAngle(varx, distance1, distance2, duration1, duration2) {
    FlxTween.tween(varx, {angle: distance1}, duration1, {
        ease: FlxEase.sineInOut,
        onComplete: 
        function (twn:FlxTween)
            {
                FlxTween.tween(varx, {angle: distance2}, duration2, {
                    ease: FlxEase.sineInOut,
                    onComplete: 
                    function (twn:FlxTween)
                        {
                            tweenLoopAngle(varx, distance1, distance2, duration1, duration2);
                        }
                });
            }
    });
}

function onPause() {
    if (!ClientPrefs.lowQuality) stupidFix.active = false;
}

function onResume() {
    if (!ClientPrefs.lowQuality) stupidFix.active = true;
}

//thanks for da code
function onBeatHit(curBeat:Int)
    {
        if (curBeat % 1 == 0)
            doGoo();
        if (curBeat % 1 == 0)
            ponny();
    }


function doGoo()
    {
        if (!ClientPrefs.lowQuality) daGloop5.animation.play('sinkey');
        if (!ClientPrefs.lowQuality) daGloop4.animation.play('dropey');
        if (!ClientPrefs.lowQuality) daGloop2.animation.play('topey2');
        if (!ClientPrefs.lowQuality) daGloop.animation.play('topey');
    }

function ponny()
    {
        if (!ClientPrefs.lowQuality) penny.animation.play('idle');
    }
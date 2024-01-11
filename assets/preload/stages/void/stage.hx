var velocityShitHehe = 1;

// making them variables so its less confusing and stuff 
var charColors = [0xff969494, 0xFFBFE5BA]; // default, glitch part
var houseColors = [0xFF8f8f8f, 0xFF9ADA91]; // also with rock3 and rock4
var rockColors = [0xFFbababa, 0xFFB8D4B5]; // only for the rock the characters are on
var coolThingColors = [0xFFc4c0c0, 0xFFC1CEAA]; // wtf - forgor, 2023

function onCreate()
{
    void = new flixel.FlxSprite(-80, -200);
    void.frames = retrieveAsset('images/void', 'atlas');
    void.animation.addByPrefix('idle', 'idle', 24, true);
    void.animation.play('idle');
    void.setGraphicSize(Std.int(void.width * 1.7));
    void.antialiasing = ClientPrefs.globalAntialiasing;
    void.scrollFactor.set(0.4, 0.4);
    void.updateHitbox();

    glitch = new flixel.FlxSprite();
    glitch.alpha = 0.0001;
    glitch.x = 1000;
    glitch.y = 800;
    glitch.scale.set(5, 5);
    glitch.frames = retrieveAsset('images/gumballglitchbg', 'atlas');
    glitch.animation.addByPrefix('spin', 'spin', 15, false);

    house = new flixel.FlxSprite(0, -0);
    house.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-2', 'image'));
    house.setGraphicSize(Std.int(house.width * 2.5));
    house.antialiasing = ClientPrefs.globalAntialiasing;
    house.scrollFactor.set(0.75, 1.06);
    house.updateHitbox();
    house.color = houseColors[0];

    rock = new flixel.FlxSprite(0, -200);
    rock.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-3', 'image'));
    rock.setGraphicSize(Std.int(rock.width * 2.5));
    rock.antialiasing = ClientPrefs.globalAntialiasing;
    rock.scrollFactor.set(1, 1);
    rock.updateHitbox();
    rock.color = rockColors[0];

    if (!ClientPrefs.lowQuality)
    {
        rock2 = new flixel.FlxSprite(0, -200);
        rock2.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-4', 'image'));
        rock2.setGraphicSize(Std.int(rock2.width * 2.5));
        rock2.antialiasing = ClientPrefs.globalAntialiasing;
        rock2.scrollFactor.set(1.3, 0.7);
        rock2.updateHitbox();

        rock3 = new flixel.FlxSprite(0, -200);
        rock3.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-5', 'image'));
        rock3.setGraphicSize(Std.int(rock3.width * 2.5));
        rock3.antialiasing = ClientPrefs.globalAntialiasing;
        rock3.scrollFactor.set(0.9, 0.9);
        rock3.updateHitbox();
        rock3.color = houseColors[0];

        rock4 = new flixel.FlxSprite(0, -200);
        rock4.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-6', 'image'));
        rock4.setGraphicSize(Std.int(rock4.width * 2.5));
        rock4.antialiasing = ClientPrefs.globalAntialiasing;
        rock4.scrollFactor.set(0.65, 1.08);
        rock4.updateHitbox();
        rock4.color = houseColors[0];

        wtf = new flixel.FlxSprite(0, -200);
        wtf.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-7', 'image'));
        wtf.setGraphicSize(Std.int(wtf.width * 2.5));
        wtf.antialiasing = ClientPrefs.globalAntialiasing;
        wtf.scrollFactor.set(1, 1);
        wtf.updateHitbox();
        wtf.color = coolThingColors[0];
    }

    tweenLoopAngle(house, 4, -4, 6, 6);
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
    add(void);
    add(glitch);
    if (!ClientPrefs.lowQuality) add(rock4);
    if (!ClientPrefs.lowQuality) add(rock3);
    if (!ClientPrefs.lowQuality) add(rock2);
    add(house);
    add(rock);
    if (!ClientPrefs.lowQuality) add(wtf);
}

function onCreatePost()
{
    PlayState.boyfriend.origin.set(0, 200);
    PlayState.gf.origin.set(0, 200);
}

function onSongStart()
{
    PlayState.boyfriend.color = charColors[0];
    PlayState.dad.color = charColors[0];
    PlayState.gf.color = charColors[0];

    tweenLoopAngle(PlayState.boyfriend, -2.1, 2.1, 2.5, 2.5);
    tweenLoopAngle(PlayState.dad, -2.1, 2.1, 2.5, 2.5);
    tweenLoopAngle(PlayState.gf, -2.1, 2.1, 2.5, 2.5);
    tweenLoopAngle(rock, -0.8, 0.8, 2.5, 2.5);

    PlayState.camHUD.angle = -20;
    PlayState.camHUD.y -= 300;
}

function onEvent(event:String, value1:String, value2:String)
    {
        if (event == 'Apple Filter')
        {
            if (value1 == 'on') 
            {
                if (!ClientPrefs.lowQuality) wtf.visible = false;

                tweenLoopAngle(PlayState.boyfriend, 0, 0, 0.00001, 0.00001);
                tweenLoopAngle(PlayState.dad, 0, 0, 0.00001, 0.00001);
                tweenLoopAngle(PlayState.gf, 0, 0, 0.00001, 0.00001);
            }
        }
    }

function onStepHit(curStep) {
    if (glitch != null) {
        glitch.animation.play('spin');
    }

    if (curStep == 247)
    {
        FlxTween.tween(PlayState.camHUD, {angle: 0, y: PlayState.camHUD.y + 300}, 2, {ease: FlxEase.expoOut});
    }

    if (curStep == 512)
    {
        glitch.alpha = 1;
        velocityShitHehe = 2;
        PlayState.boyfriend.color = charColors[1];
        PlayState.dad.color = charColors[1];
        PlayState.gf.color = charColors[1];
        house.color = houseColors[1];
        rock.color = rockColors[1];

        if (!ClientPrefs.lowQuality)
            {
                rock3.color = houseColors[1];
                rock4.color = houseColors[1];
                wtf.color = coolThingColors[1];
            }
    }

    if (curStep == 768)
    {
        FlxTween.tween(glitch, {alpha: 0.0001}, 0.5, {
            ease: FlxEase.quadInOut
        });
        FlxTween.color(PlayState.boyfriend, 0.5, charColors[1], charColors[0], {ease: FlxEase.quadInOut } );
        FlxTween.color(PlayState.dad, 0.5, charColors[1], charColors[0], {ease: FlxEase.quadInOut } );
        FlxTween.color(PlayState.gf, 0.5, charColors[1], charColors[0], {ease: FlxEase.quadInOut } );
        FlxTween.color(house, 0.5, houseColors[1], houseColors[0], {ease: FlxEase.quadInOut } );
        FlxTween.color(rock, 0.5, rockColors[1], rockColors[0], {ease: FlxEase.quadInOut } );

        if (!ClientPrefs.lowQuality)
        {
            FlxTween.color(rock3, 0.5, houseColors[1], houseColors[0], {ease: FlxEase.quadInOut } );
            FlxTween.color(rock4, 0.5, houseColors[1], houseColors[0], {ease: FlxEase.quadInOut } );
            FlxTween.color(wtf, 0.5, coolThingColors[1], coolThingColors[0], {ease: FlxEase.quadInOut } );
        }

        velocityShitHehe = 1;
    }

    if (curStep == 1024)
    {
        glitch.alpha = 1;
        velocityShitHehe = 2;
        PlayState.boyfriend.color = charColors[1];
        PlayState.dad.color = charColors[1];
        PlayState.gf.color = charColors[1];

        house.color = houseColors[1];
        rock.color = rockColors[1];

        if (!ClientPrefs.lowQuality)
        {
            rock3.color = houseColors[1];
            rock4.color = houseColors[1];
            wtf.color = coolThingColors[1];
        }
    }

    if (curStep == 1280)
    {
        glitch.alpha = 0;
        velocityShitHehe = 5;
        PlayState.boyfriend.color = charColors[0];
        PlayState.dad.color = charColors[0];
        PlayState.gf.color = charColors[0];

        house.color = houseColors[0];
        rock.color = rockColors[0];

        if (!ClientPrefs.lowQuality)
        {
            rock3.color = houseColors[0];
            rock4.color = houseColors[0];
            wtf.color = coolThingColors[0];
        }
    }

    if (curStep == 1536)
    {
        glitch.alpha = 1;
        velocityShitHehe = 10;
        PlayState.boyfriend.color = charColors[1];
        PlayState.dad.color = charColors[1];
        PlayState.gf.color = charColors[1];

        house.color = houseColors[1];
        rock.color = rockColors[1];

        if (!ClientPrefs.lowQuality)
            {
                rock3.color = houseColors[1];
                rock4.color = houseColors[1];
                wtf.color = coolThingColors[1];
            }
    }

    if (curStep == 1792)
    {
        FlxTween.tween(glitch, {alpha: 0.0001}, 1, {
            ease: FlxEase.quadInOut
        });
        FlxTween.color(PlayState.boyfriend, 1, charColors[1], charColors[0], {ease: FlxEase.quadInOut } );
        FlxTween.color(PlayState.dad, 1, charColors[1], charColors[0], {ease: FlxEase.quadInOut } );
        FlxTween.color(PlayState.gf, 1, charColors[1], charColors[0], {ease: FlxEase.quadInOut } );
        FlxTween.color(house, 1, houseColors[1], houseColors[0], {ease: FlxEase.quadInOut } );
        FlxTween.color(rock, 1, rockColors[1], rockColors[0], {ease: FlxEase.quadInOut } );

        if (!ClientPrefs.lowQuality)
        {
            FlxTween.color(rock3, 1, houseColors[1], houseColors[0], {ease: FlxEase.quadInOut } );
            FlxTween.color(rock4, 1, houseColors[1], houseColors[0], {ease: FlxEase.quadInOut } );
            FlxTween.color(wtf, 1, coolThingColors[1], coolThingColors[0], {ease: FlxEase.quadInOut } );
        }

        velocityShitHehe = 1;

    }

    if (curStep == 1824)
    {
        glitch.alpha = 1;
        velocityShitHehe = 10;
        PlayState.boyfriend.color = charColors[1];
        PlayState.dad.color = charColors[1];
        PlayState.gf.color = charColors[1];

        house.color = houseColors[1];
        rock.color = rockColors[1];

        if (!ClientPrefs.lowQuality)
            {
                rock3.color = houseColors[1];
                rock4.color = houseColors[1];
                wtf.color = coolThingColors[1];
            }
    }
}

function tweenLoopAngle(varx, distance1, distance2, duration1, duration2) {
    FlxTween.tween(varx, {angle: distance1}, duration1 / velocityShitHehe, {
        ease: FlxEase.sineInOut,
        onComplete: 
        function (twn:FlxTween)
            {
                FlxTween.tween(varx, {angle: distance2}, duration2 / velocityShitHehe, {
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

// the low quality shit is necessary apparently wtf???
function onPause() {
    if (!ClientPrefs.lowQuality) stupidFix.active = false;
}

function onResume() {
    if (!ClientPrefs.lowQuality) stupidFix.active = true;
}
var timerShit = 7;
var shaderTime = 0;
var stupidFix2electricboogaloo;
var coolShader;
var pixel;
var thatOtherPixel;
var angleValue;
var angleSpeed;

// making them variables so its less confusing and stuff 
var charColors = [0xff969494, 0xFFBFE5BA]; // default, glitch part
var houseColors = [0xFF8f8f8f, 0xFF9ADA91]; // also with rock3 and rock4
var rockColors = [0xFFbababa, 0xFFB8D4B5]; // only for the rock the characters are on
var coolThingColors = [0xFFc4c0c0, 0xFFC1CEAA]; // wtf - forgor, 2023

function onCreate()
{
    coolShader = new flixel.addons.display.FlxRuntimeShader(RuntimeShaders.file, null, 120);

    pixel = new flixel.addons.display.FlxRuntimeShader(RuntimeShaders.pixel, null, 120);
    pixel.setFloat('size', 10);

    thatOtherPixel = new flixel.addons.display.FlxRuntimeShader(RuntimeShaders.pixel, null, 120);
    thatOtherPixel.setFloat('size', 5);

    void = new flixel.FlxSprite(0, -200);
    void.frames = retrieveAsset('images/void', 'atlas');
    void.animation.addByPrefix('idle', 'idle', 24, true);
    void.animation.play('idle');
    void.setGraphicSize(Std.int(void.width * 1.7));
    void.antialiasing = ClientPrefs.globalAntialiasing;
    void.scrollFactor.set(0.6, 0.6);
    void.updateHitbox();
    void.color = 0xdbdbdb;
    if (ClientPrefs.shaders) void.shader = coolShader;

    house = new flixel.FlxSprite(0, -200);
    house.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-3', 'image'));
    house.setGraphicSize(Std.int(house.width * 2.5));
    house.antialiasing = ClientPrefs.globalAntialiasing;
    house.scrollFactor.set(0.85, 0.85);
    house.updateHitbox();
    house.color = houseColors[0];

   if (!ClientPrefs.lowQuality)
   {
        chatImLazyToDoMathematicalShitSoHeresACopyOfScaryGlitchAhh = new flixel.FlxSprite(-500, -300);
        chatImLazyToDoMathematicalShitSoHeresACopyOfScaryGlitchAhh.loadGraphic(retrieveAsset('images/void3/2b', 'image'));
        chatImLazyToDoMathematicalShitSoHeresACopyOfScaryGlitchAhh.scale.set(1.2, 1.2);
        chatImLazyToDoMathematicalShitSoHeresACopyOfScaryGlitchAhh.antialiasing = ClientPrefs.globalAntialiasing;
        chatImLazyToDoMathematicalShitSoHeresACopyOfScaryGlitchAhh.scrollFactor.set(0.6, 0.6);
        chatImLazyToDoMathematicalShitSoHeresACopyOfScaryGlitchAhh.updateHitbox();
        if (ClientPrefs.shaders) chatImLazyToDoMathematicalShitSoHeresACopyOfScaryGlitchAhh.shader = pixel;
   }

    rock = new flixel.FlxSprite(0, -200);
    rock.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-4', 'image'));
    rock.setGraphicSize(Std.int(rock.width * 2.5));
    rock.antialiasing = ClientPrefs.globalAntialiasing;
    rock.scrollFactor.set(1, 1);
    rock.updateHitbox();
    rock.color = rockColors[0];

    rock2 = new flixel.FlxSprite(0, -200);
    rock2.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-5', 'image'));
    rock2.setGraphicSize(Std.int(rock2.width * 2.5));
    rock2.antialiasing = ClientPrefs.globalAntialiasing;
    rock2.scrollFactor.set(1.1, 1.1);
    rock2.updateHitbox();
    rock2.color = rockColors[0];

    if (!ClientPrefs.lowQuality) {
        rock3 = new flixel.FlxSprite(0, -200);
        rock3.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-6', 'image'));
        rock3.setGraphicSize(Std.int(rock3.width * 2.5));
        rock3.antialiasing = ClientPrefs.globalAntialiasing;
        rock3.scrollFactor.set(0.9, 0.9);
        rock3.updateHitbox();
        rock3.color = houseColors[0];

        rock4 = new flixel.FlxSprite(0, -200);
        rock4.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-7', 'image'));
        rock4.setGraphicSize(Std.int(rock4.width * 2.5));
        rock4.antialiasing = ClientPrefs.globalAntialiasing;
        rock4.scrollFactor.set(0.85, 0.85);
        rock4.updateHitbox();
        rock4.color = houseColors[0];

        wtf = new flixel.FlxSprite(0, -200);
        wtf.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-8', 'image'));
        wtf.setGraphicSize(Std.int(wtf.width * 2.5));
        wtf.antialiasing = ClientPrefs.globalAntialiasing;
        wtf.scrollFactor.set(1, 1);
        wtf.updateHitbox();
        wtf.color = coolThingColors[0];
    }

    voidb = new flixel.FlxSprite(0, -200);
    voidb.loadGraphic(retrieveAsset('images/void3/1b', 'image'));
    voidb.scale.set(1.2, 1.2);
    voidb.antialiasing = ClientPrefs.globalAntialiasing;
    voidb.scrollFactor.set(0.6, 0.6);
    voidb.updateHitbox();
    voidb.visible = false;
    if (ClientPrefs.shaders) voidb.shader = coolShader;

    if (!ClientPrefs.lowQuality)
    {
        scaryGlitchAhh = new flixel.FlxSprite(0, -200);
        scaryGlitchAhh.loadGraphic(retrieveAsset('images/void3/2b', 'image'));
        scaryGlitchAhh.scale.set(1.2, 1.2);
        scaryGlitchAhh.antialiasing = ClientPrefs.globalAntialiasing;
        scaryGlitchAhh.scrollFactor.set(0.6, 0.6);
        scaryGlitchAhh.updateHitbox();
        scaryGlitchAhh.visible = false;
        if (ClientPrefs.shaders) scaryGlitchAhh.shader = pixel;

        moreGlitchWaaaButBehindTheRock = new flixel.FlxSprite(0, -200);
        moreGlitchWaaaButBehindTheRock.loadGraphic(retrieveAsset('images/void3/2b', 'image'));
        moreGlitchWaaaButBehindTheRock.scale.set(1.2, 1.2);
        moreGlitchWaaaButBehindTheRock.antialiasing = ClientPrefs.globalAntialiasing;
        moreGlitchWaaaButBehindTheRock.scrollFactor.set(0.6, 0.6);
        moreGlitchWaaaButBehindTheRock.updateHitbox();
        moreGlitchWaaaButBehindTheRock.visible = false;
        if (ClientPrefs.shaders) moreGlitchWaaaButBehindTheRock.shader = pixel;
    }

    houseb = new flixel.FlxSprite(0, -200);
    houseb.loadGraphic(retrieveAsset('images/void3/3b', 'image'));
    houseb.scale.set(1.2, 1.2);
    houseb.antialiasing = ClientPrefs.globalAntialiasing;
    houseb.scrollFactor.set(0.85, 0.85);
    houseb.updateHitbox();
    houseb.visible = false;

    rockb = new flixel.FlxSprite(0, -200);
    rockb.loadGraphic(retrieveAsset('images/void3/5b', 'image'));
    rockb.scale.set(1.2, 1.2);
    rockb.antialiasing = ClientPrefs.globalAntialiasing;
    rockb.scrollFactor.set(1, 1);
    rockb.updateHitbox();
    rockb.visible = false;

    rock2b = new flixel.FlxSprite(0, -200);
    rock2b.loadGraphic(retrieveAsset('images/void3/11', 'image'));
    rock2b.scale.set(1.2, 1.2);
    rock2b.antialiasing = ClientPrefs.globalAntialiasing;
    rock2b.scrollFactor.set(1.1, 1.1);
    rock2b.updateHitbox();
    rock2b.visible = false;
    
    if (!ClientPrefs.lowQuality) {
        rock3b = new flixel.FlxSprite(0, -200);
        rock3b.loadGraphic(retrieveAsset('images/void3/11', 'image'));
        rock3b.scale.set(1.2, 1.2);
        rock3b.antialiasing = ClientPrefs.globalAntialiasing;
        rock3b.scrollFactor.set(0.9, 0.9);
        rock3b.updateHitbox();
        rock3b.visible = false;

        rock4b = new flixel.FlxSprite(0, -200);
        rock4b.loadGraphic(retrieveAsset('images/void3/4', 'image'));
        rock4b.scale.set(1.2, 1.2);
        rock4b.antialiasing = ClientPrefs.globalAntialiasing;
        rock4b.scrollFactor.set(0.85, 0.85);
        rock4b.updateHitbox();
        rock4b.visible = false;

        wtfb = new flixel.FlxSprite(0, -200);
        wtfb.loadGraphic(retrieveAsset('images/void3/6', 'image'));
        wtfb.scale.set(1.2, 1.2);
        wtfb.antialiasing = ClientPrefs.globalAntialiasing;
        wtfb.scrollFactor.set(1, 1);
        wtfb.updateHitbox();
        wtfb.visible = false;

        moreGlitchWaaa = new flixel.FlxSprite(0, 210);
        moreGlitchWaaa.loadGraphic(retrieveAsset('images/void3/2b', 'image'));
        moreGlitchWaaa.scale.set(1.2, 1.2);
        moreGlitchWaaa.antialiasing = ClientPrefs.globalAntialiasing;
        moreGlitchWaaa.scrollFactor.set(1.1, 1.1);
        moreGlitchWaaa.updateHitbox();
        moreGlitchWaaa.visible = false;
        if (ClientPrefs.shaders) moreGlitchWaaa.shader = pixel;

        foregroundGlitch = new flixel.FlxSprite(200, 0);
        foregroundGlitch.loadGraphic(retrieveAsset('images/Ilustracion_sin_titulo-9', 'image'));
        foregroundGlitch.setGraphicSize(Std.int(foregroundGlitch.width * 2.33));
        foregroundGlitch.antialiasing = ClientPrefs.globalAntialiasing;
        foregroundGlitch.scrollFactor.set(1.2, 1.2);
        foregroundGlitch.updateHitbox();
        if (ClientPrefs.shaders) foregroundGlitch.shader = pixel;
    }

    tweenLoopAngle(house, 4, -4, 6, 6);
    tweenLoopAngle(rock2, -2, 1.2, 2.5, 2.5);
    if (!ClientPrefs.lowQuality) tweenLoopAngle(rock3, 360, 0, 30, 30);
    if (!ClientPrefs.lowQuality) tweenLoopAngle(wtf, 2, -2, 5, 5);

    tweenLoopAngle(houseb, 16, -12, 6, 6);
    tweenLoopAngle(rockb, -0.5, 0.5, 2.5, 2.5);
    tweenLoopAngle(rock2b, -2, 1.2, 2.5, 2.5);
    if (!ClientPrefs.lowQuality && rock3b != null) tweenLoopAngle(rock3b, 360, 0, 30, 30);
    if (!ClientPrefs.lowQuality && wtfb != null) tweenLoopAngle(wtfb, 5, -5, 3, 3);

    makeShitInsane(houseb, 2000, 4, 9);
    if (!ClientPrefs.lowQuality) makeShitInsane(rock4b, 2500, 3, 7); // dumb fix

    if (!ClientPrefs.lowQuality) FlxTween.tween(rock4, {angle: 360}, 30, {
        ease: FlxEase.sineInOut
    });

    if (!ClientPrefs.lowQuality) stupidFix = FlxTween.tween(wtf, {y: wtf.y}, 1);
    add(void);
    if (!ClientPrefs.lowQuality) add(rock4);
    if (!ClientPrefs.lowQuality) add(rock3);
    add(rock2);
    add(house);
    if (!ClientPrefs.lowQuality) add(chatImLazyToDoMathematicalShitSoHeresACopyOfScaryGlitchAhh);
    add(rock);
    if (!ClientPrefs.lowQuality) add(wtf);

    if (!ClientPrefs.lowQuality) stupidFix2electricboogaloo = FlxTween.tween(wtfb, {y: wtfb.y}, 1);
    add(voidb);
    if (!ClientPrefs.lowQuality) add(scaryGlitchAhh);
    if (!ClientPrefs.lowQuality) add(moreGlitchWaaaButBehindTheRock);
    if (!ClientPrefs.lowQuality) add(rock4b);
    if (!ClientPrefs.lowQuality) add(rock3b);
    add(rock2b);
    add(houseb);
    add(rockb);
    if (!ClientPrefs.lowQuality) add(wtfb);
    if (!ClientPrefs.lowQuality) foreground.add(moreGlitchWaaa);
    if (!ClientPrefs.lowQuality) add(foregroundGlitch);

    add(glitch);
}

function onSongStart()
{
    PlayState.boyfriend.color = charColors[0];
    PlayState.dad.color = charColors[0];
    PlayState.gf.color = charColors[0];

    angleSpeed = angleValue = 1;
}

function onStepHit(curStep) {
    if (glitch != null) {
        glitch.animation.play('spin');
    }
}

function tweenLoopAngle(varx, distance1, distance2, duration1, duration2) {
    FlxTween.tween(varx, {angle: distance1 * angleValue}, duration1 / angleSpeed, {
        ease: FlxEase.sineInOut,
        onComplete: 
        function (twn:FlxTween)
            {
                FlxTween.tween(varx, {angle: distance2 * angleValue}, duration2 / angleSpeed, {
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

function makeShitInsane(object, xThing, timerRandom1, timerRandom2)
{
    FlxTween.tween(object, {x: xThing}, timerShit, {
        ease: FlxEase.sineInOut,
        onComplete: 
        function(e)
        {
            timerShit = FlxG.random.float(timerRandom1, timerRandom2);
            object.x = -1800;
            object.scale.x = FlxG.random.float(0.75, 1.1);
            object.scale.y = object.scale.x;
            makeShitInsane(object, xThing, timerRandom1, timerRandom2);
        }
    });
}

function onStepHit(curStep)
{
    if (curStep == 513)
    {
        tweenLoopAngle(PlayState.boyfriend, -2.1, 2.1, 2.5, 2.5);
        tweenLoopAngle(PlayState.dad, -2.1, 2.1, 2.5, 2.5);
        tweenLoopAngle(rock, -0.8, 0.8, 2.5, 2.5);
    }

    if (curStep == 1438)
    {
        angleSpeed = 0.8;
        tweenLoopAngle(PlayState.boyfriend, 0, 0, 0.0001, 0.0001);
        tweenLoopAngle(PlayState.dad, 0, 0, 0.0001, 0.0001);
        void.visible = false;
        if (!ClientPrefs.lowQuality) wtf.visible = false;
        rock.visible = false;
        rock2.visible = false;
        if (!ClientPrefs.lowQuality) rock3.visible = false;
        if (!ClientPrefs.lowQuality) rock4.visible = false;
        house.visible = false;

        voidb.visible = true;
        rockb.visible = true;
        rock2b.visible = true;
        if (!ClientPrefs.lowQuality) rock3b.visible = true;
        if (!ClientPrefs.lowQuality) rock4b.visible = true;
        houseb.visible = true;
        if (!ClientPrefs.lowQuality) wtfb.visible = true;
        if (!ClientPrefs.lowQuality) scaryGlitchAhh.visible = true;
        if (!ClientPrefs.lowQuality) moreGlitchWaaa.visible = true;
        if (!ClientPrefs.lowQuality) moreGlitchWaaaButBehindTheRock.visible = true;
    }
    if (curStep == 516)
    {
        PlayState.boyfriend.color = 0xffa8a4a4;
        PlayState.dad.color = 0xffa8a4a4;
        if (PlayState.gf != null) {
        PlayState.gf.color = 0xffa8a4a4;
        }
    }
}

function onBeatHit(curBeat)
{
    // this looks lazy asf but can't do anything else
    pixel.setFloat('size', FlxG.random.int(5, 15));
    thatOtherPixel.setFloat('size', FlxG.random.int(2, 7));
}

function onPause() {
    if (!ClientPrefs.lowQuality) stupidFix.active = false;
}

function onResume() {
    if (!ClientPrefs.lowQuality) stupidFix.active = true;
}

function onUpdate(elapsed) {
    shaderTime += elapsed;
    coolShader.setFloat('iTime', shaderTime);
}
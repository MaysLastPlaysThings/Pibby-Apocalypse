var dadCamZoom = -1;
var coolStep = 0; // rare ass fix

var doThunder:Bool = false;
var pixel;

function onCreate()
{
    pixel = new flixel.addons.display.FlxRuntimeShader(RuntimeShaders.pixel, null, 100);
    pixel.setFloat('size', 5);

    bg = new flixel.FlxSprite(-800, -800);
    bg.loadGraphic(retrieveAsset('images/back', 'image'));
    bg.scale.set(1.8, 1.8);
    bg.antialiasing = ClientPrefs.globalAntialiasing;
    bg.updateHitbox();
    bg.alpha = 0.0001;

    treehouse = new flixel.FlxSprite(-800, -800);
    treehouse.loadGraphic(retrieveAsset('images/tree', 'image'));
    treehouse.scale.set(1.8, 1.8);
    treehouse.antialiasing = ClientPrefs.globalAntialiasing;
    treehouse.updateHitbox();
    treehouse.alpha = 0.0001;

    if (!ClientPrefs.lowQuality)
    {
        thunder = new flixel.FlxSprite();
        thunder.x = -550;
        thunder.y = -800;
        thunder.scale.set(1.2, 1,2);
        thunder.frames = retrieveAsset('images/Lighting', 'atlas');
        thunder.animation.addByPrefix('thunder', 'LIGHTNING', 24, false);
        thunder.alpha = 0.0001;
        thunder.scrollFactor.set(1,1);//I'm not offsetting the thunder one of you dumbasses set the thunder scroll 0 (if you want thunder do it) --Tormented

        backGlitch = new flixel.FlxSprite(750, 1500);
        backGlitch.loadGraphic(retrieveAsset('images/reveal/glitch', 'image'));
        backGlitch.updateHitbox();
        backGlitch.scale.set(0.7, 0.7);
        backGlitch.scrollFactor.set();

        hillShit = new flixel.FlxSprite(750, 1500);
        hillShit.loadGraphic(retrieveAsset('images/reveal/HillStuff', 'image'));
        hillShit.updateHitbox();
        hillShit.scale.set(0.7, 0.7);
        hillShit.scrollFactor.set(0.65, 0.65);

        particles = new flixel.FlxSprite(750, 1500);
        particles.loadGraphic(retrieveAsset('images/reveal/Particles', 'image'));
        particles.updateHitbox();
        particles.scale.set(0.5, 0.5);
        particles.alpha = 0;

        dangling = new flixel.FlxSprite(750, 1500);
        dangling.loadGraphic(retrieveAsset('images/reveal/Dangling', 'image'));
        dangling.updateHitbox();
        dangling.scale.set(0.7, 0.7);
        dangling.scrollFactor.set(0.85, 0.85);

        corruption = new flixel.FlxSprite(750, 1500);
        corruption.loadGraphic(retrieveAsset('images/reveal/Corruption', 'image'));
        corruption.updateHitbox();
        corruption.scale.set(0.7, 0.7); 
        corruption.alpha = 0;
        if (ClientPrefs.shaders) corruption.shader = pixel;
    }

    revealBackground = new flixel.FlxSprite(750, 1500);
    revealBackground.loadGraphic(retrieveAsset('images/reveal/realBackground', 'image'));

    outside = new flixel.FlxSprite(1150, 1450);
    outside.loadGraphic(retrieveAsset('images/intro/IMG_8337', 'image'));
    outside.updateHitbox();
    outside.scale.set(0.7, 0.7);

    outside2 = new flixel.FlxSprite(1150, 1450);
    outside2.loadGraphic(retrieveAsset('images/intro/IMG_8337', 'image'));
    outside2.updateHitbox();
    outside2.scale.set(0.65, 0.65);

    idkWhatAreThatThings = new flixel.FlxSprite(1090, 1500);
    idkWhatAreThatThings.loadGraphic(retrieveAsset('images/intro/Ilustracion_sin_titulo-2', 'image'));
    idkWhatAreThatThings.updateHitbox();
    idkWhatAreThatThings.scale.set(0.6, 0.6);

    coolGradient = new flixel.FlxSprite(1150, 1450);
    coolGradient.loadGraphic(retrieveAsset('images/intro/Ilustracion_sin_titulo-3', 'image'));
    coolGradient.updateHitbox();

    revealBackground.y += 475;
    revealBackground.x += 675;
    if (!ClientPrefs.lowQuality)
        {
            backGlitch.y -= 1910;
            hillShit.y -= 425;
            particles.y += 270;
            dangling.y -= 110;
            corruption.y += 270;

            backGlitch.x -= 1580;
            hillShit.x -= 490;
            particles.x += 130;
            dangling.x -= 210;
            corruption.x += 150;
        }

    add(bg);
    if (!ClientPrefs.lowQuality) add(thunder);
    add(treehouse);
    if (!ClientPrefs.lowQuality) add(thunder);

    // reveal shit cuz yes

    // add(revealBackground);
    if (!ClientPrefs.lowQuality) add(backGlitch);
    if (!ClientPrefs.lowQuality) add(hillShit);
    if (!ClientPrefs.lowQuality) foreground.add(particles);
    if (!ClientPrefs.lowQuality) add(dangling);
    if (!ClientPrefs.lowQuality) foreground.add(corruption);
    if (ClientPrefs.lowQuality) add(revealBackground);

    add(outside);
    add(outside2);
    add(coolGradient);
    add(idkWhatAreThatThings);
}

function onMoveCamera(focus:String)
{
    if(dadCamZoom != -1){   // chat why are we doing that -1 check again -jason
        if (focus == 'dad') 
            PlayState.defaultCamZoom = dadCamZoom;
        else
            PlayState.defaultCamZoom = dadCamZoom + 0.2;
    }
}

function onStepHit(curStep:Int)
    {
        coolStep = curStep;

        if (curStep == 1535) {
            outside.alpha = 1;
            outside2.alpha = 1;
            coolGradient.alpha = 1;
            idkWhatAreThatThings.alpha = 1;
            if (!ClientPrefs.lowQuality) thunder.alpha = 0;
            treehouse.alpha = 0;
            bg.alpha = 0;
            doThunder = false;
            dadCamZoom = 0.9;

        }else if (curStep == 1648)
        {
            outside.alpha = 0;
            outside2.alpha = 0;
            coolGradient.alpha = 0;
            idkWhatAreThatThings.alpha = 0;

            if (!ClientPrefs.lowQuality) backGlitch.alpha = 1;
            if (!ClientPrefs.lowQuality) hillShit.alpha = 1;
            if (!ClientPrefs.lowQuality) particles.alpha = 1;
            if (!ClientPrefs.lowQuality) dangling.alpha = 1;
            if (!ClientPrefs.lowQuality) corruption.alpha = 1;

            dadCamZoom = 0.85;
        }else if (curStep == 628)
        {
            outside.alpha = 0;
            outside2.alpha = 0;
            coolGradient.alpha = 0;
            idkWhatAreThatThings.alpha = 0;
            if (!ClientPrefs.lowQuality) FlxTween.tween(corruption, {alpha: 1}, 3);

            if (!ClientPrefs.lowQuality) thunder.alpha = 1;
            treehouse.alpha = 1;
            bg.alpha = 0;
            doThunder = true;
            dadCamZoom = 0.85;
        }else if (curStep == 896) {
            dadCamZoom = 0.6;

            if (ClientPrefs.lowQuality) revealBackground.alpha = 0;
            if (!ClientPrefs.lowQuality) backGlitch.alpha = 0;
            if (!ClientPrefs.lowQuality) hillShit.alpha = 0;
            if (!ClientPrefs.lowQuality) particles.alpha = 0;
            if (!ClientPrefs.lowQuality) dangling.alpha = 0;
            if (!ClientPrefs.lowQuality) corruption.alpha = 0;
            
            bg.alpha = 1;
        }else if (curStep == 1536)
            dadCamZoom = 0.8;
        else if (curStep == 1648) {
            if (ClientPrefs.lowQuality) revealBackground.alpha = 1;
        }
        else if (curStep == 1664) {
            dadCamZoom = 0.6;

            if (ClientPrefs.lowQuality) revealBackground.alpha = 0;
            if (!ClientPrefs.lowQuality) backGlitch.alpha = 0;
            if (!ClientPrefs.lowQuality) hillShit.alpha = 0;
            if (!ClientPrefs.lowQuality) particles.alpha = 0;
            if (!ClientPrefs.lowQuality) dangling.alpha = 0;
            if (!ClientPrefs.lowQuality) corruption.alpha = 0;

            if (!ClientPrefs.lowQuality) thunder.alpha = 1;
            treehouse.alpha = 1;
            bg.alpha = 1;
            doThunder = true;
        }
    }

function onBeatHit(curBeat:Int)
{
        if (curBeat % 8 == 0 && doThunder) // dumb fix
            lightningStrike();

    pixel.setFloat('size', FlxG.random.int(5, 15));
}


function lightningStrike()
    {
        if (!ClientPrefs.lowQuality) thunder.alpha = 1;
        if (!ClientPrefs.lowQuality) thunder.animation.play('thunder');
        if (!ClientPrefs.lowQuality) thunder.animation.finishCallback = function()
        if (!ClientPrefs.lowQuality) thunder.alpha = 0.0001;
    }
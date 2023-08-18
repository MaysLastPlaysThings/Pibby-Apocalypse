function onCreate()
{
    place = new flixel.FlxSprite(-600, -300);
    place.loadGraphic(retrieveAsset('images/bgnoherofull', 'image'));
    place.updateHitbox();
    place.antialiasing = ClientPrefs.globalAntialiasing;
    add(place);

    placeog = new flixel.FlxSprite(-600, -300);
    placeog.loadGraphic(retrieveAsset('images/place', 'image'));
    placeog.updateHitbox();
    placeog.antialiasing = ClientPrefs.globalAntialiasing;
    placeog.visible = false;
    add(placeog);
}

function onStepHit(curStep)
{
    if (curStep == 464)
    {
        place.visible = false;
        placeog.visible = true;
    }

    if (curStep == 592)
    {
        placeog.visible = false;
        place.visible = true;
    }
}
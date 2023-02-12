package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	public var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			var name2:String = 'icons/icon-' + char;
			if(Paths.fileExists('images/' + name2 + '.xml', IMAGE)) {
				frames = Paths.getSparrowAtlas('icons/icon-' + char);
				
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;

				animation.addByPrefix(char + 'neutral', 'neutral', 24, true, isPlayer);
				animation.addByPrefix(char + 'losing', 'losing', 24, true, isPlayer);
				playAnim(char + 'neutral');
			}else{
				var name:String = 'icons/' + char;
				if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
				if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
				var file:Dynamic = Paths.image(name);

				loadGraphic(file); //Load stupidly first for getting the file size
				loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); //Then load it fr
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
				updateHitbox();
	
				animation.add(char + 'neutral', [0], 0, false, isPlayer);
				animation.add(char + 'losing', [1], 0, false, isPlayer);
				animation.play(char + 'neutral');
			}
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	public function playAnim(anim:String, force:Bool = false, reversed:Bool = false){
		animation.play(anim, force, reversed);
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}

package;

// Code by Matheus Silver

import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;

class BSLTouchUtils
{
	public static var prevTouched:Int = -1;

	public static function justTouched():Bool //Copiado do Hsys k
	{
		#if (flixel && android)
		var justTouched:Bool = false;

		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				justTouched = true;
		}

		return justTouched;
		#else
		return FlxG.mouse.justPressed; //Isso aqui é mais válido pro modboa mas né?
		#end
	}

	public static function aperta(coisas:Dynamic, coisasID:Int):String //Esse code foi feito só pq em outro projeto, eu usei um padrãozinho deste várias vezes e fiquei com preguiça de fazer isso de novo
    {
        var leToqueOrdem:String = '';
	    #if desktop
		if (FlxG.mouse.overlaps(coisas) && FlxG.mouse.justPressed && prevTouched == coisasID){
            leToqueOrdem = 'segundo';
		}else if (FlxG.mouse.overlaps(coisas) && FlxG.mouse.justPressed){
			prevTouched = coisasID;
			leToqueOrdem = 'primeiro';
        }
	    #elseif mobile
		for (touch in FlxG.touches.list){
			if (touch.overlaps(coisas) && touch.justPressed && prevTouched == coisasID)
            	leToqueOrdem = 'segundo';
			else if (touch.overlaps(coisas) && touch.justPressed){
				prevTouched = coisasID;
				leToqueOrdem = 'primeiro';
        	}    
		}
	    #end
		return leToqueOrdem;
    }

	public static function apertasimples(coisa:Dynamic):Bool
    {
	    #if desktop
		if (FlxG.mouse.overlaps(coisa) && FlxG.mouse.justPressed)
			return true;
	    #elseif mobile
		for (touch in FlxG.touches.list)
			if (touch.overlaps(coisa) && touch.justPressed)
				return true;
	    #end

		return false;
    }

	public static function pressionando(coisa:Dynamic):Bool
	{
		#if desktop
		if (FlxG.mouse.overlaps(coisa) && FlxG.mouse.justPressed && !FlxG.mouse.justReleased)
			return true;
		#elseif mobile
		for (touch in FlxG.touches.list)
			if (touch.overlaps(coisa) && touch.justPressed && !touch.justReleased)
				return true;
		#end

		return false;
	}

	public static function solto(coisa:Dynamic):Bool
	{
		#if desktop
		if (FlxG.mouse.overlaps(coisa) && FlxG.mouse.justReleased)
			return true;
		#elseif mobile
		for (touch in FlxG.touches.list)
			if (touch.overlaps(coisa) && touch.justReleased)
				return true;
		#end

		return false;
	}

	#if desktop
	public static function pegarpos(pos:String):Int
	{
		if (pos == 'x')
			return FlxG.mouse.x;
		
		if (pos == 'y')
			return FlxG.mouse.y;

		return 0;
	}
	#elseif mobile

	public static function pegarpos(touch:flixel.input.touch.FlxTouch, pos:String):Int
	{
		if (pos == 'x')
			return touch.x;

		if (pos == 'y')
			return touch.y;

		return 0;
	}

	#end
}
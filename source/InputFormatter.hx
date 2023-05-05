import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

using StringTools;

class InputFormatter 
{

	public static var keyNameMap : Map < FlxKey, String >;

	// Load keys upon startup
	public static function loadKeys() : Void
	{
		keyNameMap = [
			BACKSPACE => "BcpSpc",
			CONTROL => "Ctrl",
			ALT => "Alt",
			CAPSLOCK => "Caps",
			PAGEUP => "PgUp",
			PAGEDOWN => "PgDown",
			ZERO => "0",
			ONE => "1",
			TWO => "2",
			THREE => "3",
			FOUR => "4",
			FIVE => "5",
			SIX => "6",
			SEVEN => "7",
			EIGHT => "8",
			NINE => "9",
			NUMPADZERO => "#0",
			NUMPADONE => "#1",
			NUMPADTWO => "#2",
			NUMPADTHREE => "#3",
			NUMPADFOUR => "#4",
			NUMPADFIVE => "#5",
			NUMPADSIX => "#6",
			NUMPADSEVEN => "#7",
			NUMPADEIGHT => "#8",
			NUMPADNINE => "#9",
			NUMPADMULTIPLY => "#*",
			NUMPADPLUS => "#+",
			NUMPADMINUS => "#-",
			NUMPADPERIOD => "#.",
			SEMICOLON => ";",
			COMMA => ",",
			PERIOD => ".",
			GRAVEACCENT => "`",
			LBRACKET => "[",
			RBRACKET => "]",
			QUOTE => "'",
			PRINTSCREEN => "PrtScrn",
			NONE => "---"
		];
	}

	// Get key when called
	public static function getKeyName( key : FlxKey ) : String 
	{
		var getKey = keyNameMap.get( key );
		var label : String = Std.string(key);
		
		return getKey == null 
		? label.toLowerCase() == 'null' ? '---' : '' + label.charAt(0).toUpperCase() + label.substr(1).toLowerCase()
		: getKey;
	}
}

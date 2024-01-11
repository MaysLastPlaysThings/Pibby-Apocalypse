package;

// Se deixar as APIs só pra android não vai dar pra debugar pelo motivo de que a gente não vai conseguir compilar pra outra target sem ser android
class CppAPI
{
	public static function obtainRAM():Int
	{
		return openfl.system.System.totalMemory;
	}

	public static function darkMode()
	{
		#if none
		WindowsData.setWindowColorMode(DARK);

		// this piece of code fixes that bug about that weridly the window doesn't go dark idk why that happends lmao.
		flixel.FlxG.stage.window.borderless = true;
		flixel.FlxG.stage.window.borderless = false;
		#end
	}

	public static function lightMode()
	{
		#if none
		WindowsData.setWindowColorMode(LIGHT);
		#end
	}

	public static function setWindowOppacity(a:Float)
	{
		#if none
		WindowsData.setWindowAlpha(a);
		#end
	}

	public static function _setWindowLayered()
	{
		#if none
		WindowsData._setWindowLayered();
		#end
	}

    public static function doWindowTransparent()
    {
		#if none
        WindowsSystem.setWindowOpacity();
		#end
    }

    public static function sendNotification(title:String, desc:String)
    {
		#if none
        WindowsSystem.sendNotification(title, desc);
		#end
    }

    public static function restoreWindowTransparency()
    {
		#if none
        WindowsSystem.restoreWindowOpacity();
		#end
    }

    public static function setWindowIcon(file:String)
    {
		#if none
        lime.app.Application.current.window.setIcon(lime.graphics.Image.fromFile('${Paths.image('appIcons/$file')}'));
		#end
	}
}
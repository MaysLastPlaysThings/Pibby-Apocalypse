package;

//STOLEN FROM WEDNESDAY'S INFIDELITY PART 2 MAWHWAHAHAHAHAHAHAHAHAHAHAH (maw reference)
#if windows
class CppAPI
{
	#if cpp
	public static function obtainRAM():Int
	{
		return WindowsData.obtainRAM();
	}

	public static function darkMode()
	{
		WindowsData.setWindowColorMode(DARK);

		// this piece of code fixes that bug about that weridly the window doesn't go dark idk why that happends lmao
		flixel.FlxG.stage.window.borderless = true;
		flixel.FlxG.stage.window.borderless = false;
	}

	public static function lightMode()
	{
		WindowsData.setWindowColorMode(LIGHT);
	}

	public static function setWindowOppacity(a:Float)
	{
		WindowsData.setWindowAlpha(a);
	}

	public static function _setWindowLayered()
	{
		WindowsData._setWindowLayered();
	}

    public static function doWindowTransparent()
    {
        WindowsSystem.setWindowOpacity();
    }

    public static function sendNotification(title:String, desc:String)
    {
        WindowsSystem.sendNotification(title, desc);
    }

    public static function restoreWindowTransparency()
    {
        WindowsSystem.restoreWindowOpacity();
    }

    public static function setWindowIcon(file:String)
    {
        lime.app.Application.current.window.setIcon(lime.graphics.Image.fromFile('${Paths.image('appIcons/$file')}'));
    }
	#end
}
#end
package;

class ZeroSaveShit {
    // Week unlock variables
    public static var finnBeaten:Bool;
    public static var gumballBeaten:Bool;
    public static var cawmBeaten:Bool;

    // Zero unlocked variable
    public static var zeroUnlocked:Bool;

    public static function loadSaveData() {
        if (finnBeaten && gumballBeaten && cawmBeaten) {
            zeroUnlocked = true;
        }

        if (FlxG.save.data.finnBeaten != null) {
            FlxG.save.data.finnBeaten = finnBeaten;
        }

        if (FlxG.save.data.gumballBeaten != null) {
            FlxG.save.data.gumballBeaten = gumballBeaten;
        }

        if (FlxG.save.data.cawmBeaten != null) {
            FlxG.save.data.cawmBeaten = cawmBeaten;
        }

        if (FlxG.save.data.zeroUnlocked != null) {
            FlxG.save.data.zeroUnlocked = zeroUnlocked;
        }
    }
}
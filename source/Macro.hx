package;

class Macro
{
	public static macro function getBuildDate()
	{
		var date = Date.now();
		var offset = date.getTimezoneOffset() / 60;
		var str = '${date.toString()} (UTC${offset<0?"+":"-"}${Math.abs(offset)})';
		return macro $v{str};
	}
}
package;

// sei que as apis devem ser mais precisas, mas a gente tá falando de Android (Linux) e não
// de windows. Então vai pa vala mo fi

import openfl.system.System;

class MemoryShit {
	public static function obtainMemory():Dynamic
	{
		
		var memory = System.totalMemory;
		return memory;
	}
}
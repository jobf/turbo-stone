package stone.util;

@:publicFields
class ArrayExtensions {
	static function all<T>(array:Array<T>, call:T->Void) {
		for (item in array)
			call(item);
	}

	static function clear<T>(array:Array<T>, ?call:T->Void = null) {
		var index = array.length;
		while (index-- > 0) {
			var item = array.pop();
			if (call != null) {
				call(item);
			}
		}
	}

	static function firstOrNull<T>(array:Array<T>, should_return_item:T->Bool):T {
		for (item in array) {
			if (should_return_item(item))
				return item;
		}
		return null;
	}

	static function pushAndReturn<T>(array:Array<T>, item:T):T {
		array.push(item);
		return array[array.length - 1];
	}
}

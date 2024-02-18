package stone.core;

@:publicFields
class Event<T> {
	var listeners:Array<T->Void>;

	function new() {
		listeners = [];
	}

	function add(listener:T->Void):Void {
		listeners.push(listener);
	}

	function dispatch(event:T):Void {
		// trace('dispatch $event to ${listeners.length} listeners');
		for (listener in listeners) {
			listener(event);
		}
	}

	function remove(listener:T->Void):Void {
		var i = listeners.length;

		while (--i >= 0) {
			if (Reflect.compareMethods(listeners[i], listener)) {
				listeners.splice(i, 1);
			}
		}
	}

	function removeAll():Void {
		var len = listeners.length;

		listeners.splice(0, len);
	}
}
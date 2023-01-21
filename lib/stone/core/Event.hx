package stone.core;

class Event<T> {
	public var listeners:Array<T->Void>;

	public function new() {
		listeners = [];
	}

	public function add(listener:T->Void):Void {
		listeners.push(listener);
	}

	public function dispatch(event:T):Void {
		// trace('dispatch $event to ${listeners.length} listeners');
		for (listener in listeners) {
			listener(event);
		}
	}

	public function remove(listener:T->Void):Void {
		var i = listeners.length;

		while (--i >= 0) {
			if (Reflect.compareMethods(listeners[i], listener)) {
				listeners.splice(i, 1);
			}
		}
	}

	public function removeAll():Void {
		var len = listeners.length;

		listeners.splice(0, len);
	}
}
package stone.file;

import js.Browser;
import js.html.Storage;

class StorageWeb {
	
	static var storage(get, never):Storage;

	static function get_storage():Storage {
		return Browser.getLocalStorage();
	}

	/**
		Returns an integer representing the number of data items stored in the `Storage` object.
	**/
	static public var length(get, never):Int;

	static function get_length():Int {
		return storage.length;
	}

	/**
		When passed a number n, this method will return the name of the nth key in the storage.
		@throws Exception
	**/
	static public function key(index:Int) {
		storage.key(index);
	}

	/**
		When passed a key name, will return that key's value.
		@throws Exception
	**/
	static public function getItem(key:String) {
		return storage.getItem(key);
	}

	/**
		When passed a key name and value, will add that key to the storage, or update that key's value if it already exists.
		@throws Exception
	**/
	static public function setItem(key:String, value:String) {
		storage.setItem(key, value);
	}

	/**
		When invoked, will empty all keys out of the storage.
		@throws Exception
	**/
	static public function clear() {
		storage.clear();
	}

	/**
		When passed a key name, will remove that key from the storage.
		@throws Exception
	**/
	static public function removeItem(key:String) {
		storage.removeItem(key);
	}
}

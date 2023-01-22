package stone.file;

import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;

class StorageSys {
	static var home = Sys.environment()['HOME'];
	static var path_storage_root = Path.join([home, '.turbo-stone']);

	static function path_in_root(key:String):String {
		if (!FileSystem.exists(path_storage_root)) {
			FileSystem.createDirectory(path_storage_root);
		}
		return Path.join([path_storage_root, key]);
	}

	/**
		Returns an integer representing the number of data items stored in the `Storage` object.
	**/
	static public var length(get, never):Int;

	static function get_length():Int {
		return FileSystem.readDirectory(path_storage_root).length;
	}

	/**
		When passed a number n, this method will return the name of the nth key in the storage.
		@throws Exception
	**/
	static public function key(index:Int) {}

	/**
		When passed a key name, will return that key's value.
		@throws Exception
	**/
	static public function getItem(key:String) {
		var path = path_in_root(key);
		if(FileSystem.exists(path)){
			return File.getContent(path);
		}

		return null;
	}

	/**
		When passed a key name and value, will add that key to the storage, or update that key's value if it already exists.
		@throws Exception
	**/
	static public function setItem(key:String, value:String) {
		File.saveContent(path_in_root(key), value);
	}

	/**
		When invoked, will empty all keys out of the storage.
		@throws Exception
	**/
	static public function clear() {
		for (path in FileSystem.readDirectory(path_storage_root)) {
			FileSystem.deleteFile(path);
		}
	}

	/**
		When passed a key name, will remove that key from the storage.
		@throws Exception
	**/
	static public function removeItem(key:String) {
		FileSystem.deleteFile(path_in_root(key));
	}
}

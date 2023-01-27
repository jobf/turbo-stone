package stone.file;

import json2object.JsonWriter;
import json2object.Error;
import json2object.JsonParser;
#if js
import stone.file.StorageWeb as Store;
#else
import stone.file.StorageSys as Store;
#end

class FileStorage {
	var _file_list:FileListJSON;
	var key_file_list:String = "____FILE_LIST";

	public function new() {
		var file_list_json = Store.getItem(key_file_list);
		if(file_list_json == null){
			_file_list ={
				paths: []
			}
			file_list_save(_file_list);
		}
		else{
			_file_list = parse_file_list(file_list_json);
		}
	}
	
	function file_list_save(file_list:FileListJSON){
		var writer = new JsonWriter<FileListJSON>();
		var json_string:String = writer.write(file_list);
		Store.setItem(key_file_list, json_string);
	}

	public function file_save(file:FileJSON){
		var item = Store.getItem(file.name);
		if(item == null){
			// this is a new addition so add to the file list
			_file_list.paths.push(file.name);
			file_list_save(_file_list);
		}
		var writer = new JsonWriter<FileJSON>();
		var json_string:String = writer.write(file);
		Store.setItem(file.name, json_string);
	}


	public function file_paths():Array<String> {
		return _file_list.paths;
	}

	public function file_load(path:String):FileJSON{
		var item = Store.getItem(path);
		return parse_file(item);
	}

	public function file_delete(path:String){
		trace('delete $path');
		var item = Store.getItem(path);
		if(item != null){
			_file_list.paths.remove(path);
			file_list_save(_file_list);
			Store.removeItem(path);
		}
	}
}

@:structInit
class FileListJSON {
	public var paths:Array<String>;
}

@:structInit
class FileJSON {
	public var name(default, null):String;
	public var content(default, null):String;
}

function parse_file_list(json:String):FileListJSON {
	var errors = new Array<Error>();
	var data = new JsonParser<FileListJSON>(errors).fromJson(json, 'json-errors');
	if (errors.length <= 0 && data != null && data.paths.length > 0) {
		return data;
	}

	return {
		paths: []
	}
}

function parse_file(json:String):FileJSON {
	var errors = new Array<Error>();
	var data = new JsonParser<FileJSON>(errors).fromJson(json, 'json-errors');
	if (errors.length <= 0 && data != null && data.name != null && data.name.length > 0) {
		return data;
	}

	return {
		name:"",
		content: ""
	}
}
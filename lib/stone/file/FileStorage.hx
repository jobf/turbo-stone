package stone.file;

import json2object.Error;
import json2object.JsonParser;
import json2object.JsonWriter;
#if js
import stone.file.StorageWeb as Store;
#else
import stone.file.StorageSys as Store;
#end



@:structInit
class FileContainer{
	public var key:String;
	public var json:FileJSON;
}

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

	public function file_save(container:FileContainer){
		var item = Store.getItem(container.key);
		if(item == null){
			// this is a new addition so add to the file list
			_file_list.paths.push(container.key);
			file_list_save(_file_list);
		}
		var writer = new JsonWriter<FileJSON>();
		var json_string:String = writer.write(container.json);
		Store.setItem(container.key, json_string);
	}


	public function file_paths():Array<String> {
		return _file_list.paths;
	}

	public function file_load(file_container_key:String):FileJSON{
		var json_string = Store.getItem(file_container_key);
		return parse_file(json_string);
	}

	public function file_delete(file_container_key:String){
		trace('delete $file_container_key');
		var item = Store.getItem(file_container_key);
		if(item != null){
			_file_list.paths.remove(file_container_key);
			file_list_save(_file_list);
			Store.removeItem(file_container_key);
		}
	}
}

@:structInit
class FileListJSON {
	public var paths:Array<String>;
}

@:structInit
class FileJSON {
	/** the file name and extension e.g. filename.json**/
	public var file_path(default, null):String;
	/** the serialized content of the file **/
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
	if (errors.length <= 0 && data != null && data.file_path != null && data.file_path.length > 0) {
		return data;
	}

	return {
		file_path:"",
		content: ""
	}
}
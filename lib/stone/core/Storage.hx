package stone.core;

import haxe.io.Bytes;
import stone.file.FileStorage;
import lime.ui.Window;
import haxe.io.Path;
import stone.core.Event;
import stone.core.Models;

class Storage {
	var storage:FileStorage;

	public function new(window:Window) {
		on_drop_file = new Event();
		storage = new FileStorage();

		#if web
		window.onDropFile.add(file_list -> {
			file_drop_web(file_list);
		});
		#else
		window.onDropFile.add(path -> {
			file_drop_sys(path);
		});
		#end
	}

	public var on_drop_file:Event<FileJSON>;

	public function file_paths():Array<String> {
		var file_path_list = storage.file_paths();
		var valid_file_paths = file_path_list.filter(s -> s.length > 0);
		// todo - this shouldn't be needed, e.g. do not let invalid file paths enter the file ?
		return valid_file_paths;
	}

	function path_to_name(path:Path):String {
		return '${path.file}.FileJSON';
	}

	public function file_drop_sys(path_disk) {
		#if !js
		var content = sys.io.File.getContent(path_disk);
		// todo - check file validity

		var path = new haxe.io.Path(path_disk);
		var file:FileJSON = {
			name: path_to_name(path),
			content: content
		}
		storage.file_save(file);
		on_drop_file.dispatch(file);
		#end

	}

	public function file_drop_web(file_list:String) {
		#if js
		if (file_list.length > 0) {
			var list:js.html.FileList = cast file_list;
			if(list.length > 0){
				var file:js.html.File = list[0];
				trace('browser file ${file.name}');
				var reader = new js.html.FileReader();
				reader.onload = () -> {
					var fileJSON:FileJSON = {
						name: file.name,
						content: reader.result
					};
					storage.file_save(fileJSON);
					on_drop_file.dispatch(fileJSON);
				};
				reader.readAsText(file);
			}
		}
		#end
	}

	public function file_save(file:FileJSON){
		storage.file_save(file);
	}

	public function export_bytes(bytes_image:Bytes, file_name:String) {
		#if web
		stone.util.Browser.release_blob_bytes(bytes_image, file_name);
		#else
		var output =  sys.io.File.write(file_name, true);
		output.writeBytes(bytes_image, 0, bytes_image.length);
		output.close();
		#end
	}

	public function file_new():FileJSON {
		var time_stamp = Date.now().to_time_stamp();
		return {
			name: '$time_stamp.fileJSON',
			content: Serialize.to_string(init_empty_file())
		}
	}

	public function file_delete(path_file:String) {
		storage.file_delete(path_file);
	}

	public function export(path_file) {
		#if web
		var file:FileJSON = storage.file_load(path_file);
		stone.util.Browser.release_blob_string(file.content, path_file);
		#end
	}

	public function file_load(path_file_selected:String):FileJSON {
		var item = storage.file_load(path_file_selected);
		if(item == null){
			// todo : init new, store and return
		}
		return item;
	}

	function init_empty_file():FileModel {
		return {
			models: [for(i in 0...256) {
				name: "",
				lines: [],
				index: i
			} ]
		}
	}
}
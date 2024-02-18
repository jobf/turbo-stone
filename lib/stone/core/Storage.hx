package stone.core;

import haxe.io.Bytes;
import haxe.io.Path;
import lime.ui.Window;
import stone.core.Event;
import stone.core.Models;
import stone.file.FileStorage;


@:publicFields
class Storage {
	private var storage:FileStorage;

	function new(window:Window) {
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

	var on_drop_file:Event<FileContainer>;

	function file_paths():Array<String> {
		var file_path_list = storage.file_paths();
		var valid_file_paths = file_path_list.filter(s -> s.length > 0 && !StringTools.endsWith(s.toLowerCase(), '.json'));
		// todo - this shouldn't be needed, e.g. do not let invalid file paths enter the file ?
		return valid_file_paths;
	}

	function file_drop_sys(path_disk) {
		#if !js
		var content = sys.io.File.getContent(path_disk);

		// todo - check file validity

		var path = new haxe.io.Path(path_disk);

		var file_container:FileContainer = {
			key: path.file,
			json: {
				file_path: '${path.file}.${path.ext}',
				content: content
			}
		}

		storage.file_save(file_container);
		on_drop_file.dispatch(file_container);
		#end

	}

	function file_drop_web(file_list:String) {
		#if js
		if (file_list.length > 0) {
			var list:js.html.FileList = cast file_list;
			if(list.length > 0){
				var file:js.html.File = list[0];
				var path = new haxe.io.Path(file.name);
				
				trace('browser file ${file.name}');
				var reader = new js.html.FileReader();
				reader.onload = () -> {
					var file_container:FileContainer = {
						key: path.file,
						json: {
							file_path: file.name,
							content: reader.result
						}
					}
					storage.file_save(file_container);
					on_drop_file.dispatch(file_container);
				};
				reader.readAsText(file);
			}
		}
		#end
	}

	function file_save(file_container:FileContainer){
		storage.file_save(file_container);
	}

	function export_bytes(bytes_image:Bytes, file_name:String) {
		#if web
		stone.util.Browser.release_blob_bytes(bytes_image, file_name);
		#else
		var output =  sys.io.File.write(file_name, true);
		output.writeBytes(bytes_image, 0, bytes_image.length);
		output.close();
		#end
	}

	function file_new():FileContainer {
		var time_stamp = Date.now().to_time_stamp();
		return {
			key: time_stamp,
			json: {
				file_path: '$time_stamp.json',
				content: Serialize.to_string(init_empty_file())
			}
		}
	}

	function file_delete(path_file:String) {
		storage.file_delete(path_file);
	}

	function export(file_container_key) {
		#if web
		var fileJSON = storage.file_load(file_container_key);
		stone.util.Browser.release_blob_string(fileJSON.content, fileJSON.file_path);
		#end
	}

	function file_load(file_container_key:String): FileContainer {
		var item = storage.file_load(file_container_key);
		if(item == null){
			// todo : init new, store and return
		}
		return {
			key: file_container_key,
			json: item
		}
	}

	private function init_empty_file():FileModel {
		return {
			models: [for(i in 0...256) {
				name: "",
				lines: [],
				index: i
			} ]
		}
	}
}

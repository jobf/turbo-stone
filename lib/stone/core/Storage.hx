package stone.core;

import haxe.io.Bytes;
import stone.file.FileStorage;
import lime.ui.Window;
import haxe.io.Path;
import stone.core.Event;

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
		return storage.file_paths();
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

	public function file_new(content:String):FileJSON {
		var time_stamp = Date.now().to_time_stamp();
		return {
			name: '$time_stamp.json',
			content: content
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
}
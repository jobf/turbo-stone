package stone;

import stone.core.GraphicsAbstract;
import stone.core.Models.Deserialize;
import stone.core.Engine;
import stone.DesignerScene;
import stone.core.Vector;
import stone.core.Engine.RectangleGeometry;
import stone.core.Ui;
import stone.ui.Interactive;
import stone.file.FileStorage;
import stone.core.Engine.Scene;
import stone.text.Text;
import stone.ui.Tray;
import stone.ui.FileList;

using StringTools;

class FileStorageScene extends HudScene {
	var x_label = 40;
	var y_label = 40;
	var file_key_selected:String = "";
	var file_list:FileList;

	public function new(game:Game, bounds:RectangleGeometry, color:RGBA, file_name_selected:String){
		var device = "BROWSER";
		#if !web
		device = "DISK";
		#end

		var tray_sections:Array<Section> = [
			{
				contents: [
					{
						role: BUTTON,
						label: "NEW",
						interactions: {
							on_click: interactive -> {
								file_new();
							}
						}
					},
					{
						role: BUTTON,
						label: "DELETE",
						interactions: {
							on_click: interactive -> {
								file_delete();
							}
						},
						confirmation: {
							message: 'DELETE SELECTED FILE\nFROM $device  ?',
							confirm: 'DELETE',
						},
						conditions: () -> return has_file_path_selected()
					},
					#if web
					{
						role: BUTTON,
						label: "DOWNLOAD",
						interactions: {
							on_click: interactive -> {
								file_export();
							},
						},
						confirmation: {
							message: 'DOWNLOAD LINE DRAWINGS\nAS JSON'
						},
						conditions: () -> has_file_path_selected()
					}
					#end
				]
			},
			{
				contents: [
					{
						role: BUTTON,
						label: "EDIT",
						interactions: {
							on_click: interactive -> {
								file_edit();
							}
						},
						conditions: () -> has_file_path_selected()
					}
				]
			}
		];
		
		super(game, bounds, color, tray_sections);

		// trace('file_set_selected(file_name_selected) $file_name_selected');
		file_set_selected(file_name_selected);
	}

	function file_new(){
		var file_container = game.storage.file_new();
		game.storage.file_save(file_container);
		list_files(file_container.key);
	}

	function file_delete(){
		game.storage.file_delete(file_key_selected);
		file_key_selected = "";
		list_files(file_key_selected);
	}

	function file_export(){
		if (file_key_selected.length > 0) {
			game.storage.export(file_key_selected);
		}
	}

	function file_edit(){
		if (file_key_selected.length > 0) {
			var file = game.storage.file_load(file_key_selected);
			var models = Deserialize.parse_file_contents(file.json.content);
			if(models == null){
				models = {
					models: []
				}
			}
			var init_scene:Game->Scene = game -> new DesignerScene(game, bounds, Theme.bg_scene, models, file_key_selected);
			game.scene_change(init_scene);
		}
	}

	function has_file_path_selected():Bool{
		return file_key_selected.length > 0;
	}

	override public function init() {
		game.storage.on_drop_file.add(container -> {
			file_key_selected = container.key;
			list_files(file_key_selected);
		});

		file_key_selected = "";

		file_list = new FileList(
			game.graphics_layer_init,
			bounds_main,
			file_name -> {
				file_set_selected(file_name);
				ui.show(true);
			}
		);
	
		super.init();

		list_files(file_key_selected);
	}

	function file_set_selected(path_file:String) {
		file_key_selected = path_file;
	}

	function list_files(file_key_selected:String) {
		var paths = game.storage.file_paths();
		file_list.list_files(paths, file_key_selected);
		ui.show();
	}

	override public function draw() {
		super.draw();
		file_list.draw();
	}

	override public function close() {
		super.close();
		file_list.close();
	}

	override function mouse_press_main() {
		var x_mouse = Std.int(game.input.mouse_position.x);
		var y_mouse = Std.int(game.input.mouse_position.y);
		file_list.handle_mouse_click(x_mouse, y_mouse);
	}

	override function mouse_release_main() {
		file_list.ui.handle_mouse_release();
	}

	override function mouse_moved(mouse_position:Vector) {
		super.mouse_moved(mouse_position);
		var x_mouse = Std.int(mouse_position.x);
		var y_mouse = Std.int(mouse_position.y);
		file_list.ui.handle_mouse_moved(x_mouse, y_mouse);
	}
}

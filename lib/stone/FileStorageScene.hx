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
	var path_file_selected:String = "";
	var file_list:FileList;
	var file_selected_buttons:Array<stone.ui.Interactive.Button>;

	public function new(game:Game, bounds:RectangleGeometry, color:RGBA, file_name_selected:String){
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
							message: 'CONFIRM DELETE',
							confirm: 'DELETE',
						},
						conditions: () -> return has_file_path_selected()
					},
					{
						role: BUTTON,
						label: "EXPORT",
						interactions: {
							on_click: interactive -> {
								file_export();
							}
						},
						conditions: () -> has_file_path_selected()
					}
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

		trace('file_set_selected(file_name_selected) $file_name_selected');
		file_set_selected(file_name_selected);
	}

	function file_new(){
		var file:FileJSON = game.storage.file_new();
		game.storage.file_save(file);
		list_files(file.name);
	}

	function file_delete(){
		game.storage.file_delete(path_file_selected);
		path_file_selected = "";
		list_files(path_file_selected);
	}

	function file_export(){
		if (path_file_selected.length > 0) {
			game.storage.export(path_file_selected);
		}
	}

	function file_edit(){
		if (path_file_selected.length > 0) {
			var file = game.storage.file_load(path_file_selected);
			var models = Deserialize.parse_file_contents(file.content);
			if(models == null){
				models = {
					models: []
				}
			}
			var init_scene:Game->Scene = game -> new DesignerScene(game, bounds, Theme.bg_scene, models, file.name);
			game.scene_change(init_scene);
		}
	}

	function has_file_path_selected():Bool{
		return path_file_selected.length > 0;
	}

	override public function init() {

		game.storage.on_drop_file.add(file_json -> 
			{
				path_file_selected = file_json.name;
				list_files(file_json.name);

			});

		path_file_selected = "";

		file_list = new FileList(
			game.graphics_layer_init,
			bounds_main,
			file_name -> {
				file_set_selected(file_name);
				ui.show(true);
			}
		);
	
		file_selected_buttons = [
			// button_delete,
			// button_export,
			// button_edit,
		];

		super.init();

		list_files(path_file_selected);
	}

	function file_set_selected(path_file:String) {
		path_file_selected = path_file;
	}

	function list_files(path_file_selected:String) {
		var paths = game.storage.file_paths();
		file_list.list_files(paths, path_file_selected);
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
		// super.mouse_press_main();
		var x_mouse = Std.int(game.input.mouse_position.x);
		var y_mouse = Std.int(game.input.mouse_position.y);
		file_list.handle_mouse_click(x_mouse, y_mouse);
	}

	override function mouse_release_main() {
		// super.mouse_release_main();
		file_list.ui.handle_mouse_release();
	}

	override function mouse_moved(mouse_position:Vector) {
		super.mouse_moved(mouse_position);
		var x_mouse = Std.int(mouse_position.x);
		var y_mouse = Std.int(mouse_position.y);
		file_list.ui.handle_mouse_moved(x_mouse, y_mouse);
	}
}

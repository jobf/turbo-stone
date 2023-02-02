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

using StringTools;

class FileStorageScene extends HudScene {
	var x_label = 40;
	var y_label = 40;
	var path_file_selected:String = "";
	var file_list:FileList;
	var file_selected_buttons:Array<stone.ui.Interactive.Button>;

	public function new(game:Game, bounds:RectangleGeometry, color:RGBA){
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
						},
						conditions: () -> !has_file_path_selected()
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
	}

	function file_new(){
		var file:FileJSON = game.storage.file_new("");
		game.storage.file_save(file);
		list_files();
	}

	function file_delete(){
		game.storage.file_delete(path_file_selected);
		path_file_selected = "";
		list_files();
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

		game.storage.on_drop_file.add(file_json -> list_files());
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

		list_files();

		super.init();
	}

	function file_set_selected(path_file:String) {
		path_file_selected = path_file;
	}

	function list_files() {
		var paths = game.storage.file_paths();
		file_list.list_files(paths);
		// ui_refresh();
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

class FileList{
	public var ui(default, null):Ui;
	var on_file_select:String->Void;
	var labels:Array<Interactive> = [];
	var bounds:RectangleGeometry;

	public function new(graphics_init:GraphicsConstructor, bounds:RectangleGeometry,  on_file_select:String->Void){
		// file list only has interactives listed in the main area, so bounds_interactive is actually bounds_main
		this.bounds = bounds;
		ui = new Ui(graphics_init);
		this.on_file_select = on_file_select;
	}

	public function draw(){
	}

	public function close(){
		ui.clear();
	}

	public function list_files(file_names:Array<String>) {
		var length_labels = labels.length;
		while (length_labels-- > 0) {
			var label = labels.pop();
			label.erase();
		}

		var font = font_load_embedded(24);
		var height_button = Std.int(font.height_model * 1.5);
		var width_button = bounds.width;

		var bounds_interactive:RectangleGeometry = {
			y: 0,
			x: 0,
			width: width_button,
			height: height_button
		}

		trace('listing files');
		for (n => path in file_names) {
			// trace(path);
			var label = path;

			var label_geometry:RectangleGeometry = {
				y: bounds.y + (n * height_button),
				x: bounds.x,
				width: bounds_interactive.width,
				height: bounds_interactive.height
			}

			var model:InteractiveModel = {
				role: LABEL_TOGGLE(true),
				label: label,
				interactions: {
					// on_hover: on_hover,
					on_highlight: should_highlight-> {
						if(should_highlight){
							buttons_file_selected(path);
						}
						else{
							buttons_file_selected("");
						}
					},
				}
			}
			var interactive = ui.make_label(model, label_geometry, Theme.drawing_lines, Theme.bg_ui_interactive_label, false);
			@:privateAccess
			trace('label ${interactive.background.x} ${interactive.background.x} ${interactive.background.width} ${interactive.background.height}');
			labels.push(interactive);
		}
	}

	
	public function reset_hover(){
		for (label in labels) {
			label.hover(false);
		}
	}

	function buttons_file_selected(path:String){
		on_file_select(path);
	}

	public function handle_mouse_click(x_mouse:Int, y_mouse:Int){
		for (label in labels) {
			label.highlight(false);
		}
		ui.handle_mouse_click(x_mouse, y_mouse);
	}
}
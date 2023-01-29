package stone;

import stone.core.GraphicsAbstract;
import stone.core.Event;
import stone.core.Models.Deserialize;
import stone.core.Engine;
import stone.graphics.implementation.Graphics;
import peote.view.Display;
import stone.DesignerScene;
import stone.core.Vector;
import stone.core.Engine.RectangleGeometry;
import stone.input.Controller;
import stone.core.Ui;
import stone.ui.Components;
import stone.file.FileStorage;
import stone.core.Engine.Scene;
import stone.text.Text;
import stone.core.InputAbstract;

using StringTools;

class FileStorageScene extends HudScene {
	var x_label = 40;
	var y_label = 40;
	var path_file_selected:String;
	var file_list:FileList;
	var file_selected_buttons:Array<stone.ui.Components.Button>;

	override public function init() {
		super.init();

		game.storage.on_drop_file.add(file_json -> list_files());
		path_file_selected = "";

		file_list = new FileList(graphics_main, bounds_main, file_name -> file_set_selected(file_name));

		var gap = 10;
		var width_button = Std.int(text.font.width_character * 10);
		var height_button = text.font.height_model + gap;
		var x_button = bounds.width - width_button - gap;

		add_button(KEY_N, {
			on_pressed: () -> {
				var file:FileJSON = game.storage.file_new("");
				game.storage.file_save(file);
				list_files();
			},
			name: "NEW",
		});

		var button_delete = add_button(KEY_D, {
			on_pressed: () -> {
				if (path_file_selected.length > 0) {
					
					var on_confirm:ButtonModel = {
						text: "YES",
						action: ()-> {
							game.storage.file_delete(path_file_selected);
							path_file_selected = "";
							list_files();
						}
					}

					var dialog = ui.make_dialog(
						["REALLY DELETE SELECTED ?"],
						Theme.fg_ui_component,
						Theme.bg_dialog,
						[on_confirm]
					);
				}
			},
			name: "DELETE",
		});

		var button_export = add_button(KEY_X, {
			on_pressed: () -> {
				if (path_file_selected.length > 0) {
					game.storage.export(path_file_selected);
				}
			},
			name: "EXPORT",
		});

		ui.y_offset_increase(text.font.height_model);

		var button_edit = add_button(KEY_E, {
			on_pressed: () -> {
				if (path_file_selected.length > 0) {
					var hud_bounds:RectangleGeometry = {
						x: 0,
						y: 0,
						width: bounds.width,
						height: bounds.height
					}

					var file = game.storage.file_load(path_file_selected);
					var models = Deserialize.parse_file_contents(file.content);
					if(models == null){
						models = {
							models: []
						}
					}
					var init_scene:Game->Scene = game -> new DesignerScene(game, hud_bounds, Theme.bg_scene, models, file.name);
					game.scene_change(init_scene);
				}
			},
			name: "EDIT",
		});
		
		file_selected_buttons = [
			button_delete,
			button_export,
			button_edit,
		];

		list_files();
	}

	function file_set_selected(path_file:String) {
		path_file_selected = path_file;
	}

	function list_files() {
		var paths = game.storage.file_paths();
		file_list.list_files(paths);
		ui_refresh();
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
		file_list.handle_mouse_click();
	}

	override function mouse_release_main() {
		// super.mouse_release_main();
		file_list.ui.handle_mouse_release();
	}

	override function mouse_moved(mouse_position:Vector) {
		super.mouse_moved(mouse_position);
		file_list.ui.handle_mouse_moved(mouse_position);
	}

	override function ui_refresh() {
		// super.ui_refresh();
		var file_is_selected = path_file_selected.length > 0;
		@:privateAccess
		for (clicker in ui.components.clickers) {
			for (button in file_selected_buttons) {
				if(button.label.text != clicker.label.text){
					continue;
				}
				clicker.hide();
				if(file_is_selected){
					clicker.show();
				}
			}
		}
	}
}

class FileList{
	public var ui(default, null):Ui;
	var on_file_select:String->Void;
	var labels:Array<Label> = [];
	public function new(graphics:GraphicsAbstract, bounds_file_list:RectangleGeometry, on_file_select:String->Void){
		ui = new Ui(
			graphics,
			graphics, // can be same because it never uses dialog
			bounds_file_list,
			{
				y: 0,
				x: 0,
				width: bounds_file_list.width,
				height: bounds_file_list.height
			}
		);
		this.on_file_select = on_file_select;
	}

	public function draw(){
		ui.draw();
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

		trace('listing files');
		for (path in file_names) {
			trace(path);
			var label = path;
			var label_interactions:Interactions ={
				// on_hover: on_hover,
				on_highlight: should_highlight-> {
					if(should_highlight){
						buttons_file_selected(path);
					}
					else{
						buttons_file_selected("");
					}
				},
				// on_erase: on_erase,
				// on_click: component -> {
				// 	on_file_select(path);
				// }
			}

			var component = ui.make_label(label_interactions, label, Theme.drawing_lines, Theme.bg_ui_component_label);
			@:privateAccess
			trace('label ${component.background.x} ${component.background.x} ${component.background.width} ${component.background.height}');
			labels.push(component);
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

	public function handle_mouse_click(){
		for (label in labels) {
			label.highlight(false);
		}
		ui.handle_mouse_click();
	
	}
}
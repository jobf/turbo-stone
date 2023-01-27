package stone;

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

class FileStorageScene extends Scene {
	var text:Text;
	var ui:Ui;
	var x_label = 40;
	var y_label = 40;
	var font:Font;
	var actions:Map<Button, Action>;
	var path_file_selected:String;
	var labels:Array<Label> = [];

	var bounds_components:RectangleGeometry;
	var bounds_files:RectangleGeometry;
	
	public function init() {
		game.storage.on_drop_file.add(s -> list_files());
		path_file_selected = "";
		font = font_load_embedded(24);
		text = new Text(font, game.graphics);
				
		var width_button = Std.int(font.width_model * 9);

		bounds_components = {
			y: 0,
			x: bounds.width - width_button,
			width: width_button,
			height: bounds.height
		}

		bounds_files = {
			y: 0,
			x: 0,
			width: bounds.width - width_button,
			height: bounds.height
		}

		ui = new Ui(
			game.graphics,
			text,
			bounds_components,
			bounds_files
		);

		game.input.on_pressed.add(button -> switch button {
			case MOUSE_LEFT: ui.handle_mouse_click();
			case _:
		});

		game.input.on_released.add(button -> switch button {
			case MOUSE_LEFT: ui.handle_mouse_release();
			case _:
		});

		game.input.on_mouse_move.add(mouse_position -> ui.handle_mouse_moved(mouse_position));

		var gap = 10;
		var width_button = Std.int(font.width_character * 10);
		var height_button = font.height_model + gap;
		var x_button = bounds.width - width_button - gap;

		var add_button:(Button, Action) -> Void = (button_key, action) -> {
			var button = ui.make_button(
				{
					// on_hover: on_hover,
					// on_highlight: on_highlight,
					// on_erase: on_erase,
					on_click: component ->  action.on_pressed()
				},
				action.name,
				Theme.fg_ui_component,
				Theme.bg_ui_component
			);

			actions[button_key] = action;
		}

		actions = [
			// KEY_UP => {
			// 	on_pressed: set_selected_path(-1),
			// 	name: "SELECT PREVIOUS"
			// },

			// KEY_DOWN => {
			// 	on_pressed: set_selected_path(1),
			// 	name: "SELECT NEXT"
			// },

		];

		add_button(KEY_N, {
			on_pressed: () -> {
				var on_confirm:ButtonModel = {
					text: "YES",
					action: ()-> {
						var file:FileJSON = game.storage.file_new("");
						game.storage.file_save(file);
						list_files();
					}
				}

				var dialog = ui.make_dialog(
					["REALLY MAKE NEW FILE ?"],
					Theme.fg_ui_component,
					Theme.bg_dialog,
					[on_confirm]
				);
			},
			name: "NEW",
		});

		add_button(KEY_D, {
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

		add_button(KEY_X, {
			on_pressed: () -> {
				if (path_file_selected.length > 0) {
					game.storage.export(path_file_selected);
				}
			},
			name: "EXPORT",
		});

		add_button(KEY_E, {
			on_pressed: () -> {
				if (path_file_selected.length > 0) {
					var hud_bounds:RectangleGeometry = {
						x: 0,
						y: 0,
						width: bounds.width,
						height: bounds.height
					}
					var display_hud = new Display(0, 0, hud_bounds.width, hud_bounds.height);
					var graphics:Graphics = cast game.graphics;
					graphics.display_add(display_hud);

					var hud_graphics = new Graphics(display_hud, hud_bounds);
					var file = game.storage.file_load(path_file_selected);
					var models = Deserialize.parse_file_contents(file.content);
					if(models == null){
						models = {
							models: []
						}
					}
					var init_scene:Game->Scene = game -> new DesignerScene(hud_graphics, game, hud_bounds, Theme.bg_scene, models, file.name);
					game.scene_change(init_scene);
				}
			},
			name: "EDIT",
		});

		list_files();
	}

		function file_set_selected(path_file:String) {
		path_file_selected = path_file;
	}

	function load_file(name:String) {}

	function list_files() {
		var length_labels = labels.length;
		while (length_labels-- > 0) {
			var label = labels.pop();
			label.erase();
		}

		var gap = 10;
		var geometry:RectangleGeometry = {
			y: y_label,
			x: 10,
			width: 600,
			height: font.height_model,
		}
		var line_height = geometry.height + gap;

		trace('listing files');
		for (path in game.storage.file_paths()) {
			trace(path);
			var label = path;
			var label_interactions:Interactions ={
				// on_hover: on_hover,
				// on_highlight: on_highlight,
				// on_erase: on_erase,
				on_click: component -> file_set_selected(path)
			}

			var label_ui = ui.make_label(label_interactions, label, Theme.drawing_lines, Theme.bg_ui_component_label);
			geometry.y += (gap + font.height_model);
			labels.push(label_ui);
		}
	}

	public function update(elapsed_seconds:Float) {
	}

	public function draw() {
		text.draw();
	}

	public function close() {
		trace('close FileBrowseTest');
		ui.clear();
	}
}


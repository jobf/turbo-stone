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

	public function init() {
		game.storage.on_drop_file.add(s -> list_files());
		path_file_selected = "";
		font = font_load_embedded(24);
		text = new Text(font, game.graphics);

		ui = new Ui(game.graphics, text, game.input);

		game.input.on_pressed.add(button -> switch button {
			case MOUSE_LEFT: click();
			case _:
		});

		var gap = 10;
		var width_button = Std.int(font.width_character * 10);
		var height_button = font.height_model + gap;
		var x_button = bounds.width - width_button - gap;
		var y_button = gap * 3;

		var add_button:(Button, Action) -> Void = (button_key, action) -> {
			var button = ui.make_button({
				y: y_button,
				x: x_button,
				width: width_button,
				height: height_button,
			}, action.name, 0x151517ff, 0xd0b85087);

			button.on_click = () -> action.on_pressed();
			actions[button_key] = action;
			y_button += gap + font.height_model + gap;
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
				bounds,
				["REALLY MAKE NEW FILE ?"],
				0x151517ff,
				0xd0b85087,
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
						bounds,
						["REALLY DELETE SELECTED ?"],
						0x151517ff,
						0xd0b85087,
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
					var init_scene:Game->Scene = game -> new DesignerScene(hud_graphics, game, hud_bounds, 0x151517ff, models, file.name);
					game.scene_change(init_scene);
				}
			},
			name: "EDIT",
		});

		list_files();
	}

	function click() {
		var x_mouse = Std.int(game.input.mouse_position.x);
		var y_mouse = Std.int(game.input.mouse_position.y);
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
			var label_ui = ui.make_label(geometry, label, 0xffffffFF, 0xFF85AB36);
			label_ui.on_click.add(file_path -> {
				file_set_selected(file_path);
			});
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


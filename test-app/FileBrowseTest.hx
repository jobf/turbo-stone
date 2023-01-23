import stone.core.Vector;
import stone.core.Engine.RectangleGeometry;
import stone.input.Controller;
import stone.ui.Ui;
import stone.file.FileStorage;
import stone.core.Engine.Scene;
import stone.text.Text;
import stone.core.InputAbstract;
using StringTools;

class FileBrowseTest extends Scene {
	var text:Text;
	var ui:Ui;
	var x_label = 40;
	var y_label = 40;
	var font:Font;
	var actions:Map<Button, Action>;

	public function init() {
		game.storage.on_drop_file.add(s -> trace(s));
		font = font_load_embedded(24);
		text = new Text(font, game.graphics);

		
		ui = new Ui({
			word_make: text.word_make,
			line_make: game.graphics.make_line,
			fill_make: game.graphics.make_fill
		});
		mouse_position_previous = {
			y: 0,
			x: 0
		}

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
				var file:FileJSON = game.storage.file_new("");
				file_set_selected(file.name);
				list_files();
				load_file(file.name);
			},
			name: "NEW",
		});


		add_button(KEY_L, {
			on_pressed: () -> {
				var file:FileJSON = game.storage.file_new("");
				list_files();
				load_file(file.name);
			},
			name: "LOAD",
		});


		list_files();
	}


	function file_set_selected(arg0:String) {}

	function load_file(name:String) {}

	function list_files() {

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
			var label = path.toUpperCase();
			var label_ui = ui.make_label(geometry, line_height, label, 0xffffffFF, 0xfdb6b63c);
			geometry.y += (gap + font.height_model);
		}
	}

	var mouse_position_previous:Vector;
	public function update(elapsed_seconds:Float) {
		var is_x_mouse_changed = game.input.mouse_position.x != mouse_position_previous.x;
		var is_y_mouse_changed = game.input.mouse_position.y != mouse_position_previous.y;

		if (is_x_mouse_changed || is_y_mouse_changed) {
			mouse_position_previous.x = game.input.mouse_position.x;
			mouse_position_previous.y = game.input.mouse_position.y;
			var x_mouse = Std.int(game.input.mouse_position.x);
			var y_mouse = Std.int(game.input.mouse_position.y);
			ui.handle_mouse_moved(x_mouse, y_mouse);
		}
	}

	public function draw() {
		text.draw();
	}

	public function close() {}
}

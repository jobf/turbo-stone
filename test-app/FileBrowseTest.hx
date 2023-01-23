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
		var x_label_file = 10;
		var y_label_file = y_label;
		var gap = 10;
		trace('listing files');
		for (path in game.storage.file_paths()) {
			trace(path);
			var label = path.toUpperCase();
			text.word_make(x_label_file, y_label_file, label, 0xffffffFF);
			y_label_file += (gap + font.height_model);
		}
	}

	public function update(elapsed_seconds:Float) {}

	public function draw() {
		text.draw();
	}

	public function close() {}
}

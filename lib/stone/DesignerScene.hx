package stone;

import stone.file.FileStorage.FileJSON;
import stone.ui.Ui.Modal;
import lime.utils.Assets;

import peote.view.Color;
import stone.graphics.implementation.PeoteLine;
import stone.graphics.implementation.Graphics;
import stone.editing.Editor;
import stone.FileStorageScene;
import stone.core.Models;
import stone.core.GraphicsAbstract;
import stone.core.InputAbstract;
import stone.input.Controller;
import stone.core.Engine;
import stone.util.EnumMacros;
import stone.text.CodePage;
import stone.text.Text;
import stone.ui.Ui.Ui;
import stone.ui.Ui.Slider;
import stone.ui.Ui.Toggle;
import stone.ui.Ui.Button as ButtonUI;

class DesignerScene extends Scene {
	var x_center:Int;
	var y_center:Int;
	var mouse_position:Vector;
	var designer:Designer;
	var x_axis_line:PeoteLine;
	var y_axis_line:PeoteLine;
	var divisions_total:Int = 8;
	var viewport_designer:RectangleGeometry;
	var graphics_hud:Graphics;
	var file:FileModel;
	var file_name:String;
	var text:Text;
	var label_model:Word;
	var ui:Ui;
	var help:Modal;

	public function new(graphics_hud:Graphics, game:Game, bounds:RectangleGeometry, color:RGBA, file:FileModel, file_name:String) {
		super(game, bounds, color);
		this.graphics_hud = graphics_hud;
		this.file = file;
		this.file_name = file_name;
	}

	public function init() {
		// game.input.mouse_cursor_hide();
		viewport_designer = {
			y: 0,
			x: 0,
			width: bounds.height,
			height: bounds.height
		}

		mouse_position = game.input.mouse_position;
		x_center = Std.int(viewport_designer.width * 0.5);
		y_center = Std.int(viewport_designer.width * 0.5);

		var size_segment = divisions_calculate_size_segment();
		grid_draw(size_segment);

		x_axis_line = cast game.graphics.make_line(0, y_center, viewport_designer.width, y_center, 0xFF85AB10);
		y_axis_line = cast game.graphics.make_line(x_center, 0, x_center, viewport_designer.height, 0xFF85AB10);

		if (file.models.length == 0) {
			var names_map:Map<CodePage, String> = EnumMacros.nameByValue(CodePage);

			for (i in 0...256) {
				file.models.push({
					index: i,
					name: '$i',
					lines: []
				});
			}
		}

		designer = new Designer(size_segment, game.graphics, viewport_designer, file);
		settings_load();
		label_update();
	}

	var lines_grid:Array<AbstractLine> = [];

	function grid_draw(size_segment:Int) {
		if (lines_grid.length > 0) {
			var delete_index = lines_grid.length;
			while (delete_index-- > 0) {
				lines_grid[delete_index].erase();
				lines_grid.remove(lines_grid[delete_index]);
			}
		}
		for (x in 0...Std.int(viewport_designer.width / size_segment)) {
			var x_ = Std.int(x * size_segment);
			lines_grid.push(game.graphics.make_line(x_, 0, x_, viewport_designer.height, 0xD1D76210));
		}
		for (y in 0...Std.int(viewport_designer.height / size_segment)) {
			var y_ = Std.int(y * size_segment);
			lines_grid.push(game.graphics.make_line(0, y_, viewport_designer.width, y_, 0xD1D76210));
		}
	}

	function release() {
		var x_mouse = Std.int(game.input.mouse_position.x);
		var y_mouse = Std.int(game.input.mouse_position.y);
		ui.handle_mouse_release(x_mouse, y_mouse);
	}

	function click() {
		var x_mouse = Std.int(game.input.mouse_position.x);
		var y_mouse = Std.int(game.input.mouse_position.y);
		ui.handle_mouse_click(x_mouse, y_mouse);
	}

	var mouse_position_previous:Vector;

	public function update(elapsed_seconds:Float) {
		mouse_position.x = game.input.mouse_position.x;
		mouse_position.y = game.input.mouse_position.y;
		designer.update_mouse_pointer(mouse_position);

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
		// ?
	}

	public function close() {
		// ?
		ui.clear();
	}

	function label_update(){
		var label_text = '${designer.model_index}/${file.models.length - 1}';
		if(label_model != null){
			label_model.erase();
		}
		label_model = text.word_make(720, 20, label_text, 0xffffffFF);
	}

	function handle_mouse_press_left() {
		if (!designer.isDrawingLine) {
			designer.start_drawing_line({
				x: mouse_position.x,
				y: mouse_position.y
			});
		}
	}

	function handle_mouse_release_left() {
		if (designer.isDrawingLine) {
			designer.stop_drawing_line({
				x: mouse_position.x,
				y: mouse_position.y
			});
		}
	}

	function delete_line_under_mouse(){
		designer.line_under_cursor_remove();
	}

	function settings_load() {
		var font = font_load_embedded();
		font.width_model = 18;
		font.height_model = 18;
		font.width_character = 10;
		text = new Text(font, game.graphics);

		var color:RGBA = 0xffffffFF;

		

		ui = new Ui({
			word_make: text.word_make,
			line_make: game.graphics.make_line,
			fill_make: game.graphics.make_fill
		});

		game.input.on_pressed.add(button -> switch button {
			case MOUSE_LEFT: click();
			case _:
		});

		game.input.on_released.add(button -> switch button {
			case MOUSE_LEFT: release();
			case _:
		});

		mouse_position_previous = {
			x: game.input.mouse_position.x,
			y: game.input.mouse_position.y
		}

		var actions:Map<Button, Action> = [
			MOUSE_LEFT => {
				on_pressed: () -> handle_mouse_press_left(),
				on_released: () -> handle_mouse_release_left(),
				name: "DRAW"
			},
			MOUSE_MIDDLE => {
				on_pressed: () -> delete_line_under_mouse(),
				name: "DELETE"
			},
			KEY_D => {
				on_pressed: () -> delete_line_under_mouse(),
				name: "DELETE"
			}
		];

		var gap = 10;
		var width_button = Std.int(font.width_character * 10);
		var height_button = font.height_model + gap;
		var x_button = bounds.width - width_button - gap;
		var y_button = gap * 5;

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

		var add_space:Void->Void = () -> y_button += gap * 2;

		add_button(KEY_LEFT, {
			on_pressed: () -> {
				designer.set_active_figure(-1);
				label_update();
			},
			name: "PREVIOUS"
		});

		add_button(KEY_RIGHT, {
			on_pressed: () -> {
				designer.set_active_figure(1);
				label_update();
			},
			name: "NEXT"
		});

		add_space();

		add_button(KEY_C, {
			on_pressed: () -> designer.buffer_copy(),
			name: "COPY"
		});

		add_button(KEY_V, {
			on_pressed: () -> designer.buffer_paste(),
			name: "PASTE"
		});

		// add_button(KEY_N, {
		// 	on_pressed: () -> designer.add_new_figure(),
		// 	name: "NEW"
		// });

		add_button(KEY_R, {
			on_pressed: () -> designer.lines_remove(),
			name: "CLEAR"
		});
		
		add_space();
		
		add_button(KEY_O, {
			on_pressed: () -> grid_set_granularity(-1),
			name: "GRID LESS"
		});

		add_button(KEY_P, {
			on_pressed: () -> grid_set_granularity(1),
			name: "GRID MORE"
		});

		add_space();
		
		add_button(KEY_S, {
			on_pressed: () -> {
				var file_content = Serialize.to_string(file);
				var file:FileJSON = {
					name: file_name,
					content: file_content
				}

				game.storage.file_save(file);
			},
			name: "SAVE"
		});

		// revert to last save??
		// add_button(KEY_, {
		// 	on_pressed: () -> {},
		// 	name: "REVERT"
		// });

		add_button(KEY_F, {
			on_pressed: () -> game.scene_change(game -> new FileStorageScene(game, bounds, color)),
			name: "FILES"
		});

		for(i in 0...8){
			add_space();
		}

		add_button(KEY_H, {
			on_pressed: () -> {
				if(help == null){
					var help_text = [for(pair in actions.keyValueIterator()) '${pair.key} : ${pair.value.name}'];
					help = ui.make_modal({
						y: 30,
						x: 30,
						width: font.width_character * 40,
						height: font.width_character * 40
					}, font.height_model, help_text, 0x151517ff, 0xd0b85087);
				}
				else{
					help.erase();
					help = null;
				}
			},
			name: "HELP"
		});


		game.input.on_pressed.add(button -> {
			if (actions.exists(button)) {
				actions[button].on_pressed();
			}
		});
		
		game.input.on_released.add(button -> {
			if (actions.exists(button)) {
				actions[button].on_released();
			}
		});


	}

	function divisions_calculate_size_segment() {
		return Std.int(viewport_designer.height / divisions_total);
	}

	function grid_set_granularity(direction:Int) {
		if (direction > 0) {
			divisions_total = Std.int(divisions_total * 2);
		} else {
			divisions_total = Std.int(divisions_total / 2);
		}
		if (divisions_total < 2) {
			divisions_total = 2;
		}

		var size_segment = divisions_calculate_size_segment();
		grid_draw(size_segment);
		designer.granularity_set(size_segment);
	}
}

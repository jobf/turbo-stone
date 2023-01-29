package stone;

import stone.ui.Components;
import stone.core.GraphicsAbstract.RGBA;
import stone.core.GraphicsAbstract.AbstractLine;
import stone.text.Text;
import stone.core.Engine;
import stone.core.Ui;
import stone.file.FileStorage.FileJSON;
import stone.graphics.implementation.PeoteLine;
import stone.graphics.implementation.Graphics;
import stone.editing.Editor;
import stone.FileStorageScene;
import stone.core.Models;
import stone.core.InputAbstract;
import stone.input.Controller;
import stone.util.EnumMacros;
import stone.text.CodePage;

class DesignerScene extends HudScene {
	var grid_center_x:Int;
	var grid_center_y:Int;
	var mouse_position:Vector;
	var designer:Designer;
	var divisions_total:Int = 8;
	var file:FileModel;
	var file_name:String;
	var label_model:Word;

	public function new(game:Game, bounds:RectangleGeometry, color:RGBA, file:FileModel, file_name:String) {
		super(game, bounds, color);
		this.file = file;
		this.file_name = file_name;
	}

	override public function init() {
		super.init();

		game.input.on_mouse_move.add(mouse_position -> {
			if(designer.point_is_outside_grid(mouse_position)){
				game.input.mouse_cursor_show();
			}
			else{
				game.input.mouse_cursor_hide();
			}
		});

		game.input.on_pressed.add(button -> switch button {
			case MOUSE_LEFT: handle_mouse_press_left();
			case MOUSE_MIDDLE: delete_line_under_mouse();
			case _:
		});

		mouse_position = game.input.mouse_position;
		grid_center_x = Std.int(bounds_main.width * 0.5);
		grid_center_y = Std.int(bounds_main.width * 0.5);

		var size_segment = divisions_calculate_size_segment();
		grid_draw(size_segment);

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

		designer = new Designer(size_segment, game.graphics, bounds_main, file);

		ui_setup();

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

		for (x in 0...Std.int(bounds_main.width / size_segment) + 1) {
			var x_ = Std.int(x * size_segment);
			lines_grid.push(game.graphics.make_line(x_, 0, x_, bounds_main.height, Theme.grid_lines));
		}

		for (y in 0...Std.int(bounds_main.height / size_segment)) {
			var y_ = Std.int(y * size_segment);
			lines_grid.push(game.graphics.make_line(0, y_, bounds_main.width, y_, Theme.grid_lines));
		}

		lines_grid.push(game.graphics.make_line(0, grid_center_y, bounds_main.width, grid_center_y, Theme.grid_lines_center));
		lines_grid.push(game.graphics.make_line(grid_center_x, 0, grid_center_x, bounds_main.height, Theme.grid_lines_center));
	}

	override public function update(elapsed_seconds:Float) {
		designer.update_mouse_pointer(mouse_position);
	}

	function label_update(){
		var label_text = '${designer.model_index}/${file.models.length - 1}';
		if(label_model != null){
			label_model.erase();
		}
		label_model = text.word_make(720, 20, label_text, Theme.drawing_lines);
	}

	function handle_mouse_press_left() {
		if(designer.point_is_outside_grid(mouse_position)){
			ui.handle_mouse_click();
			return;
		}

		if(ui.dialog_is_active()){
			return;
		}

		designer.start_drawing_line(mouse_position);
	}

	function handle_mouse_release_left() {
		if(designer.point_is_outside_grid(mouse_position)){
			ui.handle_mouse_release();
		}

		designer.stop_drawing_line(mouse_position);
	}

	function delete_line_under_mouse(){
		if(ui.dialog_is_active()){
			return;
		}
		designer.line_under_cursor_remove();
	}

	function ui_setup() {
		var color:RGBA = Theme.drawing_lines;
		var gap = 10;
		var width_button = Std.int(text.font.width_character * 10);
		var height_button = text.font.height_model + gap;
		var x_button = bounds.width - width_button - gap;
		var y_button = gap * 5;

		var add_space:Void->Void = () -> ui.y_offset_increase(gap * 2);

		add_button(KEY_D, {
			on_pressed: () -> {
				delete_line_under_mouse();
			},
			name: "DELETE"
		});


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
			on_pressed: () -> {
				var warning_save = ui.make_dialog(
					["UNSAVED CHANGES WILL BE LOST", "CONTINUE TO FILE BROWSER?"],
					Theme.fg_ui_component,
					Theme.bg_dialog,
					[{
						text: "YES",
						action: () -> game.scene_change(game -> new FileStorageScene(game, bounds, color))
					}]
				);
			},
			name: "FILES"
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
		return Std.int(bounds_main.height / divisions_total);
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

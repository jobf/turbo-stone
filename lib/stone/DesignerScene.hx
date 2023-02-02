package stone;

import haxe.io.Path;
import stone.file.FileStorage.FileContainer;
import stone.ui.Interactive.overlaps_rectangle;
import stone.core.GraphicsAbstract.RGBA;
import stone.core.GraphicsAbstract.AbstractLine;
import stone.text.Text;
import stone.core.Engine;
import stone.file.FileStorage.FileJSON;
import stone.editing.Editor;
import stone.FileStorageScene;
import stone.core.Models;
import stone.util.EnumMacros;
import stone.text.CodePage;
import stone.ui.Tray;
import stone.file.PNG;
import stone.graphics.implementation.Graphics;


using stone.util.DateExtensions;
using stone.editing.Editor.GraphicsExtensions;

class DesignerScene extends HudScene {
	var grid_center_x:Int;
	var grid_center_y:Int;
	var mouse_position:Vector;
	var designer:Designer;
	var divisions_total:Int = 8;
	var file:FileModel;
	var file_list_key:String;
	var label_model:Word;

	public function new(game:Game, bounds:RectangleGeometry, color:RGBA, file:FileModel, file_list_key:String) {
		var device = "BROWSER";
		#if !web
		device = "DISK";
		#end

		var tray_sections:Array<Section> = [
			{
				contents: [
					// hidden commands
					{
						role: BUTTON,
						label: "DRAG TO DRAW",
						key_code: MOUSE_LEFT,
						interactions: {
							on_click: interactive -> {
								if(overlaps_rectangle(bounds_main, game.input.mouse_position)){
									designer.start_drawing_line(game.input.mouse_position);
								}
							}
						},
						show_in_tray: false,
					},
					{
						role: BUTTON,
						label: "DELETE LINE UNDER CURSOR",
						key_code: MOUSE_MIDDLE,
						interactions: {
							on_click: interactive -> {
								delete_line_under_mouse();
							}
						},
						show_in_tray: false,
					},
					{
						role: BUTTON,
						label: "DELETE LINE UNDER CURSOR",
						key_code: KEY_D,
						interactions: {
							on_click: interactive -> {
								delete_line_under_mouse();
							}
						},
						show_in_tray: false,
					},
					// visible commands
					{
						role: LABEL,
						label: " / ",
						label_change: ()-> format_model_index()
					},
					{
						role: BUTTON,
						label: "PREVIOUS",
						key_code: KEY_LEFT,
						interactions: {
							on_click: interactive -> {
								designer.set_active_figure(-1);
							}
						}
					},
					{
						role: BUTTON,
						label: "NEXT",
						key_code: KEY_RIGHT,
						interactions: {
							on_click: interactive -> {
								designer.set_active_figure(1);
							}
						}
					}
				]
			},
			{
				contents: [
					{
						role: BUTTON,
						label: "COPY",
						key_code: KEY_C,
						interactions: {
							on_click: interactive -> {
								designer.buffer_copy();
							}
						}
					},
					{
						role: BUTTON,
						label: "PASTE",
						key_code: KEY_V,
						interactions: {
							on_click: interactive -> {
								designer.buffer_paste();
							}
						}
					},
					{
						role: BUTTON,
						label: "CLEAR",
						key_code: KEY_R,
						interactions: {
							on_click: interactive -> {
								designer.lines_remove();
							}
						},
						confirmation: {
							message: 'CLEAR ALL LINES FROM DISPLAY ?',
							confirm: 'CLEAR',
						}
					}
				]
			},
			{
				contents: [
					{
						role: BUTTON,
						label: "GRID LESS",
						interactions: {
							on_click: interactive -> {
								grid_set_granularity(-1);
							}
						}
					},
					{
						role: BUTTON,
						label: "GRID MORE",
						interactions: {
							on_click: interactive -> {
								grid_set_granularity(1);
							}
						}
					},
					// {
					// 	role: BUTTON,
					// 	label: "GRID TOGGLE",
					// 	interactions: {
					// 		on_click: interactive -> {

					// 		}
					// 	}
					// }
				]
			},
			{
				contents: [
					{
						role: BUTTON,
						label: "SAVE",
						key_code: KEY_S,
						interactions: {
							on_click: interactive -> {
								save_file();
							}
						},
						confirmation: {
							message: 'SAVE ALL CHANGES TO $device ?',
							confirm: "YES",
							cancel: "NO"
						}
					},
					{
						role: BUTTON,
						label: "PNG",
						interactions: {
							on_click: interactive -> {
								export_png();
							}
						},
						confirmation: {
							message: 'EXPORT PNG TO DISK ?',
							confirm: "YES",
							cancel: "NO"
						}
					}
				]
			},
			{
				contents: [
					{
						role: BUTTON,
						label: "FILES",
						interactions: {
							on_click: interactive -> {
								game.scene_change(game -> new FileStorageScene(game, bounds, color, file_list_key));
							}
						},
						confirmation: {
							message: 'UNSAVED CHANGES\nWILL BE\nLOST',
							confirm: "CONTINUE",
						}
					},
					{
						role: BUTTON,
						label: "OVERVIEW",
						interactions: {
							on_click: interactive -> {
								game.scene_change(game -> new OverviewScene(game, bounds, color, file, file_list_key));
							}
						}
					}
				]
			},
		];

		super(game, bounds, color, tray_sections);
		this.file = file;
		this.file_list_key = file_list_key;
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

		designer = new Designer(size_segment, graphics_main, bounds_main, file);
		ui.show();
	}

	function save_file(){
		var file_content = Serialize.to_string(file);

		var file_container:FileContainer = {
			key: file_list_key,
			json: {
				file_path: '$file_list_key.json',
				content: file_content
			}
		}

		game.storage.file_save(file_container);
	}

	function export_png(){
		var width_png:Int = bounds_main.height;
		var height_png:Int = bounds_main.height;

		var graphics:Graphics = cast graphics_main.graphics_new_layer(width_png, height_png);
		var figure = graphics.map_figure(file.models[designer.model_index], designer.translation);
		
		var data_pixels = readPixels(graphics.display);

		if(data_pixels != null){
			var time_stamp = Date.now().to_time_stamp();
			var file_name = '$time_stamp.png';
			var png_bytes = PNG.lime_bytes(data_pixels, width_png, height_png, file_name);
			game.storage.export_bytes(png_bytes, file_name);
		}

		graphics.display.peoteView.removeDisplay(graphics.display);
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
			lines_grid.push(graphics_main.make_line(x_, 0, x_, bounds_main.height, Theme.grid_lines));
		}

		for (y in 0...Std.int(bounds_main.height / size_segment)) {
			var y_ = Std.int(y * size_segment);
			lines_grid.push(graphics_main.make_line(0, y_, bounds_main.width, y_, Theme.grid_lines));
		}

		lines_grid.push(graphics_main.make_line(0, grid_center_y, bounds_main.width, grid_center_y, Theme.grid_lines_center));
		lines_grid.push(graphics_main.make_line(grid_center_x, 0, grid_center_x, bounds_main.height, Theme.grid_lines_center));
	}

	override public function update(elapsed_seconds:Float) {
		designer.update_mouse_pointer(mouse_position);
	}

	function format_model_index():String{
		if(designer == null || file == null){
			return "-";
		}

		return '${designer.model_index}/${file.models.length - 1}';
	}

	function handle_mouse_press_left() {
		if(designer.point_is_outside_grid(mouse_position)){
			return;
		}

		designer.start_drawing_line(mouse_position);
	}

	override function mouse_release_main() {
		designer.stop_drawing_line(mouse_position);
	}

	override function mouse_moved(mouse_position:Vector) {
		if(designer.isDrawingLine){
			if(!overlaps_rectangle(bounds_main, mouse_position)){
				designer.stop_drawing_line(mouse_position);
			}
		}

		super.mouse_moved(mouse_position);
	}

	function delete_line_under_mouse(){
		designer.line_under_cursor_remove();
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

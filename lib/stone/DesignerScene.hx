package stone;

import haxe.io.Path;
import stone.file.FileStorage.FileContainer;
import stone.ui.Interactive;
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
using StringTools;

class DesignerScene extends HudScene {
	var grid_center_x:Int;
	var grid_center_y:Int;
	var mouse_position:Vector;
	var designer:Designer;
	var grid_lines_total:Int = 8;
	var grid_snapping_modifer:Int = 8;
	var file:FileModel;
	var file_list_key:String;
	var label_model:Word;
	var device:String;

	public function new(game:Game, bounds:RectangleGeometry, color:RGBA, file:FileModel, file_list_key:String) {
		device = "BROWSER";
		#if !web
		device = "DISK";
		#end

		var tray_sections:Array<Section> = [
			{
				sort_order: 100,
				contents: [
					// hidden commands
					{
						role: BUTTON,
						label: "DRAG TO DRAW",
						key_code: MOUSE_LEFT,
						can_be_disabled: false,
						interactions: {
							on_click: interactive -> {
								if(is_designer_blocked()){
									return;
								}
								if(overlaps_rectangle(bounds_main, game.input.mouse_position)){
									designer.start_drawing_line(game.input.mouse_position);
								}
							},
							on_release: interactive -> {
								if(is_designer_blocked()){
									return;
								}
								designer.stop_drawing_line(mouse_position);
							}
						},
						show_in_tray: false,
					},
					{
						role: BUTTON,
						label: "DELETE LINE UNDER CURSOR",
						key_code: MOUSE_MIDDLE,
						can_be_disabled: false,
						interactions: {
							
							on_click: interactive -> {
								if(is_designer_blocked()){
									return;
								}
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
								if(is_designer_blocked()){
									return;
								}
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
				sort_order: -130,
				title: 'GRID',
				contents: [
					{
						sort_order: -30,
						role: SLIDER(get_initial_snap_slider_fraction()),
						label: "SNAP",
						interactions: {
							on_change: interactive -> {
								var slider:Slider = cast interactive;
								handle_snap_slider(slider);
							}
						}
					},
					{
						sort_order: -40,
						role: SLIDER(get_initial_grid_slider_fraction()),
						label: "LINES",
						interactions: {
							on_change: interactive -> {
								var slider:Slider = cast interactive;
								handle_grid_slider(slider);
							}
						}
					},
					{
						sort_order: -50,
						role: TOGGLE(true),
						label: "SHOW",
						interactions: {
							on_click: interactive -> {
								var toggle:Toggle = cast interactive;
								// note we set the flipped bool because this function will be called before the toggle is flipped
								grid_set_visibility(!toggle.is_toggled);
							}
						}
					},
				]
			},

			// {
			// 	contents: [
			// 	]
			// },

			{
				sort_order: -80,
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
							message: 'SAVE ALL CHANGES TO $device  ?',
							confirm: "YES",
							cancel: "NO"
						}
					},
					#if web
					{
						role: BUTTON,
						label: "DOWNLOAD",
						interactions: {
							on_click: interactive -> {
								// export_png();
								game.storage.export(file_list_key);
							}
						},
						sub_contents:[
								{
									role:BUTTON,
									label: "PNG",
									interactions: {
										on_click: interactive -> {
											export_png();
										},
										on_click_closes_menu: true,
									}
								}
						],
						confirmation: {
							message: 'DOWNLOAD\nJSON\nOR\nPNG ?',
							confirm: "JSON",
							cancel: "CANCEL",
							
						},
					}
					#end
				]
			},
			{
				// sort_order: 0,
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
							message: 'UNSAVED CHANGES\nWILL BE\nLOST  !',
							confirm: "CONTINUE",
							conditions: () ->  return designer.is_file_modified
						}
					},
					{
						role: BUTTON,
						label: "SPRITESHEET",
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

	override function draw() {
		super.draw();
		designer.draw();
	}

	override function close() {
		super.close();
		designer.erase();
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
		designer.reset_file_status();
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

	function is_designer_blocked():Bool{
		return tray.is_blocking_main;
	}

	// function is_file_changed():Bool{
	// 	// var is_file_changed = designer != null && designer.is_file_changed();
	// 	// trace('is file changed? $is_file_changed');
	// 	return is_file_changed;
	// }

	function grid_set_visibility(is_visible:Bool){
		trace('grid_set_visibility $is_visible');
		var alpha:Int = is_visible ? Theme.grid_lines_alpha : 0x00;
		for (line in lines_grid) {
			line.color.a = alpha;
		}
	}

	var grid_slots:Array<Int> = [2, 4, 8, 16, 32, 64, 128];
	
	function handle_grid_slider(slider:Slider){
		var index = Std.int(grid_slots.length * slider.fraction);
		var divisions = grid_slots.length - 1;
		var click = 1 / divisions;
		slider.set_detent(click * index);
		grid_lines_total = grid_slots[index];
		var size_segment = divisions_calculate_size_segment();
		grid_draw(size_segment);
	}

	function divisions_calculate_size_segment() {
		return Std.int(bounds_main.height / grid_lines_total);
	}
	
	var snap_slots:Array<Int> = [64, 32, 16, 8, 4, 2];

	function handle_snap_slider(slider:Slider){
		var index = Std.int(snap_slots.length * slider.fraction);
		var divisions = snap_slots.length - 1;
		var click = 1 / divisions;
		slider.set_detent(click * index);
		designer.granularity_set_modifier(snap_slots[index]);
	}

	function get_initial_snap_slider_fraction():Float{
		var index = snap_slots.indexOf(grid_snapping_modifer);
		var divisions = snap_slots.length - 1;
		var fraction = index / divisions;
		// trace('snap fraction $fraction');
		return fraction;
	}


	function get_initial_grid_slider_fraction():Float{
		var index = grid_slots.indexOf(grid_lines_total);
		var divisions = grid_slots.length - 1;
		var fraction = index / divisions;
		return fraction;
	}
}

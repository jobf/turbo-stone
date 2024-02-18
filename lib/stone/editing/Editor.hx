package stone.editing;


import Cursor;
import Graphics;
import haxe.ds.ArraySort;
import haxe.io.Bytes;
import haxe.io.UInt8Array;
import stone.abstractions.Graphic;
import stone.core.Engine;
import stone.core.Models;

using stone.editing.Editor.GraphicsExtensions;

@:publicFields
class EditorTranslation {
	var bounds_view:Rectangle;

	private var x_center:Int;
	private var y_center:Int;
	private var points_in_translation_x = 10;
	private var points_in_translation_y = 10;

	var bounds_width_half:Float;
	var bounds_height_half:Float;

	function new(bounds_view:Rectangle, points_in_translation_x:Int = 1, points_in_translation_y:Int = 1) {
		this.bounds_view = bounds_view;
		this.points_in_translation_x = points_in_translation_x;
		this.points_in_translation_y = points_in_translation_y;
		size_set(bounds_view.width, bounds_view.height);
	}

	function size_set(width:Int, height:Int) {
		bounds_view.width = width;
		bounds_view.height = height;
		x_center = Std.int(bounds_view.width * 0.5);
		y_center = Std.int(bounds_view.height * 0.5);
		bounds_width_half = bounds_view.width * 0.5;
		bounds_height_half = bounds_view.height * 0.5;
	}

	function view_to_model_point(point_in_view:Vector2):Vector2 {
		var offset_point:Vector2 = {
			x: point_in_view.x - bounds_width_half,
			y: point_in_view.y - bounds_height_half
		}

		var transformed_point:Vector2 = {
			x: (offset_point.x / bounds_view.width) * points_in_translation_x,
			y: (offset_point.y / bounds_view.height) * points_in_translation_y,
		}

		return transformed_point;
	}

	function model_to_view_point(point_in_model:Vector2):Vector2 {
		var transformed_point:Vector2 = {
			x: (point_in_model.x * bounds_view.width) / points_in_translation_x,
			y: (point_in_model.y * bounds_view.height) / points_in_translation_y,
		}

		var offset_point:Vector2 = {
			x: transformed_point.x + bounds_width_half + bounds_view.x,
			y: transformed_point.y + bounds_height_half  + bounds_view.y
		}

		return offset_point;
	}
}

@:publicFields
class Designer {
	var model_index(default, null):Int = 0;

	private var mouse_pointer:FillBase;

	var line_under_cursor:LineBase;

	private var size_segment:Int;
	private var size_segment_half:Int;
	private var size_snapping: Int;
	private var snapping_mod:Int = 4;
	private var graphics:Graphics;
	private var mouse_pointer_graphics:Cursor;
	private var bounds_grid:Rectangle;
	var is_file_modified(default, null):Bool;

	var file(default, null):FileModel;

	var translation(default, null):EditorTranslation;

	var isDrawingLineBase(default, null):Bool = false;
	var figure(default, null):Figure;

	function new(size_segment:Int, graphics:GraphicsBase, bounds_grid:Rectangle, file:FileModel) {
		this.file = file;
		is_file_modified = false;
		granularity_set(size_segment);
		this.graphics = cast graphics;
		this.bounds_grid = bounds_grid;
		size_snapping = Std.int(bounds_grid.height / 4);
		mouse_pointer_graphics = new Cursor(this.graphics.display);
		var mouse_pointer_size = Std.int(size_segment * 0.5);
		mouse_pointer = mouse_pointer_graphics.make_fill(0, 0, mouse_pointer_size, mouse_pointer_size, Theme.cursor);
		mouse_pointer.rotation = 45;
		translation = new EditorTranslation(bounds_grid, 1, 1);
		figure_init();
	}

	function erase(){
		mouse_pointer_graphics.erase();
	}

	function draw() {
		mouse_pointer_graphics.draw();
	}

	function granularity_set(size_segment:Int) {
		this.size_segment = Std.int((size_segment * 0.5));
		this.size_segment_half = -Std.int((size_segment * 0.5));
	}
	
	function granularity_set_modifier(mod:Int){
		snapping_mod = mod;
	}

	private function line_under_cursor_(position_cursor:Vector2):Null<LineBase> {
		for (line in figure.lines) {
			var overlaps:Bool = position_cursor.line_overlaps_point(line.point_from, line.point_to);
			if (overlaps) {
				return line;
			}
		}
		return null;
	}

	function line_under_cursor_remove() {
		if (line_under_cursor == null) {
			return;
		}
		var model_point_from = translation.view_to_model_point(line_under_cursor.point_from);
		var model_point_to = translation.view_to_model_point(line_under_cursor.point_to);

		var models_under_cursor = figure.model.filter(model -> model.from.x == model_point_from.x && model.from.y == model_point_from.y
			&& model.to.x == model_point_to.x && model.to.y == model_point_to.y);

		if (models_under_cursor.length > 0) {
			figure.model.remove(models_under_cursor[0]);
			figure.lines.remove(line_under_cursor);
			line_under_cursor.erase();
		}
	}

	function update_mouse_pointer(mouse_position:Vector2) {
		if (point_is_outside_grid(mouse_position)) {
			return;
		}

		mouse_position.x = round_to_nearest(mouse_position.x, size_snapping / snapping_mod);
		mouse_position.y = round_to_nearest(mouse_position.y, size_snapping / snapping_mod);
		mouse_pointer.x = mouse_position.x;
		mouse_pointer.y = mouse_position.y;
		if (isDrawingLineBase) {
			var line = figure.line_newest();
			line.point_to.x = mouse_position.x;
			line.point_to.y = mouse_position.y;
		} else {
			line_under_cursor = line_under_cursor_(mouse_position);
			for (line in figure.lines) {
				var overlaps = line == line_under_cursor;
				line.color = overlaps ? Theme.drawing_lines_hover : Theme.drawing_lines;
			}
		}
	}

	private function figure_init() {
		if (file.models.length == 0) {
			file.models = [
				{
					index: 0,
					lines: []
				}
			];
		}
		ArraySort.sort(file.models, (a, b) -> {
			if (a.index < b.index)
				return -1;
			if (a.index > b.index)
				return 1;
			return 0;
		});
		figure = graphics.map_figure(file.models[model_index], translation);
	}

	private function erase_figure_graphics() {
		// trace('clearing figure with ${figure.lines.length} lines');
		// todo refactor to have separate graphics buffer for lines in designer
		// graphics.buffer_lines.clear(true, true);
		for (i in 0...figure.lines.length) {
			line_erase(figure.lines[i]);
		}
		// trace('cleared figure');
		// trace('has remaining lines ${figure.lines.length}');
		// trace('has remaining points ${figure.model.length}');
	}

	function set_active_figure(direction:Int) {
		erase_figure_graphics();
		var index_next = (model_index + direction);
		index_next = (index_next % file.models.length + file.models.length) % file.models.length;
		// trace('next figure $index_next');

		model_index = index_next;
		// trace('show ${model_name()}');

		figure = graphics.map_figure(file.models[model_index], translation);
	}

	function add_new_figure() {
		erase_figure_graphics();
		file.models.push({
			index: file.models.length,
			lines: []
		});

		model_index = file.models.length - 1;
		trace('new figure $model_index');

		figure = graphics.map_figure(file.models[model_index], translation);
	}

	private var line_buffer:Array<LineBaseModel>;

	function buffer_copy() {
		line_buffer = figure.model;
	}

	function buffer_paste() {
		if (line_buffer != null) {
			for (line in line_buffer) {
				// file.models[model_index]
				file.models[model_index].lines.push(line);
			}
			erase_figure_graphics();
			figure = graphics.map_figure(file.models[model_index], translation);
		}
	}

	function lines_remove() {
		erase_figure_graphics();
		file.models[model_index].lines = [];
		figure = graphics.map_figure(file.models[model_index], translation);
	}

	function line_erase(line:LineBase) {
		// trace('designer clean line $line');
		line.erase();
	}

	function model_name():String {
		return '$model_index : ${file.models[model_index].name}';
	}

	private function map_line(from:Vector2, to:Vector2):LineBaseModel {
		return {
			from: translation.view_to_model_point(from),
			to: translation.view_to_model_point(to)
		}
	}

	function point_is_outside_grid(point:Vector2):Bool{
		return (point.x > bounds_grid.x + bounds_grid.width || point.y > bounds_grid.y + bounds_grid.height);
	}

	function start_drawing_line(point:Vector2) {
		if (isDrawingLineBase) {
			trace('already drawing line?');
			return;
		}

		isDrawingLineBase = true;

		var x = round_to_nearest(point.x, size_snapping / snapping_mod);
		var y = round_to_nearest(point.y, size_snapping / snapping_mod);
		var line:LineBase = graphics.make_line(x, y, x, y, Theme.drawing_lines);
		
		figure.lines.push(line);
		
		trace('start_drawing_line ${x} ${y}');
	}

	function stop_drawing_line(point:Vector2) {
		if (!isDrawingLineBase) {
			return;
		}
		isDrawingLineBase = false;

		var line = figure.line_newest();
		line.point_to.x = round_to_nearest(point.x, size_snapping / snapping_mod);
		line.point_to.y = round_to_nearest(point.y, size_snapping / snapping_mod);

		figure.model.push(map_line(line.point_from, line.point_to));
		is_file_modified = true;

		// for (line in figure.lines) {
		// 	trace('${line.point_from.x},${line.point_from.y} -> ${line.point_to.x},${line.point_to.y}');
		// }
		trace('stop_drawing_line ${point.x} ${point.y}');
	}

	function png_data_from_figure(figure:FigureModel, translation:EditorTranslation, width:Int, height:Int):UInt8Array{
		return graphics.png_data_from_figure(figure, translation, width, height);
	}

	function reset_file_status() {
		is_file_modified = false;
	}

	private function round_to_nearest(value:Float, interval:Float):Float {
		return Math.round(value / interval) * interval;
	}
}

@:publicFields
@:structInit
class Figure {
	var model:Array<LineBaseModel>;
	var lines:Array<LineBase>;

	function line_newest():LineBase {
		return lines[lines.length - 1];
	}
}

@:publicFields
class GraphicsExtensions{
	static function map_figure(graphics:GraphicsBase, model:FigureModel, translation:EditorTranslation):Figure {
		var convert_line:LineBaseModel->LineBaseModel = line -> {
			from: translation.model_to_view_point(line.from),
			to: translation.model_to_view_point(line.to)
		}

		// trace('drawing model with ${model.lines.length} lines');

		return {
			model: model.lines,
			lines: graphics.model_to_lines(model.lines.map(line -> convert_line(line)), Theme.drawing_lines)
		}
	}
}
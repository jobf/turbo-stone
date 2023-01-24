package stone.ui;

import stone.core.Ui;
import stone.core.Event;
import stone.core.Engine;
import stone.text.Text;
import stone.core.GraphicsAbstract;

class Slider {
	var label:Word;
	var track:AbstractLine;
	var handle:AbstractFillRectangle;

	public var is_dragging(default, null):Bool;
	public var x(get, never):Int;
	public var x_min(get, never):Int;
	public var x_max(get, never):Int;
	public var on_move:Float->Void = f -> trace('on_move $f');

	public function new(geometry:RectangleGeometry, label:String, color:RGBA, graphics:GraphicsAbstract, text:Text) {

		var width_center = Std.int(geometry.width * 0.5);
		var x_label = Std.int(geometry.x + width_center);
		var y_label = geometry.y;
		var width_track = geometry.width;
		var x_track = geometry.x;
		var y_track = geometry.y + Std.int(geometry.height * 0.5);
		var size_handle = Std.int(geometry.height * 0.4);

		this.label = text.word_make(x_label, y_label, label, color);
		this.track = graphics.make_line(x_track, y_track, x_track + width_track, y_track, color);
		this.handle = graphics.make_fill(x_track, y_track, size_handle, size_handle, color);
		
		is_dragging = false;
	}

	public function overlaps_handle(x_mouse:Int, y_mouse:Int) {
		x_mouse = Std.int(x_mouse + handle.width * 0.5);
		y_mouse = Std.int(y_mouse + handle.height * 0.5);

		var x_overlaps = x_mouse > handle.x && handle.x + handle.width > x_mouse;
		var y_overlaps = y_mouse > handle.y && handle.y + handle.height > y_mouse;
		return x_overlaps && y_overlaps;
	}

	public function click() {
		is_dragging = true;
		trace('click!');
	}

	public function release() {
		is_dragging = false;
		trace('!click');
	}

	public function drag(direction:Int) {
		handle.x += direction;
	}

	function get_x():Int {
		return Std.int(handle.x);
	}

	public function move(x_mouse:Int) {
		handle.x = x_mouse;
		var x_proportional = handle.x - track.point_from.x;
		on_move(x_proportional / track.length);
	}

	function get_x_min():Int {
		return Std.int(track.point_from.x);
	}

	function get_x_max():Int {
		return Std.int(track.point_from.x + track.length);
	}
}

class Toggle {
	var label:Word;
	var track:AbstractLine;
	var handle:AbstractFillRectangle;

	public var is_enabled(default, null):Bool;
	public var on_change:Bool->Void = b -> trace('on_change $b');

	public function new(geometry:RectangleGeometry, label:String, color:RGBA, graphics:GraphicsAbstract, text:Text, is_enabled:Bool) {
		var width_center = Std.int(geometry.width * 0.5);
		var x_label = Std.int(geometry.x + width_center);
		var y_label = geometry.y;
		var width_track = geometry.width * 0.2;
		var y_track = geometry.y + Std.int(geometry.height * 0.5);
		var x_track = Std.int(x_label - (width_track * 0.5));
		var size_handle = Std.int(geometry.height * 0.4);

		this.label = text.word_make(x_label, y_label, label, color);
		this.track = graphics.make_line(x_track, y_track, x_track + width_track, y_track, color);
		this.handle = graphics.make_fill(x_track, y_track, size_handle, size_handle, color);
		this.is_enabled = is_enabled;

		handle_move();
	}

	public function overlaps_handle(x_mouse:Int, y_mouse:Int) {
		x_mouse = Std.int(x_mouse + handle.width * 0.5);
		y_mouse = Std.int(y_mouse + handle.height * 0.5);

		var x_overlaps = x_mouse > handle.x && handle.x + handle.width > x_mouse;
		var y_overlaps = y_mouse > handle.y && handle.y + handle.height > y_mouse;
		return x_overlaps && y_overlaps;
	}

	public function click() {
		is_enabled = !is_enabled;
		handle_move();
		on_change(is_enabled);
	}

	inline function handle_move() {
		var x_handle = is_enabled ? track.point_to.x : track.point_from.x;
		handle.x = x_handle;
	}
}

class Button {
	var label:Word;
	var background:AbstractFillRectangle;

	public var on_click:Void->Void = () -> trace('on_click');
	var clean_up:Button->Void;

	public function new(geometry:RectangleGeometry, label:String, color_text:RGBA, color_background:RGBA, graphics:GraphicsAbstract, text:Text, clean_up:Button->Void) {
		this.clean_up = clean_up;

		var x_center = Std.int(geometry.width * 0.5);
		var y_center = Std.int(geometry.height * 0.5);

		var x_background = Std.int(geometry.x + x_center);
		var y_background = Std.int(geometry.y + y_center);

		this.background = graphics.make_fill(x_background, y_background, geometry.width, geometry.height, color_background);
		this.label = text.word_make(x_background, y_background, label, color_text);
	}

	public function overlaps_background(x_mouse:Int, y_mouse:Int) {
		x_mouse = Std.int(x_mouse + background.width * 0.5);
		y_mouse = Std.int(y_mouse + background.height * 0.5);

		var x_overlaps = x_mouse > background.x && background.x + background.width > x_mouse;
		var y_overlaps = y_mouse > background.y && background.y + background.height > y_mouse;
		return x_overlaps && y_overlaps;
	}

	public function click() {
		on_click();
	}

	public function erase() {
		label.erase();
		background.erase();
		dispose();
	}
	
	public function dispose(){
		clean_up(this);
	}
}

class Modal {
	var lines:Array<Word>;
	var background:AbstractFillRectangle;

	public function new(geometry:RectangleGeometry, lines_text:Array<String>, color_text:RGBA, color_background:RGBA, graphics:GraphicsAbstract, text:Text) {
		var width_center = Std.int(geometry.width * 0.5);
		var height_center = Std.int(geometry.width * 0.5);
		background = graphics.make_fill(geometry.x + width_center, geometry.y + height_center, geometry.width, geometry.height, color_background);
		var gap = 10;
		var y_label = geometry.y + (gap * 3);
		var x_label = geometry.x + gap;
		lines = [];
		for (string in lines_text) {
			lines.push(text.word_make(x_label, y_label, string, color_text));
			y_label += text.font.height_model + gap;
		}
	}

	public function erase() {
		var index_line = lines.length;
		while (index_line-- > 0) {
			var line = lines.pop();
			line.erase();
		}
		background.erase();
	}
}

@:structInit
class ButtonModel{
	public var text:String;
	public var action:Void->Void;
}

class Dialog<T> {
	var lines:Array<Word>;
	var background:AbstractFillRectangle;

	var buttons:Array<Button> = [];
	var actions:Array<ButtonModel>;

	public var on_erase(default, null):Event<String>;

	public function new(geometry_viewport:RectangleGeometry, lines_text:Array<String>, color_text:RGBA, color_background:RGBA, graphics:GraphicsAbstract,
			ui:Ui, text:Text, actions:Array<ButtonModel>=null) {
		on_erase = new Event();

		if(actions == null){
			this.actions = [];
		}
		else{
			this.actions = actions;
		}

		var width_center = Std.int(geometry_viewport.width * 0.5);
		var height_center = Std.int(geometry_viewport.width * 0.5);

		var length_line_max = 0;
		for (line in lines_text) {
			if(line.length > length_line_max){
				length_line_max = line.length;
			}
		}
		
		var gap = 10;
		var width_text = text.font.width_model * length_line_max;
		var height_text = (text.font.height_model + gap) * lines_text.length;

		var width_padding = text.font.width_model * 4;
		var height_padding = text.font.height_model * 4;

		var width_background = width_text + width_padding;
		var height_background = height_text + height_padding;
		
		var height_background_center = height_background * 0.5;

		var x_background = geometry_viewport.x + width_center;
		var y_background = Std.int(geometry_viewport.y + height_center - (height_background_center * 0.5));

		background = graphics.make_fill(
			x_background,
			y_background,
			width_background,
			height_background,
			color_background
		);
		
		var x_label = Std.int(x_background);
		var y_label = Std.int(y_background - (height_text * 0.5));

		lines = [];
		for (line in lines_text) {
			lines.push(text.word_make(
				x_label,
				y_label,
				line.toUpperCase(),
				color_text
			));
			y_label += text.font.height_model + gap;
		}

		// add cancel action
		this.actions.push({
			text: "CANCEL",
			action: ()-> return
		});

		var buttons_count = this.actions.length;
		var buttons_characters_count = 0;
		for (model in this.actions) {
			buttons_characters_count += model.text.length;
		}

		var buttons_gaps_total = gap * buttons_count;
		var buttons_width_total = buttons_characters_count * text.font.width_model + buttons_gaps_total;

		var x_button = Std.int(background.x - (buttons_width_total * 0.5));

		var button_text_length_max = 6;
		var height_button = text.font.height_model;
		var y_button = y_label;

		var button_geometry:RectangleGeometry = {
			y: y_button,
			x: x_button,
			width: 0, // set later
			height: height_button
		}

		var color_button_background = 0xffffff90;

		for (model in this.actions) {
			button_geometry.width = text.font.width_model * model.text.length;
			var button = ui.make_button(
				button_geometry,
				model.text,
				color_text,
				color_button_background
			);

			button.on_click = () -> {
				model.action();
				erase();
			};

			buttons.push(button);
			button_geometry.x += button_geometry.width  + gap;
		}
	}

	public function erase() {
		var index_line = lines.length;
		while (index_line-- > 0) {
			var line = lines.pop();
			line.erase();
		}
		background.erase();

		for(button in buttons){
			button.erase();
		}

		on_erase.dispatch("");
		on_erase.removeAll();
	}
}

class Label {
	var word:Word;
	var background:AbstractFillRectangle;
	var highlight_alpha:Int;
	var hover_alpha:Int;
	var is_clicked:Bool = false;

	public var on_click(default, null):Event<String>;

	public function new(geometry:RectangleGeometry, text_label:String, color_text:RGBA, color_background:RGBA, graphics:GraphicsAbstract, text:Text) {
		on_click = new Event();

		var width_center = Std.int(geometry.width * 0.5);
		var height_center = Std.int(geometry.width * 0.5);
		var gap = 10;

		var y_label = geometry.y + (gap * 3);
		var x_label = Std.int(geometry.x + width_center);

		highlight_alpha = color_background.a;
		hover_alpha = Std.int(color_background.a * 0.5);
		color_background.a = 0;

		word = text.word_make(x_label, y_label, text_label, color_text);
		background = graphics.make_fill(x_label, y_label, geometry.width, geometry.height, color_background);

		y_label += text.font.height_model + gap;
	}

	public function erase() {
		word.erase();
		background.erase();
	}

	public function dispose(){
		on_click.removeAll();
	}

	public function highlight(should_highlight:Bool) {
		background.color.a = should_highlight ? highlight_alpha : 0;
	}

	public function hover(should_hover:Bool) {
		if (is_clicked) {
			return;
		}
		background.color.a = should_hover ? hover_alpha : 0;
	}

	public function overlaps_background(x_mouse:Int, y_mouse:Int):Bool {
		var x_offset = Std.int(background.width * 0.5);
		var y_offset = Std.int(background.height * 0.5);

		return x_mouse > background.x - x_offset
			&& y_mouse > background.y - y_offset
			&& background.x + background.width - x_offset > x_mouse
			&& background.y + background.height - y_offset > y_mouse;
	}

	public function is_clicked_set(is_clicked_next:Bool) {
		is_clicked = is_clicked_next;
		highlight(is_clicked);
	}

	public function click() {
		on_click.dispatch(word.text);
		is_clicked_set(!is_clicked);
	}
}

package stone.ui;

import stone.core.Event;
import stone.core.Engine;
import stone.text.Text;
import stone.core.GraphicsAbstract;

@:structInit
class GraphicsCore {
	public var word_make:MakeWord;
	public var line_make:MakeLine;
	public var fill_make:MakeFillRectangle;
}

class Slider {
	var label:Word;
	var track:AbstractLine;
	var handle:AbstractFillRectangle;

	public var is_dragging(default, null):Bool;
	public var x(get, never):Int;
	public var x_min(get, never):Int;
	public var x_max(get, never):Int;
	public var on_move:Float->Void = f -> trace('on_move $f');

	public function new(geometry:RectangleGeometry, label:String, color:RGBA, graphics:GraphicsCore) {
		this.label = graphics.word_make(geometry.x, geometry.y, label, color);
		var y_track = geometry.y + Std.int(geometry.height * 0.5);
		this.track = graphics.line_make(geometry.x, y_track, geometry.x + geometry.width, y_track, color);
		var size_handle = Std.int(geometry.height * 0.3);
		this.handle = graphics.fill_make(geometry.x, y_track, size_handle, size_handle, color);
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

	public function new(geometry:RectangleGeometry, label:String, color:RGBA, graphics:GraphicsCore, is_enabled:Bool) {
		this.label = graphics.word_make(geometry.x, geometry.y, label, color);
		var y_track = geometry.y + Std.int(geometry.height * 0.5);
		this.track = graphics.line_make(geometry.x, y_track, geometry.x + geometry.width, y_track, color);
		var size_handle = Std.int(geometry.height * 0.3);
		this.handle = graphics.fill_make(geometry.x, y_track, size_handle, size_handle, color);
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

	public function new(geometry:RectangleGeometry, label:String, color_text:RGBA, color_background:RGBA, graphics:GraphicsCore, clean_up:Button->Void) {
		this.clean_up = clean_up;

		var x_center = Std.int(geometry.width * 0.5);
		var x_background = Std.int(geometry.x + x_center);
		var y_background = Std.int(geometry.y + geometry.height * 0);
		this.background = graphics.fill_make(x_background, y_background, geometry.width, geometry.height, color_background);

		// var width_label = label.length * 14;
		// var width_label_center = width_label * 0.5;
		// var width_char_center = 7;
		// var x_label = Std.int(geometry.x + x_center - width_label_center + width_char_center);
		this.label = graphics.word_make(geometry.x, geometry.y, label, color_text, x_center);
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
		clean_up(this);
	}
}

class Modal {
	var lines:Array<Word>;
	var background:AbstractFillRectangle;

	public function new(geometry:RectangleGeometry, line_height:Int, text:Array<String>, color_text:RGBA, color_background:RGBA, graphics:GraphicsCore) {
		var width_center = Std.int(geometry.width * 0.5);
		var height_center = Std.int(geometry.width * 0.5);
		background = graphics.fill_make(geometry.x + width_center, geometry.y + height_center, geometry.width, geometry.height, color_background);
		var gap = 10;
		var y_label = geometry.y + (gap * 3);
		var x_label = geometry.x + gap;
		lines = [];
		for (string in text) {
			lines.push(graphics.word_make(x_label, y_label, string, color_text));
			y_label += line_height + gap;
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

class Dialog<T> {
	var lines:Array<Word>;
	var background:AbstractFillRectangle;

	public var on_confirm(default, null):Event<Dialog<T>>;

	var on_cancel:Event<Dialog<T>>;
	var button_confirm:Button;
	var button_cancel:Button;

	public function new(geometry:RectangleGeometry, line_height:Int, text:Array<String>, color_text:RGBA, color_background:RGBA, graphics:GraphicsCore,
			ui:Ui) {
		on_confirm = new Event();
		on_cancel = new Event();

		var width_center = Std.int(geometry.width * 0.5);
		var height_center = Std.int(geometry.width * 0.5);
		background = graphics.fill_make(geometry.x, geometry.y, geometry.width, geometry.height, color_background);
		background.x += width_center;
		background.y += height_center;

		var gap = 10;
		var y_label = Std.int(background.y - height_center + line_height);
		var x_label = Std.int(background.x - width_center + line_height);

		lines = [];
		for (string in text) {
			lines.push(graphics.word_make(x_label, y_label, string.toUpperCase(), color_text));
			y_label += line_height + gap;
		}

		var button_height = line_height;
		var button_width = line_height * 3;
		var x_button = Std.int(background.x - (button_width));
		var y_button = Std.int(background.y + (geometry.height * 0.5) - button_height);

		var button_geometry:RectangleGeometry = {
			y: y_button,
			x: x_button,
			width: button_width,
			height: button_height
		}

		button_confirm = ui.make_button(button_geometry, "YES", 0x000000FF, 0xffffffFF);
		button_confirm.on_click = () -> {
			on_confirm.dispatch(this);
			erase();
		}

		button_geometry.x += button_width + gap;

		button_cancel = ui.make_button(button_geometry, "NO", 0x000000FF, 0xffffffFF);
		button_cancel.on_click = () -> {
			on_cancel.dispatch(this);
			erase();
		};

	}

	public function erase() {
		var index_line = lines.length;
		while (index_line-- > 0) {
			var line = lines.pop();
			line.erase();
		}
		background.erase();
		button_confirm.erase();
		button_cancel.erase();
		on_cancel.removeAll();
		on_confirm.removeAll();
	}
}

class Label {
	var word:Word;
	var background:AbstractFillRectangle;
	var highlight_alpha:Int;
	var hover_alpha:Int;
	var is_clicked:Bool = false;

	public var on_click(default, null):Event<String>;

	public function new(geometry:RectangleGeometry, line_height:Int, text_label:String, color_text:RGBA, color_background:RGBA, graphics:GraphicsCore) {
		on_click = new Event();

		var width_center = Std.int(geometry.width * 0.5);
		var height_center = Std.int(geometry.width * 0.5);
		var gap = 10;
		var y_label = geometry.y + (gap * 3);
		var x_label = geometry.x + gap;

		highlight_alpha = color_background.a;
		hover_alpha = Std.int(color_background.a * 0.5);
		color_background.a = 0;

		word = graphics.word_make(x_label, y_label, text_label, color_text);
		background = graphics.fill_make(geometry.x + width_center, y_label, geometry.width, geometry.height, color_background);

		y_label += line_height + gap;
	}

	public function erase() {
		word.erase();
		background.erase();
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

class Ui {
	var sliders:Array<Slider> = [];
	var toggles:Array<Toggle> = [];
	var buttons:Array<Button> = [];
	var labels:Array<Label> = [];
	var graphics:GraphicsCore;

	public function new(graphics:GraphicsCore) {
		this.graphics = graphics;
	}

	public function make_slider(geometry:RectangleGeometry, label:String, color:RGBA):Slider {
		return sliders.pushAndReturn(new Slider(geometry, label, color, graphics));
	}

	public function make_toggle(geometry:RectangleGeometry, label:String, color:RGBA, is_enabled:Bool):Toggle {
		return toggles.pushAndReturn(new Toggle(geometry, label, color, graphics, is_enabled));
	}

	public function make_button(geometry:RectangleGeometry, label:String, color_text:RGBA, color_background:RGBA):Button {
		return buttons.pushAndReturn(new Button(geometry, label, color_text, color_background, graphics, button -> buttons.remove(button)));
	}

	public function make_modal(geometry:RectangleGeometry, line_height:Int, text:Array<String>, color_text:RGBA, color_background:RGBA):Modal {
		return new Modal(geometry, line_height, text, color_text, color_background, graphics);
	}

	public function make_dialog<T>(geometry:RectangleGeometry, line_height:Int, text:Array<String>, color_text:RGBA, color_background:RGBA):Dialog<T> {
		return new Dialog<T>(geometry, line_height, text, color_text, color_background, graphics, this);
	}

	public function make_label(geometry:RectangleGeometry, line_height:Int, text:String, color_text:RGBA, color_background:RGBA):Label {
		var label = new Label(geometry, line_height, text, color_text, color_background, graphics);
		label.on_click.add(s -> labels_reset_clicked());
		return labels.pushAndReturn(label);
	}

	function labels_reset_clicked() {
		for (label in labels) {
			label.is_clicked_set(false);
		}
	}

	public function handle_mouse_click(x_mouse:Int, y_mouse:Int) {
		for (slider in sliders) {
			if (slider.overlaps_handle(x_mouse, y_mouse)) {
				slider.click();
			}
		}

		for (toggle in toggles) {
			if (toggle.overlaps_handle(x_mouse, y_mouse)) {
				toggle.click();
			}
		}

		for (button in buttons) {
			if (button.overlaps_background(x_mouse, y_mouse)) {
				button.click();
			}
		}

		for (label in labels) {
			if (label.overlaps_background(x_mouse, y_mouse)) {
				label.click();
			}
		}
	}

	public function handle_mouse_release(x_mouse:Int, y_mouse:Int) {
		for (slider in sliders) {
			slider.release();
		}
	}

	public function handle_mouse_moved(x_mouse:Int, y_mouse:Int) {
		for (slider in sliders) {
			if (slider.is_dragging) {
				if (x_mouse != slider.x) {
					if (x_mouse > slider.x_min && x_mouse < slider.x_max) {
						slider.move(x_mouse);
					}
				}
			}
		}

		for (label in labels) {
			var should_hover = label.overlaps_background(x_mouse, y_mouse);
			label.hover(should_hover);
		}
	}
}

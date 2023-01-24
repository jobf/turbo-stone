package stone.core;

import stone.text.Text;
import stone.core.GraphicsAbstract;
import stone.core.Engine;
import stone.ui.Components;

class Ui {
	var sliders:Array<Slider> = [];
	var toggles:Array<Toggle> = [];
	var buttons:Array<Button> = [];
	var labels:Array<Label> = [];
	var graphics:GraphicsAbstract;
	var text:Text;
	var input:InputAbstract;
	var x_mouse:Int;
	var y_mouse:Int;
	
	public function new(graphics:GraphicsAbstract, text:Text, input:InputAbstract) {
		this.graphics = graphics;
		this.text = text;
		this.input = input;
		this.input.on_mouse_move.add(mouse_position -> handle_mouse_moved());
		this.input.on_pressed.add(button -> handle_mouse_click());
		this.input.on_released.add(button -> handle_mouse_release());
	}

	public function make_slider(geometry:RectangleGeometry, label:String, color:RGBA):Slider {
		return sliders.pushAndReturn(new Slider(geometry, label, color, graphics, text));
	}

	public function make_toggle(geometry:RectangleGeometry, label:String, color:RGBA, is_enabled:Bool):Toggle {
		return toggles.pushAndReturn(new Toggle(geometry, label, color, graphics, text, is_enabled));
	}

	public function make_button(geometry:RectangleGeometry, label:String, color_text:RGBA, color_background:RGBA):Button {
		return buttons.pushAndReturn(new Button(geometry, label, color_text, color_background, graphics, text, button -> buttons.remove(button)));
	}

	public function make_dialog<T>(geometry:RectangleGeometry, lines_text:Array<String>, color_text:RGBA, color_background:RGBA, buttons:Array<ButtonModel>=null):Dialog<T> {
		return new Dialog<T>(geometry, lines_text, color_text, color_background, graphics, this, text, buttons);
	}

	public function make_label(geometry:RectangleGeometry, label_text:String, color_text:RGBA, color_background:RGBA):Label {
		var label = new Label(geometry, label_text, color_text, color_background, graphics, text);
		label.on_click.add(s -> labels_reset_clicked());
		return labels.pushAndReturn(label);
	}

	function labels_reset_clicked() {
		for (label in labels) {
			label.is_clicked_set(false);
		}
	}

	public function handle_mouse_click() {
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

	public function handle_mouse_release() {
		for (slider in sliders) {
			slider.release();
		}
	}

	public function handle_mouse_moved() {
		x_mouse = Std.int(input.mouse_position.x);
		y_mouse = Std.int(input.mouse_position.y);

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

	public function clear() {
		sliders.clear();
		toggles.clear();
		buttons.clear(button -> button.dispose());
		labels.clear(label -> label.dispose());
	}
}

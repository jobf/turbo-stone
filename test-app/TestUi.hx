import stone.core.Event;
import stone.core.GraphicsAbstract.RGBA;
import stone.text.Text;
import stone.core.Engine;
import stone.core.Ui;

class TestUi extends Scene {
	var font:Font;
	var text:Text;
	var ui:Ui;

	public function init() {
		font = font = font_load_embedded(24);

		text = new Text(font, game.graphics);
		
		ui = new Ui(game.graphics, text, game.input);

		var width_button = Std.int(font.width_model * 9);
		var height_button = Std.int(font.height_model * 1.5);
		
		var color_text:RGBA = 0x002852FF;
		var color_background:RGBA = 0x878f8fFF;
		
		var x_component = 10;
		var y_component = 10;
		
		var add_space = ()-> y_component += Std.int(height_button * 2.5);

		var button_dialog_show = ui.make_button(
			{
				x: x_component,
				y: y_component,
				width: width_button,
				height: height_button
			},
			"DIALOG",
			color_text,
			color_background
		);
		
		button_dialog_show.on_click = () -> {
			var dialog = ui.make_dialog(
				bounds,
				[
					"AN EXAMPLE DIALOG",
				],
				color_text,
				color_background,
				[
					{
						text: "YES",
						action: ()->return
					}
				]
			);
		}

		add_space();

		var button_info_show = ui.make_button(
			{
				x: x_component,
				y: y_component,
				width: width_button,
				height: height_button
			},
			"INFO",
			color_text,
			color_background
		);
		
		button_info_show.on_click = () -> {
			var dialog = ui.make_dialog(
				bounds,
				[
					"MANY",
					"MANY",
					"MANY",
					"MANY",
					"MANY",
					"MANY",
					"LINES OF",
					"MANY",
					"TEXT"
				],
				color_text,
				color_background
			);
		}

		add_space();

		var label = ui.make_label(
			{
				x: x_component,
				y: y_component,
				width: width_button,
				height: height_button
			},
			"LABEL",
			0xd42424FF,
			color_background
		);

		add_space();

		var toggle = ui.make_toggle(
			{
				x: x_component,
				y: y_component,
				width: width_button,
				height: height_button
			},
			"TOGGLE",
			color_background,
			false
		);

		toggle.on_change = b -> trace('toggle is now $b');

		add_space();

		var slider = ui.make_slider(
			{
				x: x_component,
				y: y_component,
				width: width_button,
				height: height_button
			},
			"SLIDER",
			color_background
		);

		slider.on_move = f -> trace('slider is now $f');
	}

	public function update(elapsed_seconds:Float) {
		// ui.
	}

	public function draw() {
		text.draw();
	}

	public function close() {
		ui.clear();
	}
}

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

		// var ui_bg_graphics = game.graphics_layer_init();
		var ui_fg_graphics = game.graphics_layer_init(bounds.width, bounds.height);
		text = new Text(font, ui_fg_graphics);
		
		var width_button = Std.int(font.width_model * 9);
		var height_button = Std.int(font.height_model * 1.5);

		var bounds_main:RectangleGeometry =  {
			y: 0,
			x: width_button,
			width: bounds.width - width_button,
			height: bounds.height
		}

		var bounds_components:RectangleGeometry = {
			y: 0,
			x: bounds_main.width,
			width: width_button,
			height: bounds.height
		}

		ui = new Ui(
			game.graphics_layer_init,
			bounds_main,
			bounds_components
		);

		game.input.on_pressed.add(button -> switch button {
			case MOUSE_LEFT: ui.handle_mouse_click();
			case _:
		});

		game.input.on_released.add(button -> switch button {
			case MOUSE_LEFT: ui.handle_mouse_release();
			case _:
		});

		game.input.on_mouse_move.add(mouse_position -> ui.handle_mouse_moved(mouse_position));


		var color_text:RGBA = 0x002852FF;
		var color_background:RGBA = 0x878f8fFF;
		
		var x_component = 10;
		var y_component = 10;
		
		var add_space = ()-> y_component += Std.int(height_button * 2.5);

		var button_dialog_show = ui.make_button(
			{
				// on_hover: on_hover,
				// on_highlight: on_highlight,
				// on_erase: on_erase,
				on_click: component -> {
					var dialog = ui.make_dialog(
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
			},
			"DIALOG",
			color_text,
			color_background
		);

		add_space();

		var button_info_show = ui.make_button(
			{
				on_click: component -> {
					var dialog = ui.make_dialog(
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
			},
			"INFO",
			color_text,
			color_background
		);
		
		add_space();

		var label = ui.make_label(
			{
				// on_hover: on_hover,
				// on_highlight: on_highlight,
				// on_erase: on_erase,
				// on_click: on_click
			},
			"LABEL",
			0xd42424FF,
			color_background
		);

		add_space();

		var toggle = ui.make_toggle(
			{
				// on_hover: on_hover,
				// on_highlight: on_highlight,
				// on_erase: on_erase,
				// on_click: component -> {

				// }
			},
			"TOGGLE",
			color_text,
			color_background,
			false
		);

		toggle.on_change = b -> trace('toggle is now $b');

		add_space();

		var slider = ui.make_slider(
			{
				// on_release: on_release,
				// on_hover: on_hover,
				// on_highlight: on_highlight,
				// on_erase: on_erase,
				// on_click: on_click
			},
			"SLIDER",
			color_text,
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

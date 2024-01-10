import stone.input.Controller;
import stone.core.Vector;
import stone.core.Event;
import stone.abstractions.Input;
import stone.ui.Interactive;
import stone.core.Color;
import stone.text.Text;
import stone.core.Engine;
import stone.core.Ui;
import stone.ui.Tray;
import stone.abstractions.Input.Button as Control;

class TestTray extends Scene {
	var font:Font;
	var text:Text;
	var ui:Ui;

	public function init() {
		font = font = font_load_embedded(24);

		var width_button = Std.int(font.width_model * 9);
		var height_button = Std.int(font.height_model * 1.5);

		var bounds_tray:RectangleGeometry = {
			y: 0,
			x: 0,
			width: width_button,
			height: bounds.height
		}

		var bounds_interactive:RectangleGeometry = {
			y: 0,
			x: 0,
			width: width_button,
			height: height_button
		}

		var bounds_dialog:RectangleGeometry = {
			y: 0,
			x: width_button,
			width: bounds.height,
			height: bounds.height
		}
		ui = new Ui(game.graphics_layer_init);

		var sections:Array<Section> = [
			{
				sort_order: -10,
				contents: [
					{
						sort_order: 1,
						role: LABEL,
						label: "LABEL"
	
					},
					{
						sort_order: 2,
						role: LABEL_TOGGLE(false),
						label: "SELECTABLE"
					},
					{
						sort_order: 3,
						role: TOGGLE(false),
						label: "OFF / ON" // todo change label per option ?
					},
					{
						sort_order: -100,
						role: BUTTON,
						label: "CLICK",
						key_code: Control.KEY_C,
						interactions: {
							on_click: interactive -> trace('click clicked')
						},
						show_in_tray: false,
					},
					{
						sort_order: 5,
						role: SLIDER(0),
						label: "DRAG"
					},
					{
						sort_order: 0,
						role: LABEL,
						label: "FIRST"
					},
				]
			},
			{
				sort_order: 0,
				contents: [
					{
						sort_order: 1,
						role: LABEL,
						label: "SECTION 1"
					},
					{
						sort_order: 0,
						role: BUTTON,
						label: "INFO",
						key_code: KEY_I,
						confirmation: {
							message: "YOU HAVE SEEN IT OK",
						},
						conditions: () -> is_info_button_enabled()
					},
					{
						sort_order: 20,
						role: BUTTON,
						label: "RESET",
						confirmation: {
							message: "WILL RESET TEST !?",
							confirm: "RESET"
						},
						interactions: {
							on_click: interactive -> {
								game.scene_change(game -> new TestTray(game, bounds, color));
								trace('performing DIALOG action');
							}
						}
					},
					{
						sort_order: 10,
						role: BUTTON,
						label: "?",
						confirmation: {
							message: "YES NO",
							confirm: "YES",
							cancel: "NO"
						},
						interactions: {
							on_click: interactive -> {
								_is_info_button_enabled = !_is_info_button_enabled;
								trace('_is_info_button_enabled $_is_info_button_enabled');
							}
						}
					},
					{
						role: SLIDER(1),
						label: "SLOTS",
						interactions: {
							// on_release: on_release,
							// on_hover: on_hover,
							// on_highlight: on_highlight,
							// on_erase: on_erase,
							// on_click: on_click,
							on_change: interactive -> {
								var slider:Slider = cast interactive;
								handle_slot_slider(slider);
							}
						}
					}
				]
			}
		];

		var color_text:RGBA = 0x940855FF;
		var color_background:RGBA = 0x19193dFF;

		var tray_model:TrayModel = {
			tray_geometry: bounds_tray,
			item_geometry: bounds_interactive,
			dialog_boundary: bounds_dialog,
			color_fg: color_text,
			color_bg: color_background
		}

		var tray = new Tray(
			sections,
			ui,
			tray_model
		);


		var actions:Map<Control, Action> = [];

		for (interactive in tray.items) {
			if(interactive.model.key_code != null){
				actions.set(interactive.model.key_code, {
					// on_released: on_released,
					on_pressed: () -> interactive.click(),
					name: interactive.model.label
				});
			}
		}
		
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
		
		game.input.on_pressed.add(button -> if (overlaps_rectangle(bounds_tray, game.input.mouse_position)) {
			switch button {
				case MOUSE_LEFT: {
						ui.handle_mouse_click(Std.int(game.input.mouse_position.x), Std.int(game.input.mouse_position.y));
					};
				case _:
			}
		});

		game.input.on_released.add(button -> if (overlaps_rectangle(bounds_tray, game.input.mouse_position)) {
			switch button {
				case MOUSE_LEFT: ui.handle_mouse_release();
				case _:
			}
		});

		game.input.on_mouse_move.add(mouse_position -> {
			ui.handle_mouse_moved(Std.int(mouse_position.x), Std.int(mouse_position.y));
		});
	}

	var slots:Array<Int> = [1, 2, 4, 8, 16, 32, 64];

	function handle_slot_slider(slider:Slider) {
		var index = Std.int(slots.length * slider.fraction);
		var divisions = slots.length - 1;
		var click = 1 / divisions;
		slider.set_detent(click * index);
		trace('slot index $index ${slots[index]}');
	}

	var _is_info_button_enabled:Bool = false;
	function is_info_button_enabled():Bool {
		return _is_info_button_enabled;
	}

	public function update(elapsed_seconds:Float) {
		// ui.
	}

	public function draw() {
		// ui.
	}
	
	public function close() {
		ui.clear();
	}
}
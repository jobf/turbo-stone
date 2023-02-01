package stone;

import stone.core.GraphicsAbstract;
import stone.core.Engine;
import stone.graphics.implementation.Graphics;
import stone.core.Vector;
import stone.core.Engine.RectangleGeometry;
import stone.input.Controller;
import stone.core.Ui;
import stone.core.Engine.Scene;
import stone.text.Text;
import stone.core.InputAbstract;
import stone.ui.Tray;

using StringTools;


class HudScene extends Scene {
	var ui:Ui;
	var text:Text;
	var bounds_main:RectangleGeometry;
	var bounds_tray:RectangleGeometry;
	var tray_sections:Array<Section>;
	var actions:Map<Button, Action>;
	var graphics_main:Graphics;

	public function new(game:Game, bounds_viewport:RectangleGeometry, color:RGBA, sections:Array<Section>, tray_offset_y:Int=0){
		super(game, bounds_viewport, color);
		graphics_main = cast game.graphics_layer_init(bounds.width, bounds.height);

		tray_sections = sections;
		
		actions = [];
		
		bounds_main = {
			y: 0,
			x: 0,
			width: bounds.height,
			height: bounds.height
		}

		bounds_tray = {
			y: tray_offset_y,
			x: bounds_main.width,
			width: bounds.width - bounds_main.width,
			height: bounds.height
		}

		game.input.on_pressed.add(button -> switch button {
			case MOUSE_LEFT: {
				if(game.input.mouse_position.x > bounds_main.x + bounds_main.width){
					mouse_press_ui();
				}
				else{
					mouse_press_main();
				}
			};
			case _:
		});

		game.input.on_released.add(button -> {
			switch button {
				case MOUSE_LEFT: {
					if(game.input.mouse_position.x > bounds_main.x + bounds_main.width){
						mouse_release_ui();
					}
					else{
						mouse_release_main();
					}
				}
				case _:
		}});
			
		game.input.on_mouse_move.add(mouse_position -> {
			mouse_moved(mouse_position);
		});
	}

	public function init() {
		var font = font_load_embedded(24);
		var height_button = Std.int(font.height_model * 1.5);
		var width_button = bounds.width - bounds.height;

		var bounds_interactive:RectangleGeometry = {
			y: 0,
			x: 0,
			width: width_button,
			height: height_button
		}

		ui = new Ui(game.graphics_layer_init);
		
		var tray_model:TrayModel = {
			tray_geometry: bounds_tray,
			item_geometry: bounds_interactive,
			dialog_boundary: bounds_main,
			color_fg: Theme.fg_ui_interactive,
			color_bg: Theme.bg_ui_interactive
		}

		var tray = new Tray(
			tray_sections,
			ui,
			tray_model
		);

		for (interactive in tray.items) {
			if(interactive.model.key_code != null){
				actions.set(interactive.model.key_code, {
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
	}

	public function update(elapsed_seconds:Float) {
	}

	public function draw() {
	}

	public function close() {
		ui.clear();
	}

	function mouse_press_ui(){
		var x_mouse:Int = Std.int(game.input.mouse_position.x);
		var y_mouse:Int = Std.int(game.input.mouse_position.y);
		ui.handle_mouse_click(x_mouse, y_mouse);
	}

	function mouse_press_main(){
		// override me
	}

	function mouse_release_ui(){
		ui.handle_mouse_release();
	}

	function mouse_release_main(){
		// override me
	}

	function mouse_moved(mouse_position:Vector) {
		var x_mouse:Int = Std.int(game.input.mouse_position.x);
		var y_mouse:Int = Std.int(game.input.mouse_position.y);
		ui.handle_mouse_moved(x_mouse, y_mouse);
	}
}

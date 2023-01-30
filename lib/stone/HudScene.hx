package stone;

import stone.core.GraphicsAbstract;
import stone.core.Event;
import stone.core.Models.Deserialize;
import stone.core.Engine;
import stone.graphics.implementation.Graphics;
import peote.view.Display;
import stone.DesignerScene;
import stone.core.Vector;
import stone.core.Engine.RectangleGeometry;
import stone.input.Controller;
import stone.core.Ui;
import stone.ui.Components;
import stone.file.FileStorage;
import stone.core.Engine.Scene;
import stone.text.Text;
import stone.core.InputAbstract;

using StringTools;

class HudScene extends Scene {
	var ui:Ui;
	var actions:Map<Button, Action>;
	var graphics_main:Graphics;
	var graphics_hud:Graphics;
	var bounds_main:RectangleGeometry;
	var bounds_components:RectangleGeometry;
	var help:Dialog;

	public function new(game:Game, bounds_viewport:RectangleGeometry, color:RGBA){
		super(game, bounds_viewport, color);
		
		actions = [];
		
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

		graphics_main = cast game.graphics_layer_init(bounds.width, bounds.height);
		graphics_hud = cast game.graphics_layer_init(bounds.width, bounds.height);
		
		bounds_main = {
			y: 0,
			x: 0,
			width: bounds.height,
			height: bounds.height
		}
		
		var width_components = Std.int(bounds.width - bounds.height);
		
		bounds_components = {
			y: 0,
			x: bounds_main.width,
			width: width_components,
			height: bounds.height
		}
		
		ui = new Ui(
			game.graphics_layer_init,
			bounds_main,
			bounds_components
		);

		game.input.on_pressed.add(button -> switch button {
			case MOUSE_LEFT: {
				if(game.input.mouse_position.x > bounds_main.x + bounds_main.width){
					mouse_press_ui();
				}
				else{
					mouse_press_main();
				}
				ui_refresh();
			};
			case _:
		});

		game.input.on_released.add(button -> switch button {
			case MOUSE_LEFT: {
				if(game.input.mouse_position.x > bounds_main.x + bounds_main.width){
					mouse_release_ui();
				}
				else{
					mouse_release_main();
				}
			};
			case _:
		});

		game.input.on_mouse_move.add(mouse_position -> {
			mouse_moved(mouse_position);
		});
	}

	function add_space(){
		var gap = 8;
		ui.y_offset_increase(gap * 2);
	}

	function add_button(key:Button, action:Action, y_offset:Int=0):stone.ui.Components.Button {
		actions[key] = action;
		return ui.make_button(
			{
				// on_hover: on_hover,
				// on_highlight: on_highlight,
				// on_erase: on_erase,
				on_click: component ->  action.on_pressed()
			},
			action.name,
			Theme.fg_ui_component,
			Theme.bg_ui_component,
			y_offset
		);
	}

	function get_commands():Array<String>{
		return [for(pair in actions.keyValueIterator()) '${pair.key} : ${pair.value.name}'];
	}

	public function init() {
		// override me
		add_button(
			KEY_H,
			{
				on_pressed: () -> {
					if(help == null){
						var help_text = get_commands();
						trace(help_text);
						help = ui.make_dialog(
							help_text,
							Theme.fg_ui_component,
							Theme.bg_dialog
						);

						help.on_erase.add(s -> {
							help = null;
						});
					}
				},
				name: "SECRETS"
			},
			604 // todo - better control over button y align?
		);
	}

	public function update(elapsed_seconds:Float) {
	}

	public function draw() {
		// text.draw();
		ui.draw();
		// graphics_hud.draw();
	}

	public function close() {
		ui.clear();
		// graphics_hud.close();
	}

	function mouse_press_ui(){
		ui.handle_mouse_click();
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
		ui.handle_mouse_moved(mouse_position);
	}

	function ui_refresh(){
		// override me
	}
}

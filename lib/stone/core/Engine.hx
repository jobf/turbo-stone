package stone.core;

import stone.abstractions.Graphic;
import stone.abstractions.Input;
import stone.core.Color;
import stone.core.Storage;

typedef GraphicsConstructor = (width:Int, height:Int) -> GraphicsBase

@:publicFields
class Game {
	private var current_scene:Scene;
	private var graphics_layers:Array<GraphicsBase>;
	private var graphics_constructor(default, null):GraphicsConstructor;
	var input(default, null):InputAbstract;
	var storage(default, null):Storage;

	function new(scene_constructor:Game->Scene, graphics_constructor:GraphicsConstructor, input:InputAbstract, storage:Storage) {
		this.input = input;
		this.storage = storage;
		graphics_layers = [];
		this.graphics_constructor = graphics_constructor;
		scene_init(scene_constructor);
	}

	function update(elapsed_seconds:Float) {
		input.update_mouse_position();
		input.raise_mouse_button_events();
		input.raise_keyboard_button_events();
		current_scene.update(elapsed_seconds);
	}

	private function scene_init(scene_constructor:Game->Scene) {
		current_scene = scene_constructor(this);
		current_scene.init();
	}

	function scene_change(scene_constructor:Game->Scene) {
		if (current_scene != null) {
			graphics_layers.clear(layer -> layer.close());
			current_scene.close();
			input.on_pressed.removeAll();
			input.on_released.removeAll();
			input.on_mouse_move.removeAll();
			scene_init(scene_constructor);
		}
	}

	function draw() {
		current_scene.draw();
		for (layer in graphics_layers) {
			layer.draw();
		}
	}

	function graphics_layer_init(width:Int, height:Int):GraphicsBase {
		var layer = graphics_constructor(width, height);
		graphics_layers.push(layer);
		return layer;
	}
}

@:publicFields
abstract class Scene {
	private var game:Game;
	private var bounds:Rectangle;

	var color(default, null):RGBA;

	function new(game:Game, bounds:Rectangle, color:RGBA) {
		this.game = game;
		this.bounds = bounds;
		this.color = color;
	}

	/**
		Handle scene initiliasation here, e.g. set up level, player, etc.
	**/
	abstract function init():Void;

	/**
		Handle game logic here, e,g, calculating movement for player, change object states, etc.
		@param elapsed_seconds is the amount of seconds that have passed since the last frame
	**/
	abstract function update(elapsed_seconds:Float):Void;

	/**
		Make draw calls here
	**/
	abstract function draw():Void;

	/**
		Clean up the scene here, e.g. remove graphics buffers
	**/
	abstract function close():Void;
}

@:publicFields
@:structInit
class Rectangle {
	var x:Int = 0;
	var y:Int = 0;
	var width:Int;
	var height:Int;
}

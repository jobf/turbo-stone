package stone.abstractions;

import haxe.io.UInt8Array;
import stone.core.Color;
import stone.core.Engine;
import stone.core.Models;
import stone.editing.Editor;

using stone.core.Vector;

typedef MakeLine = (from_x:Float, from_y:Float, to_x:Float, to_y:Float, color:RGBA) -> LineBase;
typedef MakeFill = (x:Int, y:Int, width:Int, height:Int, color:RGBA) -> FillBase;

@:publicFields
abstract class LineBase {
	var point_from:Vector2;
	var point_to:Vector2;
	var color:RGBA;
	var length(get, never):Float;

	private function get_length():Float{
		return point_from.distance_to(point_to);
	}

	function new(point_from:Vector2, point_to:Vector2, color:RGBA) {
		this.point_from = point_from;
		this.point_to = point_to;
		this.color = color;
	}

	/** provides an implementation to draws the graphic, to be called each render frame */
	abstract function draw():Void;

	/** provides an implementation to delete the graphic **/
	abstract function erase():Void;
}


@:publicFields
abstract class FillBase {
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
	var color:RGBA;
	var rotation:Float;
	
	function new(x:Float, y:Float, width:Float, height:Float, rotation:Float, color:RGBA) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.color = color;
		this.rotation = rotation;
	}

	/** provides an implementation to draws the graphic, to be called each render frame */
	abstract function draw():Void;


	/** provides an implementation to delete the graphic **/
	abstract function erase():Void;
}


@:publicFields
@:structInit
class Polygon {

	var origin:Vector2 = {
		x: 0,
		y: 0
	};

	var lines:Array<LineBase>;
	var model(default, null):Array<Vector2>;
	var color:RGBA;

	var rotation_sin:Float = 0;
	var rotation_cos:Float = 0;

	function draw(x:Float, y:Float, rotation:Float, scale:Float) {
		rotation_sin = Math.sin(rotation);
		rotation_cos = Math.cos(rotation);

		for (n => line in lines) {
			line.color = color;
			line.point_from = model[n].vector_transform(origin, scale, x, y, rotation_sin, rotation_cos);
			line.point_to = model[(n + 1) % lines.length].vector_transform(origin, scale, x, y, rotation_sin, rotation_cos);
			line.draw();
		}
	}

	function points():Array<Vector2> {
		return lines.map(line -> line.point_from);
	}

	function erase(){
		for (line in lines) {
			line.erase();
		}
	}
}

@:publicFields
abstract class ParticleBase {
	var size:Int;
	var color:RGBA;
	var motion:MotionInteractive;
	var lifetime_seconds:Float;
	var lifetime_seconds_remaining:Float;

	var is_expired(default, null):Bool;

	function new(x:Int, y:Int, size:Int, color:RGBA, lifetime_seconds:Float) {
		this.color = color;
		this.size = size;
		this.lifetime_seconds = lifetime_seconds;
		this.lifetime_seconds_remaining = lifetime_seconds;
		is_expired = false;
		this.motion = new MotionInteractive(x, y);
	}

	function update(elapsed_seconds:Float) {
		if (!is_expired) {
			// only run this logic if the particle is not expired

			// calculate new position
			motion.compute_motion(elapsed_seconds);

			// if enough time has passed, expire the particle so it can be recycled
			lifetime_seconds_remaining -= elapsed_seconds;
			if (lifetime_seconds_remaining <= 0) {
				// change expired state so update logic is no longer run
				is_expired = true;
				color.a = 0;
			}
		}
	}

	abstract function draw():Void;

	function set_trajectory(x_acceleration:Float, y_acceleration:Float) {
		motion.acceleration.x = x_acceleration;
		motion.acceleration.y = y_acceleration;
	}

	function set_color(color:RGBA) {
		if (!is_expired) {
			this.color = color;
		} else {
			this.color.a = 0;
		}
	}

	function reset_to(x:Int, y:Int, size:Int, color:RGBA) {
		// reset life time
		is_expired = false;
		lifetime_seconds_remaining = lifetime_seconds;

		// reset motion
		motion.acceleration.x = 0;
		motion.acceleration.y = 0;
		motion.velocity.x = 0;
		motion.velocity.y = 0;
		motion.deceleration.y = 0;

		// set new position
		motion.position.x = Std.int(x);
		motion.position.y = Std.int(y);

		// set new size
		this.size = size;

		this.color = color;
	}
}

@:publicFields
abstract class GraphicsBase {
	var viewport_bounds:Rectangle;

	function new(viewport_bounds:Rectangle) {
		this.viewport_bounds = viewport_bounds;
	}

	abstract function draw():Void;

	abstract function close():Void;

	abstract function make_line(from_x:Float, from_y:Float, to_x:Float, to_y:Float, color:RGBA):LineBase;

	abstract function make_fill(x:Int, y:Int, width:Int, height:Int, color:RGBA):FillBase;

	abstract function make_particle(x:Float, y:Float, size:Int, color:RGBA, lifetime_seconds:Float):ParticleBase;

	abstract function png_data_from_figure(figure:FigureModel, translation:EditorTranslation, width:Int, height:Int):UInt8Array;

	function model_to_lines(model:Array<LineBaseModel>, color:RGBA):Array<LineBase>{
		var lines:Array<LineBase> = [];
		for (line in model) {
			lines.push(make_line(line.from.x, line.from.y, line.to.x, line.to.y, color));
		}
		return lines;
	}

	function model_points_to_lines(model:Array<Vector2>, color:RGBA):Array<LineBase>{
		var lines:Array<LineBase> = [];
		for (a in 0...model.length) {
			var from = model[a % model.length];
			var to = model[(a + 1) % model.length];
			lines.push(make_line(from.x, from.y, to.x, to.y, color));
		}
		return lines;
	}

	function make_polygon(model:Array<Vector2>, color:RGBA):Polygon {
		return {
			model: model,
			color: color,
			lines: model_points_to_lines(model, color)
		}
	}
}

@:publicFields
abstract class CursorBase {
	abstract function draw():Void;
	abstract function erase():Void;
}
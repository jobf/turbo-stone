package stone.core;

import stone.abstractions.Graphic;
import stone.editing.Editor;

@:publicFields
class Entity {
	var motion(default, null):MotionInteractive;

	var lines:Polygon;

	var weight:Float = 250;
	var rotation:Float = 0;
	var rotation_speed:Float;

	var scale:Float = 1;

	private var rotation_direction:Int = 0;
	private var model_points:Array<Vector2>;
	private var lines_points:Array<Vector2>;

	function new(model:Array<Vector2>, x:Int, y:Int, rotation_speed:Float, graphics:GraphicsBase) {
		// set up motion
		motion = new MotionInteractive(x, y);
		this.rotation_speed = rotation_speed;
		rotation_direction = Math.random() > 0.5 ? -1 : 1;
		// set up lines
		model_points = model;
		final color = 0xFF00FFff;
		lines = graphics.make_polygon(model_points, color);
		lines_points = lines.points();
	}

	function update(elapsed_seconds:Float) {
		motion.compute_motion(elapsed_seconds);
		rotation = rotation + (rotation_speed * rotation_direction);
	}

	function set_color(color:RGBA) {
		lines.color = color;
	}

	function draw() {
		lines.draw(motion.position.x, motion.position.y, rotation, scale);
		lines_points = lines.points();
	}

	function set_rotation_direction(direction:Int) {
		rotation_direction = direction;
	}

	function collision_points():Array<Vector2> {
		return lines.points();
	}

	var offset:Float = 0;

	function collision_center(translation:EditorTranslation):Vector2 {
		// return motion.position.vector_transform(lines.origin, scale, 0, 0, lines.rotation_sin, lines.rotation_cos);

		var rotation_sin = Math.sin(rotation);
		var rotation_cos = Math.cos(rotation);

		var x_origin = motion.position.x + (lines.origin.x);
		var y_origin = motion.position.y + (lines.origin.y);

		var transformed:Vector2 = {
			x: x_origin * rotation_cos - y_origin * rotation_sin,
			y: x_origin * rotation_sin + y_origin * rotation_cos
		};

		// scale
		// 		transformed.x = transformed.x * scale;
		// 		transformed.y = transformed.y * scale;
		// 1
		transformed.x = transformed.x + translation.bounds_width_half;
		transformed.y = transformed.y + translation.bounds_height_half;


		transformed.x = transformed.x - (lines.origin.x);
		transformed.y = transformed.y - (lines.origin.y);

		// return {
		// 	x: x_origin,
		// 	y: y_origin
		// }
		return transformed;
		// return {
		// 	x: motion.position.x + scale * (lines.origin.x),
		// 	y: motion.position.y + scale * (lines.origin.y),
		// };
	}

	function overlaps_polygon(model:Array<Vector2>):Bool {
		for (point in model) {
			if (lines_points.polygon_overlaps_point(point)) {
				return true;
			}
		}
		return false;
	}
}
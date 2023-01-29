package stone.graphics.implementation;

import lime.graphics.Image;
import stone.graphics.Fill;
import stone.graphics.LineCPU;
import stone.core.Engine;
import stone.core.GraphicsAbstract;
import stone.core.Vector;
import peote.view.*;

class Graphics extends GraphicsAbstract {
	var lines:Array<PeoteLine> = [];
	var fills:Array<PeoteFill> = [];
	var size_cap:Int = 1;
	var angle_cap:Int = -45;
	var moon_texture:Texture;
	var moon_buffer:Buffer<Sprite>;
	var moon_program:Program;
	var display:Display;
	var graphics_layer_init:GraphicsConstructor;

	public var buffer_lines(default, null):Buffer<Line>;

	var buffer_fills:Buffer<Rectangle>;

	public function new(display:Display, viewport_bounds:RectangleGeometry, graphics_layer_init:GraphicsConstructor) {
		super(viewport_bounds);
		this.display = display;
		this.graphics_layer_init = graphics_layer_init;

		buffer_fills = new Buffer<Rectangle>(256, 256, true);
		var rectangleProgram = new Program(buffer_fills);
		display.addProgram(rectangleProgram);

		buffer_lines = new Buffer<Line>(256, 256, true);
		var lineProgram = new Program(buffer_lines);
		display.addProgram(lineProgram);

		moon_buffer = new Buffer<Sprite>(1, 1, false);
		moon_program = new Program(moon_buffer);
		display.addProgram(moon_program);
	}

	public function add_moon(image:Image):Sprite {
		moon_texture = new Texture(image.width, image.height);
		moon_texture.setImage(image);

		moon_program.addTexture(moon_texture, "custom");
		moon_program.snapToPixel(1);
		var moon = new Sprite(320, 320, 1015, 1015);
		moon_buffer.addElement(moon);
		return moon;
	}

	public function make_line(from_x:Float, from_y:Float, to_x:Float, to_y:Float, color:RGBA):AbstractLine {
		var element = new Line(from_x, from_y, 1, 1, 0, cast color);
		element.timeAStart = 0.0;
		element.timeADuration = 3.0;
		buffer_lines.addElement(element);

		var line_clean_up:PeoteLine -> Void = line -> {
			buffer_lines.removeElement(line.element);
			lines.remove(line);
		}

		lines.push(new PeoteLine({
			x: from_x,
			y: from_y
		}, {
			x: to_x,
			y: to_y
		},
			element, line_clean_up, make_rectangle(Std.int(from_x), Std.int(from_y), size_cap, size_cap, color),
			make_rectangle(Std.int(from_x), Std.int(from_y), size_cap, size_cap, color), cast color));
		// trace('new line $from_x $from_y $to_x $to_y');
		return lines[lines.length - 1];
	}

	public function make_fill(x:Int, y:Int, width:Int, height:Int, color:RGBA):AbstractFillRectangle {
		var element = make_rectangle(x, y, width, height, color);
		
		var fill_clean_up:PeoteFill -> Void = fill -> {
			buffer_fills.removeElement(fill.element);
			fills.remove(fill);
		}
		
		fills.push(new PeoteFill(element, fill_clean_up));
		
		return fills[fills.length - 1];
	}

	function make_rectangle(x:Float, y:Float, width:Float, height:Float, color:RGBA):Rectangle {
		final rotation = 0;
		var element = new Rectangle(x, y, width, height, rotation, cast color);
		buffer_fills.addElement(element);
		return element;
	}

	public function make_particle(x:Float, y:Float, size:Int, color:RGBA, lifetime_seconds:Float):AbstractParticle {
		var element = make_rectangle(x, y, size, size, cast color);
		return new Particle(Std.int(x), Std.int(y), size, cast color, lifetime_seconds, element);
	}

	function line_erase(line:PeoteLine) {
		buffer_fills.removeElement(line.head);
		buffer_fills.removeElement(line.end);
		buffer_lines.removeElement(line.element);
		lines.remove(line);
	}

	public function draw() {
		for (line in lines) {
			line.draw();
		}
		for (fill in fills) {
			fill.draw();
		}
		buffer_fills.update();
		buffer_lines.update();
		moon_buffer.update();
	}

	public function translate_mouse(x:Float, y:Float):Vector {
		return {
			x: display.localX(x),
			y: display.localY(y)
		}
	}

	public function set_color(color:RGBA) {
		display.color = cast color;
	}

	public function close() {
		fills.clear(fill -> fill.erase());
		lines.clear(line -> line.erase());
	}

	public function display_add(display_additional:Display) {
		display.peoteView.addDisplay(display_additional);
	}

	public function graphics_new_layer():GraphicsAbstract{
		return graphics_layer_init();
	}
}

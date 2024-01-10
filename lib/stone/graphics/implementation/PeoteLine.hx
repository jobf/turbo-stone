package stone.graphics.implementation;

import stone.graphics.Fill;
import stone.graphics.LineCPU;

import stone.abstractions.Graphic;

import peote.view.Color;

class PeoteLine extends Line {
	var a:Float = 0;
	var b:Float = 0;

	public var head:Rectangle;
	public var end:Rectangle;

	var remove_from_buffer:PeoteLine->Void;
	var is_erased:Bool = false;

	public var element(default, null):LineCPU;
	public var thick(get, set):Int;

	public function new(point_from:Vector2, point_to:Vector2, element:LineCPU, remove_from_buffer:PeoteLine->Void, head:Rectangle, end:Rectangle, color:Color) {
		super(point_from, point_to, cast color);
		this.element = element;
		this.remove_from_buffer = remove_from_buffer;
		this.head = head;
		this.end = end;
		thick = 2;
		draw();
	}

	public function draw():Void {
		element.c = cast color;

		element.set_start(Std.int(point_from.x), Std.int(point_from.y));
		element.set_end(Std.int(point_to.x), Std.int(point_to.y));
		element.thick = thick;

		head.x = point_from.x;
		head.y = point_from.y;
		head.rotation = -45;

		end.x = point_to.x;
		end.y = point_to.y;
		end.rotation = -45;
	}

	public function erase_graphic():Void {
		if(!is_erased){
			is_erased = true;
			remove_from_buffer(this);
		}
	}

	function get_thick():Int {
		return element.thick;
	}

	var cap_offset:Float = 0.3;

	function set_thick(value:Int):Int {
		element.thick = value;
		var cap_size = thick * 0;
		this.head.w = cap_size;
		this.head.h = cap_size;
		this.head.color.a = 40;

		this.end.w = cap_size;
		this.end.h = cap_size;
		this.end.color.a = 40;

		return element.thick;
	}
}

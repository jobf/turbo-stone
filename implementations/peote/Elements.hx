import peote.view.Color;
import peote.view.Element;

@:publicFields
class FillElement implements Element {
	@pivotX @formula("w * 0.5 + px_offset") var px_offset:Float;
	@pivotY @formula("h * 0.5 + py_offset") var py_offset:Float;
	@rotation var rotation:Float = 0.0;
	@sizeX @varying var w:Float;
	@sizeY @varying var h:Float;
	@color var color:Color;
	@posX var x:Float;
	@posY var y:Float;

	var OPTIONS = {blend: true};

	function new(positionX:Float, positionY:Float, width:Float, height:Float, rotation:Float, color:Color = 0x556677ff) {
		this.x = positionX;
		this.y = positionY;
		this.w = width;
		this.h = height;
		this.color = color;
		this.rotation = rotation;
	}
}

@:publicFields
class LineElement implements Element
{
	@posX var from_x:Int;
	@posY var from_y:Int;
	var to_x:Int;
	var to_y:Int;

	@sizeX var length:Int = 1;
	// rotation around pivot point
	@rotation var r:Float;
	
	// calculated pivot
	@pivotX @formula("thick * 0.5") var px:Int;
	@pivotY @formula("thick * 0.5") var py:Int;
	
	var OPTIONS = {blend: true};

	@sizeY var thick:Int = 1;
	@color var c:Color;

	function new(from_x:Int, from_y:Int, to_x:Int, to_y:Int, thick:Int, color:Color) {
		this.thick = thick;
		c = color;

		this.from_x = from_x;
		this.from_y = from_y;
		this.to_x = to_x;
		this.to_y = to_y;

		rotate();
	}

	inline function rotate() {
		var a = from_x - to_x;
		var b = from_y - to_y;

		// note we add the thickness to length, otherwise so it finishes too short
		length = Std.int(Math.sqrt(a * a + b * b)) + thick;
		r = Math.atan2(to_x - from_x, -(to_y - from_y)) * (180 / Math.PI) - 90;
	}

	function set_start(x:Int, y:Int) {
		this.from_x = x;
		this.from_y = y;
		rotate();
	}

	function set_end(x:Int, y:Int) {
		this.to_x = x;
		this.to_y = y;
		rotate();
	}

	function set_rotation(r:Float) {
		this.r = r;
		rotate();
	}
}

package stone.graphics;

import peote.view.Element;
import peote.view.Color;

class LineGPU implements Element
{
	@posX var from_x:Int=0;
	@posY var from_y:Int = 0;
	
	@custom var to_x:Int=0;
	@custom var to_y:Int=0;

	
	// calculate pivot point on gpu
	@pivotX @const @formula("0.0") var px:Int;
	@pivotY @const @formula("thick / 2.0") var py:Int;
	
	// calculate width and rotation on gpu
	@sizeX @const @formula("sqrt( (from_x-to_x)*(from_x-to_x) + (from_y-to_y)*(from_y-to_y) )") var w:Int;
	@rotation @const @formula("-((to_x-from_x) == 0.0 ? sign(-(to_y-from_y))*1.5707963 : atan(-(to_y-from_y),to_x-from_x))*57.2957795") var r:Float;
	
	var OPTIONS = {alpha: true};
	
	@sizeY public var thick:Int = 1;
	@color public var c:Color;
	
	public function new(from_x:Int, from_y:Int, to_x:Int, to_y:Int, color:Color) {
		this.from_x = from_x;
		this.from_y = from_y;
		this.to_x = to_x;
		this.to_y = to_y;
		this.c = color;
	}

	public function set_start(x:Int, y:Int) {
		this.from_x = x;
		this.from_y = y;
	}

	public function set_end(x:Int, y:Int) {
		this.to_x = x;
		this.to_y = y;
	}

	public function set_rotation(r:Float) {
		// todo ?
	}
}

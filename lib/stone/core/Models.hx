package stone.core;

import stone.core.Vector;

@:structInit
class FileModel {
	public var models:Array<FigureModel>;
}

@:structInit
class FigureModel{
	public var index:Int;
	public var name:String = "";
	public var lines:Array<LineModel>;
}

@:structInit
class LineModel{
	public var from:Vector;
	public var to:Vector;
}

class IsoscelesModel {
	public var a_point:Vector;
	public var b_point:Vector;
	public var c_point:Vector;
	public var points:Array<Vector>;

	public function new() {
		a_point = {x: 0.0, y: -6.0};
		b_point = {x: -3.0, y: 3.0};
		c_point = {x: 3.0, y: 3.0};
		points = [a_point, b_point, c_point];
	}
}

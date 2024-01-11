package stone.core;
import json2object.*;

import stone.core.Vector;

@:structInit
class FileModel {
	public var models:Array<FigureModel>;
}

@:structInit
class FigureModel{
	public var index:Int;
	public var name:String = "";
	public var lines:Array<LineBaseModel>;
}

@:structInit
class LineBaseModel{
	public var from:Vector2;
	public var to:Vector2;
}

class IsoscelesModel {
	public var a_point:Vector2;
	public var b_point:Vector2;
	public var c_point:Vector2;
	public var points:Array<Vector2>;

	public function new() {
		a_point = {x: 0.0, y: -6.0};
		b_point = {x: -3.0, y: 3.0};
		c_point = {x: 3.0, y: 3.0};
		points = [a_point, b_point, c_point];
	}
}


class Deserialize {
	public static function parse_file_contents(json:String):Null<FileModel> {
		var errors = new Array<Error>();
		var data = new JsonParser<FileModel>(errors).fromJson(json, 'json-errors');

		if (errors.length <= 0 && data != null) {
			return data;
		}
		else{
			for (error in errors) {
				trace(error);
			}
		}

		return null;
	}
}


class Serialize {
	public static function to_string(model:FileModel) {
		var writer = new JsonWriter<FileModel>();
		var json:String = writer.write(model);
		return json;
	}
}
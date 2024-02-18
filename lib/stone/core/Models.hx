package stone.core;

import json2object.*;
import stone.core.Vector;

@:publicFields
@:structInit
class FileModel {
	var models:Array<FigureModel>;
}

@:publicFields
@:structInit
class FigureModel{
	var index:Int;
	var name:String = "";
	var lines:Array<LineBaseModel>;
}

@:publicFields
@:structInit
class LineBaseModel{
	var from:Vector2;
	var to:Vector2;
}

@:publicFields
class IsoscelesModel {
	var a_point:Vector2;
	var b_point:Vector2;
	var c_point:Vector2;
	var points:Array<Vector2>;

	function new() {
		a_point = {x: 0.0, y: -6.0};
		b_point = {x: -3.0, y: 3.0};
		c_point = {x: 3.0, y: 3.0};
		points = [a_point, b_point, c_point];
	}
}


@:publicFields
class Deserialize {
	static function parse_file_contents(json:String):Null<FileModel> {
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


@:publicFields
class Serialize {
	static function to_string(model:FileModel) {
		var writer = new JsonWriter<FileModel>();
		var json:String = writer.write(model);
		return json;
	}
}
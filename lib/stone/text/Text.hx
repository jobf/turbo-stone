package stone.text;

import stone.editing.Editor;
import stone.core.Models;
import stone.core.GraphicsAbstract;
import stone.editing.Drawing;

@:structInit
class Font {
	public var models:Array<Array<LineModel>>;
	public var width_model:Int;
	public var height_model:Int;
	public var width_character:Int = 0;
}

function font_load_embedded(size_model:Int=64):Font {
	var models_json = CompileTime.readJsonFile("stone/text/fonts/code-page-models.json");
	var model_file = Deserialize.parse_file_contents(models_json);
	var width_char = Std.int(size_model * 0.5625);
	return {
		models: model_file.models.map(model -> model.lines),
		width_model: size_model,
		height_model: size_model,
		width_character: width_char
	}
}

class Text {
	public var font(default, null):Font;
	var graphics:GraphicsAbstract;
	var model_translation:EditorTranslation;

	var words:Array<Word> = [];

	public function new(font:Font, graphics:GraphicsAbstract) {
		if (font.models.length != 256) {
			throw "character set requires 256 models for code page 437";
		}
		this.font = font;
		this.graphics = graphics;
		model_translation = new EditorTranslation({
			y: 0,
			x: 0,
			width: font.width_model,
			height: font.width_model
		});
		// trace('font ${model_translation.}')
	}

	public function draw() {
		for (word in words) {
			word.draw();
		}
	}

	public function word_make(x:Int, y:Int, text:String, color:RGBA, x_center:Null<Int>=null):Word {
		var width_label = text.length * font.width_character;
		var width_label_center = width_label * 0.5;
		var width_char_center = font.width_character * 0.5;
		x = Std.int(x + x_center - width_label_center + width_char_center);
		var drawings:Array<Drawing> = [];
		for (i in 0...text.length) {
			var text_upper = text.toUpperCase();
			var char_code = text_upper.charCodeAt(i);
			// trace('code $char_code letter ${String.fromCharCode(char_code)}');
			drawings.push(drawing_create(font.models[char_code], x + font.width_character * i, y, color));
		}

		words.push({
			text: text,
			drawings: drawings,
			on_erase: word -> words.remove(word),
			width: width_label,
			height: font.height_model
		});

		return words[words.length - 1];
	}

	function drawing_create(model_Lines:Array<LineModel>, x:Float, y:Float, color:RGBA):Drawing {
		return new Drawing({
			model_lines: model_Lines
		}, x, y, graphics.make_line, model_translation, color);
	}


}

@:structInit
class Word {
	public var text(default, null):String;
	public var on_erase:Word->Void;
	public var height(default, null):Int;
	public var width(default, null):Int;
	var drawings(default, null):Array<Drawing>;

	public function erase() {
		for (drawing in drawings) {
			drawing.erase();
		}
		on_erase(this);
	}

	public function draw() {
		for (drawing in drawings) {
			drawing.draw();
		}
	}
}

typedef MakeWord = (x:Int, y:Int, text:String, color:RGBA, ?x_center_offset:Null<Int>) -> Word;

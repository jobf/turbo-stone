package stone.editing;

import stone.abstractions.Graphic;
import stone.core.Engine;
import stone.core.Models;
import stone.editing.Editor;

using stone.editing.Editor.GraphicsExtensions;

@:publicFields
class Overview{
	static function render_models(models:Array<FigureModel>, size_model:Int, graphics:GraphicsBase){
		var total_rows = Std.int(256 / 16);
		var total_columns = total_rows;

		var geometry:Rectangle = {
			x: 0,
			y: 0,
			width: size_model,
			height: size_model
		}
		
		var translation = new EditorTranslation(geometry);
		
		for (r in 0...total_rows) {
			var index_model = total_columns * r;
			for(c in 0...total_columns){
				geometry.x = c * size_model;
				graphics.map_figure(models[index_model], translation);
				index_model++;
			}
			geometry.x = 0;
			geometry.y += size_model;
		}
	}
}
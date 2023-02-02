package stone.editing;

import stone.core.GraphicsAbstract;
import stone.core.Models;
import stone.editing.Editor;
import stone.core.Engine;

using stone.editing.Editor.GraphicsExtensions;

class Overview{
	public static function render_models(models:Array<FigureModel>, size_model:Int, graphics:GraphicsAbstract){
		var total_rows = Std.int(256 / 16);
		var total_columns = total_rows;

		var geometry:RectangleGeometry = {
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
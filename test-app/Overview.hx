import stone.text.Text;
import stone.editing.Editor;
import stone.editing.Grid;
import stone.graphics.implementation.Graphics;
import stone.core.Models;
import stone.core.GraphicsAbstract;
import stone.core.Engine;
import stone.core.Ui;

using stone.editing.Editor.GraphicsExtensions;

class Overview extends Scene {
	var text:Text;
	var ui:Ui;
	var file:FileModel;

	
	public function new(graphics_hud:Graphics, game:Game, bounds:RectangleGeometry, color:RGBA, file:FileModel) {
		super(game, bounds, color);
		this.file = file;
	}

	public function init() {
		var segments = 16;
		var model_size = Std.int(bounds.height/segments);
		text = new Text(font_load_embedded(model_size), game.graphics);

		var x_center = Std.int(bounds.width * 0.5);
		var y_center = 0;
		
		var width_grid = Std.int(bounds.height);
		var height_grid = Std.int(bounds.height);
		
		var draw_central_lines = false;
		
		Grid.grid_draw(game.graphics.make_line, text.font.height_model, x_center, y_center, width_grid, height_grid, draw_central_lines);

		var model_bounds:RectangleGeometry = {
			y: 0,
			x: 0,
			width: model_size,
			height: model_size
		}

		var translation = new EditorTranslation(model_bounds);

		var total_rows = segments;
		var total_columns = segments;

		for (r in 0...total_rows) {
			var index_model = total_columns * r;
			for(i in 0...total_columns){
				model_bounds.x = i * model_size;
				game.graphics.map_figure(file.models[index_model], translation);
				index_model++;
			}
			model_bounds.x = 0;
			model_bounds.y += model_size;
		}
	}

	public function update(elapsed_seconds:Float) {
	}

	public function draw() {
		text.draw();
	}

	public function close() {
		ui.clear();
	}
}

import stone.util.DateExtensions;
import stone.HudScene;
import stone.core.Engine;
import stone.core.GraphicsAbstract;
import stone.core.Models;
import stone.editing.Editor;
import stone.editing.Grid;

using stone.editing.Editor.GraphicsExtensions;

class Overview extends HudScene {
	var file:FileModel;
	
	public function new(game:Game, bounds:RectangleGeometry, color:RGBA, file:FileModel) {
		super(game, bounds, color);
		this.file = file;
	}

	override function init() {
		super.init();

		var segments = 16;
		var model_size = Std.int(bounds_main.height / segments);

		var x_center = Std.int(bounds_main.height * 0.5);
		var y_center = 0;
		
		var width_grid = Std.int(bounds_main.height);
		var height_grid = Std.int(bounds_main.height);
		
		var draw_central_lines = false;
		
		Grid.grid_draw(graphics_main.make_line, model_size, x_center, y_center, width_grid, height_grid, draw_central_lines);

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
				graphics_main.map_figure(file.models[index_model], translation);
				index_model++;
			}
			model_bounds.x = 0;
			model_bounds.y += model_size;
		}

		add_button(KEY_X, {
			on_pressed: () -> {
				var time_stamp = DateExtensions.to_time_stamp(Date.now());
				var path = '$time_stamp.png';
				@:privateAccess
				stone.file.PNG.dump(graphics_main.readPixels(), graphics_main.display.width, graphics_main.display.height, path);
			},
			name: "PNG"
		});
	}
}


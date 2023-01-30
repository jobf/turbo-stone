import stone.graphics.implementation.Graphics;
import stone.Theme;
import stone.DesignerScene;
import stone.HudScene;
import stone.core.Engine;
import stone.core.GraphicsAbstract;
import stone.core.Models;
import stone.editing.Grid;
import stone.editing.Overview;

using stone.util.DateExtensions;

class OverviewScene extends HudScene {
	var file:FileModel;
	var file_name:String;

	public function new(game:Game, bounds:RectangleGeometry, color:RGBA, file:FileModel, file_name:String) {
		super(game, bounds, color);
		this.file = file;
		this.file_name = file_name;
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

		Overview.render_models(file.models, model_size, graphics_main);

		add_button(KEY_E, {
			on_pressed: () -> {
				var init_scene:Game->Scene = game -> new DesignerScene(game, bounds, Theme.bg_scene, file, file_name);
				game.scene_change(init_scene);
			},
			name: "EDIT"
		});

		add_space();

		add_button(KEY_X, {
			on_pressed: () -> {
				var size_tile = 128;
				var size_texture = size_tile * 16;
				
				var graphics:Graphics = cast graphics_main.graphics_new_layer(size_texture, size_texture);
				
				Overview.render_models(file.models, size_tile, graphics);
				
				var time_stamp = Date.now().to_time_stamp();
				var path = '$time_stamp.png';

				@:privateAccess
				stone.file.PNG.dump(graphics.readPixels(), size_texture, size_texture, path);
				
				@:privateAccess
				graphics.display.peoteView.removeDisplay(graphics.display);

			},
			name: "PNG"
		});
	}
}

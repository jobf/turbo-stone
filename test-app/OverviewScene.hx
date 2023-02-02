import stone.HudScene;
import stone.ui.Tray;
import stone.graphics.implementation.Graphics;
import stone.Theme;
import stone.DesignerScene;
import stone.core.Engine;
import stone.core.GraphicsAbstract;
import stone.core.Models;
import stone.editing.Grid;
import stone.editing.Overview;
import stone.file.PNG;

using stone.util.DateExtensions;

class OverviewScene extends HudScene {
	var file:FileModel;
	var file_list_key:String;

	public function new(game:Game, bounds:RectangleGeometry, color:RGBA, file:FileModel, file_list_key:String) {
		var tray_sections:Array<Section> = [
			{
				contents: [
					{
						role: BUTTON,
						label: "EDIT",
						key_code: KEY_E,
						interactions: {
							on_click: interactive -> {
								var init_scene:Game->Scene = game -> new DesignerScene(game, bounds, Theme.bg_scene, file, file_list_key);
								game.scene_change(init_scene);
							}
						},
					}
				],
			},
			{
				contents: [
					{
						role: BUTTON,
						label: "PNG",
						interactions: {
							on_click: interactive -> {
								export_png();
							}
						},
						confirmation: {
							message: "EXPORT PNG?",
							confirm: "YES",
							cancel: "NO"
						}
					}
				],
			}

		];
		super(game, bounds, color, tray_sections);
		this.file = file;
		this.file_list_key = file_list_key;
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
	}

	function export_png(){
		var size_tile = 128;
		var size_texture = size_tile * 16;

		var graphics:Graphics = cast graphics_main.graphics_new_layer(size_texture, size_texture);

		Overview.render_models(file.models, size_tile, graphics);

		var data_pixels = readPixels(graphics.display);

		if(data_pixels != null){
			var time_stamp = Date.now().to_time_stamp();
			var file_name = '$time_stamp.png';
			var png_bytes = PNG.lime_bytes(data_pixels, size_texture, size_texture, file_name);
			game.storage.export_bytes(png_bytes, file_name);
		}

		graphics.display.peoteView.removeDisplay(graphics.display);
	}
}

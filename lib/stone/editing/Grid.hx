package stone.editing;

import stone.core.GraphicsAbstract;
import stone.Theme;

class Grid {
	public static function grid_draw(make_line:MakeLine, size_segment:Int, x_center:Int, y_center:Int, width:Int, height:Int, draw_central_lines:Bool = true):Array<AbstractLine> {
		var lines_grid:Array<AbstractLine> = [];
		if (lines_grid.length > 0) {
			var delete_index = lines_grid.length;
			while (delete_index-- > 0) {
				lines_grid[delete_index].erase();
				lines_grid.remove(lines_grid[delete_index]);
			}
		}

		for (x in 0...Std.int(width / size_segment) + 1) {
			var x_ = Std.int(x * size_segment);
			lines_grid.push(make_line(x_, 0, x_, height, Theme.grid_lines));
		}

		for (y in 0...Std.int(height / size_segment)) {
			var y_ = Std.int(y * size_segment);
			lines_grid.push(make_line(0, y_, width, y_, Theme.grid_lines));
		}

		if ((draw_central_lines)) {
			lines_grid.push(make_line(0, y_center, width, y_center, Theme.grid_lines_center));
			lines_grid.push(make_line(x_center, 0, x_center, height, Theme.grid_lines_center));
		}
		return lines_grid;
	}
}

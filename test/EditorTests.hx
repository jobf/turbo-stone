package test;
import stone.editing.Editor;
import stone.core.Engine;
import utest.Test;
import utest.Assert;

using stone.core.Vector;

class EditorTests extends Test {

	function test_viewport_to_editor_point_center() {
		var viewport:Rectangle = {
			width: 100,
			height: 100
		};

		var editor = new EditorTranslation(viewport);

		var position_mouse:Vector2 = {
			x: 50,
			y: 50
		}

		var position_editor = editor.view_to_model_point(position_mouse);

		Assert.equals(0, position_editor.x);
		Assert.equals(0, position_editor.y);
	}


	function test_viewport_to_editor_point_min() {
		var viewport:Rectangle = {
			width: 100,
			height: 100
		};

		var points_in_editor_x = 2;
		var points_in_editor_y = 2;
		var editor = new EditorTranslation(viewport, points_in_editor_x, points_in_editor_y);

		var position_mouse:Vector2 = {
			x: 0,
			y: 0
		}

		var position_editor = editor.view_to_model_point(position_mouse);

		Assert.equals(-1, position_editor.x);
		Assert.equals(-1, position_editor.y);
	}

	function test_viewport_to_editor_point_max() {
		var viewport:Rectangle = {
			width: 100,
			height: 100
		};

		var points_in_editor_x = 2;
		var points_in_editor_y = 2;
		var editor = new EditorTranslation(viewport, points_in_editor_x, points_in_editor_y);

		var position_mouse:Vector2 = {
			x: 100,
			y: 100
		}

		var position_editor = editor.view_to_model_point(position_mouse);

		Assert.equals(1, position_editor.x);
		Assert.equals(1, position_editor.y);
	}


	function test_model_to_viewport_point_min() {
		var viewport:Rectangle = {
			width: 100,
			height: 100
		};

		var points_in_editor_x = 2;
		var points_in_editor_y = 2;
		var editor = new EditorTranslation(viewport, points_in_editor_x, points_in_editor_y);

		var model_point:Vector2 = {
			x: -1,
			y: -1
		}

		var viewport_point = editor.model_to_view_point(model_point);

		Assert.equals(0, viewport_point.x);
		Assert.equals(0, viewport_point.y);
	}

	function test_model_to_viewport_point_max() {
		var viewport:Rectangle = {
			width: 100,
			height: 100
		};

		var points_in_editor_x = 2;
		var points_in_editor_y = 2;
		var editor = new EditorTranslation(viewport, points_in_editor_x, points_in_editor_y);

		var model_point:Vector2 = {
			x: 1,
			y: 1
		}

		var viewport_point = editor.model_to_view_point(model_point);

		Assert.equals(100, viewport_point.x);
		Assert.equals(100, viewport_point.y);
	}
}

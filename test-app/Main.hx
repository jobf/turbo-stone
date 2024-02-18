import Graphics;
import haxe.CallStack;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.Window;
import peote.view.Display;
import peote.view.PeoteView;
import stone.core.Engine;
import stone.core.Models;
import stone.core.Storage;
import stone.editing.scenes.DesignerScene;
import stone.editing.scenes.FileStorageScene;
import stone.editing.scenes.LoadingScene;
import stone.editing.Theme;
import stone.input.Input;

using stone.util.DateExtensions;

class Main extends Application {
	var peoteview:PeoteView;
	var display_main:Display;
	var display_hud:Display;

	var isReady:Bool;
	var time:Float = 0;
	var elapsed_seconds:Float = 0;
	var game:Game;

	// var implementation_graphics:Graphics;
	var implementation_input:Input;

	override function onWindowCreate() {
		super.onWindowCreate();

		switch (window.context.type) {
			case WEBGL, OPENGL, OPENGLES:
				try
					init(window)
				catch (_)
					trace(CallStack.toString(CallStack.exceptionStack()), _);
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}

	var init_layer:GraphicsConstructor;

	public function init(window:Window) {
		var viewport_window:Rectangle = {
			y: 0,
			x: 0,
			width: 800,
			height: 640
		}

		peoteview = new PeoteView(window);
		implementation_input = new Input(window);

		init_layer = (width:Int, height:Int) -> {
			var bounds:Rectangle = {
				x: 0,
				y: 0,
				width: width,
				height: height
			}
			var display = new Display(0, 0, width, height);
			peoteview.addDisplay(display);
			return new Graphics(display, bounds, init_layer);
		}

		var storage = new Storage(window);
		var file_list = storage.file_paths();

		if (file_list.length <= 0) {
			var file_empty = storage.file_new();
			storage.file_save(file_empty);
			file_list = storage.file_paths();
		} else {
			var index_end_of_list = file_list.length - 1;
			var file_name = file_list[index_end_of_list];
			var file_latest = storage.file_load(file_name);
			var has_valid_file = file_latest != null && file_latest.json.content.length > 0;
			if (!has_valid_file) {
				// make sure to save new file if we needed to make one
				var file_empty = storage.file_new();
				storage.file_save(file_empty);
				file_list = storage.file_paths();
			}
		}

		var start:SceneStart = DESIGN;

		#if testoverview
		start = OVERVIEW;
		#end

		#if testui
		start = TESTUI;
		#end

		#if teststorage
		start = STORAGE;
		#end

		if (file_list.length > 0) {
			var index_end_of_list = file_list.length - 1;
			var file_name = file_list[index_end_of_list];
			var file_latest = storage.file_load(file_name);
			var file:FileModel = Deserialize.parse_file_contents(file_latest.json.content);

			var init_scene:Game->Scene = switch start {
				case DESIGN: game -> new DesignerScene(game, viewport_window, Theme.bg_scene, file, file_name);
				case STORAGE: game -> new FileStorageScene(game, viewport_window, Theme.bg_scene, file_name);
				case OVERVIEW: game -> new OverviewScene(game, viewport_window, Theme.bg_scene, file, file_name);
				case TESTUI: game -> new TestTray(game, viewport_window, 0x332036FF);
			};

			var init_scene_loader:Game->Scene = game -> new LoadingScene(preloader, init_scene, game, viewport_window, Theme.bg_scene);

			game = new Game(init_scene_loader, init_layer, implementation_input, storage);
			isReady = true;
		} else {
			trace('something went very wrong * sad face *');
		}
	}

	override function update(deltaTime:Int):Void {
		super.update(deltaTime);

		if (!isReady) {
			return;
		}

		elapsed_seconds = deltaTime / 1000;
		time += elapsed_seconds;
		game.update(elapsed_seconds);
	}

	override function render(context:RenderContext) {
		super.render(context);

		if (!isReady) {
			return;
		}

		game.draw();
	}
}

enum SceneStart {
	DESIGN;
	STORAGE;
	OVERVIEW;
	TESTUI;
}

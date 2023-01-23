import stone.core.Storage;
import peote.view.Display;
import peote.view.PeoteView;
import stone.core.Engine;
import stone.input.Input;
import stone.LoadingScene;
import stone.DesignerScene;
import stone.graphics.implementation.Graphics;
import lime.graphics.RenderContext;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

using stone.util.DateExtensions;

class Main extends Application {
	var peoteview:PeoteView;
	var display_main:Display;
	var display_hud:Display;

	var isReady:Bool;
	var time:Float = 0;
	var elapsed_seconds:Float = 0;
	var game:Game;

	var implementation_graphics:Graphics;
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

	public function init(window:Window) {
		var black = 0x000000ff;
		var slate = 0x151517ff;

		var viewport_window:RectangleGeometry = {
			y: 0,
			x: 0,
			width: window.width,
			height: window.height
		}

		peoteview = new PeoteView(window);
		display_main = new Display(0, 0, 800, 640);
		peoteview.addDisplay(display_main);

		display_hud = new Display(0, 0, window.width, window.height);
		peoteview.addDisplay(display_hud);

		implementation_graphics = new Graphics(display_main, viewport_window);
		implementation_input = new Input(window);
		implementation_graphics.set_color(slate);

		var init_scene:Game->Scene = game -> new FileBrowseTest(game, viewport_window, black);

		#if simple
		init_scene = game -> new SimpleDraw(game, viewport_window, black);
		#end

		var init_scene_loader:Game->Scene = game -> new LoadingScene(preloader, init_scene, game, viewport_window, 0x00000000);

		var storage = new Storage(window);

		game = new Game(init_scene_loader, implementation_graphics, implementation_input, storage);

		isReady = true;
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

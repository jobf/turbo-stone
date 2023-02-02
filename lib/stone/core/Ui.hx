package stone.core;

import stone.text.Text;
import stone.core.GraphicsAbstract;
import stone.core.Engine;
import stone.ui.Interactive;
import stone.graphics.implementation.Graphics;

class Ui{
	var sliders(default, null):Array<Slider>;
	var clickers(default, null):Array<Interactive>;
	
	var graphics:GraphicsAbstract;
	var text:Text;

	public var y_start_offset:Int = 0;

	public function new(graphics_new_layer:GraphicsConstructor){
		sliders = [];
		clickers = [];
		// todo pass window bounds size in 
		this.graphics = graphics_new_layer(800, 640);
		this.text =  new Text(font_load_embedded(24), graphics_new_layer(800, 640));
	}

	public function handle_mouse_click(x_mouse:Int, y_mouse:Int){
		for (slider in sliders) {
			if (slider.overlaps_background(x_mouse, y_mouse)) {
				slider.click();
			}
		}

		for (toggle in clickers) {
			if (toggle.overlaps_background(x_mouse, y_mouse)) {
					toggle.click();
			}
		}
	}

	public function handle_mouse_release(){
		for (slider in sliders) {
			slider.release();
		}

		for (toggle in clickers) {
			toggle.release();
		}

	}

	public function handle_mouse_moved(x_mouse:Int, y_mouse:Int){
		for (slider in sliders) {

			if (slider.is_clicked) {
				slider.move(x_mouse);
			}
			else{
				var is_mouse_over = slider.overlaps_background(x_mouse, y_mouse);
				slider.hover(is_mouse_over);
			}
		}

		for (click in clickers) {
			var is_mouse_over = click.overlaps_background(x_mouse, y_mouse);
			click.hover(is_mouse_over);
		}
	}

	public function clear() {
		sliders.clear(slider -> slider.erase());
		clickers.clear(clicker -> clicker.erase());
	}


	public function hide(){
		// trace('hide all');
		for (interactive in clickers) {
			interactive.hide();
		}

		for (slider in sliders) {
			slider.hide();
		}
	}

	public function show(force_refresh:Bool=false){
		for (interactive in clickers) {
			var is_not_showing = !interactive.is_enabled;
			if(is_not_showing || force_refresh){
				if(interactive.model.conditions != null){
					var condition_is_true = interactive.model.conditions();
					if(condition_is_true){
						interactive.show();
					}
					else{
						interactive.hide();
					}
				}else{
					interactive.show();
				}
			}
		}

		for (interactive in sliders) {
			if(!interactive.is_enabled){
				if(interactive.model.conditions != null && interactive.model.conditions()){
					interactive.show();
				}
			}
			else{
				interactive.show();
			}
		}
	}

	public function make_slider(model:InteractiveModel, geometry:RectangleGeometry, color_fg:RGBA, color_bg:RGBA):Slider {
		var on_erase = model.interactions.on_erase;
		model.interactions.on_erase = (interactive:Interactive) -> {
			sliders.remove(cast interactive);
			on_erase(interactive);
		}

		var slider = new Slider(
			model,
			geometry,
			color_fg,
			color_bg,
			graphics,
			text
		);

		sliders.push(slider);
		return slider;
	}


	public function make_toggle(model:InteractiveModel, geometry:RectangleGeometry, color_fg:RGBA, color_bg:RGBA, is_enabled:Bool):Toggle {
		var on_erase = model.interactions.on_erase;
		model.interactions.on_erase = (interactive:Interactive) -> {
			clickers.remove(interactive);
			on_erase(interactive);
		}


		var toggle = new Toggle(model, geometry, color_fg, color_bg, graphics, text, is_enabled);
		clickers.push(toggle);
		return toggle;
	}

	public function make_button(model:InteractiveModel, geometry:RectangleGeometry, color_fg:RGBA, color_bg:RGBA):Button {
		var on_erase = model.interactions.on_erase;
		model.interactions.on_erase = (interactive:Interactive) -> {
			clickers.remove(interactive);
			// on_erase(interactive);
		}

		// trace('button x ${geometry.x} button y ${geometry.y} $label');
		var button = new Button(model, geometry, color_fg, color_bg, graphics, text);
		clickers.push(button);
		return button;
	}

	public function make_label(model:InteractiveModel, geometry:RectangleGeometry, color_fg:RGBA, color_bg:RGBA):Label {
		var on_erase = model.interactions.on_erase;
		model.interactions.on_erase = (interactive:Interactive) -> {
			clickers.remove(cast interactive);
			// on_erase(interactive);
		}
		
		// trace('label x ${geometry.x} label y ${geometry.y} $label_text');

		var label = new Label(model, geometry, color_fg, color_bg, graphics, text);
		clickers.push(label);
		return label;
	}

	public function make_dialog_text(message:String, geometry:RectangleGeometry, color_fg:RGBA, color_bg:RGBA, text_align:Align=CENTER):TextArea{
		var x_center = Std.int(geometry.x + geometry.width * 0.5);
		var y_center = Std.int(geometry.y + geometry.height * 0.5);
		var lines = message.split("\n");
		var y_text = Std.int(geometry.y + geometry.height * 0.5) - Std.int((lines.length * text.font.height_model) * 0.5);
		var words:Array<Word> = [for (line in lines) text.word_make(x_center, y_text+=text.font.height_model, line, color_fg, geometry.width, text_align)];

		return {
			text: words,
			background: graphics.make_fill(x_center, y_center, geometry.width, geometry.height, color_bg)
		}
	}

	function erase(interactives:Array<Interactive>){
		interactives.clear(interactive -> interactive.erase);
	}
}

@:structInit
class TextArea{
	public var text:Array<Word>;
	public var background:AbstractFillRectangle;
}

package stone.core;

import Graphics;
import stone.abstractions.Graphic;
import stone.core.Color;
import stone.core.Engine;
import stone.text.Text;
import stone.ui.Interactive;

class Ui{
	var sliders(default, null):Array<Slider>;
	var clickers(default, null):Array<Interactive>;
	var labels(default, null):Array<Interactive>;
	
	var graphics:GraphicsBase;
	var text:Text;

	public var y_start_offset:Int = 0;

	public function new(graphics_new_layer:GraphicsConstructor){
		sliders = [];
		clickers = [];
		labels = [];
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

		for (interactive in labels) {
			if(interactive.model.label_change != null){
				interactive.change_text(interactive.model.label_change());
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
			var interactive:Interactive = cast slider;

			var is_mouse_over = slider.overlaps_background(x_mouse, y_mouse);

			if(is_mouse_over){
				interactive.mouse_over();
			}
			else{
				interactive.mouse_out();
			}

			if (slider.is_clicked) {
				slider.move(x_mouse);
			}
		}

		for (interactive in clickers) {
			var is_mouse_over = interactive.overlaps_background(x_mouse, y_mouse);
			
			if(is_mouse_over){
				interactive.mouse_over();
			}
			else{
				interactive.mouse_out();
			}

		}
	}

	public function clear() {
		sliders.clear(slider -> slider.erase());
		clickers.clear(clicker -> clicker.erase());
		labels.clear(interactive -> interactive.erase());
	}


	public function hide(){
		// trace('hide all');
		for (interactive in clickers) {
			interactive.hide();
		}

		for (interactive in sliders) {
			interactive.hide();
		}

		for (interactive in labels) {
			@:privateAccess
			trace('hide label ${interactive.label.text}');
			interactive.hide();
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

		for (interactive in labels) {
			interactive.show();
		}

		for (interactive in sliders) {
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
	}

	public function make_slider(model:InteractiveModel, geometry:Rectangle, color_fg:RGBA, color_bg:RGBA, fraction:Float):Slider {
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
			text,
			fraction
		);

		sliders.push(slider);
		return slider;
	}


	public function make_toggle(model:InteractiveModel, geometry:Rectangle, color_fg:RGBA, color_bg:RGBA, is_enabled:Bool):Toggle {
		var on_erase = model.interactions.on_erase;
		model.interactions.on_erase = (interactive:Interactive) -> {
			clickers.remove(interactive);
			on_erase(interactive);
		}


		var toggle = new Toggle(model, geometry, color_fg, color_bg, graphics, text, is_enabled);
		clickers.push(toggle);
		return toggle;
	}

	public function make_button(model:InteractiveModel, geometry:Rectangle, color_fg:RGBA, color_bg:RGBA):Button {
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

	public function make_label(model:InteractiveModel, geometry:Rectangle, color_fg:RGBA, color_bg:RGBA, is_toggled:Null<Bool> = null):Interactive {
		
		if(is_toggled == null){
			var on_erase = model.interactions.on_erase;
			model.interactions.on_erase = (interactive:Interactive) -> {
				labels.remove(cast interactive);
				// on_erase(interactive);
			}
			var label = new Label(model, geometry, color_fg, color_bg, graphics, text);
			labels.push(label);
			label.show();
			return label;
		}

		var on_erase = model.interactions.on_erase;
		model.interactions.on_erase = (interactive:Interactive) -> {
			clickers.remove(cast interactive);
			// on_erase(interactive);
		}
		// trace('label toggle ${model.label}');
		var is_toggled_ = is_toggled == null ? false : is_toggled;
		var label_toggle = new LabelToggle(model, geometry, color_fg, color_bg, graphics, text, is_toggled_);
		clickers.push(label_toggle);
		return label_toggle;
	}

	public function make_dialog_text(message:String, geometry:Rectangle, color_fg:RGBA, color_bg:RGBA, text_align:Align=CENTER):TextArea{
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
	public var background:FillBase;
}

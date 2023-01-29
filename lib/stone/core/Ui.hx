package stone.core;

import stone.text.Text;
import stone.core.GraphicsAbstract;
import stone.core.Engine;
import stone.ui.Components;

class Ui {

	var dialog:Null<Dialog> = null;

	var graphics:GraphicsAbstract;
	var graphics_dialog:GraphicsAbstract;

	var text:Text;
	var components:ComponentsCollection;

	var x_mouse:Int;
	var y_mouse:Int;

	var bounds_components:RectangleGeometry;
	var bounds_dialog:RectangleGeometry;

	var height_component:Int;
	
	public function new(graphics:GraphicsAbstract, graphics_dialog:GraphicsAbstract, bounds_components:RectangleGeometry, bounds_dialog:RectangleGeometry) {
		this.graphics = graphics;
		this.graphics_dialog = graphics_dialog;

		text = new Text(font_load_embedded(24), graphics_dialog);

		height_component = Std.int(text.font.height_model * 1.5);
		this.bounds_components = bounds_components;
		this.bounds_dialog = bounds_dialog;
		this.components = new ComponentsCollection(graphics, text, bounds_components, bounds_dialog, height_component);
	}

	public function draw(){
		text.draw();
	}

	public function make_slider(interactions:Interactions, label:String, color_fg:RGBA, color_bg:RGBA):Slider {
		return components.make_slider(
			interactions,
			{
				y: bounds_components.y,
				x: bounds_components.x,
				width: bounds_components.width,
				height: height_component
			},
			label,
			color_fg,
			color_bg
		);
	}

	public function make_toggle(interactions:Interactions, label:String, color_fg:RGBA, color_bg:RGBA, is_enabled:Bool):Toggle {
		return components.make_toggle(
			interactions,
			{
				y: bounds_components.y,
				x: bounds_components.x,
				width: bounds_components.width,
				height: height_component
			},
			label,
			color_fg,
			color_bg,
			is_enabled
		);
	}

	public function make_button(interactions:Interactions, label:String, color_fg:RGBA, color_bg:RGBA):Button {
		return components.make_button(
			interactions,
			{
				y: bounds_components.y,
				x: bounds_components.x,
				width: bounds_components.width,
				height: height_component
			},
			label,
			color_fg,
			color_bg
		);
	}

	public function make_label(interactions:Interactions, label:String, color_fg:RGBA, color_bg:RGBA):Label {
		return components.make_label(
			interactions,
			{
				y: bounds_components.y,
				x: bounds_components.x,
				width: bounds_components.width,
				height: height_component
			},
			label,
			color_fg,
			color_bg
		);
	}

	public function make_dialog(lines_text:Array<String>, color_fg:RGBA, color_bg:RGBA, buttons:Array<ButtonModel>=null):Dialog {
		if(dialog == null){
			components.hide();
			dialog = new Dialog(bounds_dialog, bounds_components, height_component, lines_text, color_fg, color_bg, graphics_dialog, text, buttons);
			dialog.on_erase.add(s -> {
				this.dialog = null;
				components.show();
			});
		}
		return dialog;
	}

	public function handle_mouse_click() {
		if(dialog == null){
			components.handle_mouse_click(x_mouse, y_mouse);
		}
		else{
			dialog.handle_mouse_click(x_mouse, y_mouse);
		}
	}

	public function handle_mouse_release() {
		if(dialog == null){
			components.handle_mouse_release();
		}
		else{
			dialog.handle_mouse_release();
		}
	}

	public function handle_mouse_moved(mouse_position:Vector) {
		x_mouse = Std.int(mouse_position.x);
		y_mouse = Std.int(mouse_position.y);

		if(dialog_is_active()){
			dialog.handle_mouse_moved(x_mouse, y_mouse);
		}
		else{
			components.handle_mouse_moved(x_mouse, y_mouse);
		}
	}

	public function dialog_is_active():Bool{
		return dialog != null;
	}

	public function clear() {
		if(dialog != null){
			dialog.erase();
		}
		components.clear();
	}

	public function y_offset_increase(amount:Int){
		components.y_start_offset += amount;
	}
}


class ComponentsCollection{
	var sliders(default, null):Array<Slider>;
	var clickers(default, null):Array<InteractiveComponent>;
	
	var graphics:GraphicsAbstract;
	var text:Text;

	var bounds_components:RectangleGeometry;
	var bounds_dialog:RectangleGeometry;

	var height_component:Int;
	var y_align_is_top:Bool;

	public var y_start_offset:Int = 0;

	public function new(graphics:GraphicsAbstract, text:Text, bounds_components:RectangleGeometry, bounds_dialog:RectangleGeometry, height_component:Int, y_align_is_top:Bool=true){
		sliders = [];
		clickers = [];
		this.graphics = graphics;
		this.text = text;
		this.bounds_components = bounds_components;
		this.bounds_dialog = bounds_dialog;
		this.height_component = height_component;
		this.y_align_is_top = y_align_is_top;
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
		for (component in clickers) {
			component.hide();
		}

		for (slider in sliders) {
			slider.hide();
		}
	}


	public function show(){
		for (component in clickers) {
			component.show();
		}

		for (slider in sliders) {
			slider.show();
		}
	}

	function offset_y_component(geometry:RectangleGeometry){
		if(y_align_is_top){
			geometry.y = bounds_components.y + (height_component * (clickers.length + sliders.length)) + y_start_offset;
		}
		else{
			geometry.y = bounds_components.height - height_component - (height_component * (clickers.length + sliders.length));
		}
	}

	public function make_slider(interactions:Interactions, geometry:RectangleGeometry, label:String, color_fg:RGBA, color_bg:RGBA):Slider {
		var on_erase = interactions.on_erase;
		interactions.on_erase = (component:InteractiveComponent) -> {
			sliders.remove(cast component);
			// on_erase(component);
		}

		offset_y_component(geometry);

		var slider = new Slider(label, interactions,
			geometry,
			color_fg,
			color_bg,
			graphics,
			text
		);

		sliders.push(slider);
		return slider;
	}


	public function make_toggle(interactions:Interactions, geometry:RectangleGeometry, label:String, color_fg:RGBA, color_bg:RGBA, is_enabled:Bool):Toggle {
		var on_erase = interactions.on_erase;
		interactions.on_erase = (component:InteractiveComponent) -> {
			clickers.remove(component);
			on_erase(component);
		}

		offset_y_component(geometry);

		var toggle = new Toggle(label, interactions, geometry, color_fg, color_bg, graphics, text, is_enabled);
		clickers.push(toggle);
		return toggle;
	}

	public function make_button(interactions:Interactions, geometry:RectangleGeometry, label:String, color_fg:RGBA, color_bg:RGBA):Button {
		var on_erase = interactions.on_erase;
		interactions.on_erase = (component:InteractiveComponent) -> {
			clickers.remove(component);
			// on_erase(component);
		}

		offset_y_component(geometry);

		var button = new Button( label, interactions, geometry, color_fg, color_bg, graphics, text);
		clickers.push(button);
		return button;
	}

	public function make_label(interactions:Interactions, geometry:RectangleGeometry, label_text:String, color_fg:RGBA, color_bg:RGBA):Label {
		var on_erase = interactions.on_erase;
		interactions.on_erase = (component:InteractiveComponent) -> {
			clickers.remove(cast component);
			// on_erase(component);
		}
		
		offset_y_component(geometry);

		var label = new Label(label_text, interactions, geometry, color_fg, color_bg, graphics, text);
		clickers.push(label);
		return label;
	}
}
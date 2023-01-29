package stone.ui;

import stone.core.Ui;
import stone.core.Event;
import stone.core.Engine;
import stone.text.Text;
import stone.core.GraphicsAbstract;

class Button extends InteractiveComponent{
	public function new(label:String, interactions:Interactions, geometry:RectangleGeometry, color_fg:RGBA, color_bg:RGBA, graphics:GraphicsAbstract, text:Text) {
		super(label, interactions, geometry, color_fg, color_bg, graphics, text);
	}
}


class Label extends InteractiveComponent{
	var track:AbstractLine;
	var handle:AbstractFillRectangle;
	public var on_change:Bool->Void = b -> trace('on_change $b');
	public var is_toggled(default, set):Bool;
	function set_is_toggled(v:Bool):Bool{
		is_toggled = v;
		on_change(is_toggled);
		return is_toggled;
	}
	public function new(label:String, interactions:Interactions, geometry:RectangleGeometry, color_fg:RGBA, color_bg:RGBA, graphics:GraphicsAbstract, text:Text) {
		super(label, interactions, geometry, color_fg, color_bg, graphics, text, LEFT,  0, true);
	}

	override function click() {
		super.click();
		is_toggled = !is_toggled;
		highlight(is_toggled);
	}
}

class Toggle extends InteractiveComponent{
	var track:AbstractLine;
	var handle:AbstractFillRectangle;
	public var on_change:Bool->Void = b -> trace('on_change $b');
	public var is_toggled(default, set):Bool;
	function set_is_toggled(v:Bool):Bool{
		is_toggled = v;
		on_change(is_toggled);
		handle_move();
		return is_toggled;
	}
	public function new(label:String, interactions:Interactions, geometry:RectangleGeometry, color_fg:RGBA, color_bg:RGBA, graphics:GraphicsAbstract, text:Text, is_enabled_:Bool) {
		super(label, interactions, geometry, color_fg, color_bg, graphics, text, LEFT);
		var width_track = text.font.width_character;
		var y_track = geometry.y + Std.int(geometry.height * 0.5);
		var x_track = Std.int(x_background + (geometry.width * 0.5) - (width_track + text.font.width_character));
		var size_handle = Std.int(text.font.width_character);

		this.track = graphics.make_line(x_track, y_track, x_track + width_track, y_track, color_fg);
		this.handle = graphics.make_fill(x_track, y_track, size_handle, size_handle, color_fg);
	}

	override function click() {
		super.click();
		is_toggled = !is_toggled;
		handle_move();
	}

	function handle_move() {
		var x_handle = is_toggled ? track.point_to.x : track.point_from.x;
		handle.x = x_handle;
		trace('handle_move ${handle.x}');
	}
}

class Slider extends InteractiveComponent{
	var track:AbstractLine;
	var handle:AbstractFillRectangle;
	public var on_move:Float->Void = f -> trace('on_move $f');

	public function new(label:String, interactions:Interactions, geometry:RectangleGeometry, color_fg:RGBA, color_bg:RGBA, graphics:GraphicsAbstract, text:Text) {
		var y_label_offset:Int = Std.int(text.font.height_model * 0.5);
		geometry.height += text.font.height_model;
		super(label, interactions, geometry, color_fg, color_bg, graphics, text, LEFT, -y_label_offset);
		var width_track = geometry.width - (text.font.width_model);// * 2);
		var y_track = geometry.y + Std.int(geometry.height * 0.5) + y_label_offset;
		var x_track = Std.int(x_background + (geometry.width * 0.5) - (width_track + text.font.width_character));
		var size_handle = Std.int(text.font.width_character);

		this.track = graphics.make_line(x_track, y_track, x_track + width_track, y_track, color_fg);
		this.handle = graphics.make_fill(x_track, y_track, size_handle, size_handle, color_fg);
	}

	public function move(x_mouse:Float){
		if (x_mouse > x_min && x_mouse < x_max) {
			handle.x = x_mouse;
			var x_proportional = handle.x - track.point_from.x;
			on_move(x_proportional / track.length);
		}
	}

	public var x_min(get, never):Int;
	function get_x_min():Int {
		return Std.int(track.point_from.x);
	}
	
	public var x_max(get, never):Int;
	function get_x_max():Int {
		return Std.int(track.point_from.x + track.length);
	}
}

@:structInit
class ButtonModel{
	public var text:String;
	public var action:Void->Void;
}


@:structInit
class Interactions{
	public var on_click:InteractiveComponent->Void = (component:InteractiveComponent)-> return;
	public var on_release:InteractiveComponent->Void = (component:InteractiveComponent)-> return;
	public var on_erase:InteractiveComponent->Void = (component:InteractiveComponent)-> return;
	public var on_hover:Bool->Void = (should_hover:Bool)-> return;
	public var on_highlight:Bool->Void = (should_highlight:Bool)-> return;
}

class InteractiveComponent {
	var background:AbstractFillRectangle;
	var alpha_bg:Int ;
	var alpha_highlight:Int;
	var alpha_hover:Int;
	var alpha_idle:Int ;
	public var is_clicked(default, null):Bool = false;
	var is_highlighted:Bool = false;
	var interactions:Interactions;
	var x_center:Int;
	var y_center:Int;
	var x_background:Int;
	var y_background:Int;
	var label:Word;
	var is_enabled = true;
	public function new(label:String, interactions:Interactions, geometry:RectangleGeometry, color_fg:RGBA, color_bg:RGBA, graphics:GraphicsAbstract, text:Text, align:Align=CENTER, y_label_offset:Int=0, alpha_idle_is_transparent:Bool=false) {
		this.interactions = interactions;

		x_center = Std.int(geometry.width * 0.5);
		y_center = Std.int(geometry.height * 0.5);

		x_background = Std.int(geometry.x + x_center);
		y_background = Std.int(geometry.y + y_center);

		background = graphics.make_fill(x_background, y_background, geometry.width, geometry.height, color_bg);
		
		alpha_bg = background.color.a;
		alpha_idle = alpha_idle_is_transparent ? 0 : color_bg.a;
		alpha_highlight = alpha_idle_is_transparent ? Std.int(color_bg.a * 0.3) : color_bg.a;
		alpha_hover = alpha_idle_is_transparent ?  Std.int(color_bg.a * 0.2) : Std.int(color_bg.a * 0.9);
		background.color.a = alpha_idle;
		var x_label = x_background;
		var y_label = y_background + y_label_offset;
		var width_label = (1 + label.length) * text.font.width_character;
		this.label = text.word_make(x_label, y_label, label, color_fg, geometry.width, align);
	}

	public function reset(){
		is_clicked = false;
	}

	public function click() {
		if(!is_enabled){
			return;
		}
		is_clicked = true;
		interactions.on_click(this);
	}

	public function release() {
		if(!is_enabled){
			return;
		}
		is_clicked = false;
		interactions.on_release(this);
	}

	public function erase() {
		background.erase();
		label.erase();
		interactions.on_erase(this);
	}

	public function hide() {
		is_enabled = false;
		background.color.a = 10;
	}


	public function show() {
		is_enabled = true;
		background.color.a = alpha_bg;
	}

	public function highlight(should_highlight:Bool) {
		if(!is_enabled){
			return;
		}
		is_highlighted = should_highlight;
		background.color.a = should_highlight ? alpha_highlight : alpha_idle;
		interactions.on_highlight(should_highlight);
	}

	public function hover(is_mouse_over:Bool) {
		if(!is_enabled){
			return;
		}
		if(is_highlighted){
			background.color.a = is_mouse_over ? alpha_hover : alpha_highlight;
		}
		else{
			background.color.a = is_mouse_over ? alpha_hover : alpha_idle;
		}
		interactions.on_hover(is_mouse_over);
	}

	public function overlaps_background(x_mouse:Int, y_mouse:Int):Bool {
		var x_offset = Std.int(background.width * 0.5);
		var y_offset = Std.int(background.height * 0.5);

		return x_mouse > background.x - x_offset
			&& y_mouse > background.y - y_offset
			&& background.x + background.width - x_offset > x_mouse
			&& background.y + background.height - y_offset > y_mouse;
	}
}

class Dialog {
	var lines:Array<Word>;
	var background:AbstractFillRectangle;

	var buttons:Array<Button> = [];
	var actions:Array<ButtonModel>;
	var components:ComponentsCollection;

	public var on_erase(default, null):Event<String>;

	public function new(bounds_dialog:RectangleGeometry, bounds_components:RectangleGeometry, height_component:Int, lines_text:Array<String>, color_fg:RGBA, color_bg:RGBA, graphics_layer_init:GraphicsConstructor, actions:Array<ButtonModel>=null) {
		on_erase = new Event();
		var y_align_is_top = false;
		var graphics_bg = graphics_layer_init();
		var graphics_fg = graphics_layer_init();
		var text = new Text(font_load_embedded(24), graphics_fg);
			components= new ComponentsCollection(graphics_layer_init, bounds_components, bounds_dialog, height_component, y_align_is_top);
		if(actions == null){
			this.actions = [];
		}
		else{
			this.actions = actions;
		}

		var width_center = Std.int(bounds_dialog.width * 0.5);
		var height_center = Std.int(bounds_dialog.width * 0.5);

		var length_line_max = 0;
		for (line in lines_text) {
			if(line.length > length_line_max){
				length_line_max = line.length;
			}
		}
		
		var gap = 10;
		var width_text = text.font.width_model * length_line_max;
		var height_text = (text.font.height_model + gap) * lines_text.length;

		var width_padding = text.font.width_model * 4;
		var height_padding = text.font.height_model * 4;

		var width_background = width_text + width_padding;
		var height_background = height_text + height_padding;
		
		var height_background_center = height_background * 0.5;

		var x_background = bounds_dialog.x + width_center;
		var y_background = Std.int(bounds_dialog.y + height_center - (height_background_center * 0.5));

		background = graphics_bg.make_fill(
			x_background,
			y_background,
			width_background,
			height_background,
			color_bg
		);
		
		var x_label = Std.int(x_background);
		var y_label = Std.int(y_background - (height_text * 0.5));

		lines = [];
		for (line in lines_text) {
			lines.push(text.word_make(
				x_label,
				y_label,
				line.toUpperCase(),
				color_fg,
				width_background
			));
			y_label += text.font.height_model + gap;
		}

		// add cancel action
		this.actions.push({
			text: "CANCEL",
			action: ()-> return
		});

		var buttons_count = this.actions.length;

		var button_geometry:RectangleGeometry = {
			x: bounds_components.x,
			y: bounds_components.y,
			width: bounds_components.width,
			height: height_component
		}

		for (model in this.actions) {
			var button = components.make_button(
				{
					// on_hover: on_hover,
					// on_highlight: on_highlight,
					// on_erase: on_erase,
					on_click: component -> {
						erase();
						model.action();
					}
				},
				button_geometry,
				model.text,
				color_fg,
				color_bg
			);
				
		}
	}

	public function handle_mouse_click(x_mouse:Int, y_mouse:Int) {
		components.handle_mouse_click(x_mouse, y_mouse);
	}

	public function handle_mouse_release() {
		components.handle_mouse_release();
	}

	public function handle_mouse_moved(x_mouse:Int, y_mouse:Int) {
		components.handle_mouse_moved(x_mouse, y_mouse);
	}

	public function erase() {
		var index_line = lines.length;
		while (index_line-- > 0) {
			var line = lines.pop();
			line.erase();
		}
		background.erase();
		components.clear();

		on_erase.dispatch("");
		on_erase.removeAll();
	}

	public function draw(){
	}
}

package stone.ui;

import stone.abstractions.Graphic;
import stone.core.Color;
import stone.core.Engine;
import stone.text.Text;


class Button extends Interactive{
	public function new(model:InteractiveModel, geometry:Rectangle, color_fg:RGBA, color_bg:RGBA, graphics:GraphicsBase, text:Text) {
		super(model, geometry, color_fg, color_bg, graphics, text);
	}
}


class Label extends Interactive{
	public function new(model:InteractiveModel, geometry:Rectangle, color_fg:RGBA, color_bg:RGBA, graphics:GraphicsBase, text:Text) {
		super(model, geometry, color_fg, color_bg, graphics, text, LEFT,  0, false);
	}

	override function click() {
	}

	// override function show() {
	// 	super.show();
	// }
}


class LabelToggle extends Interactive{
	public var on_change:Bool->Void = b -> trace('on_change $b');
	public var is_toggled(default, set):Bool;

	function set_is_toggled(v:Bool):Bool{
		is_toggled = v;
		background.color.a = is_toggled ? alpha_highlight : alpha_idle;
		on_change(is_toggled);
		return is_toggled;
	}

	public function new(model:InteractiveModel, geometry:Rectangle, color_fg:RGBA, color_bg:RGBA, graphics:GraphicsBase, text:Text, is_toggled:Bool) {
		super(model, geometry, color_fg, color_bg, graphics, text, LEFT,  0, true);
		this.is_toggled = is_toggled;
	}

	override function click() {
		trace('click ${model.label}');
		is_toggled = !is_toggled;
		background.color.a = is_toggled ? alpha_highlight : alpha_idle;
		super.click();
	}

	override function mouse_out() {
		super.mouse_out();
		if(is_toggled){
			background.color.a = alpha_highlight;
		}
	}

	override function reset() {
		super.reset();
		set_is_toggled(false);
	}
}


class Toggle extends Interactive{
	var track:LineBase;
	var handle:FillBase;
	public var on_change:Bool->Void = b -> trace('on_change $b');
	public var is_toggled(default, set):Bool;

	function set_is_toggled(v:Bool):Bool{
		is_toggled = v;
		on_change(is_toggled);
		handle_move();
		return is_toggled;
	}

	public function new(model:InteractiveModel, geometry:Rectangle, color_fg:RGBA, color_bg:RGBA, graphics:GraphicsBase, text:Text, is_toggled:Bool) {
		super(model, geometry, color_fg, color_bg, graphics, text, LEFT);
		var width_track = text.font.width_character;
		var y_track = geometry.y + Std.int(geometry.height * 0.5);
		var x_track = Std.int(x_background + (geometry.width * 0.5) - (width_track + text.font.width_character));
		var size_handle = Std.int(text.font.width_character);

		this.track = graphics.make_line(x_track, y_track, x_track + width_track, y_track, color_fg);
		this.handle = graphics.make_fill(x_track, y_track, size_handle, size_handle, color_fg);
		this.is_toggled = is_toggled;
	}

	override function click() {
		super.click();
		set_is_toggled(!is_toggled);
	}

	function handle_move() {
		var x_handle = is_toggled ? track.point_to.x : track.point_from.x;
		handle.x = x_handle;
		// trace('handle_move $is_toggled ${handle.x}');
	}

	override function reset() {
		set_is_toggled(false);
	}

	override function hide() {
		super.hide();
		track.color.a = 0;
		handle.color.a = 0;
	}

	override function show() {
		super.show();
		track.color.a = 255;
		handle.color.a = 255;
	}
}

class Slider extends Interactive{
	var track:LineBase;
	var handle:FillBase;
	var x_track:Int;
	var width_track:Int;
	public var on_move:Float->Void = f -> trace('on_move $f');
	public var fraction(default, null):Float = 0;
	public function new(model:InteractiveModel, geometry:Rectangle, color_fg:RGBA, color_bg:RGBA, graphics:GraphicsBase, text:Text, fraction:Float) {
		var y_label_offset:Int = Std.int(text.font.height_model * 0.5);
		geometry.height += text.font.height_model;
		super(model, geometry, color_fg, color_bg, graphics, text, LEFT, -y_label_offset);
		width_track = geometry.width - (text.font.width_model);
		var y_track = geometry.y + Std.int(geometry.height * 0.5) + y_label_offset;
		x_track = Std.int(x_background + (geometry.width * 0.5) - (width_track + text.font.width_character));
		var size_handle = Std.int(text.font.width_character);
		var x_handle = Std.int((width_track * fraction) + x_track) + 1;
		this.track = graphics.make_line(x_track, y_track, x_track + width_track, y_track, color_fg);
		this.handle = graphics.make_fill(x_handle, y_track, size_handle, size_handle, color_fg);
	}

	public function move(x_mouse:Float){
		if(!is_clicked){
			return;
		}
		if (x_mouse > x_min && x_mouse < x_max) {
			handle.x = x_mouse;
			var x_proportional = handle.x - track.point_from.x;
			fraction = x_proportional / track.length;
			on_move(fraction);
			model.interactions.on_change(this);
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

	public function set_detent(fraction:Float) {
		this.fraction = fraction;
		// trace('detent fraction $fraction ${model.label}');
		handle.x = (width_track * fraction) + x_track;
	}

	override function hide() {
		super.hide();
		track.color.a = 0;
		handle.color.a = 0;
	}

	override function show() {
		super.show();
		is_enabled = true;// todo - should notn need this
		track.color.a = 255;
		handle.color.a = 255;
	}
}

@:structInit
class ButtonModel{
	public var text:String;
	public var action:Void->Void;
}


enum InteractiveRole{
	BUTTON;
	LABEL;
	LABEL_TOGGLE(enabled:Bool);
	TOGGLE(enabled:Bool);
	SLIDER(fraction:Float);
}


@:structInit
class InteractiveModel {
	public var label:String;
	public var role:InteractiveRole;
	public var show_in_tray:Bool = true;
	public var interactions:Interactions = {};
	public var confirmation:Null<DialogModel> = null;
	public var dialog_text_align:Align = CENTER;
	public var label_text_align_override:Null<Align> = null;
	public var label_change:Null<Void->String> = null;
	public var conditions:Null<()->Bool> = null;
	public var key_code:Null<stone.abstractions.Input.Button> = null;
	public var sort_order:Int = 0;
	public var can_be_disabled:Bool = true;
	public var sub_contents:Null<Array<InteractiveModel>> = null;
}

@:structInit
class DialogModel{
	public var is_blocking:Bool = true;
	public var message:String = "";
	public var confirm:String = "";
	public var cancel:String = "";
	public var conditions:Null<()->Bool> = null;
}

@:structInit
class Interactions{
	public var on_click:Interactive->Void = (interactive:Interactive)-> return;
	public var on_release:Interactive->Void = (interactive:Interactive)-> return;
	public var on_over:Interactive->Void = (interactive:Interactive)-> return;
	public var on_out:Interactive->Void = (interactive:Interactive)-> return;
	public var on_change:Interactive->Void = (interactive:Interactive)-> return;
	public var on_erase:Interactive->Void = (interactive:Interactive)-> return;
	public var on_click_closes_menu:Bool = false;
}

class Interactive {
	public var model:InteractiveModel;
	var background:FillBase;
	var alpha_bg:Int ;
	var alpha_highlight:Int;
	var alpha_hover:Int;
	var alpha_idle:Int ;
	public var is_clicked(default, null):Bool = false;
	var x_center:Int;
	var y_center:Int;
	var x_background:Int;
	var y_background:Int;
	var label:Word;
	var text:Text;
	var color_fg:RGBA;
	var is_mouse_over:Bool = false;
	var is_mouse_out:Bool = true;

	public var is_enabled(default, null):Bool = true;
	public var height(get,never):Int;
	function get_height():Int{
		return Std.int(background.height);
	}
	public function new(model:InteractiveModel, geometry:Rectangle, color_fg:RGBA, color_bg:RGBA, graphics:GraphicsBase, text:Text, align:Align=CENTER, y_label_offset:Int=0, alpha_idle_is_transparent:Bool=false) {
		this.model = model;
		this.text = text;
		this.color_fg = color_fg;
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
		var width_label = (1 + model.label.length) * text.font.width_character;
		var label_text = model.show_in_tray ? model.label : "";
		var label_text_align = model.label_text_align_override == null ? align : model.label_text_align_override;
		this.label = text.word_make(x_label, y_label, label_text, color_fg, geometry.width, label_text_align);
	}
	
	public function enable(){
		is_enabled = true;
	}

	public function reset(){
		is_clicked = false;
		background.color.a = alpha_idle;
	}

	public function click() {
		if(model.can_be_disabled && !is_enabled){
			return;
		}
		// trace('click ${model.label}');
		is_clicked = true;
		model.interactions.on_click(this);
	}

	public function release() {
		if(model.can_be_disabled && !is_enabled){
			return;
		}
		is_clicked = false;
		model.interactions.on_release(this);
	}

	public function erase() {
		background.erase();
		label.erase();
		model.interactions.on_erase(this);
	}

	public function hide() {
		is_enabled = false;
		background.color.a = 10;
		label.hide();
	}

	public function show() {
		is_enabled = true;
		background.color.a = alpha_idle;
		if(model.label_change != null){
			change_text(model.label_change());
		}
		label.show();
	}

	public function refresh(){
			if(model.conditions != null){
				// trace('checking sub menu ${interactive.model.label}');
				if(model.conditions()){
					show();
				}
				else{
					hide();
				}
			}
			if(model.label_change != null){
				change_text(model.label_change());
			}
	}
	
	public function mouse_over(){
		if(!is_enabled){
			return;
		}
		if(!is_mouse_over){
			// trace('hover ${model.label}');
			is_mouse_over = true;
			model.interactions.on_over(this);
			background.color.a = alpha_hover;
		}
	}

	public function mouse_out(){
		if(!is_enabled){
			return;
		}
		if(is_mouse_over){
			is_mouse_over = false;
			is_clicked = false;
			model.interactions.on_out(this);
		}
		background.color.a = alpha_idle;
	}

	public function change_text(next_text:String){
		label.erase();
		label = text.word_make(Std.int(background.x), Std.int(background.y), next_text, Std.int(background.width), color_fg);
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

function overlaps_rectangle(geometry:Rectangle, position:Vector2):Bool{
	return position.x > geometry.x && (geometry.x + geometry.width) > position.x
	&& position.y > geometry.y && (geometry.y + geometry.height) > position.y;
}
package stone.ui;

import stone.text.Text.Align;
import stone.core.Color;
import stone.core.Engine.RectangleGeometry;
import haxe.ds.ArraySort;
import stone.core.Ui;
import stone.ui.Interactive;


@:structInit
class Section {
	public var sort_order:Int = 0;
	public var contents:Array<InteractiveModel>;
	public var title:Null<String> = null;
}

@:structInit
class TrayModel {
	public var color_fg:RGBA;
	public var color_bg:RGBA;
	public var tray_geometry:RectangleGeometry;
	public var item_geometry:RectangleGeometry;
	public var dialog_boundary:RectangleGeometry;
	public var section_separation:Int = 10;
	public var item_separation:Int = 2;
}

class Tray {
	var tray_model:TrayModel;
	var ui:Ui;
	public var items(default, null):Array<Interactive>;
	public var is_blocking_main(default, null):Bool = false;

	public function new(sections:Array<Section>, ui:Ui, tray_model:TrayModel) {
		this.tray_model = tray_model;
		this.ui = ui;
		items = [];

		
		var y_section:Int = tray_model.tray_geometry.y;
		
		sort_sections(sections);
		
		make_help_dialog(sections);

		for (i => section in sections) {
			sort_contents(section.contents);
			var y_next = make_contents(section.contents, y_section, section.title);
			y_section = y_next + tray_model.section_separation;
		}

		var force_fresh = true;
		ui.show(force_fresh);
	}

	inline function sort_sections(sections:Array<Section>) {
		ArraySort.sort(sections, (a, b) -> {
			if (a.sort_order < b.sort_order)
				return -1;
			if (a.sort_order > b.sort_order)
				return 1;
			return 0;
		});
	}

	inline function sort_contents(contents:Array<InteractiveModel>) {
		ArraySort.sort(contents, (a, b) -> {
			if (a.sort_order < b.sort_order)
				return -1;
			if (a.sort_order > b.sort_order)
				return 1;
			return 0;
		});
	}

	inline function make_contents(contents:Array<InteractiveModel>, y_section:Int, title:Null<String>):Int {
		var y_item:Int = y_section;
		var has_title = title != null;
		var bg_color = tray_model.color_bg;
		
		if(has_title){
			var title_label = make_label(
				{
					sort_order: -999,
					role: LABEL,
					label: title,
					label_text_align_override: RIGHT
				},
				{
					x: tray_model.tray_geometry.x,
					y: y_item,
					width: tray_model.item_geometry.width,
					height: tray_model.item_geometry.height
				},
				bg_color
			);

			items.push(title_label);

			y_item += title_label.height;
		}

		for (model in contents) {
			var item_geometry:RectangleGeometry = {
				x: tray_model.tray_geometry.x,
				y: y_item,
				width: tray_model.item_geometry.width,
				height: model.show_in_tray ? tray_model.item_geometry.height : 0
			}

			var next_interactive = switch model.role {
				case BUTTON:
					make_button(model, item_geometry, bg_color);
				case LABEL:
					make_label(model, item_geometry, bg_color);
				case LABEL_TOGGLE(enabled):
					make_label(model, item_geometry, bg_color, enabled);
				case TOGGLE(enabled):
					make_toggle(model, item_geometry, bg_color, enabled);
				case SLIDER(fraction):
					make_slider(model, item_geometry, bg_color, fraction);
			}

			items.push(next_interactive);

			if(model.show_in_tray){
				var item_separation = has_title ? 0 : tray_model.item_separation;
				y_item += next_interactive.height + item_separation;
			}
		}

		return y_item;
	}

	inline function make_sub_menu(contents:Array<InteractiveModel>, y_tray_bottom:Int, sub_menu_items:Array<Interactive>, close_sub_menu:Void->Void):Array<Interactive> {
		var y_item:Int = y_tray_bottom;
		var interactives = [];

		for (model in contents) {
			var item_geometry:RectangleGeometry = {
				x: tray_model.tray_geometry.x,
				y: y_item - tray_model.item_geometry.height,
				width: tray_model.item_geometry.width,
				height: model.show_in_tray ? tray_model.item_geometry.height : 0
			}

			var on_click = model.interactions.on_click;
			model.interactions.on_click = interactive -> {
				on_click(interactive);
				if(model.interactions.on_click_closes_menu){
					close_sub_menu();
				}
				else{
					for (interactive in sub_menu_items) {
						interactive.refresh();
					}
				}
			}

			var bg_color = Theme.bg_dialog;
			var next_interactive = switch model.role {
				case BUTTON:
					make_button(model, item_geometry, bg_color);
				case LABEL:
					make_label(model, item_geometry, bg_color);
				case LABEL_TOGGLE(enabled):
					make_label(model, item_geometry, bg_color, enabled);
				case TOGGLE(enabled):
					make_toggle(model, item_geometry, bg_color, enabled);
				case SLIDER(fraction):
					make_slider(model, item_geometry, bg_color, fraction);
			}

			interactives.push(next_interactive);
			y_item -= next_interactive.height;
			y_item -= tray_model.item_separation;
		}

		return interactives;
	}

	inline function make_help_dialog(sections:Array<Section>){

		var help_button_geometry:RectangleGeometry ={
			y: tray_model.tray_geometry.height - tray_model.item_geometry.height,
			x: tray_model.tray_geometry.x,
			width: tray_model.item_geometry.width,
			height: tray_model.item_geometry.height
		}

		var help_lines:Array<String> = [];
		for (section in sections) {
			for (model in section.contents) {
				if(model.key_code == null){
					continue;
				}
				var key_code = model.key_code + '';
				var key_label = StringTools.lpad(key_code, " ", 15);
				help_lines.push(key_label + '  ' + model.label);
			}
		}

		if(help_lines.length > 0){
			var help_text = help_lines.join("\n");
			sections.push({
				sort_order: 999,
				contents: [
					{
						role: BUTTON,
						label: "SECRETS",
						dialog_text_align: LEFT,
						confirmation: {
							message: help_text,
						}
					}
				]
			});
		}
	}

	inline function make_button(model:InteractiveModel, item_geometry:RectangleGeometry, color_bg:RGBA):stone.ui.Interactive.Button {
			var button = ui.make_button(
			model,
			item_geometry,
			tray_model.color_fg,
			color_bg
		);
		
		// if action needs confirmation, set up dialog buttons
		if (model.confirmation != null) {
			var has_message = model.confirmation.message.length > 0;
			var has_confirm = model.confirmation.confirm.length > 0;
			var has_cancel = model.confirmation.cancel.length > 0;
			
			var sub_menu_items:Array<Interactive> = [];
			var dialog_text:TextArea;

			var close_sub_menu:Void->Void = () ->{
				// remove interactive items
				sub_menu_items.clear(button -> button.erase_graphic());
				
				// remove message
				if(has_message){
					dialog_text.background.erase_graphic();
					for (word in dialog_text.text) {
						word.erase_graphic();
					}
				}
				
				// refresh main interactive items
				ui.show();
				
				// restore blocked state to default
				is_blocking_main = false;
			}
			
			var sub_menu_models:Array<InteractiveModel> = [];
			
			var on_click = model.interactions.on_click;

			if(has_confirm){
				sub_menu_models.push({
					sort_order: 0,
					role: BUTTON,
					label: model.confirmation.confirm,
					// key_code: key_code,
					interactions: {
						on_click: confirm_button -> {
							// handle the click
							on_click(button);

							close_sub_menu();
						}
					}
				});
			}

			var cancel_label = "OK";
			if(has_confirm){
				cancel_label = "CANCEL";
				if(has_cancel){
					cancel_label = model.confirmation.cancel;
				}
			}

			// always push cancel button
			sub_menu_models.push({
				sort_order: 999,
				role: BUTTON,
				label: cancel_label,
				// key_code: key_code,
				interactions: {
					on_click: cancel_button -> {
						close_sub_menu();
					}
				}
			});

			// add any further sub menu items
			if(model.sub_contents != null){
				for (model in model.sub_contents) {
					sub_menu_models.push(model);
				}
			}

			model.interactions.on_click = button -> {
				var should_show_menu = model.confirmation.conditions == null ? true : model.confirmation.conditions();
				
				if(should_show_menu){
					// disable original iteractive items
					ui.hide();
								
					// init the interactive items for the sub menu
					for (interactive in make_sub_menu(sub_menu_models, tray_model.tray_geometry.height, sub_menu_items, close_sub_menu)) {
						sub_menu_items.push(interactive);
						// resfresh to evaluate conditions (e.g. for updating the label/visiblity)
						interactive.refresh();
					}

					// show dialog text if appropriate
					if(has_message){
						dialog_text = ui.make_dialog_text(model.confirmation.message, tray_model.dialog_boundary, tray_model.color_fg, Theme.bg_dialog, model.dialog_text_align);
					}

					// block main area from interaction isf required
					is_blocking_main = model.confirmation.is_blocking;
				}
				else{
					on_click(button);
				}
			}
		}

		return button;
	}

	inline function make_label(model:InteractiveModel, item_geometry:RectangleGeometry, color_bg:RGBA, is_toggled:Null<Bool> = null):stone.ui.Interactive {
		return ui.make_label(
			model,
			item_geometry,
			tray_model.color_fg,
			color_bg,
			is_toggled
		);
	}

	inline function make_toggle(model:InteractiveModel, item_geometry:RectangleGeometry, color_bg:RGBA, is_enabled:Bool):stone.ui.Interactive.Toggle {
		return ui.make_toggle(
			model,
			item_geometry,
			tray_model.color_fg,
			color_bg,
			is_enabled
		);
	}

	inline function make_slider(model:InteractiveModel, item_geometry:RectangleGeometry, color_bg:RGBA, fraction:Float):stone.ui.Interactive.Slider {
		return ui.make_slider(
			model,
			item_geometry,
			tray_model.color_fg,
			color_bg,
			fraction
		);
	}

}

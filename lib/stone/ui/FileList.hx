package stone.ui;

import stone.abstractions.Graphic;
import stone.core.Models.Deserialize;
import stone.core.Engine;
import stone.DesignerScene;
import stone.core.Vector;
import stone.core.Engine.RectangleGeometry;
import stone.core.Ui;
import stone.ui.Interactive;
import stone.file.FileStorage;
import stone.core.Engine.Scene;
import stone.text.Text;
import stone.ui.Tray;


class FileList{
	public var ui(default, null):Ui;
	var on_file_select:String->Void;
	var labels:Array<LabelToggle> = [];
	var bounds:RectangleGeometry;

	public function new(graphics_init:GraphicsConstructor, bounds:RectangleGeometry,  on_file_select:String->Void){
		// file list only has interactives listed in the main area, so bounds_interactive is actually bounds_main
		this.bounds = bounds;
		ui = new Ui(graphics_init);
		this.on_file_select = on_file_select;
	}

	public function draw(){
	}

	public function close(){
		ui.clear();
	}

	public function list_files(file_names:Array<String>, pre_select_path:String="") {
		// first clear any existing labels
		if(labels.length > 0){
			var length_labels = labels.length;
			while (length_labels-- > 0) {
				var label = labels.pop();
				label.erase_graphic();
			}
		}

		var font = font_load_embedded(24);
		var height_button = Std.int(font.height_model * 1.5);
		var width_button = bounds.width;

		var bounds_interactive:RectangleGeometry = {
			y: 0,
			x: 0,
			width: width_button,
			height: height_button
		}

		trace('listing files');
		if(file_names.length > 0){
			for (n => path in file_names) {
				// trace(path);
				var label = path;
	
				var label_geometry:RectangleGeometry = {
					y: bounds.y + (n * height_button),
					x: bounds.x,
					width: bounds_interactive.width,
					height: bounds_interactive.height
				}
	
				var model:InteractiveModel = {
					role: LABEL_TOGGLE(false),
					label: label,
					interactions: {
						on_click: interactive -> {
							buttons_file_selected(path);
						}
					}
				}
				var interactive:LabelToggle =  cast ui.make_label(model, label_geometry, Theme.drawing_lines, Theme.bg_ui_interactive_label, false);
				@:privateAccess
				trace('label ${interactive.background.x} ${interactive.background.x} ${interactive.background.width} ${interactive.background.height}');
				labels.push(interactive);
			}
			
			if(pre_select_path.length <= 0){
				pre_select_path = file_names[file_names.length -1];
			}
		}


		if(pre_select_path.length > 0){
			// trace(' pre select $pre_select_path');

			var is_file_listed = file_names.filter(s -> s == pre_select_path).length > 0;
			if(is_file_listed){
				for (interactive in labels.filter(interactive -> interactive.model.label == pre_select_path)) {
					if(!interactive.is_clicked){
						interactive.click();
					}
				}
			}
		}
	}

	function buttons_file_selected(path:String){
		for(label in labels){
			// trace('reset ${label.model.label}  $path');
			label.reset();
			if(label.model.label == path){
				var toggle:LabelToggle = cast label;
				toggle.is_toggled = true;
			}
		}
		on_file_select(path);
	}

	public function handle_mouse_click(x_mouse:Int, y_mouse:Int){
		ui.handle_mouse_click(x_mouse, y_mouse);
	}
}
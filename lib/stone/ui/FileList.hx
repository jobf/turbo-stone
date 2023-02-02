package stone.ui;

import stone.core.GraphicsAbstract;
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
	var labels:Array<Interactive> = [];
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
				label.erase();
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
					role: LABEL_TOGGLE(true),
					label: label,
					interactions: {
						// on_hover: on_hover,
						on_highlight: should_highlight-> {
							if(should_highlight){
								buttons_file_selected(path);
							}
							else{
								buttons_file_selected("");
							}
						},
					}
				}
				var interactive = ui.make_label(model, label_geometry, Theme.drawing_lines, Theme.bg_ui_interactive_label, false);
				@:privateAccess
				trace('label ${interactive.background.x} ${interactive.background.x} ${interactive.background.width} ${interactive.background.height}');
				labels.push(interactive);
			}
			
			if(pre_select_path.length <= 0){
				pre_select_path = file_names[file_names.length -1];
			}
		}


		if(pre_select_path.length > 0){
			trace(' pre select $pre_select_path');

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

	
	public function reset_hover(){
		for (label in labels) {
			label.hover(false);
		}
	}

	function buttons_file_selected(path:String){
		on_file_select(path);
	}

	public function handle_mouse_click(x_mouse:Int, y_mouse:Int){
		for (label in labels) {
			label.highlight(false);
			label.hover(false);
			label.reset();
		}

		ui.handle_mouse_click(x_mouse, y_mouse);
	}
}
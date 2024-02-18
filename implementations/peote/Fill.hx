import stone.abstractions.Graphic;
import Elements;

class Fill extends FillBase {
	var element(default, null):FillElement;
	var is_erased(default, null):Bool = false;
	var remove_from_buffer:Fill->Void;
	function new(element:FillElement, remove_from_buffer:Fill->Void) {
		super(element.x, element.y, element.w, element.h, element.rotation, cast element.color);
		this.element = element;
		this.remove_from_buffer = remove_from_buffer;
	}

	function draw() {
		element.x = x;
		element.y = y;
		element.w = width;
		element.h = height;
		element.rotation = rotation;
		element.color = cast color;
	}

	function erase(){
		if(!is_erased){
			is_erased = true;
			remove_from_buffer(this);
		}
	}
}
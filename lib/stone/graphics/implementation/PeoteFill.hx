package stone.graphics.implementation;

import stone.graphics.Fill;
import stone.core.GraphicsAbstract;

class PeoteFill extends AbstractFillRectangle {
	public var element(default, null):Rectangle;
	public var is_erased(default, null):Bool = false;
	var remove_from_buffer:PeoteFill->Void;
	public function new(element:Rectangle, remove_from_buffer:PeoteFill->Void) {
		super(element.x, element.y, element.w, element.h, element.rotation, cast element.color);
		this.element = element;
		this.remove_from_buffer = remove_from_buffer;
	}

	public function draw() {
		element.x = x;
		element.y = y;
		element.w = width;
		element.h = height;
		element.rotation = rotation;
		element.color = cast color;
	}

	public function erase(){
		if(!is_erased){
			is_erased = true;
			remove_from_buffer(this);
		}
	}
}
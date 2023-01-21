package stone.graphics.implementation;

import stone.graphics.implementation.Graphics;
import stone.graphics.Fill;

import stone.core.GraphicsAbstract;

class PeoteFill extends AbstractFillRectangle {
	var element:Rectangle;
	var remove_from_buffer:Rectangle->Void;

	public function new(element:Rectangle, remove_from_buffer:Rectangle->Void) {
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
		remove_from_buffer(element);
	}
}
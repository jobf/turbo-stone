package stone.graphics.implementation;

import stone.graphics.Fill;
import stone.core.GraphicsAbstract;




class Particle extends AbstractParticle {
	var element:Rectangle;

	public function new(x:Int, y:Int, size:Int, color:RGBA, lifetime_seconds:Float, element:Rectangle) {
		super(x, y, size, color, lifetime_seconds);
		this.element = element;
	}

	public function draw() {
		element.x = motion.position.x;
		element.y = motion.position.y;
		element.color = cast color;
		element.w = size;
		element.h = size;
	}
}

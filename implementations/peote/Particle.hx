import stone.abstractions.Graphic;
import stone.core.Color;
import Elements;

class Particle extends ParticleBase {
	var element:FillElement;

	public function new(x:Int, y:Int, size:Int, color:RGBA, lifetime_seconds:Float, element:FillElement) {
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

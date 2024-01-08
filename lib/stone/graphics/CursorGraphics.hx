package stone.graphics;

import stone.graphics.Fill;
import stone.graphics.implementation.PeoteFill;
import stone.core.GraphicsAbstract;
import stone.core.Color;
import stone.core.Vector;
import peote.view.*;

class CursorGraphics {
	
	var display:Display;
	var program:Program;
	var buffer:Buffer<Rectangle>;
	var fills:Array<PeoteFill> = [];

	public function new(display:Display){
		this.display = display;
		buffer = new Buffer<Rectangle>(1);
		program = new Program(buffer);
		program.injectIntoFragmentShader(
			"
			const vec4 background = vec4(0.0);
			const vec2 centerUV = vec2(0.5);
			const float thicknessUV = 0.03;
			const float lengthUV = 0.15;

			vec4 compose (vec4 c)
			{
				vec2 thicknessXY = vSize.xy * thicknessUV;
				float thickness = max(max(thicknessXY.x, thicknessXY.y), 1.);
				vec2 fragCoordUV = vTexCoord;
				vec2 d = abs(centerUV - fragCoordUV) * vSize.xy;
				vec2 lengthXY = lengthUV * vSize.xy;
				float len = min(lengthXY.x, lengthXY.y);
				
				if (min(d.x, d.y) < thickness &&
					 max(d.x, d.y) < len)
				{
					 return background;
				}

				return c;
			}
			"
		);
		program.setColorFormula('compose(color)');
		display.addProgram(program);
	}

	public function draw() {
		for (fill in fills) {
			fill.draw();
		}
		buffer.update();
	}

	public function erase(){
		buffer.clear(true, true);

		if(display.hasProgram(program)){
			display.removeProgram(program);
		}
	}

	public function make_fill(x:Int, y:Int, width:Int, height:Int, color:RGBA):AbstractFillRectangle {
		var element = make_rectangle(x, y, width, height, color);
		
		var fill_clean_up:PeoteFill -> Void = fill -> {
			buffer.removeElement(fill.element);
		}
		
		fills.push(new PeoteFill(element, fill_clean_up));

		return fills[fills.length -1];
	}

	function make_rectangle(x:Float, y:Float, width:Float, height:Float, color:RGBA):Rectangle {
		final rotation = 0;
		var element = new Rectangle(x, y, width, height, rotation, cast color);
		buffer.addElement(element);
		return element;
	}
}
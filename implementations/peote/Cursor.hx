import stone.abstractions.Graphic;
import stone.core.Color;
import stone.core.Vector;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Display;
import Elements;


class Cursor {
	
	var display:Display;
	var program:Program;
	var buffer:Buffer<FillElement>;
	var fills:Array<Fill> = [];

	public function new(display:Display){
		this.display = display;
		buffer = new Buffer<FillElement>(1);
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

	public function make_fill(x:Int, y:Int, width:Int, height:Int, color:RGBA):FillBase {
		var element = new FillElement(x, y, width, height, 0, cast color);
		buffer.addElement(element);
		
		var fill_clean_up:Fill -> Void = fill -> {
			buffer.removeElement(fill.element);
		}
		
		fills.push(new Fill(element, fill_clean_up));

		return fills[fills.length -1];
	}
}
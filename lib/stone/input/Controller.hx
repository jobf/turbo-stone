package stone.input;

import stone.abstractions.Input;

@:publicFields
@:structInit
class Action {
	var on_pressed:Void->Void = () -> return;
	var on_released:Void->Void = () -> return;
	var name:String = "";
}

@:publicFields
@:structInit
class ControllerActions {
	var left:Action = {};
	var right:Action = {};
	var up:Action = {};
	var down:Action = {};
}

@:publicFields
class Controller {
	private var actions:Map<Button, Action>;
	private var input:InputAbstract;

	function new(actions:Map<Button, Action>, input:InputAbstract) {
		this.actions = actions;
		this.input = input;
	}

	function handle_button(state:ButtonState, button:Button) {
		switch state {
			case PRESSED:
				{
					if (actions.exists(button)) {
						actions[button].on_pressed();
					}
				}
			case RELEASED:
				{
					if (actions.exists(button)) {
						actions[button].on_released();
					}
				};
			case NONE:
		}
	}
}

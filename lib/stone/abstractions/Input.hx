package stone.abstractions;

import stone.core.Event;

enum Button {
	NONE;
	MOUSE_LEFT;
	MOUSE_MIDDLE;
	MOUSE_RIGHT;
	KEY_LEFT;
	KEY_RIGHT;
	KEY_UP;
	KEY_DOWN;
	KEY_A;
	KEY_B;
	KEY_C;
	KEY_D;
	KEY_E;
	KEY_F;
	KEY_G;
	KEY_H;
	KEY_I;
	KEY_J;
	KEY_K;
	KEY_L;
	KEY_M;
	KEY_N;
	KEY_O;
	KEY_P;
	KEY_Q;
	KEY_R;
	KEY_S;
	KEY_T;
	KEY_U;
	KEY_V;
	KEY_W;
	KEY_X;
	KEY_Y;
	KEY_Z;
}

enum ButtonState {
	NONE;
	PRESSED;
	RELEASED;
}

@:publicFields
abstract class InputAbstract {
	function new() {
		mouse_position = {
			x: 0,
			y: 0
		}

		mouse_position_previous = {
			x: 0,
			y: 0
		}
	}

	var mouse_position(default, null):Vector2;
	var mouse_position_previous(default, null):Vector2;

	abstract function raise_mouse_button_events():Void;

	abstract function raise_keyboard_button_events():Void;

	abstract function update_mouse_position():Void;

	abstract function mouse_cursor_hide():Void;
	
	abstract function mouse_cursor_show():Void;

	var on_pressed:Event<Button> = new Event<Button>();
	var on_released:Event<Button> = new Event<Button>();
	var on_mouse_move:Event<Vector2> = new Event<Vector2>();
}

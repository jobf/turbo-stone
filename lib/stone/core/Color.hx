package stone.core;

abstract RGBA(Int) from Int to Int from UInt to UInt {
	inline function new(rgba:Int)
		this = rgba;

	public var r(get, set):Int;
	public var g(get, set):Int;
	public var b(get, set):Int;
	public var a(get, set):Int;

	inline function get_r()
		return (this >> 24) & 0xff;

	inline function get_g()
		return (this >> 16) & 0xff;

	inline function get_b()
		return (this >> 8) & 0xff;

	inline function get_a()
		return this & 0xff;

	inline function set_r(r:Int) {
		this = (this & 0x00ffffff) | (r << 24);
		return r;
	}

	inline function set_g(g:Int) {
		this = (this & 0xff00ffff) | (g << 16);
		return g;
	}

	inline function set_b(b:Int) {
		this = (this & 0xffff00ff) | (b << 8);
		return b;
	}

	inline function set_a(a:Int) {
		this = (this & 0xffffff00) | a;
		return a;
	}
}

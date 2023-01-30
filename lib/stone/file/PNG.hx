package stone.file;

class PNG{
	public static function format_write(texture_data:lime.utils.UInt8Array, width:Int, height:Int, path:String):Void{
		#if !web
		var data = format.png.Tools.build32BGRA(width, height, texture_data.toBytes());
		var out = sys.io.File.write(path, true);
		new format.png.Writer(out).write(data);
		#end
	}

	public static function lime_bytes(texture_data:haxe.io.UInt8Array, width:Int, height:Int, path:String):haxe.io.Bytes{
		var image_data = lime.utils.UInt8Array.fromBytes(texture_data.view.buffer);
		var image_buffer = new lime.graphics.ImageBuffer(image_data, width, height);
		var image = new lime.graphics.Image(image_buffer);
		var image_bytes = image.encode();
		return image_bytes;
	}
}
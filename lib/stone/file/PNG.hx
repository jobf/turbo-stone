package stone.file;

import lime.utils.UInt8Array;

class PNG{
	public static function dump(texture_data:UInt8Array, width:Int, height:Int, path:String){
		#if !web
		var data = format.png.Tools.build32BGRA(width, height, texture_data.toBytes());
		var out = sys.io.File.write(path, true);
		new format.png.Writer(out).write(data);
		#end
	}
}
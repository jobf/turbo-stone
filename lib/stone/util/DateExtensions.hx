package stone.util;

using DateTools;

@:publicFields
class DateExtensions{
	static function to_time_stamp(date:Date):String{
		return date.format("%Y-%m-%d_%H-%M-%S");
	}
}
package stone.util;

using DateTools;

class DateExtensions{
	public static function to_time_stamp(date:Date):String{
		return date.format("%Y-%m-%d_%H:%M:%S");
	}
}
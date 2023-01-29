package deploy;

import sys.io.File;
using DateTools;

class Deploy{
	public static function main() {
		
		var host_remote = File.getContent("secrets/remote_host");
		var path_remote = File.getContent("secrets/remote_path");

		if(host_remote.length == 0 || path_remote.length == 0){
			trace('Cannot deploy without secrets.');
		}

		var path_local = "dist/html5/bin";

		var path_version = Date.now().format("%Y-%m-%d-%H-%M-%S");
		
		var command:String = "scp";
		
		var args:Array<String> = [
			"-r",
			path_local,
			'$host_remote:$path_remote/$path_version',
		];

		Sys.command(command, args);
	}
}
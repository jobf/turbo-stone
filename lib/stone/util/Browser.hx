package stone.util;

import haxe.io.UInt8Array;
import js.lib.ArrayBufferView;
import js.lib.Uint8Array;
import haxe.io.Bytes;

function release_blob_string(blob_string:String, file_name:String){
	var blob = new js.html.Blob([blob_string]);
	var url = js.html.URL.createObjectURL(blob);
	var anchor = js.Browser.document.createAnchorElement();
	anchor.href = url;
	anchor.download = file_name;
	anchor.click();
	js.html.URL.revokeObjectURL(url);
}

function release_blob_bytes(blob_bytes:Bytes, file_name:String){
	var blob = new js.html.Blob([blob_bytes.getData()],{type: "image/png"});
	var url = js.html.URL.createObjectURL(blob);
	var anchor = js.Browser.document.createAnchorElement();
	anchor.href = url;
	anchor.download = file_name;
	anchor.click();
	js.html.URL.revokeObjectURL(url);
}
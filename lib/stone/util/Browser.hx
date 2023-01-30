package stone.util;

function release_blob_string(blob_string:String, file_name:String){
	var blob = new js.html.Blob([blob_string]);
	var url = js.html.URL.createObjectURL(blob);
	var anchor = js.Browser.document.createAnchorElement();
	anchor.href = url;
	anchor.download = file_name;
	anchor.click();
	js.html.URL.revokeObjectURL(url);
}
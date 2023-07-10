//  license goes here 
/**
 * This provides Lucee file streaming
 */
component extends="mura.baseobject" output="false" hint="This provides Lucee file streaming" {

	public function init(required string mimeType="", required any file="") output=true {
        var context = getPageContext();
        //context.setFlushOutput(false);
        //response = context.getResponse();
        var response = context.getResponse();
        var out = response.getOutputStream();
        response.setContentType("#arguments.mimeType#");
        response.setContentLength(arrayLen(arguments.file));
        out.write(arguments.file);
        out.flush();
        //response.reset();
        out.close();
	}

}

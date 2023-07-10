//  license goes here 
/**
 * This provides ACF file streaming
 */
component extends="mura.baseobject" output="false" hint="This provides ACF file streaming" {

	public function init(required string mimeType="", required any file="") output=true {
		cfcontent( reset=true, variable=arguments.file, type=arguments.mimetype );
	}

}

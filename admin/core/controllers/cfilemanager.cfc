/* license goes here */
component extends="controller" output="false" {

	public function before(rc) output=false {
		param default=session.siteid name="arguments.rc.siteid";
		if ( !variables.permUtility.getModulePerm('00000000000000000000000000000000000',arguments.rc.siteid) ) {
			secure(arguments.rc);
		}
		param default="assets" name="session.resourceType";

	}

}

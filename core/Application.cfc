/* license goes here */
component output="false" {
	depth=1;
	include "#repeatString('../',depth)#core/appcfc/applicationSettings.cfm";
	include "#repeatString('../',depth)#plugins/mappings.cfm";
	include "#repeatString('../',depth)#core/appcfc/onApplicationStart_method.cfm";

	public function onRequestStart() {
		var local=structNew();
		/*
				NOTE: If you need to allow direct access to a file located under your site/theme (e.g., a remote web service, etc.),
				just add the file name to the list of files below.
		*/
		if ( !(listFindNoCase("runner.cfm,run.cfm",listLast(cgi.SCRIPT_NAME,"/"))) ) {
			writeOutput("Access Restricted.");
			abort;
		}
		include "#repeatString('../',depth)#core/appcfc/onRequestStart_include.cfm";
		include "#repeatString('../',depth)#core/appcfc/scriptProtect_include.cfm";
		return true;
	}
	include "#repeatString('../',depth)#core/appcfc/onSessionStart_method.cfm";
	include "#repeatString('../',depth)#core/appcfc/onSessionEnd_method.cfm";
	include "#repeatString('../',depth)#core/appcfc/onError_method.cfm";
	include "#repeatString('../',depth)#core/appcfc/onMissingTemplate_method.cfm";

}

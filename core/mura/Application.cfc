/* license goes here */
component { 
	function onRequestStart(){
		writeOutput('Access Restricted.');
		abort;
	}
}
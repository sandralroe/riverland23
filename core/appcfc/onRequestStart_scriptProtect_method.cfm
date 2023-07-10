<cfscript>
/* license goes here */

boolean function onRequestStart() output=false {
	include "/muraWRM/core/appcfc/onRequestStart_include.cfm";
	include "/muraWRM/core/appcfc/scriptProtect_include.cfm";
	return true;
}
</cfscript>

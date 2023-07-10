<cfscript>
/* license goes here */

boolean function onRequestEnd(String targetPage) output=false {
	include "/muraWRM/core/appcfc/onRequestEnd_include.cfm";
	return true;
}
</cfscript>

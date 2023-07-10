<cfscript>
/* license goes here */

void function onError(required exception, required string eventname) output=true {
	if ( fileExists(expandPath('/core/appcfc/onError_include.cfm')) ) {
		include "/core/appcfc/onError_include.cfm";
	}
}
</cfscript>

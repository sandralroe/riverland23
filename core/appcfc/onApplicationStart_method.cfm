<cfscript>
/* license goes here */

boolean function onApplicationStart() output=false {
	param name="application.instanceID" default=createUUID();
	lock name="appInitBlock#application.instanceID#" type="exclusive" timeout="400" {
		include "/muraWRM/core/appcfc/onApplicationStart_include.cfm";
	}
	return true;
}
</cfscript>

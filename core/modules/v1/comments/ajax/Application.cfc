<!--- license goes here --->
<cfcomponent output="false">
	<cfset depth=5>
	<cfinclude template="#repeatString('../',depth)#core/appcfc/applicationSettings.cfm">
	<cfinclude template="#repeatString('../',depth)#plugins/mappings.cfm">
	<cfinclude template="#repeatString('../',depth)#core/appcfc/onApplicationStart_method.cfm">
	<cfinclude template="#repeatString('../',depth)#core/appcfc/onRequestStart_scriptProtect_method.cfm">
	<cfinclude template="#repeatString('../',depth)#core/appcfc/onSessionStart_method.cfm">
	<cfinclude template="#repeatString('../',depth)#core/appcfc/onSessionEnd_method.cfm">
	<cfinclude template="#repeatString('../',depth)#core/appcfc/onError_method.cfm">
	<cfinclude template="#repeatString('../',depth)#core/appcfc/onMissingTemplate_method.cfm">
</cfcomponent>

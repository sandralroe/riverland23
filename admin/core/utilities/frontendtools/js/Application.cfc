<!--- license goes here --->
<cfcomponent output="false">
	<cfset depth=5>
	<cfinclude template="#repeatString('../',depth)#core/appcfc/applicationSettings.cfm">
	<!---<cfinclude template="#repeatString('../',depth)#config/mappings.cfm">--->
	<cfinclude template="#repeatString('../',depth)#plugins/mappings.cfm">

	<cffunction name="onRequestStart">
		<cfset var local=structNew()>
		<cfif listLast(cgi.SCRIPT_NAME,".") eq "cfm" and not listFind("index.cfm",lcase(listLast(cgi.SCRIPT_NAME,"/")))>
		<cfoutput>Access Restricted.</cfoutput>
		<cfabort>
		</cfif>
		<cfsetting showdebugoutput="no">
		<cfinclude template="#repeatString('../',depth)#core/appcfc/onRequestStart_include.cfm">
		<cfinclude template="#repeatString('../',depth)#core/appcfc/scriptProtect_include.cfm">
		<cfreturn true>
	</cffunction>

	<cfinclude template="#repeatString('../',depth)#core/appcfc/onApplicationStart_method.cfm">
	<cfinclude template="#repeatString('../',depth)#core/appcfc/onSessionStart_method.cfm">
	<cfinclude template="#repeatString('../',depth)#core/appcfc/onSessionEnd_method.cfm">
	<cfinclude template="#repeatString('../',depth)#core/appcfc/onError_method.cfm">
	<cfinclude template="#repeatString('../',depth)#core/appcfc/onMissingTemplate_method.cfm">

</cfcomponent>
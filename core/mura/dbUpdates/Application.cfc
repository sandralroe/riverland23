<!--- license goes here --->
<cfcomponent output="false">
	<cffunction name="onRequestStart">
		<cfoutput>Access Restricted.</cfoutput>
		<cfabort>	
	</cffunction>
</cfcomponent>
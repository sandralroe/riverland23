<cfset var = createObject("component","mura.json").encode(application.settingsManager.getList()) >


<cfoutput>
#var#
</cfoutput>
<cfabort>
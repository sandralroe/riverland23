 <!--- license goes here --->
 <cfsilent>
	<cfparam name="objectParams.sourcetype" default="custom">
	<cfparam name="objectParams.source" default="">
	<cfparam name="objectParams.render" default="server">
	<cfparam name="this.SSR" default="true">
</cfsilent>
<cfif this.SSR>
<cfif objectParams.sourcetype neq 'custom'>
<cfoutput>
<cfif objectParams.sourceType eq 'component'>
	#$.dspObject(objectid=objectParams.source,object='component')#
<cfelseif objectParams.sourceType eq 'boundattribute'>
	#$.content(objectParams.source)#
<cfelseif objectParams.sourcetype eq 'custom'>
	#objectParams.source#
<cfelse>
	<p></p>
</cfif>
</cfoutput>
<cfelse>
<cfset objectParams.render="client">
</cfif>
<cfelse>
<cfset objectParams.render="client">
</cfif>
<!--- License goes here --->
<cfsilent>
<cfset variables.strField = "" />
<cfparam name="arguments.prefix" default="">
<cfsavecontent variable="variables.strField">
	<cfoutput>
<cfif request.fieldsetopen eq true></fieldset><cfset request.fieldsetopen = false /></cfif>
<fieldset id="set-#arguments.field.name#">
	<legend>#arguments.field.label#</legend>
	</cfoutput>
</cfsavecontent>
<!--- note that fieldsets are open --->
<cfset request.fieldsetopen = true />
</cfsilent><cfoutput>#variables.strField#</cfoutput>
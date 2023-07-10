<!--- License goes here --->
<cfsilent>
<cfset variables.strField = "" />
<cfparam name="arguments.prefix" default="">
<cfsavecontent variable="variables.strField">
	<cfoutput>
	<legend>#esapiEncode('html', arguments.field.label)#</legend>
	#variables.fbManager.renderNestedForm( variables.$,session.siteid,arguments.field.formid,arguments.field.name )#
	</cfoutput>
</cfsavecontent>
</cfsilent><cfoutput>#variables.strField#</cfoutput>
﻿<!--- License goes here --->
<cfsilent>
<cfparam name="arguments.prefix" default="">
<cfset variables.strField = "" />	
<cfsavecontent variable="variables.strField">
	<cfoutput><input type="hidden" name="#arguments.prefix##arguments.field.name#" value="#arguments.field.value#" #variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_common.cfm',field=arguments.field,dataset=arguments.dataset,prefix=arguments.prefix)# /></cfoutput>
</cfsavecontent>
</cfsilent><cfoutput>#variables.strField#</cfoutput>
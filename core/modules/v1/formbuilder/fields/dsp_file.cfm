<!--- License goes here --->
<cfsilent>
<cfparam name="arguments.prefix" default="">
<cfset variables.strField = "" />	
<cfsavecontent variable="variables.strField">
	<cfoutput>
	#variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_label.cfm',field=arguments.field,dataset=arguments.dataset,prefix=arguments.prefix)#
	<input type="file" name="#arguments.prefix##arguments.field.name#_attachment" value="#arguments.field.value#" #variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_common.cfm',field=arguments.field,dataset=arguments.dataset,prefix=arguments.prefix)# /></cfoutput>
</cfsavecontent>
</cfsilent><cfoutput>#variables.strField#</cfoutput>
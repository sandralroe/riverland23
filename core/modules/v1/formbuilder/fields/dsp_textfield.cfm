<!--- License goes here --->
<cfsilent>
<cfset variables.strField='' />
<cfparam name="arguments.prefix" default="">
<cfsavecontent variable="variables.strField">
	<cfoutput>
		#variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_label.cfm',field=arguments.field,dataset=arguments.dataset,prefix=arguments.prefix)#
		<input type="text" name="#arguments.prefix##arguments.field.name#" value="#arguments.field.value#" #variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_common.cfm',field=arguments.field,dataset=arguments.dataset,prefix=arguments.prefix)# /></cfoutput>
</cfsavecontent>
</cfsilent><cfoutput>#variables.strField#</cfoutput>
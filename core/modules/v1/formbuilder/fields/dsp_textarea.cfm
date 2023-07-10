<!--- License goes here --->
<cfsilent>
<cfset variables.strField = "" />
<cfparam name="arguments.prefix" default="">
<cfsavecontent variable="variables.strField">
	<cfoutput>
	#variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_label.cfm',field=arguments.field,dataset=arguments.dataset,prefix=arguments.prefix)#
	<textarea rows="5" name="#arguments.prefix##arguments.field.name#" #variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_common.cfm',field=arguments.field,dataset=arguments.dataset,prefix=arguments.prefix)#>#arguments.field.value#</textarea>
	</cfoutput>
</cfsavecontent>
</cfsilent><cfoutput>#variables.strField#</cfoutput>
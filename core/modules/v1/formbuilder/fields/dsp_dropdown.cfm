<!--- License goes here --->
<cfsilent>
<cfparam name="arguments.prefix" default="">
<cfset variables.strField = "" />
<cfparam name="arguments.dataset.defaultid" default="" />
<cfsavecontent variable="variables.strField">
	<cfoutput>
	#variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_label.cfm',field=arguments.field,dataset=arguments.dataset,prefix=arguments.prefix)#
	<select name="#arguments.prefix##arguments.field.name#" #variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_common.cfm',field=arguments.field,dataset=arguments.dataset,prefix=arguments.prefix)#>
	</cfoutput>
</cfsavecontent>
<cfsavecontent variable="variables.strField">
	<cfoutput>
	#variables.strField#
	<cfif StructKeyExists(arguments.dataset,"datarecordorder") and isArray( arguments.dataset.datarecordorder) and ArrayLen( arguments.dataset.datarecordorder ) gt 0>
	<cfloop from="1" to="#ArrayLen(arguments.dataset.datarecordorder)#" index="variables.iiy">
		<cfset variables.record = arguments.dataset.datarecords[arguments.dataset.datarecordorder[variables.iiy]] />
		<option<cfif len(variables.record.value)> value="#variables.record.value#"</cfif><cfif variables.record.datarecordid eq arguments.dataset.defaultid> SELECTED</cfif>>#variables.record.label#</option>
	</cfloop>
	</cfif>
	</select>
	</cfoutput>
</cfsavecontent>
</cfsilent><cfoutput>#variables.strField#</cfoutput>
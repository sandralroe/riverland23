<!--- License goes here --->
<cfsilent>
<cfparam name="arguments.prefix" default="">
<cfset variables.mmRBFstrField = "" />
<cfsavecontent variable="variables.strField">
	<cfoutput>#variables.$.dspObject_Include(thefile='/formbuilder/fields/dsp_label.cfm',field=arguments.field,dataset=arguments.dataset,prefix=arguments.prefix)#</p>
	<div>
	<cfif StructKeyExists(arguments.dataset,"datarecordorder") and isArray( arguments.dataset.datarecordorder) and ArrayLen( arguments.dataset.datarecordorder ) gt 0>
	<cfloop from="1" to="#ArrayLen(arguments.dataset.datarecordorder)#" index="variables.iiy">
		<cfset variables.record = arguments.dataset.datarecords[arguments.dataset.datarecordorder[variables.iiy]] />
		<cfif variables.record.value eq "">
			<cfset variables.record.value = variables.record.label />
		</cfif>
		<div class="checkbox">
		<label for="#variables.record.datarecordid#"><input id="#variables.record.datarecordid#" name="#arguments.prefix##arguments.field.name#" type="checkbox"<cfif variables.record.isselected eq 1> CHECKED</cfif> value="#variables.record.value#">#variables.record.label#
		</div>
	</cfloop>
	</cfif>
	</div>
	</cfoutput>
</cfsavecontent>
</cfsilent><cfoutput>#variables.strField#</cfoutput>
<!--- License goes here --->
<cfsilent>
<cfset variables.strField = "" />
<cfparam name="arguments.prefix" default="">
<cfsavecontent variable="variables.strField">
	<cfoutput>
	#$.dspObject_Include(thefile='/formbuilder/fields/dsp_label.cfm',field=arguments.field,dataset=arguments.dataset,prefix=arguments.prefix)#</p>
	<div>
	<cfif StructKeyExists(arguments.dataset,"datarecordorder") and isArray( arguments.dataset.datarecordorder) and ArrayLen( arguments.dataset.datarecordorder ) gt 0>
	<cfloop from="1" to="#ArrayLen(arguments.dataset.datarecordorder)#" index="variables.iiy">
		<cfset variables.record = arguments.dataset.datarecords[dataset.datarecordorder[variables.iiy]] />
		<cfif variables.record.value eq "">
			<cfset variables.record.value = variables.record.label />
		</cfif>
		<div class="radio">
		<label for="#variables.record.datarecordid#"><input name="#arguments.prefix##arguments.field.name#" id="#record.datarecordid#" type="radio"<cfif variables.record.isselected eq 1> CHECKED</cfif> value="#variables.record.value#">#variables.record.label#</label>
		</div>
	</cfloop>
	</cfif>
	</div>
	</cfoutput>
</cfsavecontent>
</cfsilent><cfoutput>#variables.strField#</cfoutput>
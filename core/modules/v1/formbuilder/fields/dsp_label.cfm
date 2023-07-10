<!--- License goes here --->
<cfsilent>
	<cfscript>
		param name='arguments.prefix' default='';
		variables.label = '';
		variables.forattribute = StructKeyExists(arguments.field, 'cssid') && Len(arguments.field.cssid)
			? arguments.field.cssid
			: arguments.prefix & arguments.field.name;
	</cfscript>
	<cfsavecontent variable="variables.label">
		<cfoutput>
			<cfif len(arguments.field.rblabel)>
				<label for="#esapiEncode('html_attr', variables.forattribute)#">
					#$.rbKey(arguments.field.rblabel)#<cfif arguments.field.isrequired> <ins>#$.rbKey('form.required')#</ins></cfif>
			<cfelse>
				<cfif arguments.field.fieldtype.fieldtype eq "radio">
					<p>#arguments.field.label#
				<cfelseif arguments.field.fieldtype.fieldtype eq "checkbox">
					<p>#arguments.field.label#
				<cfelseif arguments.field.fieldtype.fieldtype eq "hidden">
				<cfelse>
					<label for="#esapiEncode('html_attr', variables.forattribute)#">
						#arguments.field.label#<cfif arguments.field.isrequired> <ins>#$.rbKey('form.required')#</ins></cfif>
				</cfif>
			</cfif></label>
		</cfoutput>
	</cfsavecontent>
</cfsilent><cfoutput>#variables.label#</cfoutput>
<!--- License goes here --->
<cfsilent>
<cfset variables.strField = "" />
<cfif arguments.field.isrequired>
	<cfset variables.strField = variables.strField & ' data-required="true"' />
</cfif>
<cfif structkeyexists(arguments.field,'size') and len(arguments.field.size)>
	<cfset variables.strField = strField & ' size="#arguments.field.size#"' />
</cfif>
<cfif structkeyexists(arguments.field,'placeholder') and len(arguments.field.placeholder)>
	<cfset variables.strField = strField & ' placeholder="#arguments.field.placeholder#"' />
</cfif>
<cfif structkeyexists(arguments.field,'maxlength') and len(arguments.field.maxlength)>
	<cfset variables.strField = variables.strField & ' maxlength="#arguments.field.maxlength#"' />
<cfelseif structkeyexists(arguments.field,'size') and len(arguments.field.size)>
	<cfset variables.strField = variables.strField & ' maxlength="#arguments.field.size#"' />
</cfif>
<cfif structkeyexists(arguments.field,'cols') and len(arguments.field.cols)>
	<cfset variables.strField = variables.strField & ' cols="#arguments.field.cols#"' />
</cfif>

<cfscript>
	// title (tooltip)
	if ( StructKeyExists(arguments.field, 'tooltip') && Len(arguments.field.tooltip) ) {
		variables.strField &= ' title="#esapiEncode('html_attr', arguments.field.tooltip)#"';
	}

	// css id
	variables.fieldid = StructKeyExists(arguments.field, 'cssid') && Len(arguments.field.cssid)
		? arguments.field.cssid
		: arguments.prefix & arguments.field.name;
	variables.strField &= ' id="#esapiEncode('html_attr', variables.fieldid)#"';
</cfscript>

<cfif structkeyexists(arguments.field,'cssclass') and len(arguments.field.cssclass)>
	<cfset variables.strField = variables.strField & ' class="#arguments.field.cssclass# #this.formBuilderFormFieldsClass#"' />
<cfelse>
	<cfset variables.strField = variables.strField & ' class="#this.formBuilderFormFieldsClass#"' />
</cfif>
<cfif len(arguments.field.validatemessage)>
	<cfset variables.strField = variables.strField & ' data-message="#replace(arguments.field.validatemessage,"""","&quot;","all")#"' />
</cfif>
<cfif len(arguments.field.validatetype)>
	<cfif arguments.field.validatetype eq "regex" and len(arguments.field.validateregex)>
		<cfset variables.strField = variables.strField & ' data-validate="#arguments.field.validatetype#" data-regex="#arguments.field.validateregex#"' />
	<cfelse>
		<cfset variables.strField = variables.strField & ' data-validate="#arguments.field.validatetype#"' />
	</cfif>
</cfif>
<cfif len(arguments.field.remoteid)>
	<cfset variables.strField = variables.strField & ' data-remoteid="#arguments.field.remoteid#"' />
</cfif>
</cfsilent><cfoutput>#variables.strField#</cfoutput>
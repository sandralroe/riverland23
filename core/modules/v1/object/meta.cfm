 <!--- license goes here --->
<cfsilent>
	<cfparam name="objectParams.label" default="">
	<cfparam name="objectParams.labeltag" default="h2">
	<cfparam name="objectparams.metacssclass" default="">
	<cfparam name="objectparams.metacssid" default="">
	<cfparam name="objectparams.metacssstyles" default="">
	<cfif objectparams.labeltag eq 'undefined'>
		<cfset objectparams.labeltag="h2">
	</cfif>
</cfsilent>
<cfif len(objectParams.label)>
	<cfoutput><div class="mura-object-meta-wrapper"><div<cfif len(objectparams.metacssid)> id="#esapiEncode('html_attr',trim(objectparams.metacssid))#"</cfif> class="#esapiEncode('html_attr',trim('mura-object-meta #objectparams.metacssclass#'))#" style="#$.renderCssStyles(objectparams.metacssstyles)#"><#esapiEncode('html',objectParams.labeltag)#>#esapiEncode('html',objectParams.label)#</#esapiEncode('html',objectParams.labeltag)#></div></div><div class="mura-flex-break"></div></cfoutput>
</cfif>

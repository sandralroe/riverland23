<cfscript>
    param name="attributes.name" default='hidden';
    param name="attributes.value" default='';
</cfscript>
<cfoutput>
	<input type="hidden" class="objectParam" name="#esapiEncode('html_attr',attributes.name)#" value="#esapiEncode('html_attr',attributes.value)#" >
</cfoutput>
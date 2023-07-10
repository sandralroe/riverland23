<cfscript>
    param name="attributes.label" default='Markdown';
    param name="attributes.name" default='markdown';
    param name="attributes.value" default='';
    param name="attributes.condition" default="";
</cfscript>
<cfoutput>
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
    <label class="mura-control-label">#esapiEncode('html_attr',attributes.label)#</label>
    <button type="button" class="btn mura-markdown" data-target="#esapiEncode('html_attr',attributes.name)#">Edit</button>
	<input type="hidden" id="#esapiEncode('html_attr',attributes.name)#markdown" class="objectParam" name="#esapiEncode('html_attr',attributes.name)#" value="#esapiEncode('html_attr',attributes.value)#" >
</div>
</cfoutput>
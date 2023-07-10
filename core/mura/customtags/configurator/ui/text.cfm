<cfscript>
    param name="attributes.label" default='Text';
    param name="attributes.name" default='text';
    param name="attributes.value" default='';
    param name="attributes.condition" default="";
</cfscript>
<cfoutput>
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
	<label class="mura-control-label">#esapiEncode('html_attr',attributes.label)#</label>
	<input type="text" class="objectParam" name="#esapiEncode('html_attr',attributes.name)#" value="#esapiEncode('html_attr',attributes.value)#" >
</div>
</cfoutput>
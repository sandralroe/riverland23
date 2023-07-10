<cfscript>
    param name="attributes.label" default='Date';
    param name="attributes.name" default='date';
    param name="attributes.value" default='';
    param name="attributes.condition" default="";
</cfscript>
<cfoutput>
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
	<label class="mura-control-label">#esapiEncode('html_attr',attributes.label)#</label>
	<input type="text" class="objectParam datepicker" name="#esapiEncode('html_attr',attributes.name)#" value="#esapiEncode('html_attr',attributes.value)#" >
</div>
</cfoutput>
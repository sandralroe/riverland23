<cfscript>
    param name="attributes.label" default='Text Ares';
    param name="attributes.name" default='textarea';
    param name="attributes.value" default='';
    param name="attributes.condition" default="";
    if (not isSimpleValue(attributes.value)){
        attributes.value = serializeJSON(attributes.value);
    }
</cfscript>
<cfoutput>
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
	<label class="mura-control-label">#esapiEncode('html_attr',attributes.label)#</label>
	<textarea class="objectParam" name="#esapiEncode('html_attr',attributes.name)#">#attributes.value#</textarea>
</div>
</cfoutput>
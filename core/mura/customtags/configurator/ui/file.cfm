<cfscript>
    param name="attributes.label" default='File';
    param name="attributes.name" default='file';
    param name="attributes.value" default='';
    param name="attributes.condition" default="";
</cfscript>
<cfoutput>
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
    <label class="mura-control-label">#esapiEncode('html',attributes.label)#</label>
    <input type="text" placeholder="URL" id="#esapiEncode('html_attr',attributes.name)#src" name="#esapiEncode('html_attr',attributes.name)#" class="objectParam" value="#esapiEncode('html_attr',attributes.value)#"/>
    <button type="button" class="btn mura-finder" data-target="#esapiEncode('html_attr',attributes.name)#" data-completepath="false"><i class="mi-image"></i> Select File</button>
</div>
</cfoutput>
    
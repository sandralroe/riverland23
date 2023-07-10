<cfscript>
    param name="attributes.label" default='Color';
    param name="attributes.name" default='color';
    param name="attributes.value" default='';
    param name="attributes.condition" default="";
</cfscript>
<cfoutput>
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
    <label>#esapiEncode('html',attributes.label)#</label>
    <div class="input-group mura-colorpicker">
        <span class="input-group-addon"><i class="mura-colorpicker-swatch"></i></span>
        <input type="text" name="#attributes.name#" class="objectParam" placeholder="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.selectcolor'))#" autocomplete="off" value="#esapiEncode('html_attr',attributes.value)#">
    </div>
</div>
</cfoutput>
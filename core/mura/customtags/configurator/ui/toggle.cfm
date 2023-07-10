<cfscript>
    param name="attributes.label" default='Toggle';
    param name="attributes.name" default='toggle';
    param name="attributes.value" default='false';
    param name="attributes.condition" default="";
</cfscript>
<cfoutput>
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
    <label class="css-input switch switch-sm switch-primary">
        <input name="#esapiEncode('html_attr',attributes.name)#Toggle" data-target="#esapiEncode('html_attr',attributes.name)#" type="checkbox" <cfif isBoolean(attributes.value) and attributes.value> checked</cfif>><span></span> #esapiEncode('html',attributes.label)#
    </label>
    <input name="#esapiEncode('html_attr',attributes.name)#" type="hidden" class="objectParam" name="#esapiEncode('html_attr',attributes.name)#" <cfif isBoolean(attributes.value) and attributes.value>value="true"<cfelse>value="false"</cfif>>
</div>
<script>
    Mura(function(){
        Mura('input[name="#esapiEncode('html_attr',attributes.name)#Toggle"]').change(function() {
            //use jquery for event trigger because that's what's listening
            $('input[name='+ Mura(this).data('target') +']').val(Mura(this).is(':checked') ? true : false).trigger('change');
        });
    });
</script>
</cfoutput>
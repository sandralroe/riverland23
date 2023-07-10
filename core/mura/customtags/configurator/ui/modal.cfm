<cfscript>
    cssid="m#createUUID()#";
    param name="attributes.label" default='Open Modal';
    param name="attributes.modalpath" default='example/modal.cfm';
    param name="attributes.condition" default="";
</cfscript>
<cfoutput>
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
    <button type="button" class="btn" id="#cssid#">#esapiEncode('html', attributes.label)#</button>
</div>
<input name="trim-params" class="objectParam" type="hidden" value="true"/>
<script>
    $(function(){
        $('###cssid#').click(function(){
            siteManager.openDisplayObjectModal('#attributes.modalpath#');
        });
    });
</script>
</cfoutput>
<cfscript>
    param name="attributes.label" default='Radio Group';
    param name="attributes.name" default='radiogroup';
    param name="attributes.value" default='';
    param name="attributes.condition" default="";
    param name="attributes.options" default=[];
    param name="attributes.labels" default=[];

    if(arraylen(attributes.options)){
        for(i=1;i<=arrayLen(attributes.options);i++){
            if(isSimpleValue(attributes.options[i])){
                newOption={
                    name=attributes.options[i],
                    value=attributes.options[i]
                }
                attributes.options[i]=newOption;
                if(isArray(attributes.labels) && arrayLen(attributes.labels) >= i){
                    attributes.options[i].name=attributes.labels[i];
                }
            }

        }
    }
</cfscript>
<cfoutput>
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
    <label class="mura-control-label">#esapiEncode('html_attr',attributes.label)#</label>
    <cfif arrayLen(attributes.options)>
    <div class="radio-group">
    <cfloop from="1" to="#arrayLen(attributes.options)#" index="idx">
        <label class="radio" for="#esapiEncode('html_attr',attributes.name)##idx#">
        <input type="radio" id="#esapiEncode('html_attr',attributes.name)##idx#" class="objectParam" name="#esapiEncode('html_attr',attributes.name)#" value="#esapiEncode('html_attr',attributes.options[idx].value)#"<cfif attributes.options[idx].value eq attributes.value> checked</cfif>>
             #esapiEncode('html_attr',attributes.options[idx].name)#
        </label>
    </cfloop>
    </div>
    </cfif>
</div>
</cfoutput>
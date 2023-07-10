<cfscript>
    param name="attributes.label" default='Select';
    param name="attributes.name" default='select';
    param name="attributes.value" default='';
    param name="attributes.condition" default="";
    param name="attributes.options" default=[];
    param name="attributes.labels" default=[];
    param name="request.paramSelectNames" default={};
    
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

    if(!structKeyExists(request.paramSelectNames,'#attributes.name#')){
        request.paramSelectNames['#attributes.name#']=1;
    } else {
        request.paramSelectNames['#attributes.name#']= request.paramSelectNames['#attributes.name#']+1;
    }
</cfscript>
<cfoutput>
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
    <label class="mura-control-label">#esapiEncode('html_attr',attributes.label)#</label>
    <select class="objectParam" name="#esapiEncode('html_attr',attributes.name)##request.paramSelectNames['#attributes.name#']#" data-param="#esapiEncode('html_attr',attributes.name)#">
        <cfif arrayLen(attributes.options)>
        <cfloop from="1" to="#arrayLen(attributes.options)#" index="idx">
            <option value="#esapiEncode('html_attr',attributes.options[idx].value)#"<cfif attributes.options[idx].value eq attributes.value> selected</cfif>>
                 #esapiEncode('html_attr',attributes.options[idx].name)#
            </option>
        </cfloop>
        </cfif>
    </select>
</div>
</cfoutput>
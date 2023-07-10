<cfscript>
    param name="attributes.label" default='Dispenser';
    param name="attributes.name" default='dispenser';
    param name="attributes.value" default='';
    param name="attributes.delim" default=',';
    param name="attributes.options" default=[];
    param name="attributes.labels" default=[];
    param name="attributes.condition" default="";

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
    <cfif arrayLen(attributes.options)>
        <cfset request["#attributes.name#dispenserlabels"] = []>
        <cfset request["#attributes.name#dispenservalues"] = []>
        <div class="mura-control-group mura-ui-grid"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
            <label>#esapiEncode('html',attributes.label)#</label>
            <div class="row mura-ui-row mura-flex">
                <select name="#attributes.name#dispenser" id="#attributes.name#dispenser" class="dispenser-select" data-delim="#attributes.delim#" data-param="#esapiEncode('html_attr',attributes.name)#">
                    <option value="">--</option>
                    <cfloop array="#attributes.options#" index="t">
                        <option value="#t.value#">#esapiEncode('html',t.name)#</option>
                        <cfset arrayAppend(request["#attributes.name#dispenserlabels"],t.name)>
                        <cfset arrayAppend(request["#attributes.name#dispenservalues"],t.value)>
                    </cfloop>
                </select>
                <input type="hidden" value="#esapiEncode('html_attr',attributes.value)#" name="#esapiEncode('html_attr',attributes.name)#" id="#esapiEncode('html_attr',attributes.name)#dispenserval" class="objectParam">
        <!--- 		<a class="btn btn-trans mura-select-dispense" data-select="objectTheme" href="##"><i class="mi-plus-circle"></i></a> --->
            </div>
    
            <!--- if saved theme values --->
            <cfif len(trim(attributes.value))>
                <cfset request["#attributes.name#options"] = []>
                <cfset request["#attributes.name#values"] = listToArray(attributes.value, attributes.delim)>
                <cfloop array="#request["#attributes.name#values"]#" item="c">
                    <cfif arrayFind(request["#attributes.name#dispenservalues"],c) and not arrayFind(request["#attributes.name#options"],c)>
                        <cfset arrayAppend(request["#attributes.name#options"],c)>
                    </cfif>
                </cfloop>
                <!--- if saved values match available options --->
                <cfif arrayLen(request["#attributes.name#options"])>
                    <div class="dispense-to" data-select="#attributes.name#dispenser" data-delim="#attributes.delim#" data-param="#esapiEncode('html_attr',attributes.name)#">
                        <cfloop array="#request["#attributes.name#options"]#" index="o">
                            <cfset oo = request["#attributes.name#dispenserlabels"][arrayFind(request["#attributes.name#dispenservalues"],o)]>
                            <div class="dispense-option" data-value="#esapiEncode('html_attr',o)#">
                                <span class="drag-handle"><i class="mi-navicon"></i></span>
                                <span class="dispense-label">#esapiEncode('html',oo)#</span>
                                <a class="dispense-option-close"><i class="mi-minus-circle"></i></a>
                            </div>
                        </cfloop>
                    </div>
                </cfif>	
            </cfif>	
            
        </div>
    </cfif>
    </cfoutput>
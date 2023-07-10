<cfscript>
    param name="attributes.label" default='Checkboxes';
    param name="attributes.name" default='checkboxes';
    param name="attributes.value" default='';
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
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
    <label>#esapiEncode('html_attr',attributes.label)#</label>
    <cfif arraylen(attributes.options)>
    <div class="checkbox-group">
    <cfloop from="1" to="#arrayLen(attributes.options)#" index="idx">
    <label class="checkbox"><input type="checkbox" class="objectParam" name="#esapiEncode('html_attr',attributes.name)#" value="#esapiEncode('html_attr',attributes.options[idx].value)#"<cfif listFindNoCase(attributes.value,attributes.options[idx].value)> checked</cfif>>#esapiEncode('html',attributes.options[idx].name)#</label>
    </cfloop>
    </div>
    </cfif>
  </div>
</cfoutput>

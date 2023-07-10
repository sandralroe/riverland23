<cfimport prefix="ui" taglib="../../../mura/customtags/configurator/ui">

<cf_objectconfigurator>
    <cfscript>
        param name="objectparams.selfidstart" default="I'm a";
        param name="objectparams.selfidmiddle" default="who";
        param name="objectparams.selfidend" default="your product.";
        stages=m.getFeed('stage').where().prop('selfidq').isNEQ('null').getIterator();
        personas=m.getFeed('persona').where().prop('selfidq').isNEQ('null').getIterator();
        param name="objectParams.displayType" default="inline";
        param name="objectParams.widgetPosition" default="top_right";
        param name="objectParams.customlinks" default="";
        param name="objectParams.mode" default="Preview Only";
    </cfscript>
    <cfif personas.getRecordCount() gt 1 or personas.getRecordCount() eq 1 and stages.getRecordCount() gt 1>
    <cfoutput>
        <cfif personas.getRecordCount() gt 1>
        <div class="mura-control-group">
            <label >Self ID Start</label>
            <input name="selfidstart" type="text" class="objectParam" value="#esapiEncode('html_attr',objectparams.selfidstart)#">
        </div>
        </cfif>
        <cfif stages.getRecordCount() gt 1>
        <div class="mura-control-group">
            <label>Self ID Middle</label>
            <input name="selfidmiddle" type="text"  class="objectParam" value="#esapiEncode('html_attr',objectparams.selfidmiddle)#">
        </div>
        </cfif>
        <div class="mura-control-group">
            <label>Self ID End</label>
            <input name="selfidend" type="text"  class="objectParam" value="#esapiEncode('html_attr',objectparams.selfidend)#">
        </div>
    </cfoutput>
    <cfelse>
        <div class="mura-control-group">
        <label>There are currently no persona or stages with assigned self identification questions.</label>
        </div>
    </cfif>
    <cfoutput>
        <cfset modes = "Preview Only,Preview and Save" />
        <div class="mura-control-group">
            <label>Mode</label>
            <select name="mode" data-displayobjectparam="mode" class="objectParam">
                <cfloop list="#modes#" index="mode">
                    <cfset modeValue = lcase(mode) />
                    <option value="#esapiEncode('html_attr',modeValue)#"<cfif objectParams.mode eq modeValue> selected</cfif>>#mode#</option>
                </cfloop>
            </select>
        </div>
        <cfset displayTypes = "Inline,Widget,Eyebrow" />
        <div class="mura-control-group">
            <label>Display Type</label>
            <select name="displayType" data-displayobjectparam="displayType" class="objectParam">
                <cfloop list="#displayTypes#" index="type">
                    <cfset typeValue = lcase(type) />
                    <option value="#esapiEncode('html_attr',typeValue)#"<cfif objectParams.displayType eq typeValue> selected</cfif>>#type#</option>
                </cfloop>
            </select>
        </div>
        <cfset widgetPositions = "Top / Right,Bottom / Right,Bottom / Left,Top / Left" />
        <div class="mura-control-group">
            <label>Widget Position</label>
            <select name="widgetPosition" data-displayobjectparam="widgetPosition" class="objectParam">
                <cfloop list="#widgetPositions#" index="pos">
                    <cfset posValue = lcase(replace(pos, ' / ', '_')) />
                    <option value="#esapiEncode('html_attr',posValue)#"<cfif objectParams.widgetPosition eq posValue> selected</cfif>>#pos#</option>
                </cfloop>
            </select>
        </div>
        <div class="mura-control-group">
            <ui:name_value_array name="customlinks" label="Links" value="#objectparams.customlinks#">
        </div>

        
    </cfoutput>
    
     <!--- Include global config object options --->
     <cfinclude template="#$.siteConfig().lookupDisplayObjectFilePath('object/configurator.cfm')#">
</cf_objectconfigurator>

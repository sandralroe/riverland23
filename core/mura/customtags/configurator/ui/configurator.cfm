<cfscript>
    Mura=application.Mura.getBean('Mura').init(form.siteid);
    Mura.event('contentBean',Mura.getBean('content').loadBy(contenthistid=Mura.event('contenthistid')));
	configurator=deserializeJSON(Mura.event('configurator'));
</cfscript>
<cfif isArray(configurator)>
    <cfimport prefix="ui" taglib="./">
    <cfloop from="1" to="#arrayLen(configurator)#" index="idx">
        <cfif structKeyExists(configurator[idx],'name')>
            <cfset params=duplicate(configurator[idx])>
            <cfset params.instanceid=Mura.event('instanceid')>
            <cfset params.contentid=Mura.content('contentid')>
            <cfset params.contenthistid=Mura.content('contenthistid')>
            <cfset params.siteid=Mura.event('siteid')>
            <cfparam name="params.label" default="#params.name#">
            <cfif params.type eq 'html'>
                <cfoutput>
                    <div class="mura-control-group">
                        <label class="mura-control-label">#esapiEncode('html_attr',params.label)#</label>
                        <textarea style="display:none;" name="#esapiEncode('html_attr',params.name)#" id="#esapiEncode('html_attr',params.name)#" class="objectParam htmlEditor" data-height="400" data-width="100%"></textarea>
                    </div>
                </cfoutput>
            <cfelseif params.type eq 'markdown'>
                <cfoutput>
                    <div class="mura-control-group">
                        <label class="mura-control-label">#esapiEncode('html_attr',params.label)#</label>
                        <textarea style="display:none;" name="#esapiEncode('html_attr',params.name)#" id="#esapiEncode('html_attr',params.name)#" class="objectParam mura-markdown" data-height="400" data-width="100%"></textarea>
                    </div>
                </cfoutput>
            <cfelse>
                <ui:param attributecollection="#params#">
            </cfif>
        </cfif>
    </cfloop>
</cfif>
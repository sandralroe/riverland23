<cfoutput>
    <div class="block">
									
        <h2>Content powered by Layout Manager</h2>
        <p>The assigned content type of <span id="no-body-message-type">#esapiEncode('html',rc.type)#/#esapiEncode('html', rc.contentBean.getSubType())#</span> is enabled with Mura's Layout Manager.<br>
            <cfif $.content().getIsNew()>
                Save or publish this item to add or change the primary content.
            <cfelse>
                Use the #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.edit-layout')# option to add or change the primary content.
            </cfif>
        </p>

        <cfif not $.content().getIsNew()>	
            <cfset querystring=(rc.contentBean.getActive() and rc.contentBean.getApproved()) ? "editlayout=true" : "previewid=#rc.contentBean.getContentHistID()#&editlayout=true">
            <div class="mura-control justify">
                <cfif rc.contentBean.getType() eq 'Variation'>
                    <a href="#esapiEncode('html_attr',rc.contentBean.getRemoteURL())#?#querystring#" class="btn btn-primary"><i class="mi-th"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.edit-layout')#</a>
                <cfelse>
                    <a href="#rc.contentBean.getURL(secure=rc.$.getBean('utility').isHTTPs(),complete=1,queryString=querystring,useEditRoute=true)#" class="btn btn-primary"><i class="mi-th"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.edit-layout')#</a>
                </cfif>
                
            </div>
        </cfif>

    </div>
</cfoutput>
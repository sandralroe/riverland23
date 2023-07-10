<cfcontent reset="yes" type="application/javascript">
<cfscript>
    if(server.coldfusion.productname != 'ColdFusion Server'){
        backportdir='';
        include "/mura/backport/backport.cfm";
    } else {
        backportdir='/mura/backport/';
        include "#backportdir#backport.cfm";
    }
</cfscript>
 <cfif isDefined("url.siteID")>
    <cfset $=application.serviceFactory.getBean("MuraScope").init(url.siteID)>
    <cfparam name="session.siteid" default="#url.siteid#">
    <cfif not structKeyExists(session,"rb")>
        <cfset application.rbFactory.resetSessionLocale()>
    </cfif>
    <cfcontent reset="true"><cfif not isdefined('cookie.fetdisplay')><cfset $.getBean('utility').setCookie(name="FETDISPLAY",httponly=false,value="")></cfif>
 </cfif>
 <cfoutput>(function(window){
    window.Mura=window.Mura || window.mura || {};
    window.Mura.layoutmanager=#$.getContentRenderer().useLayoutManager()#;
    
    let instanceid=Mura.createUUID();
    let utility=Mura;
    let adminProxy;
    let serverPort="#$.globalConfig('serverPort')#";
    let isRemote=#$.siteConfig('isremote')#;
    let fetDisplay=<cfif isDefined('Cookie.fetDisplay')>"#esapiEncode('javascript',Cookie.fetDisplay)#"<cfelse>""</cfif>;
    <cfif len($.globalConfig('admindomain'))>
        let adminDomain="#$.globalConfig('admindomain')#";
    <cfelseif $.siteConfig().getValue('isRemote')>
        let adminDomain="#$.siteConfig().getValue('resourceDomain')#" || "#$.getBean('utility').getRequestHost()#";
    <cfelse>
        let adminDomain="";
    </cfif>
    
    <cfif len($.globalConfig('admindomain')) or $.event('contenttype') eq 'variation' or $.siteConfig('isRemote')>
        let adminProxyLoc="#$.siteConfig().getAdminPath(complete=1)#/assets/js/porthole/proxy.html?cacheid=" + Math.random();
        let adminLoc="#$.siteConfig().getAdminPath(complete=1)#/";
        let coreLoc="#$.siteConfig().getCorePath(complete=1)#/";
        let resourceLoc="#$.siteConfig().getResourcePath(complete=1)#/";
        let frontEndProxyLoc= location.protocol + "//" + location.hostname;

        if(location.port){
            frontEndProxyLoc+=':' + location.port;
        }
    <cfelse>
        let adminProxyLoc="#$.globalConfig('context')##$.globalConfig('adminDir')#/assets/js/porthole/proxy.html?cacheid=" + Math.random();
        let adminLoc="#$.globalConfig('context')##$.globalConfig('adminDir')#/";
        let coreLoc="#$.globalConfig('context')#/core/";
        let resourceLoc="#$.globalConfig('context')#/";
        let frontEndProxyLoc="";
    </cfif>
</cfoutput>
<cfinclude template="proxy.js">
<!--- this line is needed to separated js files --->
<cfinclude template="toolbar.js">
<cfparam name="url.contenttype" default="">
<cfif isDefined('url.siteID') and isDefined('url.contenthistid') and isDefined('url.showInlineEditor') and url.showInlineEditor>
    <cfset node=application.serviceFactory.getBean('contentManager').read(contentHistID=url.contentHistID,siteid=url.siteid)>

    <cfif url.contenttype eq 'Variation'>
        <cfset node.setIsNew(0)>
        <cfset node.setType('Variation')>
    </cfif>

    <cfif not node.getIsNew()>
        <cfoutput>
        let nodeType="#node.getType()#";
        let nodeIsApproved=#node.getApproved()#;
        let nodeIsActive=#node.getApproved()#;
        let editingVariations=false;
        let targetingVariations=false;
        let lockedNodeAlertText="#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"sitemanager.draftprompt.contentislockedbyanotheruser"))#";
        <cfif $.siteConfig('hasLockableNodes')>
            <cfset stats=node.getStats()>
            <cfif stats.getLockType() eq 'node' and stats.getLockID() neq session.Mura.userid>
                let lockableNodes=true;
            <cfelse>
                let lockableNodes=false;
            </cfif>
        <cfelse>
            let lockableNodes=false;
        </cfif>
     
        let publishitemfromchangeset='#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.publishitemfromchangeset"))#'
        let changesetnotifyexport='#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.changesetnotifyexport"))#';
        let removechangeset='#esapiEncode('javascript',application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"sitemanager.content.removechangeset"),application.changesetManager.read(node.getChangesetID()).getName()))#';
        let cancelPendingApproval='#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"approvalchains.cancelPendingApproval"))#';
        let saveasdraftlm="#esapiEncode('javascript',application.rbFactory.getKey('sitemanager.content.saveasdraftlm',session.rb))#";
        let keepeditingconfirmlm="#esapiEncode('javascript',application.rbFactory.getKey('sitemanager.content.keepeditingconfirmlm',session.rb))#";
        let requiresApproval=#node.requiresApproval()#;
        
        <cfset csrfTokens=$.generateCSRFTokens(context=node.getContentHistID() & 'add')>
        let processedData={
            muraaction: 'carch.update',
            action: 'add',
            ajaxrequest: true,
            siteid: '#esapiEncode('javascript',node.getSiteID())#',
            contenthistid: '#esapiEncode('javascript',node.getContentHistID())#',
            contentid: '#esapiEncode('javascript',node.getContentID())#',
            parentid: '#esapiEncode('javascript',node.getParentID())#',
            moduleid: '#esapiEncode('javascript',node.getModuleID())#',
            approved: 0,
            changesetid: '',
            bean: 'content',
            loadby: 'contenthistid',
            approvalstatus: '#esapiEncode('javascript',node.getApprovalStatus())#',
            csrf_token: '#csrfTokens.token#',
            csrf_token_expires: '#csrfTokens.expires#'
        }

        let preprocessedData={
        <cfscript>
        started=false;
        nodeCollection=node.getAllValues();
        for(attribute in nodeCollection)
            if(isSimpleValue(nodeCollection[attribute]) and reFindNoCase("(\{{|\[sava\]|\[mura\]|\[m\]).+?(\[/sava\]|\[/mura\]|}}|\[/m\])",nodeCollection[attribute])){
                if(started){writeOutput(",");}
                writeOutput("'#esapiEncode('javascript',lcase(attribute))#':'#esapiEncode('javascript',trim(nodeCollection[attribute]))#'");
                started=true;
            }
        </cfscript>
        };

        let customtaggroups=#serializeJSON(listToArray($.siteConfig('customTagGroups')))#
        let allowopenfeeds=#application.configBean.getValue(property='allowopenfeeds',defaultValue=false)#
        
        let pluginConfigurators=[];
        <cfset rsPluginDisplayObjects=application.pluginManager.getDisplayObjectsBySiteID(siteID=session.siteID,configuratorsOnly=true)>
        <cfset nonPluginDisplayObjects=$.siteConfig().getDisplayObjectLookup()>
        <cfloop query="rsPluginDisplayObjects">
        pluginConfigurators.push({'objectid':'#rsPluginDisplayObjects.objectid#','init':'#rsPluginDisplayObjects.configuratorInit#'});
        </cfloop>
        <cfloop item="i" collection="#nonPluginDisplayObjects#">
        <cfif len(nonPluginDisplayObjects[i].configuratorInit)>
            pluginConfigurators.push({'objectid':'#nonPluginDisplayObjects[i].objectid#','init':'#nonPluginDisplayObjects[i].configuratorInit#'});
        </cfif>
        </cfloop>
        </cfoutput>
        <!--- this line is needed to separated js files --->
        <cfinclude template="editor.js">
        </cfif>
    </cfif>
})(window);
    
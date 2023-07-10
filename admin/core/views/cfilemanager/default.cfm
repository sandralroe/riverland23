<!--- License goes here --->
<cfparam name="rc.keywords" default="">
<cfparam name="session.resourceType" default="assets">
<cfparam name="rc.resourceType" default="">
<cfif len(rc.resourceType)>
  <cfset session.resourceType=rc.resourceType>
</cfif>
<cfoutput>
<div class="mura-header">
  <h1>#rc.$.rbKey("layout.filemanager")#</h1>
	<div class="nav-module-specific btn-group">
		  <a class="btn<cfif session.resourceType eq 'assets'> active</cfif>" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cFilemanager.default&siteid=#session.siteid#&&resourceType=assets"><i class="mi-folder-open"></i> #application.rbFactory.getKeyValue(session.rb,"layout.userassets")#</a>
      <cfif listFind(session.mura.memberships,'S2')>
        <cfif application.configBean.getValue(property='fmShowSiteFiles',defaultValue=true)>
				  <a class="btn<cfif session.resourceType eq 'files'> active</cfif>" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cFilemanager.default&siteid=#session.siteid#&resourceType=files"><i class="mi-folder-open"></i> #application.rbFactory.getKeyValue(session.rb,"layout.sitefiles")#</a>
	       </cfif>
	       <cfif listFind(session.mura.memberships,'S2') and application.configBean.getValue(property='fmShowApplicationRoot',defaultValue=true)>
          <a class="btn<cfif session.resourceType eq 'root'> active</cfif>" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cFilemanager.default&siteid=#session.siteid#&resourceType=root"><i class="mi-folder-open"></i> #application.rbFactory.getKeyValue(session.rb,"layout.applicationroot")#</a>
	       </cfif>
      </cfif>
      <cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
        <a class="btn" href="./?muraAction=cPerm.module&contentid=00000000000000000000000000000000018&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000018"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,'filebrowser.permissions')#</a>
      </cfif>
  </div>
</div> <!-- /.mura-header -->

<div id="MuraFileBrowserContainer"></div>
  
<script type="text/javascript">
  <cfif session.resourceType eq "assets">
        MuraFileBrowser.config.resourcepath="#esapiEncode('javascript','User_Assets')#";
  <cfelseif session.resourceType eq "files" and application.configBean.getValue(property='fmShowSiteFiles',defaultValue=true)>
        MuraFileBrowser.config.resourcepath="#esapiEncode('javascript','Site_Files')#"
  <cfelseif session.resourceType eq "root" and application.configBean.getValue(property='fmShowApplicationRoot',defaultValue=true)>
        MuraFileBrowser.config.resourcepath="#esapiEncode('javascript','Application_Root')#";
  <cfelse>
        MuraFileBrowser.config.resourcepath="#esapiEncode('javascript','User_Assets')#";
  </cfif>
  Mura(function(m) {
  MuraFileBrowser.config.height=600;
  MuraFileBrowser.render();
});
</script>
</cfoutput>
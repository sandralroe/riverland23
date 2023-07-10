 <!--- license goes here --->
<cfinclude template="js.cfm">
<cfset listed=0><cfoutput>
	<h1>#application.rbFactory.getKeyValue(session.rb,'sitemanager.drafts')#</h1>
	<table class="mura-table-grid">
    <tr>
      <th class="actions"></th>
      <th class="var-width">#application.rbFactory.getKeyValue(session.rb,'sitemanager.drafts.title')#</th>
    <th>#application.rbFactory.getKeyValue(session.rb,'sitemanager.drafts.contenttype')#</th>
    </tr></cfoutput>

      <cfoutput query="rc.rslist">
	  <cfset itemcrumbdata=application.contentManager.getCrumbList(rc.rslist.contentid,rc.siteid)>
	  <cfset itemperm=application.permUtility.getnodePerm(itemcrumbdata)>
<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2') or itemperm eq 'editor' or itemperm eq 'author'>

		<tr>
        <td class="actions">
          <a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
          <div class="actions-menu hide">
            <ul class="drafts actions-list">
              <li class="version-history">
                <a href="./?muraAction=cArch.hist&contentid=#rc.rslist.ContentID#&type=#rc.rslist.type#&parentid=#rc.rslist.parentID#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.rslist.moduleid#"><i class="mi-history"></i>#application.rbFactory.getKeyValue(session.rb,'sitemanager.versionhistory')#</a>
              </li>
           </ul>
        </div>
      </td>
      <td class="var-width">
<cfswitch expression="#rc.rslist.type#">
<cfcase value="Form,Component">
<a title="#application.rbFactory.getKeyValue(session.rb,'sitemanager.versionhistory')#" href="./?muraAction=cArch.hist&contentid=#rc.rslist.ContentID#&type=#rc.rslist.type#&parentid=#rc.rslist.parentID#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.rslist.moduleid#">#rc.rslist.menutitle#</a>
</cfcase>
<cfdefaultcase>
#$.dspZoom(itemcrumbdata)#</cfdefaultcase>
</cfswitch></td>
      <td>#rc.rslist.module#</td>
        </tr>
		<cfset listed=1>
	  </cfif>
      </cfoutput>
      <cfif not listed>
      <tr>
        <td colspan="3" class="noResults">
	<cfoutput>#application.rbFactory.getKeyValue(session.rb,'sitemanager.drafts.nodrafts')#</cfoutput>
        </td>
      </tr>
	  </cfif>
</table>

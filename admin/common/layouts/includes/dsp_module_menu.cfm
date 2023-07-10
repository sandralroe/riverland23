<!--- license goes here --->
<cfif session.siteid neq ''>

  <cfif not application.configBean.getSessionHistory() or application.configBean.getSessionHistory() gte 180>
    <cfparam name="session.dashboardSpan" default="30">
  <cfelse>
    <cfparam name="session.dashboardSpan" default="#application.configBean.getSessionHistory()#">
  </cfif>
  <cfoutput>
    <li id="admin-nav-modules">
      <a class="nav-submenu <cfif not listFindNoCase('carch,cchain,cusers,csettings,cdashboard,ceditprofile,nmessage,ctrash,clogin,cextend,cfilemanager,cfeed,ccategory,cchangesets,cplugins',rc.originalcircuit) and not (rc.moduleID eq '00000000000000000000000000000000000' and rc.originalcircuit eq 'cPerm')> active</cfif>" data-toggle="nav-submenu" href="./">
        <i class="mi-th-large"></i>
        <span class="sidebar-mini-hide">#rc.$.rbKey("layout.modules")#</span>
      </a>

      <ul>

        <!--- Advertising, this is not only available in certain legacy situations --->
          <cfif application.settingsManager.getSite(session.siteid).getAdManager() and  application.permUtility.getModulePerm("00000000000000000000000000000000006",session.siteid)>
            <li>
              <a<cfif rc.originalcircuit eq 'cAdvertising' or (rc.originalcircuit eq 'cPerm' and  rc.moduleid eq '00000000000000000000000000000000006')> class="active"</cfif> href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cAdvertising.listAdvertisers&amp;siteid=#session.siteid#&amp;moduleid=00000000000000000000000000000000006">
                <i class="mi-cog"></i>
                #rc.$.rbKey("layout.advertising")#
              </a>
            </li>
          </cfif>
        <!--- /Advertising --->

        <!--- Email Broadcaster --->
          <cfif application.settingsManager.getSite(session.siteid).getemailbroadcaster() and  application.permUtility.getModulePerm("00000000000000000000000000000000005",session.siteid)>
            <li>
              <a<cfif rc.originalcircuit eq 'cEmail' or (rc.originalcircuit eq 'cPerm' and rc.moduleid eq '00000000000000000000000000000000005')> class="active"</cfif> href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cEmail.list&amp;siteid=#session.siteid#">
                <i class="mi-cog"></i>
                #rc.$.rbKey("layout.emailbroadcaster")#
              </a>
            </li>
          </cfif>
        <!--- /Email Broadcaster --->

        <!--- Mailing Lists --->
          <cfif application.settingsManager.getSite(session.siteid).getemailbroadcaster() and  application.permUtility.getModulePerm("00000000000000000000000000000000009",session.siteid)>
            <li>
              <a<cfif rc.originalcircuit eq 'cMailingList' or (rc.originalcircuit eq 'cPerm' and rc.moduleid eq '00000000000000000000000000000000009')> class="active"</cfif> href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cMailingList.list&amp;siteid=#session.siteid#">
                <i class="mi-cog"></i>
                #rc.$.rbKey("layout.mailinglists")#
              </a>
            </li>
          </cfif>
        <!--- /Mailing Lists --->

        <!--- Custom Site Secondary Menu --->
          <cfif fileExists("#application.configBean.getWebRoot()#/#session.siteid#/includes/display_objects/custom/admin/dsp_secondary_menu.cfm")>
            <cfinclude template="/#application.configBean.getWebRootMap()#/#session.siteID#/includes/display_objects/custom/admin/dsp_secondary_menu.cfm" >
          </cfif>
        <!--- /Custom Site Secondary Menu --->

      </ul>
    </li>
  </cfoutput>
</cfif>

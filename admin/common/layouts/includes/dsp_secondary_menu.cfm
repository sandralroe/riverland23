<!--- license goes here --->
<cfif session.siteid neq ''>
<cfif not application.configBean.getSessionHistory() or application.configBean.getSessionHistory() gte 180>
	<cfparam name="session.dashboardSpan" default="30">
<cfelse>
	<cfparam name="session.dashboardSpan" default="#application.configBean.getSessionHistory()#">
</cfif>
<cfoutput>
  <cfif  rc.originalcircuit eq 'cDashboard'>
    <cfinclude template="/muraWRM#application.configBean.getAdminDir()#/core/views/cdashboard/dsp_secondary_menu.cfm">
  </cfif>
	<cfif rc.moduleid eq '00000000000000000000000000000000000' and rc.originalcircuit neq 'cDashboard'>
    <cfinclude template="/muraWRM#application.configBean.getAdminDir()#/core/views/carch/dsp_secondary_menu.cfm">
  </cfif>
  <cfif rc.originalcircuit eq 'cChangesets' or (rc.originalcircuit eq 'cPerm' and  rc.moduleid eq '00000000000000000000000000000000014')>
    <cfinclude template="/muraWRM#application.configBean.getAdminDir()#/core/views/cchangesets/dsp_secondary_menu.cfm">
  </cfif>
  <cfif rc.moduleid eq '00000000000000000000000000000000003' or (rc.originalcircuit eq 'cPerm' and  rc.moduleid eq '00000000000000000000000000000000003')>
     <cfinclude template="/muraWRM#application.configBean.getAdminDir()#/core/views/carch/dsp_secondary_menu.cfm">
  </cfif>
	<cfif rc.originalcircuit eq 'cCategory' or (rc.originalcircuit eq 'cPerm' and  rc.moduleid eq '00000000000000000000000000000000010')>
    <cfinclude template="/muraWRM#application.configBean.getAdminDir()#/core/views/ccategory/dsp_secondary_menu.cfm">
  </cfif>
  <cfif rc.originalcircuit eq 'cFeed' or (rc.originalcircuit eq 'cPerm' and  rc.moduleid eq '00000000000000000000000000000000011')>
    <cfinclude template="/muraWRM#application.configBean.getAdminDir()#/core/views/cfeed/dsp_secondary_menu.cfm">
  </cfif>
  <cfif rc.moduleid eq '00000000000000000000000000000000004'>
    <cfinclude template="/muraWRM#application.configBean.getAdminDir()#/core/views/carch/dsp_secondary_menu.cfm">
  </cfif>
  <cfif rc.originalcircuit eq 'cPublicUsers' or (rc.originalcircuit eq 'cPerm' and  rc.moduleid eq '00000000000000000000000000000000008')>
    <cfinclude template="/muraWRM#application.configBean.getAdminDir()#/core/views/cpublicusers/dsp_secondary_menu.cfm">
  </cfif>
  <cfif rc.originalcircuit eq 'cAdvertising' or (rc.originalcircuit eq 'cPerm' and  rc.moduleid eq '00000000000000000000000000000000006')>
    <cfinclude template="/muraWRM#application.configBean.getAdminDir()#/core/views/cadvertising/dsp_secondary_menu.cfm">
  </cfif>
   <cfif rc.originalcircuit eq 'cEmail' or (rc.originalcircuit eq 'cPerm' and  rc.moduleid eq '00000000000000000000000000000000005')>
      <cfinclude template="/muraWRM#application.configBean.getAdminDir()#/core/views/cemail/dsp_secondary_menu.cfm">
   </cfif>
    <cfif rc.originalcircuit eq 'cMailingList' or (rc.originalcircuit eq 'cPerm' and  rc.moduleid eq '00000000000000000000000000000000009')>
      <cfinclude template="/muraWRM#application.configBean.getAdminDir()#/core/views/cmailinglist/dsp_secondary_menu.cfm">
    </cfif>


      <!--- <cfif listFind(session.mura.memberships,'S2') or listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(session.siteid).getPrivateUserPoolID()#;0')><li<cfif rc.originalcircuit eq 'cPrivateUsers'>id="current"</cfif>><a href="./?muraAction=cPrivateUsers.list&siteid=#session.siteid#" >Administrative Users</a><cfif rc.originalcircuit eq 'cPrivateUsers'><cfinclude template="../../view/vPrivateUsers/dsp_secondary_menu.cfm"></cfif></li></cfif> --->

  <!---
	 <cfif rc.originalcircuit eq 'cFilemanager'>
    <ul class="nav nav-pills">
			<li<cfif session.resourceType eq 'assets'> class="current"</cfif>><a href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cFilemanager.default&siteid=#session.siteid#&resourceType=assets">#rc.$.rbKey("layout.userassets")#</a></li>
			<cfif listFind(session.mura.memberships,'S2')>
				<cfif application.configBean.getValue('fmShowSiteFiles') neq 0>
					<li<cfif session.resourceType eq 'files'> class="current"</cfif>><a href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cFilemanager.default&siteid=#session.siteid#&resourceType=files">#rc.$.rbKey("layout.sitefiles")#</a></li>
					</cfif>
					<cfif listFind(session.mura.memberships,'S2') and application.configBean.getValue('fmShowApplicationRoot') neq 0>
					<li<cfif session.resourceType eq 'root'> class="current"</cfif>><a href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cFilemanager.default&siteid=#session.siteid#&resourceType=root">#rc.$.rbKey("layout.applicationroot")#</a></li>
				</cfif>
				</li>
			</cfif>
		</ul>
	</cfif>
  --->
  </cfoutput>
</cfif>

<!--- license goes here --->
<cfparam name="request.action" default="core:cplugin.plugin">
<cfparam name="rc.originalfuseaction" default="#listLast(listLast(request.action,":"),".")#">
<cfparam name="rc.originalcircuit"  default="#listFirst(listLast(request.action,":"),".")#">
<cfparam name="rc.moduleid" default="">
<cfif not application.configBean.getSessionHistory() or application.configBean.getSessionHistory() gte 180>
	<cfparam name="session.dashboardSpan" default="30">
<cfelse>
	<cfparam name="session.dashboardSpan" default="#application.configBean.getSessionHistory()#">
</cfif>
<cfoutput>
<cfparam name="Cookie.fetDisplay" default="">

<cfif not arguments.jsLibLoaded>
<cfif arguments.jsLib eq "jquery">
<script src="#application.configBean.getContext()#/#application.settingsmanager.getSite(session.siteid).getDisplayPoolID()#/js/jquery/jquery.js" type="text/javascript"></script>
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/jquery/jquery.collapsibleCheckboxTree.js?coreversion=#application.coreversion#" type="text/javascript"></script>
<cfelse>
<script src="#application.configBean.getContext()#/#application.settingsmanager.getSite(session.siteid).getDisplayPoolID()#/js/prototype.js" type="text/javascript"></script>
<script type="text/javascript" src="#application.configBean.getContext()#/#application.settingsmanager.getSite(session.siteid).getDisplayPoolID()#/js/scriptaculous/src/scriptaculous.js?load=effects"></script>
</cfif>
</cfif>
<!-- JSON -->
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/json2.js" type="text/javascript"></script>
<script type="text/javascript" src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/admin.min.j?coreversion=#application.coreversion#"></script>
<link href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/css/admin.min.css?coreversion=#application.coreversion#" rel="stylesheet" type="text/css" />
<link href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/css/admin-frontend.min.css?coreversion=#application.coreversion#" rel="stylesheet" type="text/css" />

<script type="text/javascript">
function toggleAdminToolbar(){
	<cfif arguments.jslib eq "jquery">
		$("##frontEndTools").animate({opacity: "toggle"});
		<cfelse>Effect.toggle("frontEndTools", "appear");
	</cfif>
	}
</script>

	<img src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/images/mura-logo.svg" id="frontEndToolsHandle" onclick="if (document.getElementById('frontEndTools').style.display == 'none') { createCookie('FETDISPLAY','',5); } else { createCookie('FETDISPLAY','none',5); } toggleAdminToolbar();" />
	<div id="frontEndTools" class="pluginHdr" style="display: #Cookie.fetDisplay#">
			<ul>
				<li id="adminPlugIns"><a href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cPlugins.list&siteid=#session.siteid#"><i class="mi-cogs"></i> #rc.$.rbKey("layout.plugins")#</a></li>
				<li id="adminSiteManager"><a href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cArch.list&siteid=#session.siteid#&moduleid=00000000000000000000000000000000000&topid=00000000000000000000000000000000001"><i class="mi-sitemap"></i> #rc.$.rbKey("layout.sitemanager")#</a></li>
				<li id="adminDashboard"><a href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cDashboard.main&siteid=#session.siteid#&span=#session.dashboardSpan#"><i class="mi-dashboard"></i> #rc.$.rbKey("layout.dashboard")#</a></li>
				<li id="adminLogOut"><a href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cLogin.logout"><i class="mi-sign-out"></i> #rc.$.rbKey("layout.logout")#</a></li>
				<li id="adminWelcome">#rc.$.rbKey("layout.welcome")#, #esapiEncode("html","#session.mura.fname# #session.mura.lname#")#.</li>
			</ul>
		</div>
</cfoutput>
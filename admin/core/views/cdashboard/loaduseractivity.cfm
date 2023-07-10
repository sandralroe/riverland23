<!--- license goes here --->
<cfset request.layout="false">
<cfinclude template="act_defaults.cfm">
<cfoutput>
	<table class="mura-table-grid" id="recentActivity">
	<thead>
	<tr>
		<th colspan="2">#application.rbFactory.getKeyValue(session.rb,"dashboard.recentactivity")#</th>
	</tr>
	</thead>
	<tbody>
	<tr>
		<td><a href="./?muraAction=cDashboard.listSessions&siteid=#esapiEncode('url',rc.siteid)#&membersOnly=false&visitorStatus=All&spanType=n&span=15">#application.rbFactory.getKeyValue(session.rb,"dashboard.currentvisitors")#</a> <span>(#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.spannow"),15)#)</span></td>
		<td class="count">#application.dashboardManager.getSiteSessionCount(rc.siteID,false,"All",15,"n")# </td>
	</tr>
	<tr>
		<td><!--- <a href="./?muraAction=cDashboard.listSessions&siteid=#esapiEncode('url',rc.siteid)#&membersOnly=false&spanType=#spanType#&span=#spanUnits#"> --->#application.rbFactory.getKeyValue(session.rb,"dashboard.visits")#<!--- </a> --->  <span>(#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.span"),rc.span)#)</span></td>
		<td class="count">#application.dashboardManager.getSiteSessionCount(rc.siteID,false,"All",spanUnits,spanType)#</td>
	</tr>
	<tr>
		<td>#application.rbFactory.getKeyValue(session.rb,"dashboard.returnvisits")# <span>(#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.span"),rc.span)#)</span></td>
		<td class="count">#application.dashboardManager.getSiteSessionCount(rc.siteID,false,"Return",spanUnits,spanType)#</td>
	</tr>
	</tbody>
	</table>
	
	<cfif application.settingsManager.getSite(rc.siteID).getExtranet() eq 1>
	<table class="mura-table-grid" id="memberActivity">
	<thead>
	<tr>
		<th colspan="2">#application.rbFactory.getKeyValue(session.rb,"dashboard.memberactivity")#</th>
	</tr>
	</thead>
	<tbody>
	<tr>
		<td><a href="./?muraAction=cDashboard.listSessions&siteid=#esapiEncode('url',rc.siteid)#&membersOnly=true&visitorStatus=All&spanType=n&span=15">#application.rbFactory.getKeyValue(session.rb,"dashboard.currentmembers")#</a><span> (#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.spannow"),15)#)</span></td>
		<td class="count">#application.dashboardManager.getSiteSessionCount(rc.siteID,true,false,15,"n")# </td>
	</tr>
	<tr>
		<td><!--- <a href="./?muraAction=cDashboard.listSessions&siteid=#esapiEncode('url',rc.siteid)#&membersOnly=true&spanType=#spanType#&span=#spanUnits#"> --->#application.rbFactory.getKeyValue(session.rb,"dashboard.membervisits")#<!--- </a> ---><span> (#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.span"),rc.span)#)</span></td>
		<td class="count">#application.dashboardManager.getSiteSessionCount(rc.siteID,true,false,spanUnits,spanType)#</td>
	</tr>
	<cfif application.settingsManager.getSite(rc.siteID).getExtranetPublicReg() eq 1>
	<tr>
		<td><cfif application.permUtility.getModulePerm('00000000000000000000000000000000008','#rc.siteid#')><a href="./?muraAction=cUsers.advancedSearch&siteid=#esapiEncode('url',rc.siteid)#&param=1&paramField1=#esapiEncode('url','tusers.created^date')#&paramCondition1=GTE&paramCriteria1=#esapiEncode('url',rc.startDate)#&paramRelationship1=and&inActive=">#application.rbFactory.getKeyValue(session.rb,"dashboard.memberregistrations")#</a><cfelse>#application.rbFactory.getKeyValue(session.rb,"dashboard.memberregistrations")#</cfif><span> (#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.span"),rc.span)#)</span></td>
		<td class="count">#application.dashboardManager.getCreatedMembers(rc.siteID,rc.startDate,rc.stopDate)#</td>
	</tr>
	</cfif>
	<!--- <tr>
		<th class="alt">#application.rbFactory.getKeyValue(session.rb,"dashboard.mostactiveusers")#</th><td>##</td>
	</tr> --->
	</tbody>
	</table>
</cfif></cfoutput>
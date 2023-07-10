<!--- license goes here --->
<cfset request.layout="false">
<cfinclude template="act_defaults.cfm">
<cfoutput>
<cfset rsList=application.dashboardManager.getTopContent(rc.siteID,3,false,"All",rc.startDate,rc.stopDate,true) />
<cfset items=rc.$.getBean('contentIterator')>
<cfset items.setQuery(rslist)>
<cfset count=rsList.recordcount>
<table class="mura-table-grid" id="topPages">
	<thead>
		<tr>
			<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.pages")# <a href="./?muraAction=cDashboard.topContent&siteid=#esapiEncode('url',rc.siteid)#&startDate=#esapiEncode('url',rc.startDate)#&stopDate=#esapiEncode('url',rc.stopDate)#">(#application.rbFactory.getKeyValue(session.rb,"dashboard.viewreport")#)</a></th>
		</tr>
	</thead>
<tbody>

<cfloop condition="items.hasNext()">
<cfset item=items.next()>
<tr>
	<td>
		<a title="#application.rbFactory.getKeyValue(session.rb,"dashboard.view")#" href="##" onclick="return preview('#item.getURL(complete=1)#');">#esapiEncode('html',left(item.getmenutitle(),30-len(item.gethits())))#</a>
		<span>(#item.gethits()# #application.rbFactory.getKeyValue(session.rb,"dashboard.views")#)</span></td>
</tr>
</cfloop>
<cfif count eq 0><tr><td>&mdash;</td></tr></cfif>
<cfif count lt 2><tr><td>&mdash;</td></tr></cfif>
<cfif count lt 3><tr><td>&mdash;</td></tr></cfif>
</tbody>
</table>

<cfset rsList=application.dashboardManager.getTopKeywords(rc.siteID,3,false,"All",rc.startDate,rc.stopDate) />
<cfset count=rsList.recordcount>
<table class="mura-table-grid" id="topSearches">
<thead>
<tr>
	<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.topsearches")# <a href="./?muraAction=cDashboard.topSearches&siteid=#esapiEncode('url',rc.siteid)#&startDate=#esapiEncode('url',rc.startDate)#&stopDate=#esapiEncode('url',rc.stopDate)#">(View Report)</a></th>
</tr>
</thead>
<tbody>
<cfloop query="rslist">
<tr>
	<td>#esapiEncode('html',left(rsList.keywords,30-len(rsList.keywordCount)))# <span>(#rsList.keywordCount# #application.rbFactory.getKeyValue(session.rb,"dashboard.searches")#)</span></td>
</tr>
</cfloop>
<cfif count eq 0><tr><td>&mdash;</td></tr></cfif>
<cfif count lt 2><tr><td>&mdash;</td></tr></cfif>
<cfif count lt 3><tr><td>&mdash;</td></tr></cfif>
</tbody>
</table>

</cfoutput>


<!--- license goes here --->
<cfset request.layout="false">
<cfinclude template="act_defaults.cfm">
<cfset rsList=application.dashboardManager.getRecentFormActivity(rc.siteID,5) />
<cfoutput><table class="mura-table-grid">
<thead>
<tr><th class="title">#application.rbFactory.getKeyValue(session.rb,"dashboard.title")#</th><th class="dateTime">#application.rbFactory.getKeyValue(session.rb,"dashboard.lastresponse")#</th><th class="total">#application.rbFactory.getKeyValue(session.rb,"dashboard.totalresponses")#</th></tr>
</thead>
<tbody>
	<cfif rslist.recordcount>
	<cfloop query="rslist">
	<cfset crumbdata=application.contentManager.getCrumbList(rslist.contentid, rc.siteid)/>
	<cfset verdict=application.permUtility.getnodePerm(crumbdata)/>
	<tr>
	<td><cfif verdict neq 'none'><a title="Version History" href="./?muraAction=cArch.datamanager&contentid=#rslist.ContentID#&type=Form&parentid=00000000000000000000000000000000004&topid=00000000000000000000000000000000004&siteid=#rsList.siteid#&moduleid=00000000000000000000000000000000004">#esapiEncode('html',rsList.menuTitle)#</a><cfelse>#rsList.menuTitle#</cfif> </td>
	<td class="dateTime">#LSDateFormat(rsList.lastEntered,session.dateKeyFormat)# #LSTimeFormat(rsList.lastEntered,"short")#</td>
	<td class="total">#rsList.submissions#</td>
	</tr>
	</cfloop>
	<cfelse>
	<tr><td class="noResults" colspan="3">#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.noformsubmissions"),rc.span)#</td></tr>
	</cfif>
	</tbody>
	</table>
</cfoutput>
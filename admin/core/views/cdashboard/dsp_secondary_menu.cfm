<!--- license goes here --->
<cfoutput>
<cfset rc.originalfuseaction=listLast(request.action,".")>

<div class="nav-module-specific btn-group">
<!---
<a class="btn<cfif rc.originalfuseaction eq 'main'> active</cfif>" href="./?muraAction=cDashboard.main&siteID=#session.siteid#">#application.rbFactory.getKeyValue(session.rb,"dashboard.overview")#</a>
--->
<cfif application.configBean.getSessionHistory()>
	<div class="btn-group">
	  <a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
	    #application.rbFactory.getKeyValue(session.rb,"dashboard.siteactivity")#
	    <span class="caret"></span>
	  </a>
	  <ul class="dropdown-menu">
	   	<li><a class="<cfif rc.originalfuseaction eq 'sessionsearch'> active</cfif>" href="./?muraAction=cDashboard.sessionSearch&siteID=#session.siteid#&newSearch=true">#application.rbFactory.getKeyValue(session.rb,"dashboard.sessionsearch")#</a></li>
		<li><a class="<cfif rc.originalfuseaction eq 'topcontent'> active</cfif>"  href="./?muraAction=cDashboard.topContent&siteID=#session.siteid#">#application.rbFactory.getKeyValue(session.rb,"dashboard.topcontent")#</a></li>
		<li><a class="<cfif rc.originalfuseaction eq 'topreferers'> active</cfif>"  href="./?muraAction=cDashboard.topReferers&siteID=#session.siteid#">#application.rbFactory.getKeyValue(session.rb,"dashboard.topreferrers")#</a></li>
		<li><a class="<cfif rc.originalfuseaction eq 'topsearches'> active</cfif>"  href="./?muraAction=cDashboard.topSearches&siteID=#session.siteid#">#application.rbFactory.getKeyValue(session.rb,"dashboard.topsearches")#</a></li>
		<li><a class="<cfif rc.originalfuseaction eq 'toprated'> active</cfif>"  href="./?muraAction=cDashboard.topRated&siteID=#session.siteid#">#application.rbFactory.getKeyValue(session.rb,"dashboard.toprated")#</a></li>
		<!---
		<li><a class="<cfif rc.originalfuseaction eq 'recentcomments'> active</cfif>"  href="./?muraAction=cComments.default&siteID=#session.siteid#">#application.rbFactory.getKeyValue(session.rb,"dashboard.comments")#</a></li>
		--->
	  </ul>
	</div>
<cfelse>
	<a class="btn <cfif rc.originalfuseaction eq 'toprated'> active</cfif>"  href="./?muraAction=cDashboard.topRated&siteID=#session.siteid#">#application.rbFactory.getKeyValue(session.rb,"dashboard.toprated")#</a>
</cfif>

<cfset draftCount=$.getBean('contentManager').getMyDraftsCount(siteid=session.siteid,startdate=dateAdd('m',-3,now()))>
<a class="btn"  href="./?muraAction=cArch.list&moduleid=00000000000000000000000000000000000&activeTab=1&report=mydrafts&siteID=#session.siteid#&reportSortby=lastupdate&reportSortDirection=desc&refreshFlatview=true">#application.rbFactory.getKeyValue(session.rb,"dashboard.mydrafts")#<cfif draftCount> <span class="badge badge-important">#draftCount#</span></cfif></a>

<cfset draftCount=$.getBean('contentManager').getMySubmissionsCount(session.siteid)>
<a class="btn"  href="./?muraAction=cArch.list&moduleid=00000000000000000000000000000000000&activeTab=1&report=mysubmissions&siteID=#session.siteid#&reportSortby=duedate&reportSortDirection=desc&refreshFlatview=true">#application.rbFactory.getKeyValue(session.rb,"dashboard.mysubmissions")#<cfif draftCount> <span class="badge badge-important">#draftCount#</span></cfif></a>

<cfset draftCount=$.getBean('contentManager').getMyApprovalsCount(session.siteid)>
<a class="btn"  href="./?muraAction=cArch.list&moduleid=00000000000000000000000000000000000&activeTab=1&report=myapprovals&siteID=#session.siteid#&reportSortby=duedate&reportSortDirection=desc&refreshFlatview=true">#application.rbFactory.getKeyValue(session.rb,"dashboard.myapprovals")#<cfif draftCount> <span class="badge badge-important">#draftCount#</span></cfif></a>

<cfif $.siteConfig('hasChangesets')
	and application.permUtility.getModulePerm('00000000000000000000000000000000014',rc.siteid) 
	and application.permUtility.getModulePerm('00000000000000000000000000000000000',rc.siteid)>

	<cfset rsChangesets=application.changesetManager.getQuery(siteID=$.event('siteID'),published=0,sortby="PublishDate")>
	
	<cfset queryAddColumn(rsChangesets, "pending", 'integer', [])>

	<cfloop query="rsChangesets">
		<cfset querySetCell(rsChangesets, "pending", $.getBean('changesetManager').hasPendingApprovals(rsChangesets.changesetid), rsChangesets.currentrow)>
	</cfloop>

	<cfquery name="totalpending" dbtype="query">
		select sum(pending) as totalpending from rsChangesets
	</cfquery>

	<cfif rsChangesets.recordcount>	
		<div class="btn-group">
		  <a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
		    #application.rbFactory.getKeyValue(session.rb,"dashboard.pendingchangesets")
		    #<cfif totalpending.totalpending> <span class="badge badge-important">#totalpending.totalpending#</span></cfif>
		    <span class="caret"></span>
		  </a>
		  <ul class="dropdown-menu">
		   	<cfloop query="rsChangesets">
				<li>
					<a href="./?muraAction=cChangesets.assignments&changesetID=#rsChangesets.changesetID#&siteid=#session.siteid#">
						#esapiEncode('html',rsChangesets.name)#
						<cfif isDate(rsChangesets.publishDate)> (#LSDateFormat(rsChangesets.publishDate,session.dateKeyFormat)#)</cfif><cfif rsChangesets.pending> <span class="badge badge-important">#rsChangesets.pending#</span></cfif>
					</a>
				</li>
			</cfloop>
		  </ul>
		</div>
	</cfif>
</cfif>

</div>
</cfoutput>

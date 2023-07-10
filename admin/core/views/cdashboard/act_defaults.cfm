<!--- license goes here --->

<cfsilent>

	<cfif not application.configBean.getSessionHistory() or application.configBean.getSessionHistory() gte 180>
			<cfparam name="rc.span" default="30">
	<cfelse>
			<cfparam name="rc.span" default="#application.configBean.getSessionHistory()#">
	</cfif>

	<cfparam name="rc.threshold" default="1">

	<cfset rc.stopDate=LSDateFormat(now(),session.dateKeyFormat)/>
	<cfset rc.startDate=LSDateFormat(dateAdd("d",-rc.span,now()),session.dateKeyFormat) />
	<cfset spanType="d" />
	<cfset spanUnits=rc.span />
	<cfset session.dashboardSpan=rc.span />
</cfsilent>

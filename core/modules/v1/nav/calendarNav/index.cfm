<!--- License goes here --->
<cfsilent>
<!--- set this to the number of months back you would like to display --->
<cfparam name="request.sortBy" default=""/>
<cfparam name="request.sortDirection" default=""/>
<cfparam name="request.day" default="#day(now())#"/>
<cfset targetFormat='list'>
<cfset $.addToHTMLHeadQueue('nav/calendarNav/htmlhead/htmlhead.cfm')>
<cfif not isValid('uuid',arguments.objectid)>
	<cfset variables.crumbIterator=variables.$.content().getCrumbIterator()>
	<cfloop condition="variables.crumbIterator.hasNext()">
		<cfset variables.crumb=variables.crumbIterator.next()>
		<cfif listFindNoCase('Folder,Calendar',variables.crumb.getType())>
			<cfset arguments.objectid=variables.crumb.getContentID()>
			<cfif variables.crumb.getType() eq 'Calendar'>
				<cfset targetFormat=variables.$.content().getObjectParam('format')>
				<cfif not len(targetFormat)>
					<cfset targetFormat='Calendar'>
				</cfif>
			</cfif>
			<cfbreak>
		</cfif>
	</cfloop>
<cfelseif variables.$.content('contentid') neq arguments.objectid>
	<cfset targetContent=variables.$.getBean('content').loadBy(contentid=arguments.objectid)>
	<cfif targetContent.getType() eq 'Calendar'>
		<cfset targetFormat=targetContent.getObjectParam('format')>
		<cfif not len(targetFormat)>
			<cfset targetFormat='Calendar'>
		</cfif>
	</cfif>
<cfelseif variables.$.content('type') eq 'Calendar'>
	<cfset targetFormat=variables.$.content().getObjectParam('format')>
	<cfif not len(targetFormat)>
		<cfset targetFormat='Calendar'>
	</cfif>
</cfif>
</cfsilent>
<cfif targetFormat neq 'Calendar'>
<cf_CacheOMatic key="#arguments.object##$.event('siteid')##arguments.objectid##$.event('month')##$.event('year')#" nocache="#$.event('nocache')#">
<cfsilent>
<cfset navTools=new navTools($)>
<cfset navID=arguments.objectID>
<cfquery datasource="#application.configBean.getDatasource()#"
		username="#application.configBean.getDBUsername()#"
		password="#application.configBean.getDBPassword()#"
		name="rsSection">
		select filename,menutitle,type from tcontent where siteid=<cfqueryparam value="#$.event('siteID')#" cfsqltype="varchar"> and contentid=<cfqueryparam value="#arguments.objectid#" cfsqltype="varchar"> and approved=1 and active=1 and display=1
</cfquery>

<cfset navPath="#$.siteConfig('context')##getURLStem($.event('siteID'),rsSection.filename)#">
<cfset navMonth=request.month >
<cfset navYear=request.year >
<cfset navDay=request.day >
<cfif rsSection.type eq "Folder">
	<cfset navType = "releaseMonth">
<cfelse>
	<cfset navType = "CalendarMonth">
</cfif>
</cfsilent>
<cfoutput>
<nav id="svCalendarNav" class="mura-calendar mura-calendar-nav #this.navCalendarWrapperClass# ">
<cfset navTools.setParams(navMonth,navDay,navYear,navID,navPath,navType) />
#navTools.dspMonth()#
</nav>
</cfoutput>
</cf_CacheOMatic>
</cfif>

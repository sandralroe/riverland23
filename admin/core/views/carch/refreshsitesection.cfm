<!--- license goes here --->
<cfset request.layout=false>
<cfset event=request.event>
<cfparam name="session.copyContentID" default="">
<cfparam name="session.copySiteID" default="">
<cfparam name="session.copyAll" default="false">
<cfparam name="session.openSectionList" default="">
<cfparam name="rc.sorted" default="false" />

<cfset data=structNew()>

<cfif not isDefined("rc.sortby") or rc.sortby eq "">
	<cfset rc.sortBy=rc.rstop.sortBy>
</cfif>

<cfif not isDefined("rc.sortdirection") or rc.sortdirection eq "">
	<cfset rc.sortdirection=rc.rstop.sortdirection>
</cfif>

<cfset variables.pluginEvent=createObject("component","mura.event").init(event.getAllValues())/>
<cfset request.tabAssignments=$.getBean("user").loadBy(userID=session.mura.userID, siteID=session.mura.siteID).getContentTabAssignments()>
<cfset request.hasPublishingTab=not len(request.tabAssignments) or listFindNocase(request.tabAssignments,'Publishing')>
<cfset request.hasLayoutObjectsTab=not len(request.tabAssignments) or listFindNocase(request.tabAssignments,'Layout & Objects') or listFindNocase(request.tabAssignments,'Layout')>	
<cfset request.rowNum=0>
<cfset request.menulist=rc.contentID>
<cfset crumbdata=application.contentManager.getCrumbList(rc.contentID,rc.siteid)>
<cfset perm=application.permUtility.getnodePerm(crumbdata)>
<cfset r=application.permUtility.setRestriction(crumbdata).restrict>
<cfset rsNext=application.contentManager.getNest(rc.contentID,rc.siteid,rc.sortBy,rc.sortDirection)>

<cfsavecontent variable="data.html">
<cf_dsp_nest topid="#rc.contentID#" parentid="#rc.contentID#"  rsnest="#rsNext#" locking="#application.settingsManager.getSite(rc.siteid).getlocking()#" nestlevel="1" perm="#perm#" siteid="#rc.siteid#" moduleid="#rc.moduleid#" restricted="#r#" viewdepth="1" nextn="#session.mura.nextN#" startrow="#rc.startrow#" sortBy="#rc.sortBy#" sortDirection="#rc.sortDirection#" pluginEvent="#pluginEvent#" muraScope="#rc.$#" isSectionRequest="true">
</cfsavecontent>

<cfoutput>#createObject("component","mura.json").encode(data)#</cfoutput>


 <!--- license goes here --->
<cfset request.layout=false>
<cfset event=request.event>
<cfparam name="session.copyContentID" default="">
<cfparam name="session.copySiteID" default="">
<cfparam name="session.copyAll" default="false">
<cfparam name="session.openSectionList" default="">
<cfparam name="rc.sorted" default="false" />
<cfset sectionid=rc.contentid>
<cfset sectionFound=listFind(session.openSectionList,sectionid)>

<cfif not sectionFound>

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
<cfset request.menulist=sectionid>
<cfset crumbdata=application.contentManager.getCrumbList(sectionid,rc.siteid)>
<cfset perm=application.permUtility.getnodePerm(crumbdata)>
<cfset r=application.permUtility.setRestriction(crumbdata).restrict>
<cfset rsNext=application.contentManager.getNest(sectionid,rc.siteid,rc.sortBy,rc.sortDirection)>

<cfset session.openSectionList=listAppend(session.openSectionList,sectionid)>

<cfsavecontent variable="data.html">
<cf_dsp_nest topid="#esapiEncode('html_attr',sectionid)#" parentid="#esapiEncode('html_attr',sectionid)#"  rsnest="#rsNext#" locking="#application.settingsManager.getSite(rc.siteid).getlocking()#" nestlevel="1" perm="#perm#" siteid="#rc.siteid#" moduleid="#esapiEncode('html_attr',rc.moduleid)#" restricted="#r#" viewdepth="1" nextn="#session.mura.nextN#" startrow="#esapiEncode('html_attr',rc.startrow)#" sortBy="#esapiEncode('html_attr',rc.sortBy)#" sortDirection="#esapiEncode('html_attr',rc.sortDirection)#" pluginEvent="#pluginEvent#" isSectionRequest="true" muraScope="#rc.$#">
</cfsavecontent>

<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#$.getBean('jsonSerializer').serialize(data)#</cfoutput><cfabort>

<cfelse>
	<cfset session.openSectionList=listDeleteAt(session.openSectionList,sectionFound)>
</cfif>

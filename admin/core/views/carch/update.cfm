 <!--- license goes here --->
<cfset request.layout=false>
<cfif isDefined("url.qqfile")>
<cfoutput>{success:true}</cfoutput>
<cfabort>
<cfelseif rc.ajaxrequest>
<cfif StructIsEmpty(rc.contentBean.getErrors())>
<cfoutput>{success:true,location:<cfif rc.contentBean.getActive() and rc.contentBean.getIsOnDisplay()>
	'#esapiEncode('javascript',rc.contentBean.getURL(useEditRoute=true))#'
<cfelse>
	'#esapiEncode('javascript',rc.contentBean.getURL(queryString="previewid=" & rc.contentBean.getContentHistID(),useEditRoute=true))#'
</cfif>}</cfoutput>
<cfelse>
<cfset csrfTokens=$.generateCSRFTokens(context=rc.contentBean.getContentHistID() & 'add')>
<cfoutput>{success:false,
		errors:#serializeJSON(rc.contentBean.getErrors())#,
		csrf_token: '#csrfTokens.token#',
		csrf_token_expires: '#csrfTokens.expires#'
}</cfoutput><cfabort>
</cfif>
<cfelseif rc.action eq 'multiFileUpload'>
<cfoutput>success</cfoutput>
<cfabort>
<cfelseif not structIsEmpty(rc.contentBean.getErrors())>
	<cfset request.layout=true>
	<cfif rc.closeCompactDisplay eq "true">
		<cfset rc.compactDisplay=true>
	</cfif>
	<cfset session.mura.editBean=rc.contentBean>
	<cfif not isDate(session.mura.editBean.getLastUpdate())>
		<cfset session.mura.editBean.setLastUpdate(now())>
	</cfif>
	<cfset rc.contentHistID=rc.contentBean.getContentHistID()>
  	<cfset rc.contentID=rc.contentBean.getContentID()>
	<cfset rc.rsCount=application.contentManager.getItemCount(rc.contentid,rc.siteid) />
  	<cfset rc.rsPageCount=application.contentManager.getPageCount(rc.siteid) />
  	<cfset rc.rsRestrictGroups=application.contentUtility.getRestrictGroups(rc.siteid) />
  	<cfset rc.rsTemplates=application.contentUtility.getTemplates(rc.siteid,rc.type) />

	<cfif not rc.contentBean.getIsNew()>
  		<cfset rc.crumbData=application.contentManager.getCrumbList(rc.contentID,rc.siteid)/>
  	<cfelse>
  		<cfset rc.crumbData=application.contentManager.getCrumbList(rc.parentID,rc.siteid)/>
  	</cfif>

  	<cfset rc.rsCategoryAssign=application.contentManager.getCategoriesByHistID(rc.contenthistID) />

  	<cfset rsCategories=application.categoryManager.getCategoriesBySiteID(rc.siteid) />

	<cfloop query="rsCategories">
		<cfset catTrim=replace(rsCategories.categoryID,'-','','ALL')>
		<cfset currentValue=rc.contentBean.getValue("categoryAssign#catTrim#")>

		<cfif len(currentValue)>
			<cfset queryAddRow(rc.rsCategoryAssign, 1)>
			<cfset querySetCell(rc.rsCategoryAssign,
				"categoryID",
				rsCategories.categoryID,
				rc.rsCategoryAssign.recordcount
			)>
			<cfset querySetCell(rc.rsCategoryAssign,
				"contentID",
				rc.contentID,
				rc.rsCategoryAssign.recordcount
			)>

			<cfset querySetCell(rc.rsCategoryAssign,
				"contentHistID",
				rc.contentHistID,
				rc.rsCategoryAssign.recordcount
			)>

			<cfset querySetCell(rc.rsCategoryAssign,
				"siteID",
				rc.siteID,
				rc.rsCategoryAssign.recordcount
			)>

			<cfset querySetCell(rc.rsCategoryAssign,
				"name",
				rsCategories.name,
				rc.rsCategoryAssign.recordcount
			)>

			<cfset querySetCell(rc.rsCategoryAssign,
				"filename",
				rsCategories.filename,
				rc.rsCategoryAssign.recordcount
			)>

			<cfset querySetCell(
						rc.rsCategoryAssign,
						"isFeature",
						0,
						rc.rsCategoryAssign.recordcount
					)>

			<cfif currentValue eq 1>
				<cfset querySetCell(
						rc.rsCategoryAssign,
						"isFeature",
						1,
						rc.rsCategoryAssign.recordcount
					)>
			<cfelseif currentValue eq 2 >
				<cfset schedule.featureStart=rc.contentBean.getValue('featureStart#catTrim#') />
				<cfset schedule.starthour=rc.contentBean.getValue('starthour#catTrim#') />
				<cfset schedule.startMinute=rc.contentBean.getValue('startMinute#catTrim#') />
				<cfset schedule.startDayPart=rc.contentBean.getValue('startDayPart#catTrim#') />
				<cfset schedule.featureStop=rc.contentBean.getValue('featureStop#catTrim#') />
				<cfset schedule.stopHour=rc.contentBean.getValue('stopHour#catTrim#') />
				<cfset schedule.stopMinute=rc.contentBean.getValue('stopMinute#catTrim#') />
				<cfset schedule.stopDayPart=rc.contentBean.getValue('stopDayPart#catTrim#') />


				<cfif isDate(schedule.featureStart)>
					<cfif schedule.startdaypart eq "PM">
						<cfset schedule.starthour = schedule.starthour + 12>

						<cfif schedule.starthour eq 24>
							<cfset schedule.starthour = 12>
						</cfif>
					<cfelse>
						<cfif schedule.starthour eq 12>
							<cfset schedule.starthour = 0>
						</cfif>
					</cfif>

					<cfset schedule.featureStart = createDateTime(year(schedule.featureStart), month(schedule.featureStart), day(schedule.featureStart),schedule.starthour, schedule.startMinute, "0")>

					<cfset querySetCell(
						rc.rsCategoryAssign,
						"isFeature",
						2,
						rc.rsCategoryAssign.recordcount
					)>

					<cfset querySetCell(
						rc.rsCategoryAssign,
						"featureStart",
						schedule.featureStart,
						rc.rsCategoryAssign.recordcount
					)>
				<cfelse>
					<cfset querySetCell(
						rc.rsCategoryAssign,
						"isFeature",
						1,
						rc.rsCategoryAssign.recordcount
					)>
				</cfif>

				<cfif isDate(schedule.featurestop)>
					<cfif schedule.stopdaypart eq "PM">
						<cfset schedule.stophour = schedule.stophour + 12>

						<cfif schedule.stophour eq 24>
							<cfset schedule.stophour = 12>
						</cfif>
					<cfelse>
						<cfif schedule.stophour eq 12>
							<cfset schedule.stophour = 0>
						</cfif>
					</cfif>

					<cfset schedule.featurestop = createDateTime(year(schedule.featurestop), month(schedule.featurestop), day(schedule.featurestop),schedule.stophour, schedule.stopMinute, "0")>
					<cfset querySetCell(
						rc.rsCategoryAssign,
						"featureStop",
						schedule.featurestop,
						rc.rsCategoryAssign.recordcount
					)>
				</cfif>
			</cfif>
		</cfif>
	</cfloop>

	<cfif rc.moduleID eq '00000000000000000000000000000000000'>
		<!--- select contenthistid, contentid, objectid, siteid, object, name, columnid, orderno, params
		--->
		<cfloop index="r" from="1" to="#application.settingsManager.getSite(rc.siteid).getcolumncount()#">
			<cfset request["rsContentObjects#r#"]=queryNew("contenthistid, contentid, objectid, siteid, object, name, columnid, orderno, params")>
			<cfif isdefined("rc.objectList#r#")>
				<cfloop list="#rc['objectList#r#']#" index="i" delimiters="^">
					<cfset queryAddRow(request["rsContentObjects#r#"], 1)>
					<!---
					tcontentobjects (contentid,contenthistid,object,name,objectid,orderno,siteid,columnid,params)
					--->
					<cfset querySetCell(
							request["rsContentObjects#r#"],
							"contentHistID",
							rc.contentBean.getContentHistID(),
							request["rsContentObjects#r#"].recordcount
						)>
					<cfset querySetCell(
							request["rsContentObjects#r#"],
							"contentID",
							rc.contentBean.getContentID(),
							request["rsContentObjects#r#"].recordcount
						)>
					<cfset querySetCell(
							request["rsContentObjects#r#"],
							"object",
							listgetat(i,1,"~"),
							request["rsContentObjects#r#"].recordcount
						)>
					<cfset querySetCell(
							request["rsContentObjects#r#"],
							"name",
							listgetat(i,2,"~"),
							request["rsContentObjects#r#"].recordcount
						)>
					<cfset querySetCell(
							request["rsContentObjects#r#"],
							"objectid",
							listgetat(i,3,"~"),
							request["rsContentObjects#r#"].recordcount
						)>
					<cfset querySetCell(
							request["rsContentObjects#r#"],
							"orderno",
							request["rsContentObjects#r#"].recordcount,
							request["rsContentObjects#r#"].recordcount
						)>
					<cfset querySetCell(
						request["rsContentObjects#r#"],
						"siteID",
						rc.siteid,
						request["rsContentObjects#r#"].recordcount
						)>
					<cfset querySetCell(
						request["rsContentObjects#r#"],
						"columnID",
						r,
						request["rsContentObjects#r#"].recordcount
						)>
					<cfif listLen(i,"~") gt 3 >
						<cfset querySetCell(
							request["rsContentObjects#r#"],
							"params",
							listgetat(i,4,"~"),
							request["rsContentObjects#r#"].recordcount
							)>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
	</cfif>


	<cfif len(rc.contentBean.getValue("relatedContentID"))>
		<cfset feed=application.serviceFactory.getBean("feed")>
		<cfset feed.setSiteID(rc.siteID)>
		<cfset feed.setMaxItems(0)>
		<cfset feed.setLiveOnly(0)>
		<cfset feed.addParam(field="tcontent.contentID",condition="in",criteria=rc.contentBean.getValue("relatedContentID"))>
		<cfset rc.rsRelatedContent=feed.getQuery() />
	<cfelse>
		<cfset rc.rsRelatedContent=queryNew("empty")>
	</cfif>
	<cfinclude template="edit.cfm">
<cfelse>
	<cfset structDelete(session.mura,"editBean")>
	<cfinclude template="dsp_close_compact_display.cfm">
</cfif>

<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides content feed CRUD functionality">

	<cfset variables.fieldList="feedID,siteID,dateCreated,lastUpdate,lastUpdateBy,name,altName,lang,maxitems,isActive,isPublic,isDefault,description,allowHTML,isFeaturesOnly,restricted,restrictGroups,version,channelLink,type,sortBy,sortDirection,nextn,displayName,displayRatings,displayComments,parentID,remoteID,remoteSourceURL,remotePubDate,imageSize,imageHeight,imageWidth,displayList,showNavOnly,showExcludeSearch,viewalllink,viewalllabel,autoimport,isLocked,CssClass,useCategoryIntersect,contentpoolid,authtype">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="utility" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfset variables.utility=arguments.utility />
		<cfreturn this />
	</cffunction>

	<cffunction name="create" output="false">
		<cfargument name="feedBean" type="any" />

		<cfquery>
			insert into tcontentfeeds (feedID,siteid,dateCreated,lastupdate,lastupdateBy,name, altName, description,
			isActive,isPublic,isDefault,lang,maxItems,allowHTML,isFeaturesOnly,restricted,restrictGroups,version,
			ChannelLink,type,ParentID,sortBy,sortDirection,nextN,displayName,displayRatings,displayComments,remoteID,remoteSourceURL, remotePubDate,
			imageSize,imageHeight,imageWidth,displayList,showNavOnly,showExcludeSearch,viewalllink,viewalllabel,autoimport,isLocked,CssClass,useCategoryIntersect,contentpoolid,authtype)
			values (
			<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.feedBean.getfeedID()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getSiteID() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getsiteID()#">,
			<cfif isDate(arguments.feedBean.getDateCreated()) ><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.feedBean.getDateCreated()#"><cfelse>null</cfif>,
			<cfif isDate(arguments.feedBean.getLastUpdate()) ><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.feedBean.getLastUpdate()#"><cfelse>null</cfif>,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getLastUpdateBy() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getLastUpdateBy()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getName() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getName()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getAltName() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getAltName()#">,
			<cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.feedBean.getDescription() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getDescription()#">,
			#arguments.feedBean.getIsActive()#,
			#arguments.feedBean.getIsPublic()#,
			#arguments.feedBean.getIsDefault()#,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getLang() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getLang()#">,
			#arguments.feedBean.getMaxItems()#,
			#arguments.feedBean.getAllowHTML()#,
			#arguments.feedBean.getIsFeaturesOnly()#,
			#arguments.feedBean.getRestricted()#,
			<cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.feedBean.getRestrictGroups() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getRestrictGroups()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getVersion() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getVersion()#">,
			<cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.feedBean.getChannelLink() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getChannelLink()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getType() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getType()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getParentID() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getParentID()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getSortBy() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getSortBy()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getSortDirection() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getSortDirection()#">,
			#arguments.feedBean.getNextN()#,
			#arguments.feedBean.getDisplayName()#,
			#arguments.feedBean.getDisplayRatings()#,
			#arguments.feedBean.getDisplayComments()#,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getRemoteID() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getRemoteID()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getRemoteSourceURL() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getRemoteSourceURL()#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" null="#iif(arguments.feedBean.getRemotePubDate() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getRemotePubDate()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getImageSize() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getImageSize()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getImageHeight() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getImageHeight()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getImageWidth() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getImageWidth()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getDisplayList() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getDisplayList()#">,
			#arguments.feedBean.getShowNavOnly()#,
			#arguments.feedBean.getShowExcludeSearch()#,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getViewAllLink() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getViewAllLink()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getViewAllLabel() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getViewAllLabel()#">,
			#arguments.feedBean.getAutoImport()#,
			#arguments.feedBean.getIsLocked()#,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getCssClass() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getCssClass()#">,
			#arguments.feedBean.getUseCategoryIntersect()#,
			<cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.feedBean.getContentPoolID() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getContentPoolID()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getAuthType() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getAuthType()#">
			)
		</cfquery>

		<cfset createItems(arguments.feedBean.getfeedID(),arguments.feedBean.getcontentID(),'contentID') />
		<cfset createItems(arguments.feedBean.getfeedID(),arguments.feedBean.getCategoryID(),'categoryID') />
		<cfset createAdvancedParams(arguments.feedBean.getfeedID(),arguments.feedBean.getAdvancedParams()) />

	</cffunction>

	<cffunction name="read" output="false">
		<cfargument name="feedID" type="string" />
		<cfargument name="feedBean" default="" />
		<cfset var rs ="" />
		<cfset var bean=arguments.feedBean />

		<cfif not isObject(bean)>
			<cfset bean=getBean("feed") />
		</cfif>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			Select
			#variables.fieldList#
			from tcontentfeeds where
			feedID= <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.feedID#">
		</cfquery>

		<cfif rs.recordcount>
		<cfset bean.set(rs) />
		<cfset bean.setcontentID(readItems(rs.feedID,"contentID")) />
		<cfset bean.setCategoryID(readItems(rs.feedID,"categoryID")) />
		<cfset bean.setAdvancedParams(readAdvancedParams(rs.feedID)) />
		<cfset bean.setIsNew(0)>
		</cfif>

		<cfreturn bean />
	</cffunction>

	<cffunction name="readByName" output="false">
		<cfargument name="name" type="string" />
		<cfargument name="siteid" type="string" />
		<cfargument name="feedBean" default="" />
		<cfset var rs ="" />
		<cfset var beanArray=arrayNew(1)>
		<cfset var bean=arguments.feedBean />

		<cfif not isObject(bean)>
			<cfset bean=getBean("feed") />
		</cfif>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			Select
			#variables.fieldList#
			from tcontentfeeds where
			name= <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.name#">
			and siteid=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.siteid#">
		</cfquery>

		<cfif rs.recordcount gt 1>
			<cfloop query="rs">
				<cfset bean=getBean("feed").set(variables.utility.queryRowToStruct(rs,rs.currentrow))>
				<cfset bean.setcontentID(readItems(rs.feedID,"contentID")) />
				<cfset bean.setCategoryID(readItems(rs.feedID,"categoryID")) />
				<cfset bean.setAdvancedParams(readAdvancedParams(rs.feedID)) />
				<cfset bean.setIsNew(0)>
				<cfset arrayAppend(beanArray,feedBean)>
			</cfloop>
			<cfreturn beanArray>
		<cfelseif rs.recordcount>
			<cfset bean.set(rs) />
			<cfset bean.setcontentID(readItems(rs.feedID,"contentID")) />
			<cfset bean.setCategoryID(readItems(rs.feedID,"categoryID")) />
			<cfset bean.setAdvancedParams(readAdvancedParams(rs.feedID)) />
			<cfset bean.setIsNew(0)>
		<cfelse>
			<cfset bean.setSiteID(arguments.siteID)>
		</cfif>

		<cfreturn bean />
	</cffunction>

	<cffunction name="readByRemoteID" output="false">
		<cfargument name="remoteID" type="string" />
		<cfargument name="siteid" type="string" />
		<cfargument name="feedBean" default="" />
		<cfset var rs ="" />
		<cfset var beanArray=arrayNew(1)>
		<cfset var bean=arguments.feedBean />

		<cfif not isObject(bean)>
			<cfset bean=getBean("feed") />
		</cfif>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			Select
			#variables.fieldList#
			from tcontentfeeds where
			remoteID= <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.remoteID#">
			and siteid=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.siteid#">
		</cfquery>

		<cfif rs.recordcount gt 1>
			<cfloop query="rs">
				<cfset bean=getBean("feed").set(variables.utility.queryRowToStruct(rs,rs.currentrow))>
				<cfset bean.setcontentID(readItems(rs.feedID,"contentID")) />
				<cfset bean.setCategoryID(readItems(rs.feedID,"categoryID")) />
				<cfset bean.setAdvancedParams(readAdvancedParams(rs.feedID)) />
				<cfset bean.setIsNew(0)>
				<cfset arrayAppend(beanArray,bean)>
			</cfloop>
			<cfreturn beanArray>
		<cfelseif rs.recordcount>
			<cfset bean.set(rs) />
			<cfset bean.setcontentID(readItems(rs.feedID,"contentID")) />
			<cfset bean.setCategoryID(readItems(rs.feedID,"categoryID")) />
			<cfset bean.setAdvancedParams(readAdvancedParams(rs.feedID)) />
			<cfset bean.setIsNew(0)>
		<cfelse>
			<cfset bean.setSiteID(arguments.siteID)>
		</cfif>

		<cfreturn bean />
	</cffunction>

	<cffunction name="update" output="false" >
		<cfargument name="feedBean" type="any" />

		<cfquery>
			update tcontentfeeds set
			lastUpdate = <cfif isDate(arguments.feedBean.getLastUpdate()) ><cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.feedBean.getLastUpdate()#"><cfelse>null</cfif>,
			lastupdateBy = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getLastUpdateBy() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getLastUpdateBy()#">,
			name = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getName() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getName()#">,
			altName = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getAltName() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getAltName()#">,
			isActive = #arguments.feedBean.getIsActive()#,
			isDefault = #arguments.feedBean.getIsDefault()#,
			isPublic = #arguments.feedBean.getIsPublic()#,
			Description= <cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.feedBean.getDescription() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getDescription()#">,
			lang = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getLang() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getLang()#">,
			maxItems = #arguments.feedBean.getMaxItems()#,
			allowHTML = #arguments.feedBean.getAllowHTML()#,
			isFeaturesOnly = #arguments.feedBean.getIsFeaturesOnly()#,
			restricted = #arguments.feedBean.getRestricted()#,
			RestrictGroups= <cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.feedBean.getRestrictGroups() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getRestrictGroups()#">,
			version = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getVersion() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getVersion()#">,
			ChannelLink = <cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.feedBean.getChannelLink() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getChannelLink()#">,
			type = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getType() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getType()#">,
			parentID = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getParentID() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getParentID()#">,
			sortBy = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getSortBy() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getSortBy()#">,
			sortDirection = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getSortDirection() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getSortDirection()#">,
			nextN=#arguments.feedBean.getNextN()#,
			displayName = #arguments.feedBean.getDisplayName()#,
			displayRatings = #arguments.feedBean.getDisplayRatings()#,
			displayComments = #arguments.feedBean.getDisplayComments()#,
			remoteID= <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getRemoteID() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getRemoteID()#">,
			remoteSourceURL= <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getRemoteSourceURL() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getRemoteSourceURL()#">,
			remotePubDate= <cfqueryparam cfsqltype="cf_sql_timestamp" null="#iif(arguments.feedBean.getRemotePubDate() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getRemotePubDate()#">,
			imageSize=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getImageSize() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getImageSize()#">,
			imageHeight=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getImageHeight() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getImageHeight()#">,
			imageWidth=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getImageWidth() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getImageWidth()#">,
			displayList=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getDisplayList() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getDisplayList()#">,
			showNavOnly=#arguments.feedBean.getShowNavOnly()#,
			showExcludeSearch=#arguments.feedBean.getShowExcludeSearch()#,
			viewAllLink=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getViewAllLink() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getViewAllLink()#">,
			viewAllLabel=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getViewAllLabel() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getViewAllLabel()#">,
			autoimport=#arguments.feedBean.getAutoImport()#,
			isLocked=#arguments.feedBean.getIsLocked()#,
			CssClass=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getCssClass() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getCssClass()#">,
			useCategoryIntersect=#arguments.feedBean.getUseCategoryIntersect()#,
			contentpoolid=<cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.feedBean.getContentPoolID() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getContentPoolID()#">,
			authtype=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.feedBean.getAuthType() neq '',de('no'),de('yes'))#" value="#arguments.feedBean.getAuthType()#">
			where feedID =<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.feedBean.getfeedID()#">
		</cfquery>

		<cfset deleteItems(arguments.feedBean.getfeedID()) />
		<cfset createItems(arguments.feedBean.getfeedID(),arguments.feedBean.getcontentID(),'contentID') />
		<cfset createItems(arguments.feedBean.getfeedID(),arguments.feedBean.getCategoryID(),'categoryID') />
		<cfset createAdvancedParams(arguments.feedBean.getfeedID(),arguments.feedBean.getAdvancedParams()) />
	</cffunction>

	<cffunction name="delete" output="false" >
		<cfargument name="feedID" type="String" />

		<cfquery>
			delete from tcontentfeeds
			where feedID = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.feedID#">
		</cfquery>
	</cffunction>

	<cffunction name="createItems" output="false">
		<cfargument name="feedID" type="string" required="yes" default="" />
		<cfargument name="itemList" type="string" required="yes" default="" />
		<cfargument name="type" type="string" required="yes" default="" />

		<cfset var I = ""/>

		<cfloop list="#arguments.itemList#" index="I">
			<cfquery>
				insert into tcontentfeeditems (feedID,itemID,type)
				values (
				<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.feedID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar"  value="#I#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.type neq '',de('no'),de('yes'))#" value="#arguments.type#">
				)
			</cfquery>
		</cfloop>
	</cffunction>

	<cffunction name="deleteItems" output="false" >
		<cfargument name="feedID" type="String" />

		<cfquery>
			delete from tcontentfeeditems
			where feedID =<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.feedID#">
		</cfquery>
	</cffunction>

	<cffunction name="deleteItem" output="false" >
		<cfargument name="feedID" type="String" />
		<cfargument name="itemID" type="String" />

		<cfquery>
			delete from tcontentfeeditems
			where feedID = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.feedID#"> and itemID = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.itemID#">
		</cfquery>
	</cffunction>

	<cffunction name="readItems" output="false">
		<cfargument name="feedID" type="string" required="yes" default="" />
		<cfargument name="type" type="string" required="yes" default="" />

		<cfset var rs =""/>
		<cfset var ItemList =""/>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			select itemID from tcontentfeeditems
			where feedID=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.feedID#"> and type = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.type#">
		</cfquery>

		<cfset ItemList=valueList(rs.itemID) />

		<cfreturn ItemList />
	</cffunction>

	<cffunction name="readAdvancedParams" output="false">
		<cfargument name="feedID" type="string" required="yes" default="" />

		<cfset var rs =""/>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			select * from tcontentfeedadvancedparams
			where feedID=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.feedID#"> order by param
		</cfquery>

		<cfreturn rs />
	</cffunction>

	<cffunction name="createAdvancedParams" output="false">
		<cfargument name="feedID" type="any" required="yes" default="" />
		<cfargument name="params" type="any" required="yes" default="" />

		<cfset deleteAdvancedParams(arguments.feedID) />

		<cfif arguments.params.recordcount>
			<cfloop query="arguments.params">
				<cfquery>
					insert into tcontentfeedadvancedparams (feedID,paramID,param,relationship,field,dataType,<cfif variables.configBean.getDbType() eq "mysql">`condition`<cfelse>condition</cfif>,criteria)
					values (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.feedID#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#createUUID()#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.params.param#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.params.relationship#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.params.field#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.params.dataType#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.params.condition#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.params.criteria#">
					)
				</cfquery>
			</cfloop>
		</cfif>

	</cffunction>

	<cffunction name="deleteAdvancedParams" output="false" >
		<cfargument name="feedID" type="String" />

		<cfquery>
			delete from tcontentfeedadvancedparams
			where feedID = <cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.feedID#">
		</cfquery>
	</cffunction>

</cfcomponent>

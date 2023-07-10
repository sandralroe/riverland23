<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides category gateway queries">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="settingsManager" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfset variables.settingsManager=arguments.settingsManager />
		<cfreturn this />
	</cffunction>

	<cffunction name="getCategories" output="false">
		<cfargument name="siteID" type="String">
		<cfargument name="parentID" type="String">
		<cfargument name="keywords"  type="string" required="true" default=""/>
		<cfargument name="activeOnly" type="boolean" required="true" default="false">
		<cfargument name="InterestsOnly" type="boolean" required="true" default="false">

		<cfset var rsCategories ="" />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsCategories')#">
			select tcontentcategories.siteID,tcontentcategories.categoryID,tcontentcategories.name,tcontentcategories.filename,tcontentcategories.urltitle,tcontentcategories.parentID,tcontentcategories.isActive,tcontentcategories.isInterestGroup,tcontentcategories.isOpen, count(tcontentcategories2.parentid) as hasKids
			,tcontentcategories.restrictGroups,tcontentcategories.isfeatureable from
			tcontentcategories left join tcontentcategories tcontentcategories2 ON
			(tcontentcategories.categoryID = tcontentcategories2.parentID)
			where tcontentcategories.siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.settingsManager.getSite(arguments.siteID).getCategoryPoolID()#" />
			and tcontentcategories.parentID <cfif arguments.parentID neq ''> = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.parentID#" /><cfelse> is null </cfif>
			<cfif arguments.keywords neq ''>and tcontentcategories.name like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keywords#%" /></cfif>
			<cfif arguments.activeOnly>and tcontentcategories.isActive=1</cfif>
			<cfif arguments.InterestsOnly>and tcontentcategories.isInterestGroup=1</cfif>
			group by tcontentcategories.siteID,tcontentcategories.categoryID,tcontentcategories.name,tcontentcategories.filename,tcontentcategories.urltitle,tcontentcategories.parentID,tcontentcategories.isActive,tcontentcategories.isInterestGroup,tcontentcategories.isOpen,tcontentcategories.restrictGroups, tcontentcategories.isfeatureable
			order by tcontentcategories.name
		</cfquery>

		<cfreturn rsCategories />
	</cffunction>

	<cffunction name="getInterestGroupCount" output="false">
		<cfargument name="siteID" type="String">
		<cfargument name="activeOnly" type="boolean" required="true" default="false">

		<cfset var rsInterestGroupCount ="" />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsInterestGroupCount')#">
			select count(*) as theCount from tcontentcategories
			where siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.settingsManager.getSite(arguments.siteID).getCategoryPoolID()#" />
			and isInterestGroup=1
			<cfif arguments.activeOnly>
			and isactive=1
			</cfif>
		</cfquery>

		<cfreturn rsInterestGroupCount.theCount />
	</cffunction>

	<cffunction name="getCategoryCount" output="false">
		<cfargument name="siteID" type="String">
		<cfargument name="activeOnly" type="boolean" required="true" default="false">

		<cfset var rsCategoryCount ="" />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsCategoryCount')#">
			select count(*) as theCount from tcontentcategories
			where siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.settingsManager.getSite(arguments.siteID).getCategoryPoolID()#" />
			<cfif arguments.activeOnly>
			and isactive=1
			</cfif>
		</cfquery>

		<cfreturn rsCategoryCount.theCount />
	</cffunction>

	<cffunction name="getCategoriesBySiteID" output="false">
		<cfargument name="siteID" type="String">
		<cfargument name="keywords"  type="string" required="true" default=""/>

		<cfset var rsCategoriesBySiteID ="" />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsCategoriesBySiteID')#">
			select * from tcontentcategories where siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.settingsManager.getSite(arguments.siteID).getCategoryPoolID()#" />
			<cfif arguments.keywords neq ''>and tcontentcategories.name like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keywords#%" /></cfif>
			order by name
		</cfquery>

		<cfreturn rsCategoriesBySiteID />
	</cffunction>

	<cffunction name="getInterestGroupsBySiteID" output="false">
		<cfargument name="siteID" type="String">
		<cfargument name="keywords"  type="string" required="true" default=""/>

		<cfset var rsInterestGroupsBySiteID ="" />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsInterestGroupsBySiteID')#">
			select * from tcontentcategories where siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#application.settingsManager.getSite(arguments.siteID).getCategoryPoolID()#" />
			and isInterestGroup=1
			<cfif arguments.keywords neq ''>and tcontentcategories.name like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.keywords#%" /></cfif>
			order by name
		</cfquery>

		<cfreturn rsInterestGroupsBySiteID />
	</cffunction>

	<cffunction name="getCategoryfeatures" output="false">
		<cfargument name="categoryBean" type="any">

		<cfset var rsCategoryfeatures ="" />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsCategoryfeatures')#">
			select tcontent.title, tcontent.releasedate, tcontent.menuTitle, tcontent.lastupdate, tcontent.summary,
			tcontent.filename, tcontent.type, tcontent.contentid, tcontent.target, tcontent.targetParams,
			tcontent.restricted, tcontent.restrictgroups, tcontent.displaystart, tcontent.displaystop, 0 as comments,
			tcontentcategoryassign.orderno,tcontent.display,tcontent.active,tcontent.approved,tcontentcategoryassign.featureStart,tcontentcategoryassign.featureStop,
			tcontentcategoryassign.isFeature,tfiles.fileSize,tfiles.fileExt, tcontent.fileID, tcontent.fileID, tcontent.credits,
			tcontent.remoteSource, tcontent.remoteURL, tcontent.remoteSourceURL, tcontent.Audience, tcontent.keyPoints
			from tcontent inner join tcontentcategoryassign
			ON (tcontent.contenthistid=tcontentcategoryassign.contenthistID)
			Left Join tfiles ON (tcontent.fileID=tfiles.fileID)
			where
			tcontent.active=1
			and tcontentcategoryassign.isFeature > 0
			and tcontentcategoryassign.categoryID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.categoryBean.getCategoryID()#" />
			order by
			<cfif arguments.categoryBean.getSortBy() neq 'orderno'>
				tcontent.#arguments.categoryBean.getSortBy()# #arguments.categoryBean.getSortDirection()#
			<cfelse>
			tcontentcategoryassign.#arguments.categoryBean.getSortBy()# #arguments.categoryBean.getSortDirection()#
			</cfif>
		</cfquery>

		<cfreturn rsCategoryfeatures />
	</cffunction>

	<cffunction name="getLiveCategoryfeatures" output="false">
		<cfargument name="categoryBean" type="any">

		<cfset var rsLiveCategoryfeatures ="" />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsLiveCategoryfeatures')#">
			select tcontent.title, tcontent.releasedate, tcontent.menuTitle, tcontent.lastupdate, tcontent.summary,
			tcontent.filename, tcontent.type, tcontent.contentid, tcontent.target, tcontent.targetParams,
			tcontent.restricted, tcontent.restrictgroups, tcontent.displaystart, tcontent.displaystop, 0 as comments,
			tcontentcategoryassign.orderno,tcontent.display,tcontent.active,tcontent.approved,tcontentcategoryassign.featureStart,tcontentcategoryassign.featureStop,
			tcontentcategoryassign.isFeature, tfiles.fileSize,tfiles.fileExt,tcontent.fileID, tcontent.credits,
			tcontent.remoteSource, tcontent.remoteURL, tcontent.remoteSourceURL, tcontent.Audience, tcontent.keyPoints
			from tcontent inner join tcontentcategoryassign
			ON (tcontent.contenthistid=tcontentcategoryassign.contenthistID)
			Left Join tfiles ON (tcontent.fileID=tfiles.fileID)
			where
			tcontent.active=1
			and tcontentcategoryassign.categoryID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.categoryBean.getCategoryID()#" />

			AND


			(tcontent.Display=1

			or

			tcontent.Display = 2

			and tcontent.DisplayStart <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#"> AND  (tcontent.DisplayStop >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#"> or tcontent.DisplayStop is null)

			)

			and

			(tcontentcategoryassign.isFeature=1

			or

			tcontentcategoryassign.isFeature = 2

			and tcontentcategoryassign.FeatureStart <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#"> AND  (tcontentcategoryassign.FeatureStop >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#"> or tcontentcategoryassign.FeatureStop is null)

			)

			order by
			<cfif arguments.categoryBean.getSortBy() neq 'orderno'>
				tcontent.#arguments.categoryBean.getSortBy()# #arguments.categoryBean.getSortDirection()#
			<cfelse>
			tcontentcategoryassign.#arguments.categoryBean.getSortBy()# #arguments.categoryBean.getSortDirection()#
			</cfif>
		</cfquery>

		<cfreturn rsLiveCategoryfeatures />
	</cffunction>

	<cffunction name="getPrivateInterestGroups" output="false">
		<cfargument name="siteid" type="string" default="" />
		<cfargument name="parentid" type="string" default="" />
		<cfset var rs = "" />
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsPrivateInterestGroups')#">
			SELECT tsettings.Site, tcontentcategories.categoryID, tcontentcategories.name,tcontentcategories.filename,tcontentcategories.urltitle,tcontentcategories.isOpen,
			count(tcontentcategories2.parentid) as hasKids
			FROM tsettings INNER JOIN tcontentcategories ON tsettings.SiteID = tcontentcategories.SiteID
			left join tcontentcategories tcontentcategories2 ON(
			tcontentcategories.categoryID = tcontentcategories2.parentID)
			WHERE tcontentcategories.isInterestGroup=1
			and tcontentcategories.parentID <cfif arguments.parentID neq ''> = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.parentID#" /><cfelse> is null </cfif>
			and tsettings.PrivateUserPoolID = '#variables.settingsManager.getSite(arguments.siteid).getPrivateUserPoolID()#'
			group by  tsettings.Site, tcontentcategories.categoryID, tcontentcategories.name,tcontentcategories.filename,tcontentcategories.urltitle,tcontentcategories.isOpen
			ORDER BY tsettings.Site, tcontentcategories.name
		</cfquery>
		<cfreturn rsPrivateInterestGroups />
	</cffunction>

	<cffunction name="getPublicInterestGroups" output="false">
		<cfargument name="siteid" type="string" default="" />
		<cfargument name="parentid" type="string" default="" />
		<cfset var rsPublicInterestGroups = "" />
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsPublicInterestGroups')#">
			SELECT tsettings.Site, tcontentcategories.categoryID, tcontentcategories.name,tcontentcategories.filename,tcontentcategories.urltitle,tcontentcategories.isOpen,
			count(tcontentcategories2.parentid) as hasKids
			FROM tsettings INNER JOIN tcontentcategories ON tsettings.SiteID = tcontentcategories.SiteID
			left join tcontentcategories tcontentcategories2 ON(
			tcontentcategories.categoryID = tcontentcategories2.parentID)
			WHERE tcontentcategories.isInterestGroup =1
			and tcontentcategories.parentID <cfif arguments.parentID neq ''> = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.parentID#" /><cfelse> is null </cfif>
			and tsettings.PublicUserPoolID = '#variables.settingsManager.getSite(arguments.siteid).getPublicUserPoolID()#'
			group by  tsettings.Site, tcontentcategories.categoryID, tcontentcategories.name,tcontentcategories.filename,tcontentcategories.urltitle,tcontentcategories.isOpen
			ORDER BY tsettings.Site, tcontentcategories.name
		</cfquery>
		<cfreturn rsPublicInterestGroups />
	</cffunction>

	<cffunction name="getCrumbQuery" output="false">
		<cfargument name="path" required="true">
		<cfargument name="siteID" required="true">
		<cfargument name="sort" required="true" default="asc">
		<cfset var rsCategoryCrumbData="">

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsCategoryCrumbData')#">
			select categoryID,siteID,dateCreated,lastUpdate,lastUpdateBy,name,isInterestGroup,parentID,isActive,isOpen,notes,sortBy,sortDirection,restrictGroups,path,remoteID,remoteSourceURL,remotePubDate,
			<cfif variables.configBean.getDBType() eq "MSSQL">
			len(Cast(path as varchar(1000))) depth
			<cfelse>
			length(path) depth
			</cfif>
			from tcontentcategories where
			categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.path#">)
			and siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#application.settingsManager.getSite(arguments.siteID).getCategoryPoolID()#"/>
			order by depth <cfif arguments.sort eq "desc">desc<cfelse>asc</cfif>
		</cfquery>

		<cfreturn rsCategoryCrumbData>
	</cffunction>

</cfcomponent>

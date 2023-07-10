<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides user favorite service level logic functionality">
	<cffunction name="init">
		<cfargument name="configBean" type="any" required="yes">
		<cfargument name="settingsManager" type="any" required="yes">

		<cfset variables.configBean=arguments.configBean>
		<cfset variables.settingsManager=arguments.settingsManager>

		<cfreturn this>
	</cffunction>

	<cffunction name="getBean" output="false">
		<cfargument name="beanName" default="favorite">
		<cfreturn super.getBean(arguments.beanName)>
	</cffunction>

	<cffunction name="getFavorites">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="favoriteType" type="string" required="yes" default="all">
		<cfargument name="siteID" type="string" required="yes">

		<cfset var rsFavorites = "" />
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsFavorites')#">
			select * from tusersfavorites
			where userID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#"/>

			<cfif favoriteType neq 'all'>
				and type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.favoriteType#"/>
				and siteID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
				order by rowNumber
			<cfelse>
				and siteID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
				order by dateCreated
			</cfif>
		</cfquery>
		<cfreturn rsFavorites />
	</cffunction>

	<cffunction name="getInternalContentFavorites" output="false">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="siteID" type="String">
		<cfargument name="type" type="String" required="false" default="">

		<cfset var rsInternalFavorites ="" />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsInternalFavorites')#">
			SELECT tusersfavorites.favoriteID, tusersfavorites.favorite, tusersfavorites.dateCreated, tcontent.title, tcontent.releasedate, tcontent.menuTitle, tcontent.lastupdate, tcontent.summary,
			tcontent.filename, tcontent.type, tcontent.contentid,
			tcontent.target,tcontent.targetParams, tcontent.restricted, tcontent.restrictgroups, tcontent.displaystart, tcontent.displaystop, tcontent.orderno,tcontent.sortBy,tcontent.sortDirection,
			tcontent.fileid, tcontent.credits, tcontent.remoteSource, tcontent.remoteSourceURL, tcontent.remoteURL,
			tfiles.fileSize,tfiles.fileExt
			FROM 	tcontent Inner Join tusersfavorites ON (tcontent.contentID=tusersfavorites.favorite
											AND tcontent.siteID=tusersfavorites.siteID)
				Left Join tfiles ON (tcontent.fileID=tfiles.fileID)
				Left Join tcontent tparent on (tcontent.parentid=tparent.contentid
											and tcontent.siteid=tparent.siteid
											and tparent.active=1)
			WHERE
			tcontent.siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
			and tusersfavorites.userid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#"/>

			<cfif len(arguments.type)>
			and tusersfavorites.type= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.type#"/>
			</cfif>

			and tcontent.active=1

			AND (
				tcontent.Display = 1
				OR
				(	tcontent.Display = 2
					and (
							(tcontent.DisplayStart <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
							AND (tcontent.DisplayStop >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#"> or tcontent.DisplayStop is null))

							OR tparent.type='Calendar'
						)
				)

				)
			ORDER BY tusersfavorites.dateCreated DESC
		</cfquery>

		<cfreturn rsInternalFavorites />


	</cffunction>

	<cffunction name="readFavorite">
		<cfargument name="favoriteID" type="string" required="yes">

		<cfset var favorite = getBean("favorite") />
		<cfset favorite.setFavoriteID(arguments.favoriteID) />
		<cfset favorite.load(argumentcollection=arguments) />

		<cfreturn favorite />
	</cffunction>

	<cffunction name="checkForFavorite" returntype="boolean">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="contentID" type="string" required="yes">
		<cfargument name="type" type="string" required="false">

		<cfset var returnVar = "" />
		<cfset var rsFavorite = "" />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsFavorite')#">
		select favorite from tusersfavorites where favorite= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#"/>
		and userID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#"/>
			<cfif isDefined( "arguments.type" )>
				and type= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.type#"/>
			</cfif>
		</cfquery>

		<cfif rsFavorite.recordCount gt 0>
			<cfset returnVar = true />
		<cfelse>
			<cfset returnVar = false />
		</cfif>

		<cfreturn returnVar />
	</cffunction>

	<cffunction name="saveFavorite">
		<cfargument name="favoriteID" type="string" required="yes">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="siteID" type="string" required="yes">
		<cfargument name="favoriteName" type="string" required="yes">
		<cfargument name="favoriteLocation" type="string" required="yes">
		<cfargument name="type" type="string" required="yes">
		<cfargument name="columnNumber" type="string" required="yes" default="">
		<cfargument name="rowNumber" type="string" required="yes" default="">
		<cfargument name="maxRssItems" type="string" required="yes" default="">

		<cfset var favorite = getBean("favorite") />
		<cfif arguments.favoriteID neq ''>
			<cfset favorite.setFavoriteID(arguments.favoriteID) />
		<cfelse>
			<cfset favorite.setFavoriteID(createUUID()) />
		</cfif>
		<cfset favorite.setSiteID(arguments.siteID) />
		<cfset favorite.setUserID(arguments.userID) />
		<cfset favorite.setFavoriteName(arguments.favoriteName) />
		<cfset favorite.setFavorite(arguments.favoriteLocation) />
		<cfset favorite.setType(arguments.type) />
		<cfset favorite.setColumnNumber(arguments.columnNumber) />
		<cfset favorite.setRowNumber(arguments.rowNumber) />
		<cfset favorite.setMaxRssItems(arguments.maxRssItems) />
		<cfset favorite.setDateCreated(now()) />


		<cfset favorite.save() />

		<cfreturn favorite />

	</cffunction>

	<cffunction name="deleteFavorite">
		<cfargument name="favoriteID" type="string" required="yes">

		<cfset var favorite = getBean("favorite") />
		<cfset favorite.setFavoriteID(arguments.favoriteID) />

		<cfset favorite.delete() />

	</cffunction>

	<cffunction name="deleteRSSFavoriteByUserID">
		<cfargument name="userID" type="string" required="yes">
		<cfargument name="siteID" type="string" required="yes">

		<cfquery>
			delete from tusersfavorites where type = 'RSS'
			and userID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#"/>
			and siteID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
		</cfquery>
	</cffunction>

</cfcomponent>

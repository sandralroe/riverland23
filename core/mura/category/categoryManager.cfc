<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides category service level logic">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="categoryGateway" type="any" required="yes"/>
		<cfargument name="categoryDAO" type="any" required="yes"/>
		<cfargument name="utility" type="any" required="yes"/>
		<cfargument name="settingsManager" type="any" required="yes"/>
		<cfargument name="categoryUtility" type="any" required="yes"/>
		<cfargument name="pluginManager" type="any" required="yes"/>
		<cfargument name="trashManager" type="any" required="yes"/>
		<cfargument name="clusterManager" type="any" required="yes"/>

		<cfset variables.configBean=arguments.configBean />
		<cfset variables.gateway=arguments.categoryGateway />
		<cfset variables.DAO=arguments.categoryDAO />
		<cfset variables.utility=arguments.utility />
		<cfset variables.settingsManager=arguments.settingsManager />
		<cfset variables.categoryUtility=arguments.categoryUtility />
		<cfset variables.pluginManager=arguments.pluginManager />
		<cfset variables.trashManager=arguments.trashManager />
		<cfset variables.clusterManager=arguments.clusterManager />

		<cfreturn this />
	</cffunction>

	<cffunction name="getPrivateInterestGroups" output="false">
		<cfargument name="siteID"  type="string" />
		<cfargument name="parentID"  type="string" />

		<cfreturn variables.gateway.getPrivateInterestGroups(arguments.siteid,arguments.parentID) />
	</cffunction>

	<cffunction name="getPublicInterestGroups" output="false">
		<cfargument name="siteID"  type="string" />
		<cfargument name="parentID"  type="string" />

		<cfreturn variables.gateway.getPublicInterestGroups(arguments.siteid,arguments.parentID) />
	</cffunction>

	<cffunction name="getInterestGroupCount" output="false">
		<cfargument name="siteID" type="String">
		<cfargument name="activeOnly" type="boolean" required="true" default="false">

		<cfreturn variables.gateway.getInterestGroupCount(arguments.siteid,arguments.activeOnly) />
	</cffunction>

	<cffunction name="getCategoryCount" output="false">
		<cfargument name="siteID" type="String">
		<cfargument name="activeOnly" type="boolean" required="true" default="false">

		<cfreturn variables.gateway.getCategoryCount(arguments.siteid,arguments.activeOnly) />
	</cffunction>

	<cffunction name="getCategories" output="false">
		<cfargument name="siteID"  type="string" />
		<cfargument name="parentID"  type="string" />
		<cfargument name="keywords"  type="string" required="true" default=""/>
		<cfargument name="activeOnly" type="boolean" required="true" default="false">
		<cfargument name="InterestsOnly" type="boolean" required="true" default="false">

		<cfreturn variables.gateway.getCategories(arguments.siteid,arguments.parentID,arguments.keywords,arguments.activeOnly,arguments.InterestsOnly) />
	</cffunction>

	<cffunction name="getIterator" output="false">
		<cfargument name="siteID"  type="string" />
		<cfargument name="parentID"  type="string" />
		<cfargument name="keywords"  type="string" required="true" default=""/>
		<cfargument name="activeOnly" type="boolean" required="true" default="true">
		<cfargument name="InterestsOnly" type="boolean" required="true" default="false">

		<cfset var it=getBean("categoryIterator").init()>
		<cfset it.setQuery(getCategories(arguments.siteid,arguments.parentID,arguments.keywords,arguments.activeOnly,arguments.InterestsOnly))>
		<cfreturn it />
	</cffunction>

	<cffunction name="getCategoriesBySiteID" output="false">
		<cfargument name="siteID"  type="string" />
		<cfargument name="keywords"  type="string" required="true" default=""/>

		<cfreturn variables.gateway.getCategoriesBySiteID(arguments.siteid,arguments.keywords) />
	</cffunction>

	<cffunction name="getInterestGroupsBySiteID" output="false">
		<cfargument name="siteID"  type="string" />
		<cfargument name="keywords"  type="string" required="true" default=""/>

		<cfreturn variables.gateway.getInterestGroupsBySiteID(arguments.siteid,arguments.keywords) />
	</cffunction>

	<cffunction name="getCategoryfeatures" output="false">
		<cfargument name="categoryID"  type="string" />

		<cfset var categoryBean=read(arguments.categoryID) />
		<cfreturn variables.gateway.getCategoryFeatures(categoryBean) />
	</cffunction>

	<cffunction name="getLiveCategoryFeatures" output="false">
		<cfargument name="categoryID"  type="string" />

		<cfset var categoryBean=read(arguments.categoryID) />
		<cfreturn variables.gateway.getLiveCategoryFeatures(categoryBean) />
	</cffunction>

	<cffunction name="setMaterializedPath" output="false">
		<cfargument name="categoryBean" type="any">

		<cfset var rsCat= ""/>
		<cfset var ID = arguments.categoryBean.getParentID() />
		<cfset var path = "#categoryBean.getCategoryID()#" />
		<cfset var reversePath = "" />
		<cfset var i =0 />

		<cfif ID neq ''>
			<cfloop condition="ID neq ''">
				<cfset path =  listAppend(path,"#ID#")>
				<cfquery name="rsCat" datasource="#variables.configBean.getReadOnlyDatasource()#"  username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#">
				select parentid from tcontentcategories where categoryid='#ID#' and siteid='#arguments.categoryBean.getSiteID()#'
				</cfquery>
				<cfset ID = rsCat.parentID />
			</cfloop>

			<cfloop from="#ListLen(path)#" to="1" index="i" step="-1">
				<cfset reversePath=listAppend(reversePath,"#listGetAt(path,i)#")>
			</cfloop>

			<cfset path=reversePath />
		</cfif>

		<cfset arguments.categoryBean.setPath(path)>
	</cffunction>

	<cffunction name="updateMaterializedPath" output="false">
		<cfargument name="newPath" type="any">
		<cfargument name="currentPath" type="any">
		<cfargument name="siteID" type="any">

		<cfquery datasource="#variables.configBean.getDatasource()#"  username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
			update tcontentcategories
			set path=replace(rtrim(ltrim(cast(path AS char(1000)))),<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.currentPath#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.newPath#">)
			where path like	<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#arguments.currentPath#%">
			and siteID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">
		</cfquery>
	</cffunction>

	<cffunction name="save" output="false">
		<cfargument name="data" type="any" default="#structnew()#"/>

		<cfset var categoryID="">
		<cfset var rs="">

		<cfif isObject(arguments.data)>
			<cfif listLast(getMetaData(arguments.data).name,".") eq "categoryBean">
				<cfset arguments.data=arguments.data.getAllValues()>
			<cfelse>
				<cfthrow type="custom" message="The attribute 'DATA' is not of type 'mura.category.categoryBean'">
			</cfif>
		</cfif>

		<cfif not structKeyExists(arguments.data,"categoryID")>
			<cfthrow type="custom" message="The attribute 'CATEGORYID' is required when saving a category.">
		</cfif>

		<cfquery datasource="#variables.configBean.getReadOnlyDatasource()#" username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#" name="rs">
		select categoryID from tcontentcategories where categoryID=<cfqueryparam value="#arguments.data.categoryID#">
		</cfquery>

		<cfif rs.recordcount>
			<cfreturn update(arguments.data)>
		<cfelse>
			<cfreturn create(arguments.data)>
		</cfif>
	</cffunction>

	<cffunction name="create" output="false">
		<cfargument name="data" type="struct" default="#structnew()#"/>

		<cfset var categoryBean=getBean("categoryBean") />
		<cfset var pluginEvent = new mura.event(arguments.data) />
		<cfset var parentBean="">
		<cfset var sessionData=getSession()>

		<cfset categoryBean.set(arguments.data) />
		<cfset var addObjects=categoryBean.getAddObjects()>
		<cfset categoryBean.validate()>

		<cfset pluginEvent.setValue("categoryBean",categoryBean)>
		<cfset pluginEvent.setValue("bean",categoryBean)>
		<cfset pluginEvent.setValue("siteID", categoryBean.getSiteID())>
		<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeCategorySave",currentEventObject=pluginEvent,objectid=categoryBean.getCategoryID())>
		<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeCategoryCreate",currentEventObject=pluginEvent,objectid=categoryBean.getCategoryID())>
		<cfif structIsEmpty(categoryBean.getErrors())>
			<cfset categoryBean.setLastUpdate(now())>
			<cfset categoryBean.setLastUpdateBy(left(sessionData.mura.fname & " " & sessionData.mura.lname,50)) />
			<cfif not (structKeyExists(arguments.data,"categoryID") and len(arguments.data.categoryID))>
				<cfset categoryBean.setCategoryID("#createUUID()#") />
			</cfif>

			<cfset setMaterializedPath(categoryBean) />

			<cfif not len(categoryBean.getURLTitle())>
				<cfset categoryBean.setURLTitle(categoryBean.getName())>
			</cfif>

			<cfset parentBean=read(categoryBean.getParentID())>
			<cfif not parentBean.getIsNew()>
				<cfif not len(parentBean.getFilename())>
					<cfset parentBean.save()>
					<cfset parentBean=read(categoryBean.getParentID())>
				</cfif>
				<cfset categoryBean.setFilename(parentBean.getFilename() & "/" & categoryBean.getURLTitle())>
			<cfelse>
				<cfset categoryBean.setFilename(categoryBean.getURLTitle())>
			</cfif>

			<cfset makeFilenameUnique(categoryBean)>

			<cfset variables.utility.logEvent("CategoryID:#categoryBean.getCategoryID()# Name:#categoryBean.getName()# was created","mura-content","Information",true) />
			<cfset variables.DAO.create(categoryBean) />

			<cfscript>
				if(arrayLen(addObjects)){
					for(var obj in addObjects){
						obj.save();
					}
				}

				categoryBean.setAddObjects([]);
				categoryBean.setRemoveObjects([]);
			</cfscript>

			<cfset variables.trashManager.takeOut(categoryBean)>
			<cfset categoryBean.setIsNew(0)>
			<cfset purgeCategoryCache(categoryBean=categoryBean)>

			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onCategorySave",currentEventObject=pluginEvent,objectid=categoryBean.getCategoryID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onCategoryCreate",currentEventObject=pluginEvent,objectid=categoryBean.getCategoryID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterCategorySave",currentEventObject=pluginEvent,objectid=categoryBean.getCategoryID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterCategoryCreate",currentEventObject=pluginEvent,objectid=categoryBean.getCategoryID())>

		</cfif>

		<cfreturn categoryBean />
	</cffunction>

	<cffunction name="makeFilenameUnique" output="false">
	<cfargument name="categoryBean">
		<cfset var count=0>
		<cfset var isUnique=false>
		<cfset var rsCheck="">
		<cfset var tempFilename=arguments.categoryBean.getFilename()>
		<cfloop condition="not isUnique">
			<cfquery name="rsCheck" datasource="#variables.configBean.getReadOnlyDatasource()#" username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#">
				select categoryID from tcontentcategories
				where categoryID != <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.categoryBean.getCategoryID()#">
				and filename=<cfqueryparam cfsqltype="cf_sql_varchar" value="#tempFilename#">
				and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.categoryBean.getSiteID()#">
			</cfquery>
			<cfif rsCheck.recordcount>
				<cfset count=count+1>
				<cfset tempFilename=arguments.categoryBean.getFilename() & count>
			<cfelse>
				<cfset isUnique=true>
			</cfif>
		</cfloop>

		<cfif count>
			<cfset arguments.categoryBean.setFilename(tempFilename)>
			<cfset arguments.categoryBean.setURLTitle(listLast(tempFilename,"/"))>
		</cfif>
	</cffunction>

	<cffunction name="read" output="false">
		<cfargument name="categoryID" required="true" default=""/>
		<cfargument name="name" required="true" default=""/>
		<cfargument name="remoteID" required="true" default=""/>
		<cfargument name="filename" required="true" default=""/>
		<cfargument name="urltitle" required="true" default=""/>
		<cfargument name="siteID" required="true" default=""/>
		<cfargument name="categoryBean" required="true" default=""/>
		<cfset var key= "" />
		<cfset var site=""/>
		<cfset var cacheFactory="">
		<cfset var bean=arguments.categoryBean>
		<cfset var sessionData=getSession()>

		<cfif isdefined("sessionData.siteID") and not len(arguments.siteID)>
			<cfset arguments.siteID=sessionData.siteID>
		</cfif>

		<cfif not len(arguments.categoryID) and len(arguments.siteID)>
			<cfif len(arguments.name)>
				<cfreturn readByName(arguments.name, arguments.siteID, bean) />
			<cfelseif len(arguments.remoteID)>
				<cfreturn readByRemoteID(arguments.remoteID, arguments.siteID, bean) />
			<cfelseif len(arguments.filename)>
				<cfreturn readByFilename(arguments.filename, arguments.siteID, bean) />
			<cfelseif len(arguments.urltitle)>
				<cfreturn readByUrlTItle(arguments.urltitle, arguments.siteID, bean) />
			</cfif>
		</cfif>

		<cfset key= "category" & arguments.siteid & arguments.categoryID />
		<cfset site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset cacheFactory=site.getCacheFactory(name="data")>

		<cfif site.getCache()>
			<!--- check to see if it is cached. if not then pass in the context --->
			<!--- otherwise grab it from the cache --->
			<cfif NOT cacheFactory.has( key )>
				<cfset bean=variables.DAO.read(arguments.categoryID,bean)>
				<cfif not bean.getIsNew()>
					<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
				</cfif>
				<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: categoryBean, key: #key#}"))>
				<cfreturn bean/>
			<cfelse>
				<cftry>
					<cfif not isObject(bean)>
						<cfset bean=variables.DAO.getBean("category")/>
					</cfif>
					<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
					<cfset bean.setValue('frommuracache',true)>
					<cfset commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: categoryBean, key: #key#}"))>
					<cfreturn bean />
					<cfcatch>
						<cfset bean=variables.DAO.read(arguments.categoryID,bean)>
						<cfif not bean.getIsNew()>
							<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
						</cfif>
						<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: categoryBean, key: #key#}"))>
						<cfreturn bean/>
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfreturn variables.DAO.read(arguments.categoryID,bean) />
		</cfif>
	</cffunction>

	<cffunction name="readByName" output="false">
		<cfargument name="name" type="String" />
		<cfargument name="siteid" type="string" />
		<cfargument name="categoryBean" required="true" default=""/>
		<cfset var key= "category" & arguments.siteid & arguments.name />
		<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset var cacheFactory=site.getCacheFactory(name="data")>
		<cfset var bean=arguments.categoryBean>

		<cfif site.getCache()>
			<!--- check to see if it is cached. if not then pass in the context --->
			<!--- otherwise grab it from the cache --->
			<cfif NOT cacheFactory.has( key )>
				<cfset bean=variables.DAO.readByName(arguments.name,arguments.siteID,bean) >
				<cfif not isArray(bean) and not bean.getIsNew()>
					<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
				</cfif>
				<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: categoryBean, key: #key#}"))>
				<cfreturn bean/>
			<cfelse>
				<cftry>
					<cfif not isObject(bean)>
						<cfset bean=variables.DAO.getBean("category")/>
					</cfif>
					<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
					<cfset bean.setValue('frommuracache',true)>
					<cfset commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: categoryBean, key: #key#}"))>
					<cfreturn bean />
					<cfcatch>
						<cfset bean=variables.DAO.readByName(arguments.name,arguments.siteID,bean) >
						<cfif not isArray(bean) and not bean.getIsNew()>
							<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
						</cfif>
						<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: categoryBean, key: #key#}"))>
						<cfreturn bean/>
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfreturn variables.DAO.readByName(arguments.name,arguments.siteID,bean) />
		</cfif>

	</cffunction>

	<cffunction name="readByURLTitle" output="false">
		<cfargument name="urlTitle" type="String" />
		<cfargument name="siteid" type="string" />
		<cfargument name="categoryBean" required="true" default=""/>
		<cfset var key= "category" & arguments.siteid & arguments.urlTitle />
		<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset var cacheFactory=site.getCacheFactory(name="data")>
		<cfset var bean=arguments.categoryBean>

		<cfif site.getCache()>
			<!--- check to see if it is cached. if not then pass in the context --->
			<!--- otherwise grab it from the cache --->
			<cfif NOT cacheFactory.has( key )>
				<cfset bean=variables.DAO.readByURLTitle(arguments.urlTitle,arguments.siteID,bean) >
				<cfif not isArray(bean) and not bean.getIsNew()>
					<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
				</cfif>
				<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: categoryBean, key: #key#}"))>
				<cfreturn bean/>
			<cfelse>
				<cftry>
					<cfif not isObject(bean)>
						<cfset bean=variables.DAO.getBean("category")/>
					</cfif>
					<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
					<cfset bean.setValue('frommuracache',true)>
					<cfset commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: categoryBean, key: #key#}"))>
					<cfreturn bean />
					<cfcatch>
						<cfset bean=variables.DAO.readByURLTitle(arguments.urlTitle,arguments.siteID,bean) >
						<cfif not isArray(bean) and not bean.getIsNew()>
							<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
						</cfif>
						<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: categoryBean, key: #key#}"))>
						<cfreturn bean/>
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfreturn variables.DAO.readByURLTitle(arguments.urlTitle,arguments.siteID,bean) />
		</cfif>

	</cffunction>

	<cffunction name="readByFilename" output="false">
		<cfargument name="filename" type="String" />
		<cfargument name="siteid" type="string" />
		<cfargument name="categoryBean" required="true" default=""/>
		<cfset var key= "" />
		<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset var cacheFactory=site.getCacheFactory(name="data")>
		<cfset var bean=arguments.categoryBean>

		<cfif arguments.filename eq "/">
			<cfset arguments.filename="">
		<cfelse>
			<cfif left(arguments.filename,1) eq "/">
				<cfif len(arguments.filename) gt 1>
					<cfset arguments.filename=right(arguments.filename,len(arguments.filename)-1)>
				<cfelse>
					<cfset arguments.filename="">
				</cfif>
			</cfif>

			<cfif right(arguments.filename,1) eq "/">
				<cfif len(arguments.filename) gt 1>
					<cfset arguments.filename=left(arguments.filename,len(arguments.filename)-1)>
				<cfelse>
					<cfset arguments.filename="">
				</cfif>
			</cfif>
		</cfif>

		<cfset key= "category" & arguments.siteid & arguments.filename />

		<cfif site.getCache()>
			<!--- check to see if it is cached. if not then pass in the context --->
			<!--- otherwise grab it from the cache --->
			<cfif NOT cacheFactory.has( key )>
				<cfset bean=variables.DAO.readByFilename(arguments.filename,arguments.siteID,bean) >
				<cfif not isArray(bean) and not bean.getIsNew()>
					<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
				</cfif>
				<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: categoryBean, key: #key#}"))>
				<cfreturn bean/>
			<cfelse>
				<cftry>
					<cfif not isObject(bean)>
						<cfset bean=variables.DAO.getBean("category")/>
					</cfif>
					<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
					<cfset commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: categoryBean, key: #key#}"))>
					<cfset bean.setValue('frommuracache',true)>
					<cfreturn bean />
					<cfcatch>
						<cfset bean=variables.DAO.readByFilename(arguments.filename,arguments.siteID,bean) >
						<cfif not isArray(bean) and not bean.getIsNew()>
							<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
						</cfif>
						<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: categoryBean, key: #key#}"))>
						<cfreturn bean/>
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfreturn variables.DAO.readByFilename(arguments.filename,arguments.siteID,bean) />
		</cfif>
	</cffunction>

	<cffunction name="readByRemoteID" output="false">
		<cfargument name="remoteID" type="String" />
		<cfargument name="siteID" type="String" />
		<cfargument name="categoryBean" required="true" default=""/>
		<cfset var key= "category" & arguments.siteid & arguments.remoteID />
		<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset var cacheFactory=site.getCacheFactory(name="data")>
		<cfset var bean=arguments.categoryBean>

		<cfif site.getCache()>
			<!--- check to see if it is cached. if not then pass in the context --->
			<!--- otherwise grab it from the cache --->
			<cfif NOT cacheFactory.has( key )>
				<cfset bean=variables.DAO.readByRemoteID(arguments.remoteID,arguments.siteID,bean) >
				<cfif not isArray(bean) and not bean.getIsNew()>
					<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
				</cfif>
				<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: categoryBean, key: #key#}"))>
				<cfreturn bean/>
			<cfelse>
				<cftry>
					<cfif not isObject(bean)>
						<cfset bean=variables.DAO.getBean("category")/>
					</cfif>
					<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
					<cfset bean.setValue('frommuracache',true)>
					<cfset commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: categoryBean, key: #key#}"))>
					<cfreturn bean />
					<cfcatch>
						<cfset bean=variables.DAO.readByRemoteID(arguments.remoteID,arguments.siteID,bean) >
						<cfif not isArray(bean) and not bean.getIsNew()>
							<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
						</cfif>
						<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: categoryBean, key: #key#}"))>
						<cfreturn bean/>
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfreturn variables.DAO.readByRemoteID(arguments.remoteID,arguments.siteID,bean) />
		</cfif>
	</cffunction>

	<cffunction name="purgeCategoryCache" output="false">
		<cfargument name="categoryID">
		<cfargument name="categoryBean">
		<cfargument name="broadcast" default="true">
		<cfset var cache="">

		<cfif NOT isDefined("arguments.categoryBean")>
			<cfset arguments.categoryBean=read(categoryID=arguments.categoryID)>
		</cfif>

		<cfif NOT arguments.categoryBean.getIsNew()>
			<cfset cache=variables.settingsManager.getSite(arguments.categoryBean.getSiteID()).getCacheFactory(name="data")>

			<cfset cache.purge("category" & arguments.categoryBean.getSiteID() & arguments.categoryBean.getCategoryID())>
			<cfif len(arguments.categoryBean.getRemoteID())>
				<cfset cache.purge("category" & arguments.categoryBean.getSiteID() & arguments.categoryBean.getRemoteID())>
			</cfif>
			<cfif len(arguments.categoryBean.getName())>
				<cfset cache.purge("category" & arguments.categoryBean.getSiteID() & arguments.categoryBean.getName())>
			</cfif>
			<cfif len(arguments.categoryBean.getFilename())>
				<cfset cache.purge("category" & arguments.categoryBean.getSiteID() & arguments.categoryBean.getFilename())>
			</cfif>

			<cfif len(arguments.categoryBean.getURLTitle())>
				<cfset cache.purge("category" & arguments.categoryBean.getSiteID() & arguments.categoryBean.getURLTitle())>
			</cfif>

			<cfif arguments.broadcast>
				<cfset variables.clusterManager.purgeCategoryCache(categoryID=arguments.categoryBean.getcategoryID())>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="purgeCategoryDescendentsCache" output="false">
		<cfargument name="categoryID">
		<cfargument name="categoryBean">
		<cfargument name="broadcast" default="true">
		<cfset var it="">
		<cfset var rs="">

		<cfif not isDefined("arguments.categoryBean")>
			<cfset arguments.categoryBean=read(categoryID=arguments.categoryID)>
		</cfif>

		<cfquery name="rs" datasource="#variables.configBean.getReadOnlyDatasource()#"  username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#">
		select categoryID,siteID,dateCreated,lastUpdate,lastUpdateBy,
		name,isInterestGroup,parentID,isActive,isOpen,notes,sortBy,
		sortDirection,restrictGroups,path,remoteID,remoteSourceURL,
		remotePubDate,urlTitle,filename
		from tcontentcategories where
		path like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.categoryBean.getCategoryID()#%">
		</cfquery>

		<cfset it=getBean("categoryIterator").setQuery(rs)>

		<cfloop condition="it.hasNext()">
			<cfset purgeCategoryCache(categoryBean=it.next(),broadcast=false)>
		</cfloop>

		<cfif arguments.broadcast>
			<cfset variables.clusterManager.purgeCategoryDescendentsCache(categoryID=arguments.categoryBean.getcategoryID())>
		</cfif>
	</cffunction>

	<cffunction name="update" output="false">
		<cfargument name="data" type="struct" default="#structnew()#"/>

		<cfset var categoryBean=variables.DAO.read(arguments.data.categoryID) />
		<cfset var currentParentID= "" />
		<cfset var currentURLTitle= "" />
		<cfset var currentPath= "" />
		<cfset var pluginEvent = new mura.event(arguments.data) />
		<cfset var currentFilename="">
		<cfset var parentBean="">
		<cfset var sessionData=getSession()>

		<cfset currentParentID=categoryBean.getParentID() />
		<cfset currentURLTitle=categoryBean.getURLTitle() />
		<cfset currentFilename=categoryBean.getFilename() />
		<cfset categoryBean.set(arguments.data) />
		<cfset categoryBean.validate()>
		<cfset currentPath=categoryBean.getPath() />

		<cfset pluginEvent.setValue("categoryBean",categoryBean)>
		<cfset var addObjects=categoryBean.getAddObjects()>
		<cfset var removeObjects=categoryBean.getRemoveObjects()>
		<cfset pluginEvent.setValue("siteID", categoryBean.getSiteID())>
		<cfset variables.pluginManager.announceEvent("onBeforeCategorySave",pluginEvent)>
		<cfset variables.pluginManager.announceEvent("onBeforeCategoryUpdate",pluginEvent)>

		<cfif structIsEmpty(categoryBean.getErrors())>
			<cfif not len(categoryBean.getURLTitle())>
				<cfset categoryBean.setURLTitle(categoryBean.getName())>
			</cfif>

			<cfif currentURLTitle neq categoryBean.getURLTitle()
				or currentParentID neq categoryBean.getParentID()>

				<cfif currentParentID neq categoryBean.getParentID()>
					<cfset setMaterializedPath(categoryBean) />
					<cfset updateMaterializedPath(categoryBean.getPath(),currentPath,categoryBean.getSiteID())>
				</cfif>

				<cfset parentBean=read(categoryBean.getParentID())>

				<cfif not parentBean.getIsNew()>
					<cfif not len(parentBean.getFilename())>
						<cfset parentBean.save()>
						<cfset parentBean=read(categoryBean.getParentID())>
					</cfif>
					<cfset categoryBean.setFilename(parentBean.getFilename() & "/" & categoryBean.getURLTitle())>
				<cfelse>
					<cfset categoryBean.setFilename(categoryBean.getURLTitle())>
				</cfif>

				<cfset makeFilenameUnique(categoryBean)>

				<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
				update tcontentcategories set filename=replace(filename,<cfqueryparam cfsqltype="cf_sql_varchar" value="#currentFilename#/"/>,<cfqueryparam cfsqltype="cf_sql_varchar" value="#categoryBean.getFilename()#/"/>) where siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#categoryBean.getSiteID()#"/>
				and filename like <cfqueryparam cfsqltype="cf_sql_varchar" value="#currentFilename#/%"/>
				</cfquery>

				<cfset purgeCategoryDescendentsCache(categoryBean=categoryBean)>
			</cfif>

			<cfset categoryBean.setLastUpdate(now())>
			<cfset categoryBean.setLastUpdateBy(left(sessionData.mura.fname & " " & sessionData.mura.lname,50)) />
			<cfset variables.DAO.update(categoryBean) />

			<cfscript>
				var obj='';

				if(arrayLen(addObjects)){
					for(obj in addObjects){
						obj.save();
					}
				}

				if(arrayLen(removeObjects)){
					for(obj in removeObjects){
						obj.delete();
					}
				}

				categoryBean.setAddObjects([]);
				categoryBean.setRemoveObjects([]);
			</cfscript>

			<cfif isdefined('arguments.data.OrderID')>
				<cfset setListOrder(categoryBean.getCategoryID(),arguments.data.OrderID,arguments.data.Orderno,arguments.data.siteID) />
			</cfif>
			<cfset purgeCategoryCache(categoryBean=categoryBean)>
			<cfset variables.pluginManager.announceEvent("onCategorySave",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onCategoryUpdate",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterCategorySave",pluginEvent)>
			<cfset variables.pluginManager.announceEvent("onAfterCategoryUpdate",pluginEvent)>
		</cfif>

		<cfset variables.utility.logEvent("CategoryID:#categoryBean.getCategoryID()# Name:#categoryBean.getName()# was updated","mura-content","Information",true) />

		<cfreturn categoryBean />
	</cffunction>

	<cffunction name="delete" output="false">
		<cfargument name="categoryID" type="String" />

		<cfset var categoryBean=read(arguments.categoryID) />
		<cfset var currentPath=categoryBean.getPath() />
		<cfset var newPath=""/>
		<cfset var pluginEvent = "" />
		<cfset var pluginStruct=structNew()>

		<cfset pluginStruct.categoryBean=categoryBean>
		<cfset pluginStruct.bean=categoryBean>
		<cfset pluginStruct.siteID=categoryBean.getSiteID()>
		<cfset pluginStruct.categoryID=arguments.categoryID>

		<cfset pluginEvent=new mura.event(pluginStruct)>

		<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeCategoryDelete",currentEventObject=pluginEvent,objectid=categoryBean.getCategoryID())>

		<cfif currentPath neq "">
			<cfset newPath=listDeleteAt(categoryBean.getPath(),listLen(categoryBean.getPath())) />
			<cfset updateMaterializedPath(newPath,currentPath,categoryBean.getSiteID())>
		</cfif>

		<cfset variables.trashManager.throwIn(categoryBean)>
		<cfset variables.utility.logEvent("CategoryID:#categoryBean.getCategoryID()# Name:#categoryBean.getName()# was deleted","mura-content","Information",true) />
		<cfset variables.DAO.delete(arguments.categoryID) />
		<cfset purgeCategoryCache(categoryBean=categoryBean)>
		<cfset purgeCategoryDescendentsCache(categoryBean=categoryBean)>

		<cfset variables.pluginManager.announceEvent(eventToAnnounce="onCategoryDelete",currentEventObject=pluginEvent,objectid=categoryBean.getCategoryID())>
		<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterCategoryDelete",currentEventObject=pluginEvent,objectid=categoryBean.getCategoryID())>

	</cffunction>

	<cffunction name="setListOrder" output="false">
		<cfargument name="categoryID" type="string" default=""/>
		<cfargument name="orderID" type="string" default=""/>
		<cfargument name="orderno" type="string" default=""/>
		<cfargument name="siteid" type="string" default=""/>

		<cfset variables.DAO.setListOrder(arguments.categoryID,arguments.orderID,arguments.orderno,arguments.siteid) />
		<cfset variables.settingsManager.getSite(arguments.siteid).purgeCache() />

	</cffunction>

	<cffunction name="setCategories" output="false">
		<cfargument name="data" type="struct" default="#structNew()#"/>
		<cfargument name="contentID" type="string" default=""/>
		<cfargument name="contentHistID" type="string" default=""/>
		<cfargument name="siteID" type="string" default=""/>
		<cfargument name="rsCurrent" type="query"/>

		<cfset var orderno=0/>
		<cfset var isFeature=0/>
		<cfset var rsCategories=variables.gateway.getCategoriesBySiteID(arguments.siteid,'') />
		<cfset var catTrim=""/>
		<cfset var rsKeeper=""/>
		<cfset var schedule= structNew()/>

		<cfloop query="rsCategories">
			<cfif isdefined('arguments.data.categoryAssign#replace(rsCategories.categoryID,'-','','ALL')#')
			and listFind(arguments.data.categoryid,rsCategories.categoryID)
			and arguments.data['categoryAssign#replace(rsCategories.categoryID,'-','','ALL')#'] neq ''>

			<cfset catTrim=replace(rsCategories.categoryID,'-','','ALL') />

				<cfset isFeature=arguments.data['categoryAssign#catTrim#'] />

				<!---
				<cfif isFeature>

					<cfset orderno = variables.DAO.getCurrentOrderNO(rsCategories.categoryID,arguments.contentid,arguments.siteid) />
					<cfif not orderno>
						<cfset variables.DAO.pushCategory(rsCategories.categoryID,arguments.siteID) />
						<cfset orderno=1/>
					</cfif>

				</cfif>
				--->
				<cfif isFeature eq 2>
					<cfset schedule.featureStart=arguments.data['featureStart#catTrim#'] />
					<cfset schedule.starthour=arguments.data['starthour#catTrim#'] />
					<cfset schedule.startMinute=arguments.data['startMinute#catTrim#'] />

					<cfparam name="arguments.data.startDayPart#catTrim#" default="" />
					<cfset schedule.startDayPart=arguments.data['startDayPart#catTrim#'] />

					<cfset schedule.featureStop=arguments.data['featureStop#catTrim#'] />
					<cfset schedule.stopHour=arguments.data['stopHour#catTrim#'] />
					<cfset schedule.stopMinute=arguments.data['stopMinute#catTrim#'] />

					<cfparam name="arguments.data.stopDayPart#catTrim#" default="" />
					<cfset schedule.stopDayPart=arguments.data['stopDayPart#catTrim#'] />
				<cfelse>
					<cfset schedule.featureStart="" />
					<cfset schedule.starthour="" />
					<cfset schedule.startMinute="" />
					<cfset schedule.startDayPart="" />
					<cfset schedule.featureStop="" />
					<cfset schedule.stopHour="" />
					<cfset schedule.stopMinute="" />
					<cfset schedule.stopDayPart="" />
				</cfif>

				<cfset variables.DAO.setAssignment(rsCategories.categoryID,arguments.contentID,arguments.contentHistID,isFeature,orderno,arguments.siteID,schedule) />
			<cfelseif not isdefined('arguments.data.categoryAssign#replace(rsCategories.categoryID,'-','','ALL')#')>
				<cfquery name="rsKeeper" dbType="query">
					select * from arguments.rsCurrent where categoryID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#rsCategories.categoryID#" />
				</cfquery>

				<cfif rsKeeper.recordcount>
					<cfset variables.DAO.saveAssignment(arguments.contentHistID, rsKeeper.contentID, rsKeeper.categoryID, rsKeeper.siteID,
					rsKeeper.orderno, rsKeeper.isFeature, rsKeeper.featureStart, rsKeeper.featureStop)>
				</cfif>
			</cfif>
		</cfloop>

	</cffunction>

	<cffunction name="keepCategories" output="false">
		<cfargument name="contentHistID" type="string" default=""/>
		<cfargument name="rsKeepers" type="query"/>

			<cfset variables.DAO.keepCategories(arguments.contentHistID,arguments.rsKeepers) />

	</cffunction>

	<cffunction name="getCrumbQuery" output="false">
		<cfargument name="path" required="true">
		<cfargument name="siteID" required="true">
		<cfargument name="sort" required="true" default="asc">

		<cfreturn variables.gateway.getCrumbQuery(arguments.path, arguments.siteid, arguments.sort)>
	</cffunction>

</cfcomponent>

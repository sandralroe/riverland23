<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides site service level logic functionality">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="utility" type="any" required="yes"/>
		<cfargument name="settingsGateway" type="any" required="yes"/>
		<cfargument name="settingsDAO" type="any" required="yes"/>
		<cfargument name="clusterManager" type="any" required="yes"/>
		
		<cfset variables.configBean=arguments.configBean />
		<cfset variables.utility=arguments.utility />
		<cfset variables.Gateway=arguments.settingsGateway />
		<cfset variables.DAO=arguments.settingsDAO />
		<cfset variables.clusterManager=arguments.clusterManager />
		<cfset variables.classExtensionManager=variables.configBean.getClassExtensionManager()>
		
		<cfif variables.configBean.getValue(property="individualsitebuilds", defaultValue=false)>
			<cfset buildSite(siteid="default",resetEvents=true) />
		<cfelse>
			<cfset setSites() />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="validate" output="false">
		<cfset var defaultSite=getSite('default')>
		<cfreturn isObject(variables.configBean)
		and isObject(variables.utility)
		and isObject(variables.Gateway)
		and isObject(variables.DAO)
		and isObject(variables.clusterManager)
		and isObject(variables.classExtensionManager)
		and isDefined('variables.sites')
		and not structIsEmpty(variables.sites)
		and (
				defaultSite.isBuilding() or defaultSite.hasDisplayObject('container')
			)>
	</cffunction>

	<cffunction name="getBean" output="false">
		<cfargument name="beanName" default="site">
		<cfreturn super.getBean(arguments.beanName)>
	</cffunction>

	<cffunction name="getList" output="false">
		<cfargument name="sortBy" default="orderno">
		<cfargument name="sortDirection" default="asc">
		<cfargument name="cached" default="true" />
		<cfset var rs = variables.gateway.getList(arguments.sortBy,arguments.sortDirection,arguments.cached) />
		<cfreturn rs />
	</cffunction>

	<cffunction name="publishSite" output="false">
		<cfargument name="siteID" required="yes" default="">
		<cfset var bundleFileName = "">
		<cfset var authToken = "">
		<cfset var i = "">
		<cfset var serverArgs = structNew()>
		<cfset var rsPlugins = getBean("pluginManager").getSitePlugins(arguments.siteID)>
		<cfset var result="">
		<cfif variables.configBean.getValue('deployMode') eq "bundle">
			<cfset bundleFileName = getBean("Bundle").Bundle(
				siteID=arguments.siteID,
				moduleID=ValueList(rsPlugins.moduleID),
				BundleName='deployBundle',
				includeVersionHistory=false,
				includeTrash=false,
				includeMetaData=true,
				includeMailingListMembers=false,
				includeUsers=false,
				includeFormData=false,
				saveFile=true) />

			<cfloop list="#variables.configBean.getServerList()#" index="i" delimiters="^">
				<cfset serverArgs = deserializeJSON(i)>
				<cfset result = pushBundle(siteID, bundleFileName, serverArgs)>
			</cfloop>

			<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
				update tsettings set lastDeployment = #createODBCDateTime(now())#
				where siteID = <cfqueryparam cfsqltype="cf_sql_VARCHAR" value="#arguments.siteID#">
			</cfquery>

			<cfset fileDelete(bundleFileName)>
		<cfelse>
			<cfset getBean("publisher").start(arguments.siteid) />
		</cfif>
		<cfset getBean('clusterManager').broadcastCommand("getBean('settingsManager').buildSite('#arguments.siteid#')")>

	</cffunction>

	<cffunction name="pushBundle" output="no">
		<cfargument name="siteID" required="yes" default="">
		<cfargument name="bundleFileName" required="yes">
		<cfargument name="serverArgs" required="yes">
		<cfset var bundleArgs = structNew()>
		<cfset var result = "">
		<cfset var authToken="">
		<cfinvoke webservice="#serverArgs.serverURL#?wsdl"
			method="login"
			returnVariable="authToken">
			<cfinvokeargument name="username" value="#serverArgs.username#">
			<cfinvokeargument name="password" value="#serverArgs.password#">
			<cfinvokeargument name="siteID" value="#serverArgs.siteID#">
		</cfinvoke>

		<cfset bundleArgs.siteID = arguments.siteID />
		<cfset bundleArgs.bundleImportKeyMode = "publish">

		<cfif serverArgs.deployMode eq "files">
			<!--- push just files --->
			<cfset bundleArgs.bundleImportContentMode = "none">
		<cfelse>
			<!--- files and content --->
			<cfset bundleArgs.bundleImportContentMode = "all">
		</cfif>

		<cfset bundleArgs.bundleImportRenderingMode = "all">
		<cfset bundleArgs.bundleImportPluginMode = "all">
		<cfset bundleArgs.bundleImportMailingListMembersMode = "none">
		<cfset bundleArgs.bundleImportUsersMode = "none">
		<cfset bundleArgs.bundleImportLastDeployment = "">
		<cfset bundleArgs.bundleImportModuleID = "">
		<cfset bundleArgs.bundleImportFormDataMode = "none">

		<cfhttp attributeCollection='#getHTTPAttrs(method="post",url="#serverArgs.serverURL#")#'>
			<cfhttpparam name="method" type="url" value="call">
			<cfhttpparam name="serviceName" type="url" value="bundle">
			<cfhttpparam name="methodName" type="url" value="deploy">
			<cfhttpparam name="authToken" type="url" value="#authToken#">
			<cfhttpparam name="args" type="url" value="#serializeJSON(bundleArgs)#">
			<cfhttpparam name="bundleFile" type="file" file="#bundleFileName#">
		</cfhttp>

		<cfif cfhttp.FileContent contains "success">
			<cfset result = "Deployment Successful">
		<cfelse>
			<cfset result = cfhttp.FileContent>
		</cfif>

		<cfreturn result>
	</cffunction>

	<cffunction name="saveOrder" output="false">
		<cfargument name="orderno" required="yes" default="">
		<cfargument name="orderID" required="yes" default="">

		<cfset var i=0/>

		<cfif arguments.orderID neq ''>
			<cfloop from="1" to="#listlen(arguments.orderid)#" index="i">
			<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
			update tsettings set orderno= #listgetat(arguments.orderno,i)# where siteid ='#listgetat(arguments.orderid,i)#'
			</cfquery>
			</cfloop>
		</cfif>

		<cfset variables.gateway.getList(cached=false)>

	</cffunction>

	<cffunction name="saveDeploy" output="false">
		<cfargument name="deploy" required="yes" default="">
		<cfargument name="orderID" required="yes" default="">
		<cfset var i=0/>
		<cfif arguments.deploy neq '' and arguments.orderID neq ''>
			<cfloop from="1" to="#listlen(arguments.orderid)#" index="i">
			<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
			update tsettings set deploy= #listgetat(arguments.deploy,i)# where siteid ='#listgetat(arguments.orderid,i)#'
			</cfquery>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="read" output="false">
		<cfargument name="siteid" type="string" />
		<cfargument name="settingsBean" default=""> />
		<cfreturn variables.DAO.read(arguments.siteid,arguments.settingsBean) />
	</cffunction>

	<cffunction name="update" output="false">
		<cfargument name="data" type="struct" />
		<cfset var bean=variables.DAO.read(arguments.data.SiteID) />
		<cfset var pluginEvent = new mura.event(arguments.data) />
		<cfset var initialTheme=bean.get('theme')>

		<cfset bean.set(arguments.data) />
		<cfset pluginEvent.setValue('settingsBean',bean)>

		<cfset bean.setModuleID("00000000000000000000000000000000000")>
		<cfset bean.validate()>

		<cfset getBean('pluginManager').announceEvent("onBeforeSiteUpdate",pluginEvent)>
		<cfset getBean('pluginManager').announceEvent("onBeforeSiteSave",pluginEvent)>

		<cfif structIsEmpty(bean.getErrors())>
			<cfset variables.utility.logEvent("SiteID:#bean.getSiteID()# Site:#bean.getSite()# was updated","mura-settings","Information",true) />
			<cfif structKeyExists(arguments.data,"extendSetID") and len(arguments.data.extendSetID)>
				<cfset variables.classExtensionManager.saveExtendedData(bean.getBaseID(),bean.getAllValues())/>
			</cfif>

			<cfset bean.getRazunaSettings().set(arguments.data).save()>

			<cfif len(bean.getNewPlaceholderImg())>
				<cfif len(bean.getPlaceholderImgId())>
					<cfset getBean('fileManager').deleteIfNotUsed(bean.getPlaceholderImgId(),'',bean.getSiteID())>
				</cfif>

				<cfset local.fileBean=getBean('file')>
				<cfset local.fileBean.setSiteID(bean.getSiteID())>
				<cfset local.fileBean.setModuleID('')>
				<cfset local.fileBean.setFileField('newPlaceholderImg')>
				<cfset local.fileBean.setNewFile(bean.getNewPlaceholderImg())>
				<cfset local.fileBean.save()>
				<cfset bean.setPlaceholderImgID(local.fileBean.getFileID()) />
				<cfset bean.setPlaceholderImgExt(local.fileBean.getFileExt()) />
			<cfelseif len(bean.getDeletePlaceholderImg())>
				<cfset getBean('fileManager').deleteIfNotUsed(bean.getPlaceholderImgId(),'',bean.getSiteID())>
				<cfset bean.setPlaceholderImgID('') />
				<cfset bean.setPlaceholderImgExt('') />
			</cfif>

			<cfset local.oauthsettingbean = getBean('oauthSetting').loadBy(siteid=bean.getSiteID())/>
			<cfif isDefined("arguments.data.allowedDomain")>
				<cfset local.oauthsettingbean.setAllowedDomain(arguments.data.allowedDomain)/>
			</cfif>
			<cfif isDefined("arguments.data.allowedAdminDomain")>
				<cfset local.oauthsettingbean.setAllowedAdminDomain(arguments.data.allowedAdminDomain)/>
			</cfif>
			<cfif isDefined("arguments.data.allowedAdminGroupEmailList")>
				<cfset local.oauthsettingbean.setAllowedAdminGroupEmailList(arguments.data.allowedAdminGroupEmailList)/>
			</cfif>
			<cfif isDefined("arguments.data.allowedS2EmailList")>
				<cfset local.oauthsettingbean.setAllowedS2EmailList(arguments.data.allowedS2EmailList)/>
			</cfif>
			
			<cfset local.oauthsettingbean.save()/>

			<cfset variables.DAO.update(bean) />
		
			<cfset checkForBundle(arguments.data,bean.getErrors())>

			<cfif variables.configBean.getValue(property="individualsitebuilds", defaultValue=false)>
				<cfset buildSite(bean.getSiteID(),true) />
				<cfset getBean('clusterManager').broadcastCommand("getBean('settingsManager').buildSite('#bean.getSiteID()#',true)")>
			<cfelse>
				<cfset application.appInitialized=false>
				<cfset getBean('clusterManager').reload()>
			</cfif>
				
			<cfset getBean('pluginManager').announceEvent("onAfterSiteUpdate",pluginEvent)>
			<cfset getBean('pluginManager').announceEvent("onAfterSiteSave",pluginEvent)>
		</cfif>

		<cfreturn bean />

	</cffunction>

	<cffunction name="delete" output="false">
		<cfargument name="siteid" type="string" />

		<cfset var bean=read(arguments.siteid) />
		<cfset var data={sited=arguments.siteid,settingsBean=bean}>
		<cfset var pluginEvent =new mura.event(data) />

		<cfset getBean('pluginManager').announceEvent("onBeforeSiteDelete",pluginEvent)>

		<cfset bean.getRazunaSettings().delete()>

		<cfset variables.utility.logEvent("SiteID:#arguments.siteid# Site:#bean.getSite()# was deleted","mura-settings","Information",true) />
		<cfset variables.DAO.delete(arguments.siteid) />
		
		<cfset pruneSite(bean.getSiteID()) />

		<cftry>
		<cfset variables.utility.deleteDir("#variables.configBean.getSiteDir()#/#arguments.siteid#/") />
		<cfcatch></cfcatch>
		</cftry>
		<cftry>
		<cfset variables.utility.deleteDir("#variables.configBean.getFileDir()#/#arguments.siteid#/") />
		<cfcatch></cfcatch>
		</cftry>
		<cftry>
		<cfset variables.utility.deleteDir("#variables.configBean.getAssetDir()#/#arguments.siteid#/") />
		<cfcatch></cfcatch>
		</cftry>

		<cfif variables.configBean.getValue(property="individualsitebuilds", defaultValue=false)>
			<cfset buildSite(bean.getSiteID())>
			<cfset getBean('clusterManager').broadcastCommand("getBean('settingsManager').buildSite('#bean.getSiteID()#')")>
		<cfelse>
			<cfset application.appInitialized=false>
			<cfset getBean('clusterManager').reload()>
		</cfif>

		<cfset getBean('pluginManager').announceEvent("onAfterSiteDelete",pluginEvent)>
	</cffunction>

	<cffunction name="create" output="false">
		<cfargument name="data" type="struct" />
		<cfset var rs=""/>
		<cfset var bean=getBean("settingsBean") />
		<cfset var pluginEvent = new mura.event(arguments.data) />

		<cfset bean.set(arguments.data) />
		<cfset pluginEvent.setValue('settingsBean',bean)>
		<cfset bean.setModuleID("00000000000000000000000000000000000")>
		<cfset bean.validate()>

		<cfset getBean('pluginManager').announceEvent("onBeforeSiteCreate",pluginEvent)>
		<cfset getBean('pluginManager').announceEvent("onBeforeSiteSave",pluginEvent)>

		<cfif structIsEmpty(bean.getErrors()) and  bean.getSiteID() neq ''>
			<cfquery name="rs" datasource="#variables.configBean.getReadOnlyDatasource()#" username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#">
				select siteid from tsettings where siteid='#bean.getSiteID()#'
			</cfquery>

			<cfif rs.recordcount>
				<cfparam name="arguments.data.autocreated" default="false">
				<cfif isBoolean(arguments.data.autocreated) and arguments.data.autocreated>
					<cfreturn>
				<cfelse>
					<cfthrow message="The SiteID you entered is already being used.">
					<cfabort>
				</cfif>
			</cfif>

			<!---
			<cfif directoryExists("#variables.configBean.getSiteDir()#/#bean.getSiteID()#")>
				<cfthrow message="A directory with the same name as the SiteID you entered is already being used.">
			</cfif>
			--->
		
			<cfset variables.utility.logEvent("SiteID:#bean.getSiteID()# Site:#bean.getSite()# was created","mura-settings","Information",true) />
			<cfif structKeyExists(arguments.data,"extendSetID") and len(arguments.data.extendSetID)>
				<cfset variables.classExtensionManager.saveExtendedData(bean.getBaseID(),bean.getAllValues())/>
			</cfif>
			
			<cfif len(bean.getNewPlaceholderImg())>
				<cfset local.fileBean=getBean('file')>
				<cfset local.fileBean.setSiteID(bean.getSiteID())>
				<cfset local.fileBean.setModuleID('')>
				<cfset local.fileBean.setFileField('newPlaceholderImg')>
				<cfset local.fileBean.setNewFile(bean.getNewPlaceholderImg())>
				<cfset local.fileBean.save()>
				<cfset bean.setPlaceholderImgID(local.fileBean.getFileID()) />
				<cfset bean.setPlaceholderImgExt(local.fileBean.getFileExt()) />
			</cfif>

			<cfset local.oauthsettingbean = getBean('oauthSetting').loadBy(siteid=bean.getSiteID())/>
			<cfif isDefined("arguments.data.allowedDomain")>
				<cfset local.oauthsettingbean.setAllowedDomain(arguments.data.allowedDomain)/>
			</cfif>
			<cfif isDefined("arguments.data.allowedAdminDomain")>
				<cfset local.oauthsettingbean.setAllowedAdminDomain(arguments.data.allowedAdminDomain)/>
			</cfif>
			<cfif isDefined("arguments.data.allowedAdminGroupEmailList")>
				<cfset local.oauthsettingbean.setAllowedAdminGroupEmailList(arguments.data.allowedAdminGroupEmailList)/>
			</cfif>
			<cfif isDefined("arguments.data.allowedS2EmailList")>
				<cfset local.oauthsettingbean.setAllowedS2EmailList(arguments.data.allowedS2EmailList)/>
			</cfif>
			
			<cfset local.oauthsettingbean.save()/>
	
			<cfset variables.DAO.create(bean) />

			<cfset var fileDelim=variables.configBean.getFileDelim()>

			<cfif variables.configBean.getCreateRequiredDirectories()>
				<cfset variables.utility.createRequiredSiteDirectories(bean.getSiteID(),bean.getDisplayPoolID()) />
			</cfif>

			<cfset checkForBundle(arguments.data,bean.getErrors())>
		
			<cfif variables.configBean.getValue(property="individualsitebuilds", defaultValue=false)>
				<cfset buildSite(bean.getSiteID())>
				<cfset getBean('clusterManager').broadcastCommand("getBean('settingsManager').buildSite('#bean.getSiteID()#')")>
			<cfelse>
				<cfset application.appInitialized=false>
				<cfset getBean('clusterManager').reload()>
			</cfif>
			
			<cfset getBean('pluginManager').announceEvent("onAfterSiteCreate",pluginEvent)>
			<cfset getBean('pluginManager').announceEvent("onAfterSiteSave",pluginEvent)>
		</cfif>

		<cfreturn bean />
	</cffunction>


	<cffunction name="getDeferredGlobalModuleAssets" output="false">
		<cfargument name="reset" default="false">
		<cfif arguments.reset or not isDefined('variables.DeferredGlobalModuleAssets')>
			<cfset variables.DeferredGlobalModuleAssets={
				assets=[],
				template=getBean('site')
			}>
	
			<cfset request.muraDeferredModuleErrors=[]>
			<cfset variables.DeferredGlobalModuleAssets.assets=variables.DeferredGlobalModuleAssets.template.discoverGlobalModules(variables.DeferredGlobalModuleAssets.assets)>
			<cfset variables.DeferredGlobalModuleAssets.assets=variables.DeferredGlobalModuleAssets.template.discoverGlobalContentTypes(variables.DeferredGlobalModuleAssets.assets)>
		</cfif>
	
		<cfreturn variables.DeferredGlobalModuleAssets>
	</cffunction>

	<cffunction name="getDeferredSiteModuleAssets" output="false">
		<cfargument name="siteid"/>
		<cfargument name="reset" default="false">

		<cfif arguments.reset  or not structKeyExists(variables,'DeferredSiteModuleAssets#arguments.siteid#')>
			<cfset variables['DeferredSiteModuleAssets#arguments.siteid#']={
				assets=[],
				template=getBean('site')
			}>

			<cfset variables['DeferredSiteModuleAssets#arguments.siteid#'].template.setSiteId(arguments.siteid)>
			<cfset variables['DeferredSiteModuleAssets#arguments.siteid#'].template.setDisplayPoolID(getBean('settingsManager').getSite(arguments.siteid).getDisplayPoolID())>
			
			<cfparam name="request.muraDeferredModuleErrors" default="#arrayNew(1)#">

			<cfset variables['DeferredSiteModuleAssets#arguments.siteid#'].assets=variables['DeferredSiteModuleAssets#arguments.siteid#'].template.discoverSiteModules(variables['DeferredSiteModuleAssets#arguments.siteid#'].assets)>
			<cfset variables['DeferredSiteModuleAssets#arguments.siteid#'].assets=variables['DeferredSiteModuleAssets#arguments.siteid#'].template.discoverSitePluginModules(variables['DeferredSiteModuleAssets#arguments.siteid#'].assets)>
			<cfset variables['DeferredSiteModuleAssets#arguments.siteid#'].assets=variables['DeferredSiteModuleAssets#arguments.siteid#'].template.discoverSiteContentTypes(variables['DeferredSiteModuleAssets#arguments.siteid#'].assets)>
		</cfif>

		<cfreturn variables['DeferredSiteModuleAssets#arguments.siteid#']>
	</cffunction>
	<cffunction name="getDeferredThemeModuleAssets" output="false">
		<cfargument name="theme"/>
		<cfargument name="reset" default="false">
		
		<cfif arguments.reset or not structKeyExists(variables,'DeferredThemeModuleAssets#arguments.theme#')>
			<cfset variables['DeferredThemeModuleAssets#arguments.theme#']={
				assets=[],
				template=getBean('site')
			}>

			<cfset variables['DeferredThemeModuleAssets#arguments.theme#'].template.setTheme(arguments.theme)>

			<cfparam name="request.muraDeferredModuleErrors" default="#arrayNew(1)#">

			<cfset variables['DeferredThemeModuleAssets#arguments.theme#'].assets=variables['DeferredThemeModuleAssets#arguments.theme#'].template.discoverThemeModules(variables['DeferredThemeModuleAssets#arguments.theme#'].assets)>
			<cfset variables['DeferredThemeModuleAssets#arguments.theme#'].assets=variables['DeferredThemeModuleAssets#arguments.theme#'].template.discoverThemeContentTypes(variables['DeferredThemeModuleAssets#arguments.theme#'].assets)>
		</cfif>

		<cfreturn variables['DeferredThemeModuleAssets#arguments.theme#']>
	</cffunction>

	<cffunction name="isSiteBuilt" output="false">
		<cfargument name="siteid" default="default">
		<cfreturn structKeyExists(variables.sites,'#arguments.siteid#')>
	</cffunction>

	<cffunction name="buildSite" output="false">
		<cfargument name="siteid" default="default">
		<cfargument name="resetEvents" default="false">
		<cfset request.buildsiteid=arguments.siteid>
		<cfparam name="request.siteid" default="">
		<cfset var requestSiteid=request.siteid>
		<cftry>
			<cfset setSites(buildSiteID=arguments.siteid,resetEvents=arguments.resetEvents)>
			<cfset variables.gateway.invalidateSiteListCache()>
			<cfset request.siteid=requestSiteid>
			<cfcatch>
				<cfset request.siteid=requestSiteid>
				<cfset application.Mura.status['#request.buildSiteID#']='live'>
				<cfrethrow>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="pruneSite" output="false">
		<cfargument name="siteid" default="default">
		<cfset structDelete(variables.sites,arguments.siteid)>
		<cfset variables.gateway.invalidateSiteListCache()>
		<cfset getBean('pluginManager').prundeSiteEvents(arguments.siteid)>
	</cffunction>

	<cffunction name="setSites" output="false">
		<cfargument name="missingOnly" default="false">
		<cfargument name="buildSiteID" default="">
		<cfargument name="resetEvents" default="false">

		<cflock name="setSites#buildSiteID##application.instanceID#" type="exclusive" timeout="200">
			<cfset var rs="" />
			<cfset var builtSites=structNew()>
			<cfset var foundSites=structNew()>
			<cfset var i="">
			<cfset var tracepoint1=''>
			<cfset var tracepoint2=''>
			<cfset var tracepoint3=''>
			
			<cfif (
					arguments.missingOnly
					or len(arguments.buildSiteID)
				)>
				<cfif len(arguments.buildSiteID)>
					<cfset variables.gateway.invalidateSiteListCache()>
					<cfset rs=getList()>
					<cfquery name="rs" dbtype="query">
						select * from rs where siteid=<cfqueryparam value="#arguments.buildSiteID#">
					</cfquery>
					<cfif not rs.recordcount>
						<cfreturn false>
					</cfif>
				<cfelse>	
					<cfset rs=getList()>
				</cfif>
			<cfelse>
				<cfset request.MuraAPIReset=true>
				<cfset variables.gateway.invalidateSiteListCache()>
				<cfset rs=getList()>
			</cfif>
	
			<cfset tracepoint1=initTracepoint("Loading global modules")>
			<cfset var globalTemplate=getDeferredGlobalModuleAssets()>
			<cfset var themeTemplateLookUp={}>
			<cfset commitTracepoint(tracepoint1)>

			<cfif not isDefined('request.muraBaseRBFactory')>
				<cfset request.muraBaseRBFactory=globalTemplate.template.getRBFactory()>
			</cfif>
		
			<cfparam name="variables.sites" default="#structNew()#">

			<cfset tracepoint1=initTracepoint("Checking required directories")>

			<cfif len(arguments.buildSiteID)>
				<cfset application.Mura.status['#arguments.buildSiteID#']='building'>
				<cfif arguments.resetEvents>
					<cfset getBean('pluginManager').resetSiteEvents(arguments.buildSiteID)>
				</cfif>
				<cfset arguments.missingOnly=true>
				<cfset builtSites['#arguments.buildSiteID#']=variables.DAO.read(arguments.buildSiteID) />
				<cfset foundSites['#arguments.buildSiteID#']=true>
				<cfif variables.configBean.getCreateRequiredDirectories()>
					<cfset variables.utility.createRequiredSiteDirectories(arguments.buildSiteID,builtSites['#arguments.buildSiteID#'].getDisplayPoolID()) />
				</cfif>	
			<cfelse>
				<cfloop query="rs">
					<cfif arguments.missingOnly and structKeyExists(variables.sites,'#rs.siteid#')>
						<cfset builtSites['#rs.siteid#']=variables.sites['#rs.siteid#'] />
					<cfelse>
						<cfset builtSites['#rs.siteid#']=variables.DAO.read(rs.siteid) />
						<cfset foundSites['#rs.siteid#']=true>
					</cfif>
					<cfif variables.configBean.getCreateRequiredDirectories()>
						<cfset variables.utility.createRequiredSiteDirectories(rs.siteid,builtSites['#rs.siteid#'].getDisplayPoolID()) />
					</cfif>
				</cfloop>
			</cfif>
			
			<cfset commitTracepoint(tracepoint1)>
			
			<cfif len(arguments.buildSiteID)>
				<cfset variables.sites['#arguments.buildSiteID#']=builtSites['#arguments.buildSiteID#']>
			<cfelse>
				<cfset variables.sites=builtSites>
			</cfif>

			<cfset tracepoint1=initTracepoint("Loading global model directories")>
			<cfif arrayLen(globalTemplate.assets)>
				<cfif arguments.missingOnly>
					<cfloop from="1" to="#arrayLen(globalTemplate.assets)#" index="i">
						<cfif structKeyExists(globalTemplate.assets[i],'modelDir') and len(globalTemplate.assets[i].modelDir)>
							<cfset variables.configBean.registerBeanDir(dir=globalTemplate.assets[i].modelDir,package=globalTemplate.assets[i].package,siteid=structKeyList(foundSites))>
						</cfif>
					</cfloop>
				<cfelse>
					<cfloop from="1" to="#arrayLen(globalTemplate.assets)#" index="i">
						<cfif structKeyExists(globalTemplate.assets[i],'modelDir') and len(globalTemplate.assets[i].modelDir)>
							<cfset variables.configBean.registerBeanDir(dir=globalTemplate.assets[i].modelDir,package=globalTemplate.assets[i].package,siteid=valuelist(rs.siteid))>
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
			<cfset commitTracepoint(tracepoint1)>

			<cfset tracepoint1=initTracepoint("Loading theme templates")>
			<cfloop query="rs">
				<cfif not arguments.missingOnly or arguments.missingOnly and structKeyExists(foundSites,'#rs.siteid#')>
					<!--- this sets haslocaltheme --->
					<cfset builtSites['#rs.siteid#'].getThemeIncludePath()>

					<cfif not builtSites['#rs.siteid#'].get('haslocaltheme')>
						<cfset var theme=builtSites['#rs.siteid#'].getTheme()>
						<cfif not structKeyExists(themeTemplateLookUp,theme)>
							<cfset tracepoint2=initTracepoint("Loading theme modules: #theme#")>
							<cfset themeTemplateLookUp['#theme#']=getDeferredThemeModuleAssets(theme=theme)>
							<cfset commitTracepoint(tracepoint2)>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
			<cfset commitTracepoint(tracepoint1)>
			
			<cfset tracepoint1=initTracepoint("Loading sites")>
			<cfloop query="rs">
				<cfif structKeyExists(foundSites,'#rs.siteid#')>
					<cfset builtSites['#rs.siteid#'].getRBFactory()>
					<cfset tracepoint2=initTracepoint("Loading site: #rs.siteid#")>
					<cfset tracepoint3=initTracepoint("Loading global assets: #rs.siteid#")>
					<cfif arrayLen(globalTemplate.assets)>
						<cfloop from="1" to="#arrayLen(globalTemplate.assets)#" index="i">
							<!--- class extensions need to be loaded into target sites--->
							<cfif structKeyExists(globalTemplate.assets[i],'config')>
								<cfset variables.configBean.getClassExtensionManager().loadConfigXML(globalTemplate.assets[i].config,rs.siteid)>
							</cfif>
							<!--- each site can have a difference locale--->
							<cfif structKeyExists(globalTemplate.assets[i],'rbDir') and len(globalTemplate.assets[i].rbDir)>
								<cfset builtSites['#rs.siteid#'].setRBFactory(
									new mura.resourceBundle.resourceBundleFactory(
										builtSites['#rs.siteid#'].getRBFactory(),
										globalTemplate.assets[i].rbDir,
										builtSites['#rs.siteid#'].getJavaLocale()
									)
								)>
							</cfif>
						</cfloop>
					</cfif>
					<cfset commitTracepoint(tracepoint3)>

					<cfset tracepoint3=initTracepoint("Loading local assets: #rs.siteid#")>
					
					<cfif builtSites['#rs.siteid#'].get('haslocaltheme')>

						<cfset builtSites['#rs.siteid#']
							.set('displayObjectLookup',duplicate(globalTemplate.template.get('displayObjectLookup')))
							.set('displayObjectLookUpArray',duplicate(globalTemplate.template.get('displayObjectLookUpArray')))>

						<cfset builtSites['#rs.siteid#']
							.set('contentTypeLookUpArray',duplicate(globalTemplate.template.get('contentTypeLookUpArray')))>
						
						<cfset builtSites['#rs.siteid#'].discoverSiteModules()>
						<cfset builtSites['#rs.siteid#'].discoverSitePluginModules()>
						<cfset builtSites['#rs.siteid#'].discoverSiteContentTypes()>

						<cfset builtSites['#rs.siteid#'].discoverThemeModules()>
						<cfset builtSites['#rs.siteid#'].discoverThemeContentTypes()>

						<cfset builtSites['#rs.siteid#'].discoverBeans()>

						<cfset builtSites['#rs.siteid#'].discoverProxies()>

					<cfelse>
						
						<cfset var theme=builtSites['#rs.siteid#'].getTheme()>
						
						<!--- Add global module values --->
						<cfset builtSites['#rs.siteid#'].set(
								'displayObjectLookup',
								duplicate(globalTemplate.template.get('displayObjectLookup') ) 
							)
							.set(
								'displayObjectLookUpArray',
								duplicate(globalTemplate.template.get('displayObjectLookUpArray'))
							)
						>

						<cfif getBean('configBean').getValue(property="siteLevelModules",defaultValue=true)>
							<cfset builtSites['#rs.siteid#'].discoverSiteModules()>
						</cfif>
						<cfset builtSites['#rs.siteid#'].discoverSitePluginModules()>

						<cfset structAppend(
							builtSites['#rs.siteid#'].get('displayObjectLookup'),
							themeTemplateLookUp[theme].template.get('displayObjectLookup')
						)>

						<cfset var from=themeTemplateLookUp[theme].template.get('displayObjectLookUpArray')>
						<cfset var to=builtSites['#rs.siteid#'].get('displayObjectLookUpArray')>

						<cfif arrayLen(from)>
							<cfloop from="#arrayLen(from)#" to="1" step="-1" index="i">
								<cfset arrayPrepend(to, from[i])>
							</cfloop>
						</cfif>

						<cfset builtSites['#rs.siteid#'].set('displayObjectLookUpArray',to)>

						<!--- Add global content type values --->
						<cfset builtSites['#rs.siteid#'].set(
								'contentTypeLookUpArray',
								duplicate(globalTemplate.template.get('contentTypeLookUpArray'))
							)
						>

						<cfif getBean('configBean').getValue(property="siteLevelModules",defaultValue=true)>
							<cfset builtSites['#rs.siteid#'].discoverSiteContentTypes()>
						</cfif>

						<cfset var from=themeTemplateLookUp[theme].template.get('contentTypeLookUpArray')>
						<cfset var to=builtSites['#rs.siteid#'].get('contentTypeLookUpArray')>

						<cfif arrayLen(from)>
							<cfloop from="#arrayLen(from)#" to="1" step="-1" index="i">
								<cfset arrayPrepend(to, from[i])>
							</cfloop>
						</cfif>
					
						<cfset builtSites['#rs.siteid#'].set('contentTypeLookUpArray',to)>

						<cfset builtSites['#rs.siteid#'].discoverBeans()>
			

						<cfset builtSites['#rs.siteid#'].discoverProxies()>
						<cfset commitTracepoint(tracepoint3)>

						<cfset tracepoint3=initTracepoint("Loading theme assets: #rs.siteid#")>
						
						<cfif arrayLen(themeTemplateLookUp[theme].assets)>
							<cfloop from="1" to="#arrayLen(themeTemplateLookUp[theme].assets)#" index="i">
								<cfif structKeyExists(themeTemplateLookUp[theme].assets[i],'config')>
									<cfset variables.configBean.getClassExtensionManager().loadConfigXML(themeTemplateLookUp[theme].assets[i].config,rs.siteid)>
								</cfif>
								<cfif structKeyExists(themeTemplateLookUp[theme].assets[i],'modelDir') and len(themeTemplateLookUp[theme].assets[i].modelDir)>
									<cfset variables.configBean.registerBeanDir(dir=themeTemplateLookUp[theme].assets[i].modelDir,package=themeTemplateLookUp[theme].assets[i].package,siteid=rs.siteid)>
								</cfif>
								<cfif structKeyExists(themeTemplateLookUp[theme].assets[i],'rbDir') and len(themeTemplateLookUp[theme].assets[i].rbDir)>
								
									<cfset builtSites['#rs.siteid#'].setRBFactory(
										new mura.resourceBundle.resourceBundleFactory(
											builtSites['#rs.siteid#'].getRBFactory(),
											themeTemplateLookUp[theme].assets[i].rbDir,
											builtSites['#rs.siteid#'].getJavaLocale()
										)
									)>
								</cfif>
							</cfloop>
						</cfif>
						
					</cfif>

					<cfset var themeRBDir1=expandPath(builtSites['#rs.siteid#'].getThemeIncludePath()) & "/resourceBundles/">
					<cfset var themeRBDir2=expandPath(builtSites['#rs.siteid#'].getThemeIncludePath()) & "/resource_bundles/">

					<cfif directoryExists(themeRBDir1)>
						<cfset builtSites['#rs.siteid#'].setRBFactory(
								new mura.resourceBundle.resourceBundleFactory(
									builtSites['#rs.siteid#'].getRBFactory(),
									themeRBDir1,
									builtSites['#rs.siteid#'].getJavaLocale()
								)
							)>
					<cfelseif directoryExists(themeRBDir2)>
						<cfset builtSites['#rs.siteid#'].setRBFactory(
								new mura.resourceBundle.resourceBundleFactory(
									builtSites['#rs.siteid#'].getRBFactory(),
									themeRBDir2,
									builtSites['#rs.siteid#'].getJavaLocale()
								)
							)>
					</cfif>

					<cfset  builtSites['#rs.siteid#'].loadClientConfigs()>
					
					<cfset commitTracepoint(tracepoint3)>
					<cfset commitTracepoint(tracepoint2)>
				</cfif>
			</cfloop>

			<cfif isDefined('request.MuraAPIReset') and request.MuraAPIReset and isDefined('request.MuraAPIConfig')>
				<cfset application.MuraAPIConfig=request.MuraAPIConfig>
			</cfif>
			
			<cfif len(arguments.buildSiteID)>
				<cfif arguments.resetEvents>
					<cfset variables.sites[arguments.buildSiteID].runSiteAndThemeApplicationLoad()>
					<cfset getBean('pluginManager').rerunModuleBasedApplicationLoad()>
				</cfif>
				<cfset application.Mura.status['#arguments.buildSiteID#']='live'>
			</cfif>
	
			<cfset commitTracepoint(tracepoint1)>
		</cflock>
	</cffunction>

	<cffunction name="getSite" output="false">
		<cfargument name="siteid" type="string" />
		<cfif not len(arguments.siteid)>
			<cfset arguments.siteid='default'>
		</cfif>

		<cfparam name="variables.sites" default="#structNew()#">

		<cfif structKeyExists(variables.sites,'#arguments.siteid#')>
			<cfreturn variables.sites['#arguments.siteid#']>
		<cfelseif siteExists(arguments.siteid)>
			<cfset buildSite(siteid=arguments.siteid,resetEvents=true) />	
			<cfif structKeyExists(variables.sites,'#arguments.siteid#')>
				<cfreturn variables.sites['#arguments.siteid#'] />
			<cfelse>
				<cfreturn variables.sites['default'] />
			</cfif>
		<cfelse>
			<cfreturn variables.sites['default'] />
		</cfif>
		
	</cffunction>

	<cffunction name="siteExists" output="false">
		<cfargument name="siteid" type="string" />
		<cfset var rs=queryExecute("select siteid from tsettings where siteid = :siteid", {siteid=arguments.siteid})>
		<cfreturn (rs.recordcount ? true : false)>
	</cffunction>

	<cffunction name="getSites" output="false">
		<cfparam name="variables.sites" default="#structNew()#">
		<cfreturn variables.sites />
	</cffunction>

	<cffunction name="getSiteCustomTemplates" output="false">
		<cfargument name="siteid" type="string" />

		<cfreturn variables.DAO.getCustomTemplates(arguments.siteid) />
	</cffunction>

	<cffunction name="purgeAllCache" output="false">
		<cfargument name="broadcast" default="true">
		<cfset var rs=getList()>

		<cfloop query="rs">
			<cfset getSite(rs.siteid).getCacheFactory(name="data").purgeAll()/>
			<cfset getSite(rs.siteid).getCacheFactory(name="output").purgeAll()/>
		</cfloop>

		<cfif arguments.broadcast>
			<cfset variables.clusterManager.purgeCache(name="all")>
		</cfif>
	</cffunction>

	<cffunction name="getUserSites" output="false">
		<cfargument name="siteArray" type="array" required="yes" default="#arrayNew(1)#">
		<cfargument name="isS2" type="boolean" required="yes" default="false">
		<cfargument name="searchString" type="string" required="no" default="">
		<cfargument name="searchMaxRows" type="numeric" required="no" default="-1">

		<cfset var rsSites=""/>
		<cfset var counter=1/>
		<cfset var rsAllSites=getList(sortby="site")/>
		<cfset var s=0/>
		<cfset var where=false/>

		<cfquery name="rsSites" dbtype="query" maxrows="#arguments.searchMaxRows#">
			select * from rsAllSites
			<cfif arrayLen(arguments.siteArray) and not arguments.isS2>
				<cfset where=true/>
				where siteid in (
				<cfloop from="1" to="#arrayLen(arguments.siteArray)#" index="s">
				'#arguments.siteArray['#s#']#'
				<cfif counter lt arrayLen(arguments.siteArray)>,</cfif>
				<cfset counter=counter+1>
				</cfloop>)
			<cfelseif not arrayLen(arguments.siteArray) and not arguments.isS2>
			<cfset where=true/>
			where 0=1
			</cfif>
			<cfif arguments.searchString neq "">
			<cfif where>
			and
			<cfelse>
			where
			</cfif>
			(
				siteid like <cfqueryparam value="%#arguments.searchString#%">
			or	Site like <cfqueryparam value="%#arguments.searchString#%">
			)
			</cfif>

		</cfquery>

		<cfreturn rsSites />
	</cffunction>

	<cffunction name="checkForBundle" output="false">
		<cfargument name="data">
		<cfargument name="errors">
		
		<cfset var fileManager=getBean("fileManager")>
		<cfset var tempfile="">
		<cfset var deletetempfile=true>

		<cfif isDefined("arguments.data.serverBundlePath") and len(arguments.data.serverBundlePath) and fileExists(arguments.data.serverBundlePath)>
			<cfset arguments.data.bundleFile=arguments.data.serverBundlePath>
		</cfif>

		<cfif structKeyExists(arguments.data,"bundleFile") and len(arguments.data.bundleFile)>
			<cfif fileManager.isPostedFile(arguments.data.bundleFile)>
				<cffile action="upload" result="tempFile" filefield="bundleFile" nameconflict="makeunique" destination="#variables.configBean.getTempDir()#">
			<cfelse>
				<cfset tempFile=fileManager.emulateUpload(arguments.data.bundleFile)>
				<cfset deletetempfile=true>
			</cfif>
			<cfparam name="arguments.data.bundleImportKeyMode" default="copy">
			<cfparam name="arguments.data.bundleImportContentMode" default="none">
			<cfparam name="arguments.data.bundleImportRenderingMode" default="none">
			<cfparam name="arguments.data.bundleImportPluginMode" default="none">
			<cfparam name="arguments.data.bundleImportMailingListMembersMode" default="none">
			<cfparam name="arguments.data.bundleImportUsersMode" default="none">
			<cfparam name="arguments.data.bundleImportFormDataMode" default="none">
			<cfset restoreBundle(
				"#tempfile.serverDirectory#/#tempfile.serverFilename#.#tempfile.serverFileExt#" ,
				arguments.data.siteID,
				arguments.errors,
				arguments.data.bundleImportKeyMode,
				arguments.data.bundleImportContentMode,
				arguments.data.bundleImportRenderingMode,
				arguments.data.bundleImportMailingListMembersMode,
				arguments.data.bundleImportUsersMode,
				arguments.data.bundleImportPluginMode,
				'',
				'',
				arguments.data.bundleImportFormDataMode
				)>
			<cfif deletetempfile>
				<cffile action="delete" file="#tempfile.serverDirectory#/#tempfile.serverFilename#.#tempfile.serverFileExt#">
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="restoreBundle" output="false">
		<cfargument name="bundleFile">
		<cfargument name="siteID" default="">
		<cfargument name="errors" default="#structNew()#">
		<cfargument name="keyMode" default="copy">
		<cfargument name="contentMode" default="none">
		<cfargument name="renderingMode" default="none">
		<cfargument name="mailingListMembersMode" default="none">
		<cfargument name="usersMode" default="none">
		<cfargument name="pluginMode" default="none">
		<cfargument name="lastDeployment" default="">
		<cfargument name="moduleID" default="">
		<cfargument name="formDataMode" default="none">

		<cfparam name="application.appBundleRestore" default="#structNew()#">

		<cfset application.appBundleRestore['#arguments.siteid#']=now()>

		<cfset var sArgs			= structNew()>
		<cfset var config 			= application.configBean />
		<cfset var Bundle			= getBean("bundle") />
		<cfset var publisher 		= getBean("publisher") />
		<cfset var keyFactory		= new mura.publisherKeys(arguments.keyMode,application.utility)>
		<cfsetting requestTimeout = "7200">

		<cfset Bundle.restore( arguments.BundleFile)>

		<cfset sArgs.fromDSN		= config.getDatasource() />
		<cfset sArgs.toDSN			= config.getDatasource() />
		<cfset sArgs.fromSiteID		= "" />
		<cfset sArgs.toSiteID		= arguments.siteID />
		<cfset sArgs.contentMode			= arguments.contentMode />
		<cfset sArgs.keyMode			= arguments.keyMode />
		<cfset sArgs.renderingMode			= arguments.renderingMode />
		<cfset sArgs.mailingListMembersMode			= arguments.mailingListMembersMode />
		<cfset sArgs.usersMode			= arguments.usersMode />
		<cfset sArgs.formDataMode			= arguments.formDataMode />
		<cfset sArgs.keyFactory		= keyFactory />
		<cfset sArgs.pluginMode		= arguments.pluginMode  />
		<cfset sArgs.Bundle		= Bundle />
		<cfset sArgs.moduleID		= arguments.moduleID />
		<cfset sArgs.errors			= arguments.errors />
		<cfset sArgs.lastDeployment = arguments.lastDeployment />

		<cftry>
			<cfset publisher.getToWork( argumentCollection=sArgs )>

			<cfif len(arguments.siteID)>
				<!-- Legacy data updates --->
				<cfquery>
					update tclassextend set type='Folder' where type in ('Portal','LocalRepo')
				</cfquery>
				<cfquery>
					update tcontent set type='Folder' where type in ('Portal','LocalRepo')
				</cfquery>
				<cfquery>
					update tsystemobjects set
					object='folder_nav',
					name='Folder Navigation'
					where object='portal_nav'
				</cfquery>
				<!--- --->

				<cfset getSite(arguments.siteID).getCacheFactory(name="output").purgeAll()>
				<cfif sArgs.contentMode neq "none">
					<cfset getSite(arguments.siteID).getCacheFactory(name="data").purgeAll()>
					<cfset getBean("contentUtility").updateGlobalMaterializedPath(siteID=arguments.siteID)>
				</cfif>
				<cfif sArgs.pluginMode neq "none">
					<cfset getBean("pluginManager").loadPlugins()>
				</cfif>
			</cfif>

			<cfset buildSite(arguments.siteid)>
			<cfset getBean('clusterManager').broadcastCommand("getBean('settingsManager').buildSite('#arguments.siteid#')")>
			

		<cfcatch>

			<cfset logError(cfcatch)>

			<cfset arguments.errors.message="The bundle was not successfully imported:<br/>ERROR (Full Details Available in 'exception' Log)<br/>: " & cfcatch.message>
			<cfif findNoCase("duplicate",errors.message)>
				<cfset arguments.errors.message=arguments.errors.message & "<br/>HINT: This error is most often caused by 'Maintaining Keys' when the bundle data already exists within another site in the current Mura instance.">
			</cfif>
			<cfif isDefined("cfcatch.sql") and len(cfcatch.sql)>
				<cfset argumefnts.errors.message=arguments.errors.message & "<br/>SQL: " & cfcatch.sql>
			</cfif>
			<cfif isDefined("cfcatch.detail") and len(cfcatch.detail)>
				<cfset arguments.errors.message=arguments.errors.message & "<br/>DETAIL: " & cfcatch.detail>
			</cfif>
			<cfif isDefined("cfcatch.cause.stacktrace") and len(cfcatch.cause.stacktrace)>
				<cfset arguments.errors.message=arguments.errors.message & "<br/>EXTENDED INFO: " & cfcatch.cause.stacktrace>
			</cfif>
		</cfcatch>
		</cftry>

		<cfset structDelete(application.appBundleRestore,'#arguments.siteid#')>

		<cfreturn arguments.errors>
	</cffunction>

	<cffunction name="isBundle" output="false">
		<cfargument name="BundleFile">
		<cfset var rs=new mura.Zip().List(zipFilePath="#arguments.BundleFile#")>

		<cfquery name="rs" dbType="query">
			select entry from rs where entry in ('sitefiles.zip','pluginfiles.zip','filefiles.zip','pluginfiles.zip')
		</cfquery>
		<cfreturn rs.recordcount>
	</cffunction>

	<cffunction name="isPartialBundle" output="false">
		<cfargument name="BundleFile">
		<cfset var rs=new mura.Zip().List(zipFilePath="#arguments.BundleFile#")>

		<cfquery name="rs" dbType="query">
			select entry from rs where entry in ('assetfiles.zip')
		</cfquery>
		<cfreturn rs.recordcount>
	</cffunction>

	<cffunction name="createCacheFactory" output="false">
		<cfargument name="freeMemoryThreshold" required="true" default="60">
		<cfargument name="name" required="true" default="output">
		<cfargument name="siteid" required="true">
		<cfif variables.configBean.getValue(property='advancedCaching',defaultValue=false)>
			<cfreturn new mura.cache.cacheAdvanced(name=arguments.name,siteid=arguments.siteid)>
		<cfelse>
			<cfreturn new mura.cache.cacheSimple(freeMemoryThreshold=arguments.freeMemoryThreshold)>
		</cfif>
	</cffunction>

	<cffunction name="save" output="false">
		<cfargument name="data" type="any" default="#structnew()#"/>

		<cfset var siteID="">
		<cfset var rs="">

		<cfif isObject(arguments.data)>
			<cfif listLast(getMetaData(arguments.data).name,".") eq "settingsBean">
				<cfset arguments.data=arguments.data.getAllValues()>
			<cfelse>
				<cfthrow type="custom" message="The attribute 'DATA' is not of type 'mura.settings.settingsBean'">
			</cfif>
		</cfif>

		<cfif not structKeyExists(arguments.data,"siteID")>
			<cfthrow type="custom" message="The attribute 'SITEID' is required when saving a site settingsBean.">
		</cfif>

		<cfquery datasource="#variables.configBean.getReadOnlyDatasource()#" username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#" name="rs">
		select siteID from tsettings where siteID=<cfqueryparam value="#arguments.data.siteID#">
		</cfquery>

		<cfif rs.recordcount>
			<cfreturn update(arguments.data)>
		<cfelse>
			<cfreturn create(arguments.data)>
		</cfif>
	</cffunction>

	<cffunction name="remoteReload" output="false">
		<cfset application.appInitialized=false>
		<cfset application.broadcastInit=false>
	</cffunction>

	<cffunction name="getAccessControlOriginDomainList" output="false">
		<cfargument name="reset" default="false">
		<cfscript>
			if(arguments.reset || !isDefined("variables.AccessControlOriginDomainList")){
				lock name="origindomainlist#application.instanceid#" type="exclusive" timeout="10"{
					var buildList='';

					var admindomain=variables.configBean.getAdminDomain();

					if(len(admindomain)){
						buildList=listAppend(buildList,admindomain);
					}

					var sites=getList();
					var originArray=[];
					var origin='';

					for(var site in sites){
						originArray=listToArray(formatAccessControlOriginDomainList(site));
						if(arrayLen(originArray)){
							for(origin in originArray){
								if(!listFind(buildList,origin)){
									buildList=listAppend(buildList,origin);
								}
							}
						}

					}
					variables.AccessControlOriginDomainList=buildList;
				}
			}

			return variables.AccessControlOriginDomainList;

		</cfscript>
	</cffunction>

	<cffunction name="getAccessControlOriginDomainArray" output="false">
		<cfscript>
			if(!isDefined("variables.AccessControlOriginDomainArray")){
				variables.AccessControlOriginDomainArray=listToArray(getAccessControlOriginDomainList());
			}

			return variables.AccessControlOriginDomainArray;

		</cfscript>
	</cffunction>

	<cfscript>
		function formatAccessControlOriginDomainList(siteStruct) output=false {
			var thelist=arguments.siteStruct.domain;
			var i="";
			var lineBreak=chr(13)&chr(10);

			if ( len(application.configBean.getAdminDomain()) ) {
				if ( !ListFindNoCase(thelist, application.configBean.getAdminDomain()) ) {
					thelist = listAppend(thelist,application.configBean.getAdminDomain());
				}
			}

			if ( isBoolean(arguments.siteStruct.isRemote) && arguments.siteStruct.isRemote && len(arguments.siteStruct.resourceDomain) ) {
				if ( !ListFindNoCase(thelist, arguments.siteStruct.resourceDomain) ) {
					thelist = listAppend(thelist,arguments.siteStruct.resourceDomain);
				}
			}

			if ( len(arguments.siteStruct.domainAlias) ) {
				for(i in listToArray(arguments.siteStruct.domainAlias,lineBreak) ){
					if ( !ListFindNoCase(thelist, i ) ) {
						thelist = listAppend(thelist,i);
					}
				}
			}
			return thelist;
		}

		function getServerPortFromSiteStruct(siteStruct) output=false {
			if (arguments.siteStruct.isRemote ) {
				var port=arguments.siteStruct.RemotePort;
				if ( isNumeric(port) && !ListFind('80,443', port) ) {
					return ":" & port;
				} else {
					return "";
				}
			} else {
				return application.configBean.getServerPort();
			}
		}
	</cfscript>
</cfcomponent>
<!---
License goes here
--->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides user service level logic functionality">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="userDAO" type="any" required="yes"/>
		<cfargument name="userGateway" type="any" required="yes"/>
		<cfargument name="userUtility" type="any" required="yes"/>
		<cfargument name="utility" type="any" required="yes"/>
		<cfargument name="fileManager" type="any" required="yes"/>
		<cfargument name="pluginManager" type="any" required="yes"/>
		<cfargument name="trashManager" type="any" required="yes"/>
		<cfargument name="settingsManager" type="any" required="yes"/>
		<cfargument name="clusterManager" type="any" required="yes"/>
		<cfargument name="permUtility" type="any" required="yes"/>

		<cfset variables.configBean=arguments.configBean />
		<cfset variables.userDAO=arguments.userDAO />
		<cfset variables.userGateway=arguments.userGateway />
		<cfset variables.userUtility=arguments.userUtility />
		<cfset variables.globalUtility=arguments.utility />
		<cfset variables.ClassExtensionManager=variables.configBean.getClassExtensionManager() />
		<cfset variables.fileManager=arguments.fileManager />
		<cfset variables.pluginManager=arguments.pluginManager />
		<cfset variables.trashManager=arguments.trashManager />
		<cfset variables.settingsManager=arguments.settingsManager />
		<cfset variables.clusterManager=arguments.clusterManager />
		<cfset variables.permUtility=arguments.permUtility />

		<!---<cfset variables.userDAO.setUserManager(this)>--->

		<cfreturn this />
	</cffunction>

	<cffunction name="getBean" output="false">
		<cfargument name="beanName" default="user">
		<cfreturn super.getBean(arguments.beanName)>
	</cffunction>

	<cffunction name="getUserGroups" output="false">
		<cfargument name="siteid" type="string" default=""/>
		<cfargument name="isPublic" type="numeric" default="0"/>
		<cfreturn variables.userGateway.getUserGroups(arguments.siteid,arguments.isPublic) />
	</cffunction>

	<cffunction name="read" output="false">
		<cfargument name="userid" type="string" default=""/>
		<cfargument name="username" type="string" default=""/>
		<cfargument name="remoteID" type="string" default=""/>
		<cfargument name="siteID" type="string" default=""/>
		<cfargument name="groupname" type="string" default=""/>
		<cfargument name="isPublic" type="string" default="1"/>
		<cfargument name="userBean" type="any" default=""/>
		<cfargument name="groupid" type="string" default=""/>
		<cfset var key= "" />
		<cfset var site=""/>
		<cfset var cacheFactory="">
		<cfset var bean=arguments.userBean>
		<cfset var sessionData=getSession()>

		<cfif not len(arguments.siteID) and isdefined("sessionData.siteID")>
			<cfset arguments.siteID=sessionData.siteID>
		</cfif>

		<cfif len(arguments.siteID)>
			<cfif len(arguments.username)>
				<cfreturn readByUsername(arguments.username,arguments.siteid,bean) />
			<cfelseif len(arguments.groupname)>
				<cfreturn readByGroupName(arguments.groupname,arguments.siteid,arguments.isPublic,bean) />
			<cfelseif len(arguments.remoteID)>
				<cfreturn readByRemoteID(arguments.remoteID,arguments.siteid,bean) />
			</cfif>
		</cfif>

		<cfif len(arguments.groupid)>
			<cfset arguments.userid=arguments.groupid>
		</cfif>

		<cfset key= "user" & arguments.siteid & arguments.userID />
		<cfset site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset cacheFactory=site.getCacheFactory(name="data")>

		<cfif site.getCache()>
			<!--- check to see if it is cached. if not then pass in the context --->
			<!--- otherwise grab it from the cache --->
			<cfif NOT cacheFactory.has( key )>
				<cfset bean=variables.userDAO.read(arguments.userid,bean)>
				<cfif not isArray(bean) and not bean.getIsNew()>
					<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
				</cfif>
				<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: userBean, key: #key#}"))>
				<cfreturn bean/>
			<cfelse>
				<cftry>
					<cfif not isObject(bean)>
						<cfset bean=getBean("user")/>
					</cfif>
					<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
					<cfset bean.setValue("extendAutoComplete",false)>
					<cfset bean.setValue('frommuracache',true)>
					<cfset commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: userBean, key: #key#}"))>
					<cfreturn bean />
					<cfcatch>
						<cfset bean=variables.userDAO.read(arguments.userid,bean)>
						<cfif not isArray(bean) and not bean.getIsNew()>
							<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
						</cfif>
						<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: userBean, key: #key#}"))>
						<cfreturn bean/>
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfreturn variables.userDAO.read(arguments.userid,bean) />
		</cfif>
	</cffunction>

	<cffunction name="readUserHash" output="false">
		<cfargument name="userid" type="string" default=""/>
		<cfreturn variables.userDAO.readUserHash(arguments.userid) />
	</cffunction>

	<cffunction name="readByUsername" output="false">
		<cfargument name="username" type="string" default=""/>
		<cfargument name="siteid" type="string" default=""/>
		<cfargument name="userBean" type="any" default=""/>
		<cfset var key= "user" & arguments.siteid & arguments.username />
		<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset var cacheFactory=site.getCacheFactory(name="data")>
		<cfset var bean=arguments.userBean>

		<cfif site.getCache()>
			<!--- check to see if it is cached. if not then pass in the context --->
			<!--- otherwise grab it from the cache --->
			<cfif NOT cacheFactory.has( key )>
				<cfset bean=variables.userDAO.readByUsername(arguments.username,arguments.siteid,bean) />
				<cfif not isArray(bean) and not bean.getIsNew()>
					<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
				</cfif>
				<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: userBean, key: #key#}"))>
				<cfreturn bean/>
			<cfelse>
				<cftry>
					<cfif not isObject(bean)>
						<cfset bean=getBean("user")/>
					</cfif>
					<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
					<cfset bean.setValue("extendAutoComplete",false)>
					<cfset bean.setValue('frommuracache',true)>
					<cfset commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: userBean, key: #key#}"))>
					<cfreturn bean />
					<cfcatch>
						<cfset bean=variables.userDAO.readByUsername(arguments.username,arguments.siteid,bean) />
						<cfif not isArray(bean) and not bean.getIsNew()>
							<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
						</cfif>
						<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: userBean, key: #key#}"))>
						<cfreturn bean/>
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfreturn variables.userDAO.readByUsername(arguments.username,arguments.siteid,bean) />
		</cfif>
	</cffunction>

	<cffunction name="readByGroupName" output="false">
		<cfargument name="groupname" type="string" default=""/>
		<cfargument name="siteid" type="string" default=""/>
		<cfargument name="isPublic" type="string" required="yes" default="both"/>
		<cfargument name="userBean" type="any" default=""/>
		<cfset var key= "user" & arguments.siteid & arguments.groupname />
		<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset var cacheFactory=site.getCacheFactory(name="data")>
		<cfset var bean=arguments.userBean>

		<cfif site.getCache()>
			<!--- check to see if it is cached. if not then pass in the context --->
			<!--- otherwise grab it from the cache --->
			<cfif NOT cacheFactory.has( key )>
				<cfset bean=variables.userDAO.readByGroupName(arguments.groupname,arguments.siteid,arguments.isPublic,bean)  />
				<cfif not isArray(bean) and not bean.getIsNew()>
					<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
				</cfif>
				<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: userBean, key: #key#}"))>
				<cfreturn bean/>
			<cfelse>
				<cftry>
					<cfif not isObject(bean)>
						<cfset bean=getBean("user")/>
					</cfif>
					<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
					<cfset bean.setValue("extendAutoComplete",false)>
					<cfset bean.setValue('frommuracache',true)>
					<cfset commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: userBean, key: #key#}"))>
					<cfreturn bean />
					<cfcatch>
						<cfset bean=variables.userDAO.readByGroupName(arguments.groupname,arguments.siteid,arguments.isPublic,bean)  />
						<cfif not isArray(bean) and not bean.getIsNew()>
							<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
						</cfif>
						<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: userBean, key: #key#}"))>
						<cfreturn bean/>
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfreturn variables.userDAO.readByGroupName(arguments.groupname,arguments.siteid,arguments.isPublic,bean) />
		</cfif>
	</cffunction>

	<cffunction name="readByRemoteID" output="false">
		<cfargument name="remoteID" type="string" default=""/>
		<cfargument name="siteid" type="string" default=""/>
		<cfargument name="userBean" type="any" default=""/>
		<cfset var key= "user" & arguments.siteid & arguments.remoteID />
		<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset var cacheFactory=site.getCacheFactory(name="data")>
		<cfset var bean=arguments.userBean>

		<cfif site.getCache()>
			<!--- check to see if it is cached. if not then pass in the context --->
			<!--- otherwise grab it from the cache --->
			<cfif NOT cacheFactory.has( key )>
				<cfset bean=variables.userDAO.readByRemoteID(arguments.remoteID,arguments.siteid,bean) />
				<cfif not isArray(bean) and not bean.getIsNew()>
					<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
				</cfif>
				<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: userBean, key: #key#}"))>
				<cfreturn bean/>
			<cfelse>
				<cftry>
					<cfif not isObject(bean)>
						<cfset bean=getBean("user")/>
					</cfif>
					<cfset bean.setAllValues( structCopy(cacheFactory.get( key )) )>
					<cfset bean.setValue("extendAutoComplete",false)>
					<cfset bean.setValue('frommuracache',true)>
					<cfset commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: userBean, key: #key#}"))>
					<cfreturn bean />
					<cfcatch>
						<cfset bean=variables.userDAO.readByRemoteID(arguments.remoteID,arguments.siteid,bean) />
						<cfif not isArray(bean) and not bean.getIsNew()>
							<cfset cacheFactory.get( key, structCopy(bean.getAllValues()) ) />
						</cfif>
						<cfset commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: userBean, key: #key#}"))>
						<cfreturn bean/>
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfreturn variables.userDAO.readByRemoteID(arguments.remoteID,arguments.siteid,bean) />
		</cfif>
	</cffunction>

	<cffunction name="purgeUserCache" output="false">
		<cfargument name="userID">
		<cfargument name="userBean">
		<cfargument name="broadcast" default="true">
		<cfset var cache="">
		<cfset var poolIDs="">
		<cfset var p="">

		<cfif not isDefined("arguments.userBean")>
			<cfset arguments.userBean=read(userID=arguments.userID)>
		</cfif>

		<cfset poolIDs=getAssociatedUserPoolIDs(arguments.userBean.getSiteID())>

		<cfif NOT arguments.userBean.getIsNew()>
			<cfloop list="#poolIDs#" index="p">
				<cftry>
					<cfset cache=variables.settingsManager.getSite(p).getCacheFactory(name="data")>

					<cfset cache.purge("user" & p & arguments.userBean.getUserID())>
					<cfif len(arguments.userBean.getRemoteID())>
						<cfset cache.purge("user" & p & arguments.userBean.getRemoteID())>
					</cfif>
					<cfif len(arguments.userBean.getUsername())>
						<cfset cache.purge("user" & p & arguments.userBean.getUsername())>
					</cfif>
					<cfif len(arguments.userBean.getGroupname())>
						<cfset cache.purge("user" & p & arguments.userBean.getGroupname())>
					</cfif>
					<cfcatch>
						<cflog type="Error" log="exception" text="Error clearing user from cache siteid '#userBean.getSiteID()#': #serializeJSON(cfcatch)#">
					</cfcatch>
				</cftry>
			</cfloop>

			<cfif arguments.broadcast>
				<cfset variables.clusterManager.purgeUserCache(userID=arguments.userBean.getUserID())>
			</cfif>

		</cfif>
	</cffunction>

	<cffunction name="save" output="false">
		<cfargument name="data" type="any" default="#structnew()#"/>
		<cfargument name="updateGroups" type="boolean" default="true" required="yes" />
		<cfargument name="updateInterests" type="boolean" default="true" required="yes" />
		<cfargument name="OriginID" type="string" default="" required="yes" />

		<cfset var userID="">
		<cfset var rs="">

		<cfif isObject(arguments.data)>
			<cfif listLast(getMetaData(arguments.data).name,".") eq "userBean">
			<cfset arguments.data=arguments.data.getAllValues()>
			<cfelse>
				<cfthrow type="custom" message="The attribute 'DATA' is not of type 'mura.user.userBean'">
			</cfif>
		</cfif>

		<cfif not structKeyExists(arguments.data,"userID")>
			<cfthrow type="custom" message="The attribute 'USERID' is required when saving a user.">
		</cfif>

		<cfquery datasource="#variables.configBean.getReadOnlyDatasource()#" username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#" name="rs">
		select userID from tusers where userID=<cfqueryparam value="#arguments.data.userID#">
		</cfquery>

		<cfif rs.recordcount>
			<cfreturn update(arguments.data,arguments.updateGroups,arguments.updateInterests, arguments.originID)>
		<cfelse>
			<cfreturn create(arguments.data)>
		</cfif>
	</cffunction>

	<cffunction name="update" output="false">
		<cfargument name="data" type="any" default="#structnew()#"/>
		<cfargument name="updateGroups" type="boolean" default="true" required="yes" />
		<cfargument name="updateInterests" type="boolean" default="true" required="yes" />
		<cfargument name="OriginID" type="string" default="" required="yes" />

		<cfset var errors =""/>
		<cfset var addressBean =""/>
		<cfset var userBean="" />

		<cfif isObject(arguments.data)>
			<cfset arguments.data=arguments.data.getAllValues() />
		</cfif>

		<cfset var pluginEvent =new mura.event(arguments.data) />
		<cfset pluginEvent.setValue("updateGroups",arguments.updateGroups) />
		<cfset pluginEvent.setValue("updateInterests",arguments.updateInterests) />
		<cfset pluginEvent.setValue("OriginID",arguments.OriginID) />

		<cfif not structKeyExists(arguments.data,"userID") or (structKeyExists(arguments.data,"userID") and not len(arguments.data.userID))>
			<cfreturn create(arguments.data) />
		</cfif>

		<cfif not structKeyExists(arguments.data,"siteID") or (structKeyExists(arguments.data,"siteID") and not len(arguments.data.siteID))>
			<cfthrow type="custom" message="The attribute 'SITEID' is required when saving a user.">
		</cfif>

		<cfset userBean=variables.userDAO.read(arguments.data.userid)/>

		<cfset userBean.set(arguments.data) />
		<cfset var addObjects=userBean.getAddObjects()>
		<cfset var removeObjects=userBean.getRemoveObjects()>

		<cfif userBean.getS2()>
			<cfset userBean.setIsPublic(0)>
		</cfif>

		<cfset userBean.validate()>

		<!--- <cfif userBean.getType() eq 2 and  userBean.getAddressID() neq ''> --->
		<cfif userBean.getAddressID() neq ''>
		<cfset addressBean=variables.userDAO.readAddress(userBean.getAddressID()) />
		<cfset addressBean.set(arguments.data) />
		<cfset pluginEvent.setValue("addressBean",addressBean)/>
		</cfif>

		<cfset pluginEvent.setValue("siteID", userBean.getSiteID())>

		<cfif userBean.getType() eq 1>
			<cfset pluginEvent.setValue("groupBean",userBean)/>
			<cfset pluginEvent.setValue("bean",userBean)/>

			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeGroupUpdate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeGroupSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeGroup#userBean.getSubType()#Update",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeGroup#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
		<cfelse>
			<cfset pluginEvent.setValue("userBean",userBean)/>
			<cfset pluginEvent.setValue("bean",userBean)/>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeUserUpdate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeUserSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeUser#userBean.getSubType()#Update",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeUser#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
		</cfif>

		<cfset hasRestrictedFiles=variables.fileManager.requestHasRestrictedFiles(scope=userBean.getAllValues())>
		<cfif len(hasRestrictedFiles) gt 1 and findNoCase('|',hasRestrictedFiles)>
			<cfset restrictedFilesArray=listToArray(hasRestrictedFiles, '|')>
			<cfset hasRestrictedFiles=restrictedFilesArray[1]>
			<cfset fileSize=restrictedFilesArray[2]>
		</cfif>
		<cfif hasRestrictedFiles eq '1'>
			<cfset errors=userBean.getErrors()>
			<cfset errors.requestHasRestrictedFiles=variables.settingsManager.getSite(userBean.getSiteID()).getRBFactory().getKey('sitemanager.requestHasRestrictedFiles')>
		</cfif>
		<cfif hasRestrictedFiles eq '2'>
			<cfset errors=userBean.getErrors()>
			<cfset errors.requestHasRestrictedFiles=application.rbFactory.getResourceBundle(session.rb).messageFormat(variables.settingsManager.getSite(userBean.getSiteID()).getRBFactory().getKey('sitemanager.requesthasinvalidsize'),fileSize)>
		</cfif>

		<cfif structIsEmpty(userBean.getErrors())>

			<!--- Reset extended data internal ids --->
			<cfset arguments.data=userBean.getAllValues()>
			<cfset arguments.updateGroups = pluginEvent.getValue('updateGroups') />
			<cfset arguments.updateInterests = pluginEvent.getValue('updateInterests') />

			<cfif isDefined('arguments.data.activationNotify') and userBean.getInActive() eq 0>
				<cfset variables.userUtility.sendActivationNotification(userBean) />
			</cfif>

			<cfif structKeyExists(arguments.data,"extendSetID") and len(arguments.data.extendSetID)>
				<cfset variables.ClassExtensionManager.saveExtendedData(userBean.getUserID(),arguments.data,'tclassextenddatauseractivity')/>
			</cfif>

			<cfif structKeyExists(arguments.data,"newFile") and len(arguments.data.newfile)>
				<cfset setPhotoFile(userBean)/>
			</cfif>

			<cfif isDefined('arguments.data.removePhotoFile') and arguments.data.removePhotoFile eq "true" and len(userBean.getPhotoFileID())>
				<cfset variables.fileManager.deleteVersion(userBean.getPhotoFileID()) />
				<cfset userBean.setPhotoFileID("") />
			</cfif>

			<cfif userBean.getAddressID() neq ''>
			<cfset variables.userDAO.updateAddress(addressBean) />
			</cfif>

			<cfset variables.globalUtility.logEvent("UserID:#userBean.getUserID()# Type:#userBean.getType()# User:#userBean.getFName()# #userBean.getFName()# Group:#userBean.getGroupName()# was updated","mura-users","Information",true) />
			<cfset setLastUpdateInfo(userBean) />
			<cfset variables.userDAO.update(userBean,arguments.updateGroups,arguments.updateInterests,arguments.OriginID) />
			<cfset purgeUserCache(userBean=userBean)>
			<!--- Put in re-read the user to make sure that all extended attributes are cleaned.
			Not need due to extended attributes now not using ext[pluginID] based form field names.
			<cfset userBean=read(userID=userBean.getUserID())>
			--->

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

				userBean.setAddObjects([]);
				userBean.setRemoveObjects([]);
			</cfscript>

			<cfif  userBean.getType() eq 1>
				<cfset pluginEvent.setValue("groupBean",userBean)/>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onGroupUpdate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onGroupSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onGroup#userBean.getSubType()#Update",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onGroup#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterGroupUpdate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterGroupSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterGroup#userBean.getSubType()#Update",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterGroup#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfelse>
				<cfset pluginEvent.setValue("userBean",userBean)/>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onUserUpdate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onUserSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onUser#userBean.getSubType()#Update",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onUser#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterUserUpdate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterUserSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterUser#userBean.getSubType()#Update",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterUser#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			</cfif>

		</cfif>

		<cfreturn userBean />
	</cffunction>

	<cffunction name="create" output="false">
		<cfargument name="data" type="any" default="#structnew()#"/>

		<cfset var addressBean = "" />
		<cfset var userBean= getBean("user") />

		<cfif isObject(arguments.data)>
			<cfset arguments.data=arguments.data.getAllValues() />
		</cfif>

		<cfset var pluginEvent = new mura.event(arguments.data) />

		<cfset userBean.set(arguments.data) />
		<cfset var addObjects=userBean.getAddObjects()>

		<cfif userBean.getS2()>
			<cfset userBean.setIsPublic(0)>
		</cfif>

		<cfset userBean.validate()>

		<!--- MAKE SURE ALL REQUIRED DATA IS THERE--->
		<cfif not structKeyExists(arguments.data,"userID") or (structKeyExists(arguments.data,"userID") and not len(arguments.data.userID))>
			<cfset userBean.setUserID(createuuid()) />
		<cfelse>
			<cfset userBean.setUserID(arguments.data.userID) />
		</cfif>

		<cfif not structKeyExists(arguments.data,"siteID") or (structKeyExists(arguments.data,"siteID") and not len(arguments.data.siteID))>
			<cfthrow type="custom" message="The attribute 'SITEID' is required when saving a user.">
		</cfif>

		<cfif not structKeyExists(arguments.data,"fromMuraTrash")>
			<cfset addressBean=getBean("addressBean") />
			<cfset addressBean.set(arguments.data) />
			<cfif not len(addressBean.getAddressID())>
				<cfset addressBean.setAddressID(createuuid()) />
			</cfif>
			<cfset addressBean.setUserID(userBean.getUserID()) />
			<cfset addressBean.setIsPrimary(1) />
			<cfif not len(addressBean.getAddressName())>
				<cfset addressBean.setAddressName('Primary') />
			</cfif>
		</cfif>

		<cfif userBean.getPassword() eq ''>
			<cfset userBean.setPassword(variables.userUtility.getRandomPassword(12,"alphanumeric","yes"))/>
		</cfif>

		<cfset pluginEvent.setValue("siteID", userBean.getSiteID())>

		<cfif userBean.getType() eq 1>
			<cfset pluginEvent.setValue("groupBean",userBean)/>
			<cfset pluginEvent.setValue("bean",userBean)/>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeGroupCreate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeGroupSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeGroup#userBean.getSubType()#Create",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeGroup#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
		<cfelse>
			<cfset pluginEvent.setValue("userBean",userBean)/>
			<cfset pluginEvent.setValue("bean",userBean)/>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeUserCreate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeUserSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeUser#userBean.getSubType()#Create",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeUser#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
		</cfif>

		<cfset hasRestrictedFiles=variables.fileManager.requestHasRestrictedFiles(scope=userBean.getAllValues())>
		<cfif len(hasRestrictedFiles) gt 1 and findNoCase('|',hasRestrictedFiles)>
			<cfset restrictedFilesArray=listToArray(hasRestrictedFiles, '|')>
			<cfset hasRestrictedFiles=restrictedFilesArray[1]>
			<cfset fileSize=restrictedFilesArray[2]>
		</cfif>
		<cfif hasRestrictedFiles eq '1'>
			<cfset errors=userBean.getErrors()>
			<cfset errors.requestHasRestrictedFiles=variables.settingsManager.getSite(userBean.getSiteID()).getRBFactory().getKey('sitemanager.requestHasRestrictedFiles')>
		</cfif>
		<cfif hasRestrictedFiles eq '2'>
			<cfset errors=userBean.getErrors()>
			<cfset errors.requestHasRestrictedFiles=application.rbFactory.getResourceBundle(session.rb).messageFormat(variables.settingsManager.getSite(userBean.getSiteID()).getRBFactory().getKey('sitemanager.requesthasinvalidsize'),fileSize)>
		</cfif>

		<cfif structIsEmpty(userBean.getErrors())>

			<!--- Reset extended data internal ids --->
			<cfset arguments.data=userBean.getAllValues()>

			<cfif structKeyExists(arguments.data,"extendSetID") and len(arguments.data.extendSetID)>
				<cfset variables.ClassExtensionManager.saveExtendedData(userBean.getUserID(),arguments.data,'tclassextenddatauseractivity')/>
			</cfif>

			<cfif structKeyExists(arguments.data,"newFile") and len(arguments.data.newfile)>
				<cfset setPhotoFile(userBean)/>
			</cfif>

			<cfset variables.globalUtility.logEvent("UserID:#userBean.getUserID()# Type:#userBean.getType()# User:#userBean.getFName()# #userBean.getFName()# Group:#userBean.getGroupName()# was created","mura-users","Information",true) />
			<cfset setLastUpdateInfo(userBean) />
			<cfset variables.userDAO.create(userBean) />
			<cfset purgeUserCache(userBean=userBean)>
			<cfset variables.trashManager.takeOut(userBean)>
			<cfif isObject(addressBean)>
				<cfset variables.userDAO.createAddress(addressBean) />
			</cfif>

			<cfset userBean.purgeExtendedData()>
			<cfset userBean.setIsNew(0)>

			<cfscript>
				if(arrayLen(addObjects)){
					for(var obj in addObjects){
						obj.save();
					}
				}

				userBean.setAddObjects([]);
				userBean.setRemoveObjects([]);
			</cfscript>

			<cfif  userBean.getType() eq 1>
				<cfset pluginEvent.setValue("groupBean",userBean)/>
				<cfset pluginEvent.setValue("bean",userBean)/>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onGroupCreate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onGroupSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onGroup#userBean.getSubType()#Create",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onGroup#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterGroupCreate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterGroupSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterGroup#userBean.getSubType()#Create",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterGroup#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfelse>
				<cfset pluginEvent.setValue("userBean",userBean)/>
				<cfset pluginEvent.setValue("bean",userBean)/>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onUserCreate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onUserSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onUser#userBean.getSubType()#Create",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onUser#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterUserCreate",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterUserSave",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterUser#userBean.getSubType()#Create",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
				<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterUser#userBean.getSubType()#Save",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			</cfif>
		</cfif>

		<cfreturn userBean />
	</cffunction>

	<cffunction name="delete" output="false">
		<cfargument name="userid" type="string" default=""/>
		<cfargument name="type" type="numeric" default="2"/>

		<cfset var userBean=read(arguments.userid) />
		<cfset var pluginEvent = new mura.event(arguments) />
		<cfset var addresses="">
		<cfset pluginEvent.setValue("siteID", userBean.getSiteID())>

		<cfif  userBean.getType() eq 1>
			<cfset pluginEvent.setValue("groupBean",userBean)/>
			<cfset pluginEvent.setValue("bean",userBean)/>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onGroupDelete",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeGroupDelete",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeGroup#userBean.getSubType()#Delete",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
		<cfelse>
			<cfset pluginEvent.setValue("userBean",userBean)/>
			<cfset pluginEvent.setValue("bean",userBean)/>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onUserDelete",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeUserDelete",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onBeforeUser#userBean.getSubType()#Delete",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
		</cfif>

		<cfset variables.trashManager.throwIn(userBean)>
		<cfset variables.globalUtility.logEvent("UserID:#arguments.userid# Type:#userBean.getType()# User:#userBean.getFName()# #userBean.getFName()# Group:#userBean.getGroupName()# was deleted","mura-users","Information",true) />
		<cfif len(userBean.getPhotoFileID())>
			<cfset variables.fileManager.deleteVersion(userBean.getPhotoFileID()) />
		</cfif>

		<cfset variables.userDAO.delete(arguments.userid,arguments.type,userBean.getSiteID()) />
		<cfset purgeUserCache(userBean=userBean)>

		<cfif  userBean.getType() eq 1>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterGroupDelete",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterGroup#userBean.getSubType()#Delete",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
		<cfelse>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterUserDelete",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
			<cfset variables.pluginManager.announceEvent(eventToAnnounce="onAfterUser#userBean.getSubType()#Delete",currentEventObject=pluginEvent,objectid=userBean.getUserID())>
		</cfif>
	</cffunction>

	<cffunction name="readGroupMemberships" output="false">
		<cfargument name="userid" type="string" default="" required="yes"/>
		<cfreturn variables.userDAO.readGroupMemberships(arguments.userid) />
	</cffunction>

	<cffunction name="getAddresses" output="false">
		<cfargument name="userid" type="string" default="" required="yes"/>
		<cfreturn variables.userDAO.getAddresses(arguments.userid) />
	</cffunction>

	<cffunction name="getAddressByID" output="false">
		<cfargument name="addressid" type="string" default="" required="yes"/>
		<cfreturn variables.userDAO.getAddressByID(arguments.addressid) />
	</cffunction>

	<cffunction name="readInterestGroups" output="false">
		<cfargument name="userid" type="string" default="" required="yes"/>
		<cfreturn variables.userDAO.readInterestGroups(arguments.userid) />
	</cffunction>

	<cffunction name="readMemberships" output="false">
		<cfargument name="userid" type="string" default="" required="yes"/>
		<cfreturn variables.userDAO.readMemberships(arguments.userid) />
	</cffunction>

	<cffunction name="getPublicGroups" output="false">
		<cfargument name="siteid" type="string" default="" required="yes"/>
		<cfreturn variables.userGateway.getPublicGroups(arguments.siteid) />
	</cffunction>

	<cffunction name="getPublicGroupsIterator" output="false">
		<cfargument name="siteid" type="string" default="" required="yes"/>
		<cfset var rs=variables.userGateway.getPublicGroups(arguments.siteid) />
		<cfreturn getBean("userIterator").setQuery(rs) />
	</cffunction>

	<cffunction name="getPrivateGroups" output="false">
		<cfargument name="siteid" type="string" default="" required="yes"/>
		<cfreturn variables.userGateway.getPrivateGroups(arguments.siteid) />
	</cffunction>

	<cffunction name="getPrivateGroupsIterator" output="false">
		<cfargument name="siteid" type="string" default="" required="yes"/>
		<cfset var rs=variables.userGateway.getPrivateGroups(arguments.siteid) />
		<cfreturn getBean("userIterator").setQuery(rs) />
	</cffunction>

	<cffunction name="createUserInGroup" output="false">
		<cfargument name="userid" type="string" default="" required="yes"/>
		<cfargument name="groupid" type="string" default="" required="yes"/>
		<cfset variables.userDAO.createUserInGroup(arguments.userid,arguments.groupid) />
		<cfset purgeUserCache(userID=arguments.userID)>
		<cfset purgeUserCache(userID=arguments.groupID)>
	</cffunction>

	<cffunction name="deleteUserFromGroup" output="false">
		<cfargument name="userid" type="string" default="" required="yes"/>
		<cfargument name="groupid" type="string" default="" required="yes"/>
		<cfset variables.userDAO.deleteUserFromGroup(arguments.userid,arguments.groupid) />
		<cfset purgeUserCache(userID=arguments.userID)>
		<cfset purgeUserCache(userID=arguments.groupID)>
	</cffunction>

	<cffunction name="getSearch" output="false">
		<cfargument name="search" type="string" default="" required="yes"/>
		<cfargument name="siteid" type="string" default="" required="yes"/>
		<cfargument name="isPublic" type="numeric" default="1" required="yes"/>
		<cfargument name="isGroupSearch" type="boolean" default="false" />
		<cfreturn variables.userGateway.getSearch(argumentCollection=arguments) />
	</cffunction>

	<cffunction name="getAdvancedSearch" output="false">
		<cfargument name="data" type="any" default="" hint="This can be a struct or an instance of userFeedBean."/>
		<cfargument name="siteid" type="any" hint="deprecated, use userFeedBean.setSiteID()" default=""/>
		<cfargument name="isPublic" type="any" hint="deprecated, use userFeedBean.setIsPublic()" default=""/>
		<cfreturn variables.userGateway.getAdvancedSearch(argumentCollection=arguments) />
	</cffunction>

	<cffunction name="getAdvancedSearchQuery" output="false">
		<cfargument name="userFeedBean" type="any" default="" required="yes"/>
		<cfreturn getAdvancedSearch(arguments.userFeedBean) />
	</cffunction>

	<cffunction name="getAdvancedSearchIterator" output="false">
		<cfargument name="userFeedBean" type="any" required="yes"/>
		<cfset var rs= getAdvancedSearch(arguments.userFeedBean) />
		<cfreturn getBean("userIterator").setQuery(rs) />
	</cffunction>

	<cffunction name="setLastUpdateInfo" output="false">
		<cfargument name="userBean" type="any" default="" required="yes"/>
		<cfset var sessionData=getSession()>

		<cfif isDefined('sessionData.mura.isLoggedIn') and sessionData.mura.isLoggedIn>
			<cfset arguments.userBean.setLastUpdateBy(left(sessionData.mura.fname & " " & sessionData.mura.lname,50))/>
			<cfset arguments.userBean.setLastUpdateByID(sessionData.mura.userID)/>
		<cfelse>
			<cfset arguments.userBean.setLastUpdateBy(left("#arguments.userBean.getFname()# #arguments.userBean.getlname()#",50))/>
			<cfset arguments.userBean.setLastUpdateByID(arguments.userBean.getUserID())/>
		</cfif>
	</cffunction>

	<cffunction name="sendLoginByEmail" output="false">
		<cfargument name="email" type="string" default=""/>
		<cfargument name="siteid" type="string" default=""/>
		<cfargument name="returnURL" type="string" default=""/>
		<cfreturn variables.userUtility.sendLoginByEmail(arguments.email,arguments.siteid,arguments.returnURL) />
	</cffunction>

	<cffunction name="sendLoginByUser" output="false">
		<cfargument name="userBean" type="any"/>
		<cfargument name="siteid" type="string" default=""/>
		<cfargument name="returnURL" type="string" default=""/>
		<cfargument name="isPublicReg" required="yes" type="boolean" default="false"/>
		<cfreturn variables.userUtility.sendLoginByUser(arguments.userBean,arguments.siteid,arguments.returnURL,arguments.isPublicReg) />
	</cffunction>

	<cffunction name="createAddress" returntype="struct" output="false">
		<cfargument name="data" type="any" default="#structnew()#"/>

		<cfset var addressBean=getBean("addressBean") />
		<cfset var userBean="" />

		<cfif isObject(arguments.data)>
			<cfset arguments.data=arguments.data.getAllValues() />
		</cfif>

		<cfif not structKeyExists(arguments.data,"userID") or (structKeyExists(arguments.data,"userID") and not len(arguments.data.userID))>
			<cfthrow type="custom" message="The attribute 'USERID' is required when saving an address.">
		</cfif>

		<cfset addressBean.set(arguments.data) />
		<cfset addressBean.validate()>

		<cfset userBean=read(addressBean.getUserID())>
		<cfset addressBean.setSiteID(userBean.getSiteID())>

		<cfif not structKeyExists(arguments.data,"addressID") or (structKeyExists(arguments.data,"addressID") and not len(arguments.data.addressID))>
			<cfset addressBean.setAddressID(createuuid()) />
		<cfelse>
			<cfset addressBean.setAddressID(arguments.data.addressID) />
		</cfif>

		<cfif structIsEmpty(addressBean.getErrors())>
			<cfset variables.userDAO.createAddress(addressBean) />
			<cfif structKeyExists(arguments.data,"extendSetID")>
				<cfset arguments.data.siteID=addressBean.getSiteID() />
				<cfset variables.ClassExtensionManager.saveExtendedData(addressBean.getAddressID(),arguments.data,'tclassextenddatauseractivity')/>
			</cfif>
		</cfif>
		<cfset variables.trashManager.takeOut(addressBean)>
		<cfset purgeUserCache(userBean=userBean)>
		<cfreturn addressBean />
	</cffunction>

	<cffunction name="updateAddress" output="false">
		<cfargument name="data" type="any" default="#structnew()#"/>

		<cfset var errors =""/>
		<cfset var addressBean=""/>
		<cfset var userBean="" />

		<cfif isObject(arguments.data)>
			<cfset addressBean=arguments.data>
			<cfset arguments.data=arguments.data.getAllValues() />
		<cfelseif structKeyExists(arguments.data,"addressID")>
			<cfset addressBean=variables.userDAO.readAddress(arguments.data.addressid)>
		<cfelse>
			<cfset addressBean=getBean("addressBean")>
		</cfif>

		<cfif not structKeyExists(arguments.data,"userID") or (structKeyExists(arguments.data,"userID") and not len(arguments.data.userID))>
			<cfthrow type="custom" message="The attribute 'USERID' is required when saving an address.">
		</cfif>

		<cfif not structKeyExists(arguments.data,"addressID") or (structKeyExists(arguments.data,"addressID") and not len(arguments.data.addressID))>
			<cfreturn createAddress(arguments.data) />
		</cfif>

		<cfset addressBean.set(arguments.data) />
		<cfset addressBean.validate()>

		<cfset userBean=read(addressBean.getUserID())>
		<cfset addressBean.setSiteID(userBean.getSiteID())>

		<cfif structIsEmpty(addressBean.getErrors())>
			<cfset variables.userDAO.updateAddress(addressBean) />
			<cfif structKeyExists(arguments.data,"extendSetID")>
				<cfset arguments.data.siteID=addressBean.getSiteID() />
				<cfset variables.ClassExtensionManager.saveExtendedData(addressBean.getAddressID(),arguments.data,'tclassextenddatauseractivity')/>
			</cfif>
		</cfif>

		<cfset purgeUserCache(userBean=userBean)>

		<cfreturn addressBean />
	</cffunction>

	<cffunction name="deleteAddress" output="false">
		<cfargument name="addressid" type="string" default=""/>
		<cfset var addressBean=variables.userDAO.readAddress(arguments.addressID) />
		<cfif not addressBean.getIsNew()>
			<cfset variables.trashManager.throwIn(addressBean)>
			<cfset variables.userDAO.deleteAddress(arguments.addressid,addressBean.getSiteID()) />
		</cfif>
		<cfset purgeUserCache(userID=addressBean.getUserID())>
	</cffunction>

	<cffunction name="getCurrentUserID" output="false">
		<cfset var sessionData=getSession()>
		<cfreturn sessionData.mura.userID />
	</cffunction>

	<cffunction name="getCurrentName" output="false">
		<cftry>
			<cfset var sessionData=getSession()>
			<cfreturn sessionData.mura.fname & " " & sessionData.mura.lname />
			<cfcatch>
				<cfreturn ''/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getCurrentLastLogin" output="false">
		<cftry>
			<cfset var sessionData=getSession()>
			<cfreturn sessionData.mura.lastlogin />
			<cfcatch>
				<cfreturn ''/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="getCurrentCompany" output="false">
		<cftry>
			<cfset var sessionData=getSession()>
			<cfreturn sessionData.mura.company />
			<cfcatch>
				<cfreturn ''/>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="setPhotoFile" output="false">
		<cfargument name="userBean" />

		<cfset var theFileStruct=structNew() />
		<cfset var error=structNew() />
		<cfset var tempFile=structNew()>

		<!--- Check to see if it's a posted binary file--->
		<cfif variables.fileManager.isPostedFile(userBean.getNewFile())>
			<cffile action="upload" result="tempFile" filefield="NewFile" nameconflict="makeunique" destination="#variables.configBean.getTempDir()#">
		<!--- Else fake it to think it was a posted files--->
		<cfelse>
			<cfset tempFile=variables.fileManager.emulateUpload(userBean.getNewFile())>
		</cfif>

		<cfif (tempFile.ServerFileExt eq "jpeg" or tempFile.ServerFileExt eq "jpg" or tempFile.ServerFileExt eq "gif" or tempFile.ServerFileExt eq "png" or tempFile.ServerFileExt eq "webp") and tempFile.ContentType eq "Image">
			<cftry>
				<cfif len(arguments.userBean.getPhotoFileID())>
					<cfset variables.fileManager.deleteVersion(arguments.userBean.getPhotoFileID()) />
				</cfif>
				<cfset theFileStruct=variables.fileManager.process(tempFile,arguments.userBean.getSiteID()) />
				<cfset arguments.userBean.setPhotoFileID(variables.fileManager.create(theFileStruct.fileObj,arguments.userBean.getUserID(),arguments.userBean.getSiteID(),tempFile.ClientFile,tempFile.ContentType,tempFile.ContentSubType,tempFile.FileSize,'00000000000000000000000000000000008',tempFile.ServerFileExt,theFileStruct.fileObjSmall,theFileStruct.fileObjMedium,variables.globalUtility.getUUID(),theFileStruct.fileObjSource)) />
				<cfcatch>
					<cfset userBean.setErrors(error)/>
					<cfset error.photo="The file you uploaded appears to be corrupt. Please select another file to upload."&cfcatch.message/>
				</cfcatch>
			</cftry>
		<cfelse>
			<cffile action="delete" file="#variables.configBean.getTempDir()##tempFile.serverfile#">
			<cfset error.photo="The file you uploaded is not a supported format. Only, JPEG, GIF and PNG files are accepted."/>
			<cfset userBean.setErrors(error)/>
		</cfif>
	</cffunction>

	<cffunction name="setUserBeanMetaData" output="false">
		<cfargument name="userBean">
		<cfreturn variables.userDAO.setUserBeanMetaData(userBean)>
	</cffunction>

	<cffunction name="setUserStructDefaults" output="false">
		<cfset var user="">
		<cfset var sessionData=getSession()>
		<cfif not structKeyExists(sessionData,"mura")>
			<cfif yesNoFormat(variables.configBean.getValue("useLegacySessions"))
					and len(getAuthUser()) and isValid("UUID",listFirst(getAuthUser(),"^"))>
				<cfset user=read(listFirst(getAuthUser(),"^"))>
				<cfset variables.userUtility.setUserStruct(user.getAllValues())>
			<cfelse>
				<cfset variables.userUtility.setUserStruct()>
			</cfif>
		</cfif>
		<cfparam name="sessionData.mura.membershipids" default="" />
	</cffunction>

	<cffunction name="getIterator" output="false">
		<cfreturn getBean("userIterator").init()>
	</cffunction>

	<cffunction name="getUserFeedBean" output="false">
		<cfset var userFeedBean=new mura.user.userFeedBean()>
		<cfset userFeedBean.setUserManager(this)>
		<cfreturn userFeedBean>
	</cffunction>

	<cffunction name="getReversePermLookUp" output="false">
		<cfargument name="siteid">

		<cfset var rsLookUp="">
		<cfset var sessionData=getSession()>

		<cfif variables.permUtility.getModulePerm('00000000000000000000000000000000008',arguments.siteid)
		or listFind(sessionData.mura.memberships,'Admin;#variables.settingsManager.getSite(arguments.siteid).getPrivateUserPoolID()#;0')>
			<cfreturn true>
		</cfif>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsLookUp')#">
			select siteID
			from tsettings
			where publicUserPoolID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">
		</cfquery>

		<cfloop query="rsLookUp">
			<cfif variables.permUtility.getModulePerm('00000000000000000000000000000000008',rsLookUp.siteid)>
				<cfreturn true>
			</cfif>
		</cfloop>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsLookUp')#">
			select siteID
			from tsettings
			where privateUserPoolID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">
		</cfquery>

		<cfloop query="rsLookUp">
			<cfif listFind(sessionData.mura.memberships,'Admin;#variables.settingsManager.getSite(rsLookUp.siteid).getPrivateUserPoolID()#;0')>
				<cfreturn true>
			</cfif>
		</cfloop>

		<cfreturn false>
	</cffunction>

	<cffunction name="getAssociatedUserPoolIDs" output="false">
		<cfargument name="siteid">

		<cfset var rsLookUp="">

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsLookUp')#">
			select siteID
			from tsettings
			where publicUserPoolID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">
			or privateUserPoolID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">
		</cfquery>

		<cfloop query="rslookUp">
			<cfif not listFind(arguments.siteID,rsLookUp.siteID)>
				<cfset arguments.siteID=listAppend(arguments.siteID,rsLookUp.siteID)>
			</cfif>
		</cfloop>

		<cfreturn arguments.siteID>
	</cffunction>

	<cffunction name="readUserPassword" output="false">
		<cfargument name="userid">

		<cfset var rs="">

		<cfquery name="rs">
		select password from tusers where userID=<cfqueryparam value="#arguments.userID#">
		</cfquery>

		<cfreturn rs.password>
	</cffunction>

	<cffunction name="getUnassignedUsers" output="false">
		<cfargument name="siteid" default="" />
		<cfargument name="ispublic" default="1" />
		<cfargument name="showSuperUsers" default="0" />
		<cfset arguments.isunassigned = true />
		<cfreturn variables.userGateway.getUsers(argumentCollection=arguments) />
	</cffunction>

	<cffunction name="getUsers" output="false">
		<cfargument name="siteid" default="" />
		<cfargument name="ispublic" default="1" />
		<cfargument name="isunassigned" default="0" />
		<cfargument name="showsuperusers" default="0" />
		<cfreturn variables.userGateway.getUsers(argumentCollection=arguments) />
	</cffunction>


	<cffunction name="readAddress" output="false">
		<cfargument name="addressid">
		<cfreturn variables.userDAO.readAddress(argumentCollection=arguments)>
	</cffunction>

</cfcomponent>

<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides module and content permissioning functionality">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="settingsManager" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfset variables.settingsManager=arguments.settingsManager />
		<cfreturn this />
	</cffunction>

	<cffunction name="getGroupPermVerdict" output="false">
		<cfargument name="ContentID" type="string" required="true">
		<cfargument name="GroupID" type="string" required="true">
		<cfargument name="Type" type="string" required="false" default="Editor">
		<cfargument name="siteid" type="string" required="true">

		<cfset var key=arguments.type & arguments.groupID & arguments.ContentID & arguments.siteid/>
		<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset var cacheFactory=site.getCacheFactory(name="output")>

		<cfif site.getCache()>
			<!--- check to see if it is cached. if not then pass in the context --->
			<!--- otherwise grab it from the cache --->

			<cfif NOT cacheFactory.has( key )>
				<cfreturn cacheFactory.get( key, buildGroupPermVerdict(arguments.contentID,arguments.groupID,arguments.type,arguments.siteid)  ) />
			<cfelse>
				<cftry>
					<cfreturn cacheFactory.get( key ) />
					<cfcatch>
						<cfreturn cacheFactory.get( key, buildGroupPermVerdict(arguments.contentID,arguments.groupID,arguments.type,arguments.siteid)  ) />
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfreturn buildGroupPermVerdict(arguments.contentID,arguments.groupID,arguments.type,arguments.siteid)/>
		</cfif>
	</cffunction>

	<cffunction name="buildGroupPermVerdict" output="false">
		<cfargument name="ContentID" type="string" required="true">
		<cfargument name="GroupID" type="string" required="true">
		<cfargument name="Type" type="string" required="false" default="Editor">
		<cfargument name="siteid" type="string" required="true">
		<cfset var rsPermited="">
		<cfset var verdict="none">

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsPermited')#">
		Select GroupID,type from tpermissions where ContentID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#"/> 
		and type in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.type#"/>) and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/> and groupid='#arguments.groupid#'
		</cfquery>

		<cfloop query="rsPermited">
			<cfif getPermRank(rsPermited.type) gt  getPermRank(verdict)>
				<cfset verdict=rsPermited.type />
			</cfif>
		</cfloop>

		<cfreturn verdict>
	</cffunction>

	<cffunction name="getGroupPerm" output="false">
		<cfargument name="GroupID" type="string" required="true">
		<cfargument name="ContentID" type="string" required="true">
		<cfargument name="siteid" type="string" required="true">
		<cfargument name="threshold" default="editor">
		<cfreturn getgrouppermverdict(arguments.contentid,arguments.groupid,'editor,author,read,deny',arguments.siteid,arguments.threshold)>
	</cffunction>

	<cffunction name="getPermVerdict" output="false">
		<cfargument name="ContentID" type="string" required="true">
		<cfargument name="Type" type="string" required="false" default="Editor">
		<cfargument name="siteid" type="string" required="true">
		<cfargument name="threshold" default="editor">
		<cfset var perm=0>
		<cfset var rsPermited="">
		<cfset var key=arguments.type & arguments.ContentID & arguments.siteid & arguments.threshold/>
		<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset var cacheFactory=site.getCacheFactory(name="output")>
		<cfset var sessionData=getSession()>
		<cfset var verdict='none'>

		<cfif site.getCache()>
			<!--- check to see if it is cached. if not then pass in the context --->
			<!--- otherwise grab it from the cache --->
			<cfif NOT cacheFactory.has( key )>
				<cfset rsPermited=getPermVerdictQuery(arguments.contentID,arguments.type,arguments.siteid) />
				<cfset cacheFactory.get( key, rsPermited.recordcount  ) />
			<cfelse>
				<cftry>
					<cfif cacheFactory.get( key ) >
						<cfset rsPermited=getPermVerdictQuery(arguments.contentID,arguments.type,arguments.siteid) />
					<cfelse>
						<cfreturn "none">
					</cfif>
					<cfcatch>
						<cfset rsPermited=getPermVerdictQuery(arguments.contentID,arguments.type,arguments.siteid) />
					<cfset cacheFactory.get( key, rsPermited.recordcount  ) />
					</cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfset rsPermited=getPermVerdictQuery(arguments.contentID,arguments.type,arguments.siteid) />
		</cfif>

		<cfloop query="rsPermited">
			<cfif rsPermited.isPublic>
				<cfif listFind(sessionData.mura.memberships,"#rsPermited.groupname#;#application.settingsManager.getSite(arguments.siteid).getPublicUserPoolID()#;1")>
					<cfif getPermRank(rsPermited.permtype) gt getPermRank(verdict)>
						<cfset verdict=rsPermited.permtype>
					</cfif>
				</cfif>
			<cfelse>
				<cfif listFind(sessionData.mura.memberships,"#rsPermited.groupname#;#application.settingsManager.getSite(arguments.siteid).getPrivateUserPoolID()#;0")>
					<cfif getPermRank(rsPermited.permtype) gt getPermRank(verdict)>
						<cfset verdict=rsPermited.permtype>
					</cfif>			
				</cfif>
			</cfif>
			<cfif getPermRank(verdict) gte getPermRank(arguments.threshold)>
				<cfreturn verdict>
			</cfif>
		</cfloop>

		<cfreturn verdict>
	</cffunction>

	<cffunction name="getPermVerdictQuery" output="false">
		<cfargument name="ContentID" type="string" required="true">
		<cfargument name="Type" type="string" required="false" default="Editor">
		<cfargument name="siteid" type="string" required="true">
		<cfset var rsPermVerdict="">

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsPermVerdict')#">
		Select tusers.GroupName, tusers.isPublic, tpermissions.type as permtype
		from tpermissions inner join tusers on tusers.userid in (tpermissions.groupid)
		where tpermissions.ContentID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#"/>
		and tpermissions.type in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#arguments.type#"/>)
		and tpermissions.siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
		</cfquery>

		<cfreturn rsPermVerdict>
	</cffunction>

	<cffunction name="getPerm" output="false">
		<cfargument name="ContentID" type="string" required="true">
		<cfargument name="siteid" type="string" required="true">
		<cfargument name="threshold" default="editor">
		<cfset var verdict="none">
		<cfset var sessionData=getSession()>

		<cfparam name="request.muraPermLookup" default="#structNew()#">
		<cfparam name="request.muraSharedContentPermLookup" default="#structNew()#">

		<cfset var key='#arguments.contentid##arguments.siteid##arguments.threshold#'>
		<cfset var sharedkey='#arguments.contentid##arguments.siteid#'>

		<cfif not structkeyExists(request.muraPermLookup,'#key#')>
			<cfif listFind(sessionData.mura.memberships,'Admin;#variables.settingsManager.getSite(arguments.siteid).getPrivateUserPoolID()#;0') or  listFind(sessionData.mura.memberships,'S2') >
				<cfset Verdict="editor">
			<cfelse>
				<cfset verdict=getPermVerdict(arguments.contentid,'editor,author,read,deny',arguments.siteid,arguments.threshold)>
			</cfif>

			<cfif structKeyExists(request.muraSharedContentPermLookup,'#sharedkey#') 
				and getPermRank(request.muraSharedContentPermLookup['#sharedkey#']) gt getPermRank(verdict)>
				<cfset verdict=request.muraSharedContentPermLookup['#sharedkey#']>
			</cfif>

			<cfset request.muraPermLookup['#key#']=verdict>
		</cfif>
		<cfreturn request.muraPermLookup['#key#']>
	</cffunction>

	<cffunction name="getPermPublic" output="false">
		<cfargument name="ContentID" type="string" required="true">
		<cfargument name="siteid" type="string" required="true">
		<cfargument name="threshold" default="editor">
		<cfset var verdict="none">
		<cfset var sessionData=getSession()>

		<cfparam name="request.muraPermPublicLookup" default="#structNew()#">
		<cfparam name="request.muraSharedContentPermLookup" default="#structNew()#">

		<cfset var key='#arguments.contentid##arguments.siteid##arguments.threshold#'>
		<cfset var sharedkey='#arguments.contentid##arguments.siteid#'>

		<cfif not structkeyExists(request.muraPermPublicLookup,'#key#')>
			<cfif listFind(sessionData.mura.memberships,'Admin;#variables.settingsManager.getSite(arguments.siteid).getPrivateUserPoolID()#;0') or  listFind(sessionData.mura.memberships,'S2') >
				<cfset verdict="editor">
			<cfelse>
				<cfset verdict=getpermverdict(arguments.contentid,'editor,author,read,deny',arguments.siteid,arguments.threshold)>
			</cfif>

			<cfif structKeyExists(request.muraSharedContentPermLookup,'#sharedkey#') 
				and getPermRank(request.muraSharedContentPermLookup['#sharedkey#']) gt getPermRank(verdict)>
				<cfset verdict=request.muraSharedContentPermLookup['#sharedkey#']>
			</cfif>

			<cfset request.muraPermPublicLookup['#key#']=verdict>
		</cfif>
		<cfreturn request.muraPermPublicLookup['#key#']>
	</cffunction>

	<!--- 
		This method is use when you want the explicit permission of the node.
	--->
	<cffunction name="getNodePerm" output="false">
		<cfargument name="crumbdata" required="yes" type="array">
		<cfargument name="threshold" default="editor">
		<cfset var verdictlist="" />
		<cfset var verdict="" />
		<cfset var I = "" />

		<cfloop from="1" to="#arrayLen(arguments.crumbdata)#" index="I">
		<cfset verdict=getPerm(arguments.crumbdata[I].contentid,arguments.crumbdata[I].siteid,arguments.threshold)/>
		<cfif verdict neq 'none'><cfbreak></cfif>
		</cfloop>

		<cfif verdict eq 'deny' or verdict eq ''>
		<cfset verdict='none'>
		</cfif>
		
		<cfreturn verdict>
	</cffunction>

	<cffunction name="getNodePermPublic" output="false">
		<cfargument name="crumbdata" required="yes" type="array">
		<cfargument name="threshold" default="editor">
		<cfset var verdictlist="" />
		<cfset var verdict="none" />
		<cfset var I = "" />

		<cfloop from="1" to="#arrayLen(arguments.crumbdata)#" index="I">
			<cfset verdict=getPermPublic(arguments.crumbdata[I].contentid,arguments.crumbdata[I].siteid,arguments.threshold)/>
			<cfif verdict neq 'none'><cfbreak></cfif>
		</cfloop>

		<cfreturn verdict/>
	</cffunction>

	<cffunction name="getModulePermType" output="false">
		<cfargument name="moduleID" type="string" required="true">
		<cfargument name="siteid" type="string" required="true">
		<cfargument name="publicUserPoolID" default="" type="string" required="true">
		<cfargument name="privateUserPoolID" default="" type="string" required="true">
		
		<cfset var Verdict="none">
		<cfset var rsgroups="">
		<cfset var key="perm" & arguments.moduleID & arguments.siteid  />
		<cfset var sessionData=getSession()>
		<cfset var isSiteBuilt=variables.settingsManager.isSiteBuilt(arguments.siteid)>
		<cfset var site="">

		<cfif isSiteBuilt or
			not len(arguments.privateUserPoolID)
			or not len(arguments.publicUserPoolID)>
			<cfset site=variables.settingsManager.getSite(arguments.siteid)/>
		</cfif>
		
		<cfparam name="sessionData.mura.memberships" default="">

		<cfif not len(arguments.privateUserPoolID)>
			<cfset arguments.privateUserPoolID=site.getPrivateUserPoolID()>
		</cfif>
		<cfif not len(arguments.publicUserPoolID)>
			<cfset arguments.publicUserPoolID=site.getPublicUserPoolID()>
		</cfif>
		
		<cfif listFind(sessionData.mura.memberships,'Admin;#privateUserPoolID#;0') or  listFind(sessionData.mura.memberships,'S2') >
			<cfreturn "module">
		<cfelse>
			<cfif isObject(site) and site.getCache()>
				<cfset var cacheFactory=site.getCacheFactory(name="output")>
				<!--- check to see if it is cached. if not then pass in the context --->
				<!--- otherwise grab it from the cache --->
				<cfif NOT cacheFactory.has( key )>
					<cfset rsgroups=getModulePermQuery(arguments.moduleID,arguments.siteid) />
					<cfset cacheFactory.get( key, rsgroups.recordcount  ) />
				<cfelse>
					<cftry>
						<cfif cacheFactory.get( key ) >
							<cfset rsgroups=getModulePermQuery(arguments.moduleID,arguments.siteid) />
						<cfelse>
							<cfreturn Verdict />
						</cfif>
						<cfcatch>
							<cfset rsgroups=getModulePermQuery(arguments.moduleID,arguments.siteid) />
							<cfset cacheFactory.get( key, rsgroups.recordcount  ) />
						</cfcatch>
					</cftry>
				</cfif>
			<cfelse>
				<cfset rsgroups=getModulePermQuery(arguments.moduleID,arguments.siteid) />
			</cfif>
		
			<cfloop query="rsgroups">
				<cfif getPermRank(rsgroups.permtype) gt getPermRank(Verdict)>
					<cfif rsGroups.isPublic>
						<cfif listFind(sessionData.mura.memberships,"#rsgroups.groupname#;#arguments.publicUserPoolID#;1")>
							<cfset verdict=rsgroups.permtype>
						</cfif>
					<cfelse>
						<cfif listFind(sessionData.mura.memberships,"#rsgroups.groupname#;#arguments.privateUserPoolID#;0")>
							<cfset verdict=rsgroups.permtype>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn verdict>
	</cffunction>

	<cffunction name="getModulePerm" returntype="boolean" output="false">
		<cfargument name="moduleID" type="string" required="true">
		<cfargument name="siteid" type="string" required="true">
		<cfargument name="publicUserPoolID" default="" type="string" required="true">
		<cfargument name="privateUserPoolID" default="" type="string" required="true">
		
		<cfset var rsgroups="">
		<cfset var key="perm" & arguments.moduleID & arguments.siteid  />
		<cfset var sessionData=getSession()>
		<cfset var isSiteBuilt=variables.settingsManager.isSiteBuilt(arguments.siteid)>
		<cfset var site="">

		<cfif isSiteBuilt or
			not len(arguments.privateUserPoolID)
			or not len(arguments.publicUserPoolID)>
			<cfset site=variables.settingsManager.getSite(arguments.siteid)/>
		</cfif>
		
		<cfparam name="sessionData.mura.memberships" default="">

		<cfif not len(arguments.privateUserPoolID)>
			<cfset arguments.privateUserPoolID=site.getPrivateUserPoolID()>
		</cfif>
		<cfif not len(arguments.publicUserPoolID)>
			<cfset arguments.publicUserPoolID=site.getPublicUserPoolID()>
		</cfif>
	
		<cfif listFind(sessionData.mura.memberships,'Admin;#privateUserPoolID#;0') or  listFind(sessionData.mura.memberships,'S2') >
			<cfreturn 1>
		<cfelse>
			<cfif isObject(site) and site.getCache()>
				<cfset var cacheFactory=site.getCacheFactory(name="output")>
				<!--- check to see if it is cached. if not then pass in the context --->
				<!--- otherwise grab it from the cache --->
				<cfif NOT cacheFactory.has( key )>
					<cfset rsgroups=getModulePermQuery(arguments.moduleID,arguments.siteid) />
					<cfset cacheFactory.get( key, rsgroups.recordcount  ) />
				<cfelse>
					<cftry>
						<cfif cacheFactory.get( key ) >
							<cfset rsgroups=getModulePermQuery(arguments.moduleID,arguments.siteid) />
						<cfelse>
							<cfreturn 0>
						</cfif>
						<cfcatch>
							<cfset rsgroups=getModulePermQuery(arguments.moduleID,arguments.siteid) />
							<cfset cacheFactory.get( key, rsgroups.recordcount  ) />
						</cfcatch>
					</cftry>
				</cfif>
			<cfelse>
				<cfset rsgroups=getModulePermQuery(arguments.moduleID,arguments.siteid) />
			</cfif>
		
			<cfloop query="rsgroups">
				<cfif rsGroups.isPublic>
					<cfif listFind(sessionData.mura.memberships,"#rsgroups.groupname#;#arguments.publicUserPoolID#;1")>
						<cfreturn 1>
					</cfif>
				<cfelse>
					<cfif listFind(sessionData.mura.memberships,"#rsgroups.groupname#;#arguments.privateUserPoolID#;0")>
						<cfreturn 1>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn 0>
	</cffunction>

	<cffunction name="getModulePermQuery" output="false">
		<cfargument name="moduleID" type="string" required="true">
		<cfargument name="siteid" type="string" required="true">
		<cfset var rsModulePerm="">

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsModulePerm')#">
			select tusers.groupname,isPublic,tpermissions.type as permtype from tusers INNER JOIN tpermissions ON (tusers.userid = tpermissions.groupid) where tpermissions.contentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.moduleID#"/> and tpermissions.siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
		</cfquery>

		<cfreturn rsModulePerm>
	</cffunction>

	<cfset variables.permRank={
		'editor'=4,
		'module'=4,
		'author'=3,
		'read'=2,
		'deny'=1,
		'none'=0
	}>

	<cffunction name="getPermRank" output="false">
		<cfargument name="perm">
		<cfif structKeyExists(variables.permRank,'#arguments.perm#')>
			<cfreturn variables.permRank['#arguments.perm#']> 
		<cfelse>
			<cfreturn 0>
		</cfif>
	</cffunction>

	<cffunction name="setRestriction" returntype="struct" output="false">
		<cfargument name="crumbdata" required="yes" type="array">
		<cfargument name="hasModuleAccess" required="yes" default="">
		<cfargument name="mode" required="yes" default="default">

		<cfparam name="request.muraSharedContentPermLookup" default="#structNew()#">

		<cfset var r=structnew() />
		<cfset var I = "">
		<cfset var G=0/>
		<cfset var sessionData=getSession()>
		<cfset var explicitDeny=false>
		<cfset r.allow=1 />
		<cfset r.restrict=0 />
		<cfset r.loggedIn=1 />
		<cfset r.perm="read" />
		<cfset r.restrictGroups="" />
		<cfset r.hasModuleAccess=0 />

		<cfif not sessionData.mura.isLoggedIn >
			<cfif cgi.HTTP_USER_AGENT eq 'vspider' and listFirst(cgi.http_host,":") eq 'LOCALHOST' >
				<cfreturn r>
			</cfif>
			<cfset r.loggedIn=0>
		</cfif>

		<cfif not arrayLen(arguments.crumbdata)>
			<cfset r.restrict=0>
			<cfset r.allow=0>
			<cfset r.perm="none" />
			<cfreturn r>
		</cfif>

		<cfif not isBoolean(arguments.hasModuleAccess)>
			<cfset r.hasModuleAccess=getModulePerm('00000000000000000000000000000000000','#arguments.crumbdata[1].siteid#')>
		<cfelse>
			<cfset r.hasModuleAccess=arguments.hasModuleAccess>
		</cfif>

		<cfset site=variables.settingsManager.getSite(arguments.crumbdata[1].siteid)>

		<!--- Check to see if this node is restricted--->
		<cfloop from="1" to="#arrayLen(arguments.crumbdata)#" index="I" step="1">
			<cfif arguments.crumbdata[I].restricted eq 1>
				<cfset r.restrict=1>
				<cfset r.allow=0>
				<cfset r.perm="none" />
				<cfset r.restrictGroups=arguments.crumbdata[I].restrictGroups />
				<cfset r.siteid=arguments.crumbdata[I].siteid />
				<cfif request.muraApiRequest>
					<cfset getBean('utility').excludeFromClientCache()>
					<cfset request.cacheItem=false>
				</cfif>
				<cfbreak>
			</cfif>
		</cfloop>

		<!--- Super users can do anything --->
		<cfif sessionData.mura.isLoggedIn>
			<cfif listFind(sessionData.mura.memberships,'S2')>
				<cfset r.allow=1>
				<cfset r.perm="editor" />
				<cfreturn r>
			<!--- 
				Check if the user has been denied access if they have site module permissions
				or shared content permissions.
			--->
			<cfelseif r.hasModuleAccess or not StructIsEmpty(request.muraSharedContentPermLookup)>
				<cfset var threshold=(arguments.mode == 'default')  ? 'editor' : 'read'>
				<cfset r.perm=getNodePermPublic(arguments.crumbdata,threshold)>

				<cfif r.perm eq 'deny'>
					<cfset r.allow=0>
					<cfset explicitDeny=true>
				<cfelseif r.hasModuleAccess>
					<cfif r.perm eq 'none'>
						<cfset r.perm='read'>
					</cfif>
					<cfset r.allow=1>
					<cfreturn r>
				<cfelseif getPermRank(r.perm) gte getPermRank('read') or not len(r.restrictGroups) >
					<cfset r.allow=1>
					<cfreturn r>
				</cfif>
			</cfif>
		</cfif>
		
		<!--- Check for member group restrictions set on the content node advanced tab--->
		<cfif r.restrict and r.loggedIn>
			<!--- If you have been explicitly denied, the you must belong to a group specifically given access--->
			<cfif r.restrictGroups eq '' and not explicitDeny>
				<cfset r.allow=1>
				<cfset r.perm="read">
			<cfelseif r.restrictGroups neq ''>
				<cfloop list="#r.restrictGroups#" index="G">
					<cfif listFind(sessionData.mura.memberships,"#G#;#variables.settingsManager.getSite(r.siteid).getPublicUserPoolID()#;1")
							or listFind(sessionData.mura.memberships,"#G#;#variables.settingsManager.getSite(r.siteid).getPrivateUserPoolID()#;0")
							or listFind(sessionData.mura.membershipids,G)>
						<cfset r.allow=1>
						<cfset r.perm="read">
					</cfif>
				</cfloop>
			</cfif>
		</cfif>

		<cfreturn r>
	</cffunction>

	<cffunction name="getCategoryPerm" returntype="boolean" output="false">
		<cfargument name="groupList" required="yes" type="string">
		<cfargument name="siteid" required="yes" type="string">

		<cfset var groupArray = "" />
		<cfset var I = "" />
		<cfset var sessionData=getSession()>

		<cfif arguments.groupList neq ''>

			<cfif listFind(sessionData.mura.memberships,'Admin;#variables.settingsManager.getSite(arguments.siteid).getPrivateUserPoolID()#;0')
				or listFind(sessionData.mura.memberships,'S2')>
				<cfreturn true />
			</cfif>

			<cfset groupArray = listtoarray(arguments.grouplist) />
			<cfloop from="1" to="#arrayLen(groupArray)#" index="I" step="1">
				<cfif listFind(sessionData.mura.memberships,'#groupArray[I]#;#variables.settingsManager.getSite(arguments.siteid).getPrivateUserPoolID()#;0')
						or listFind(sessionData.mura.memberships,'#groupArray[I]#;#variables.settingsManager.getSite(arguments.siteid).getPublicUserPoolID()#;1')
						or listFind(sessionData.mura.membershipids,groupArray[I])>
					<cfreturn true />
				</cfif>
			</cfloop>

			<cfreturn false />
		</cfif>

		<cfreturn true />
	</cffunction>

	<cffunction name="getNodePermGroups"  output="false" returntype="struct" >
		<cfargument name="crumbdata" required="yes" type="array">
		<cfargument name="siteid">
		<cfset var permStruct=structnew()>
		<cfset var editorlist=""/>
		<cfset var authorlist=""/>
		<cfset var rsGroups=""/>
		<cfset var deny=false />
		<cfset var author=false />
		<cfset var editor=false />
		<cfset var Verdictlist=""/>
		<cfset var I = "" />

		<cfif arrayLen(arguments.crumbdata)>
			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsGroups')#">
				select userid, groupname from tusers  where type=1 and groupname='admin' and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getBean('settingsManager').getSite(arguments.crumbdata[1].siteid).getPrivateUserPoolID()#"/> 
			</cfquery>

			<cfset editorlist=rsGroups.userid>
		
			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsGroups')#">
				select groupid from tpermissions where contentid='00000000000000000000000000000000000' and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.crumbdata[1].siteid#"/>
			</cfquery>

			<cfloop query="rsGroups">
				<cfset Verdictlist="">
				
				<cfloop from="#arrayLen(arguments.crumbdata)#" to="1" index="I" step="-1">
					<cfset verdictlist=listappend(verdictlist,getGroupPerm(rsgroups.groupid,arguments.crumbdata[I].contentid,arguments.crumbdata[I].siteid))>
				</cfloop>

				<cfset deny=listfind(verdictlist,'deny')>
				<cfset author=listfind(verdictlist,'author')>
				<cfset editor=listfind(verdictlist,'editor')>
			
				<cfif editor gt deny and editor gt author>
					<cfset editorList=listappend(editorList,rsgroups.groupid)>
				<cfelseif author gt deny and author gt editor>
					<cfset authorList=listappend(authorList,rsgroups.groupid)>
				</cfif>

			</cfloop>
		<cfelseif isDefined('arguments.siteid')>
			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsGroups')#">
				select userid, groupname from tusers where type=1 and groupname='admin' and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#getBean('settingsManager').getSite(arguments.siteid).getPrivateUserPoolID()#"/> 
			</cfquery>

			<cfset editorlist=rsGroups.userid>
		</cfif>

		<cfset permStruct.authorList=authorList>
		<cfset permStruct.editorList=editorList>

		<cfreturn permStruct>
	</cffunction>

	<cffunction name="update" output="false">
		<cfargument name="data" type="struct" />
		<cfset var Mura=getBean('Mura').init(arguments.data.siteid)>
		<cfset var rsGroups=Mura.getBean('userGateway').getAllGroups(arguments.data.siteid)>
		
		<cfquery>
		Delete From tpermissions where contentid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.contentID#"/> and siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.siteid#"/>
		</cfquery>

		<cfloop query="rsGroups">
			<cfif isdefined('arguments.data.p#replacelist(rsGroups.userid,"-","")#')
			and (form['p#replacelist(rsGroups.userid,"-","")#'] eq 'Editor'
			or arguments.data['p#replacelist(rsGroups.userid,"-","")#'] eq 'Author'
			or arguments.data['p#replacelist(rsGroups.userid,"-","")#'] eq 'Read'
			or arguments.data['p#replacelist(rsGroups.userid,"-","")#'] eq 'Deny')>
				<cfquery>
				Insert Into tpermissions  (ContentID,GroupID,Type,siteid)
				values(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.ContentID#"/>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#rsGroups.UserID#"/>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data['p#replacelist(rsGroups.userid,"-","")#']#"/>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.siteid#"/>
				)</cfquery>

			</cfif>

		</cfloop>

		<cfif getBean('configBean').getValue(property='autoPurgeOutputCache',defaultValue=true)>
			<cfset variables.settingsManager.getSite(arguments.data.siteid).purgeCache(name="output")>
		</cfif>
	</cffunction>

	<cffunction name="updateGroup" output="true">
		<cfargument name="data" type="struct" />
		<cfset var rsContentlist=""/>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsContentList')#">
		select contentID from tcontent where siteid='#arguments.data.siteid#' group by contentid
		</cfquery>

		<cfquery>
		Delete From tpermissions where groupid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.groupID#"/> and siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.siteid#"/>
		</cfquery>

		<cfloop query="rsContentlist">
			<cfif isdefined('arguments.data.p#replacelist(rsContentlist.contentid,"-","")#')
			and
			(arguments.data['p#replacelist(rsContentlist.contentid,"-","")#'] eq 'Editor'
				or arguments.data['p#replacelist(rsContentlist.contentid,"-","")#'] eq 'Author'
				or arguments.data['p#replacelist(rsContentlist.contentid,"-","")#'] eq 'Module')>

				<cfquery>
				Insert Into tpermissions  (ContentID,GroupID,Type,siteid)
				values(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#rsContentlist.ContentID#"/>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.groupid#"/>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#form['p#replacelist(rsContentlist.contentid,"-","")#']#"/>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.siteid#"/>
				)</cfquery>

			</cfif>

		</cfloop>

		<cfset variables.settingsManager.getSite(arguments.data.siteid).purgeCache()>
	</cffunction>

	<cffunction name="getModule" output="false">
		<cfargument name="data" type="struct" />
		<cfset var rsModulePerm = "" />
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsModulePerm')#">
			SELECT * FROM tcontent WHERE
			ContentID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.contentID#"/> and  siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.siteid#"/> and active=1
		</cfquery>
		<cfreturn rsModulePerm />
	</cffunction>

	<cffunction name="getGroupList" returntype="struct" output="false">
		<cfargument name="data" type="struct" />
		<cfset var rsGroupList = "" />
		<cfset var returnStruct=structNew() />
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsGroupList')#">
			select userid, groupname from tusers where type=1 and groupname <>'Admin' and isPublic=0
			and siteid='#application.settingsManager.getSite(arguments.data.siteid).getPrivateUserPoolID()#'
			order by groupname
		</cfquery>

		<cfset returnStruct.privateGroups=rsGroupList />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsGroupList')#">
			select userid, groupname from tusers where type=1  and isPublic=1
			and siteid='#application.settingsManager.getSite(arguments.data.siteid).getPublicUserPoolID()#'
			order by groupname
		</cfquery>

		<cfset returnStruct.publicGroups=rsGroupList />

		<cfreturn returnStruct />
	</cffunction>

	<cffunction name="getPermitedGroups"  output="false">
		<cfargument name="data" type="struct" />
		<cfset var rsGroupPermissions = "" />
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsGroupPermissions')#">
		select * from tpermissions where contentid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.contentID#"/> and siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.siteid#"/> and type='module'
		</cfquery>
		<cfreturn rsGroupPermissions />
	</cffunction>

	<cffunction name="getcontent" output="false">
		<cfargument name="data" type="struct" />
		<cfset var rsContent = "" />
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rsContent')#">
			SELECT tcontent.*, tfiles.fileEXT FROM tcontent
			LEFT Join tfiles ON (tcontent.fileID=tfiles.fileID)
			WHERE tcontent.ContentID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.contentID#"/> and tcontent.active=1 and tcontent.siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.siteid#"/>
		</cfquery>
		<cfreturn rsContent />
	</cffunction>

	<cffunction name="updateModule"  output="false">
		<cfargument name="data" type="struct" />
		<cfset var I = "" />
		<cfparam name="arguments.data.groupid" type="string" default="" />

		<cfquery>
			Delete From tpermissions where contentid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.contentID#"/> and siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.siteid#"/>
		</cfquery>

		<cfloop list="#arguments.data.groupid#" index="I">

			<cfquery>
			Insert Into tpermissions  (ContentID,GroupID,Type,siteid)
			values(
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.contentID#"/>,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#I#"/>,
			'module',
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.siteid#"/>
			)</cfquery>

		</cfloop>

		<cfif getBean('configBean').getValue(property='autoPurgeOutputCache',defaultValue=true)>
			<cfset variables.settingsManager.getSite(arguments.data.siteid).purgeCache(name="output")>
		</cfif>
	</cffunction>

	<cffunction name="isPrivateUser" returntype="boolean" output="false">
		<cfargument name="siteID" required="true" default="" />
		<cfset var sessionData=getSession()>

		<cfif arguments.siteID neq ''>
			<cfreturn listFindNoCase(sessionData.mura.memberships,'S2IsPrivate;#application.settingsManager.getSite(arguments.siteid).getPrivateUserPoolID()#') />
		<cfelse>
			<cfreturn listFindNoCase(sessionData.mura.memberships,'S2IsPrivate') />
		</cfif>
	</cffunction>

	<cffunction name="isUserInGroup" returntype="boolean" output="false">
		<cfargument name="group" required="true" default="" />
		<cfargument name="siteID" required="true" default="" />
		<cfargument name="isPublic" required="true" default="1" />
		<cfset var sessionData=getSession()>
		<cfif arguments.isPublic>
			<cfreturn listFindNoCase(sessionData.mura.memberships,'#arguments.group#;#application.settingsManager.getSite(arguments.siteid).getPublicUserPoolID()#;#arguments.isPublic#') />
		<cfelse>
			<cfreturn listFindNoCase(sessionData.mura.memberships,'#arguments.group#;#application.settingsManager.getSite(arguments.siteid).getPrivateUserPoolID()#;#arguments.isPublic#') />
		</cfif>
	</cffunction>

	<cffunction name="isS2" returntype="boolean" output="false">
		<cfset var sessionData=getSession()>
		<cfreturn listFindNoCase(sessionData.mura.memberships,'S2') />
	</cffunction>

	<cffunction name="getHasModuleAccess" output="false">
		<cfargument name="siteid">
		<cfif isDefined('request.r.hasModuleAccess')>
			<cfreturn request.r.hasModuleAccess>
		<cfelse>
			<cfreturn ''>
		</cfif>
	</cffunction>

	<cffunction name="queryPermFilter" output="false">
		<cfargument name="rawQuery" type="query">
		<cfargument name="resultQuery" default="">
		<cfargument name="siteID" type="string">
		<cfargument name="hasModuleAccess" required="true" default="#getHasModuleAccess()#">
		<cfargument name="liveOnly" default="true">
		<cfargument name="allowPublicOffLine" default="false">

		<cfset var rows=0/>
		<cfset var r=""/>
		<cfset var i="">
		<cfset var rs=arguments.resultQuery />
		<cfset var hasPath=isDefined('arguments.rawQuery.path') />
		<cfset var hasPermFields=isDefined('arguments.rawQuery.contentid') and isDefined('arguments.rawQuery.parentid') and isDefined('arguments.rawQuery.restricted') and isDefined('arguments.rawQuery.restrictgroups')>
		<cfset var hasLiveFields=isDefined('arguments.rawQuery.approved') && isDefined('arguments.rawQuery.display') and isDefined('arguments.rawQuery.displayStart') and isDefined('arguments.rawQuery.displayStop')>
		<cfset var content=getBean('contentBean')>

		<cfif not arguments.liveOnly and not arguments.allowPublicOffLine>
			<cfset getBean('utility').excludeFromClientCache()>
			<cfset request.cacheItem=false>
		</cfif>

		<cfparam name="request.muraCrumbLookup" default="#structNew()#">

		<cfif not isBoolean(arguments.hasModuleAccess)>
			<cfif not StructKeyExists(request,"r")>
				<cfset request.r=structNew()>
			</cfif>
			<cfset request.r.hasModuleAccess=getModulePerm('00000000000000000000000000000000000',arguments.siteID)>
			<cfset arguments.hasModuleAccess=request.r.hasModuleAccess>
		</cfif>

		<cfif not isQuery(rs)>
			<cfquery name="rs" dbtype="query">
				select * from arguments.rawQuery where 0=1
			</cfquery>
		</cfif>
		
		<!--- loop through and check permissions. If the query has the required field use them to add the prevent the need for building individually --->

		<cfloop query="arguments.rawQuery">
			<cfif not structKeyExists(request.muraCrumbLookup,'#arguments.rawQuery.contentid#')>
				<cfif hasPermFields>
					<cfif arguments.rawQuery.contentid eq '00000000000000000000000000000000001'>
						<cfset var crumbs=[]>
					<cfelse>
						<cfif not structKeyExists(request.muraCrumbLookup,'#arguments.rawQuery.parentid#')>
							<cfif hasPath AND listLen(arguments.rawQuery.path)>
								<cfset var crumbs=duplicate(application.contentGateway.getCrumblist('#arguments.rawQuery.parentid#','#arguments.siteid#',false,listDeleteAt(arguments.rawQuery.path,listLen(arguments.rawQuery.path))))/>
							<cfelse>
								<cfset var crumbs=duplicate(application.contentGateway.getCrumblist('#arguments.rawQuery.parentid#','#arguments.siteid#',false))/>
							</cfif>
							<cfset request.muraCrumbLookup['#arguments.rawQuery.parentid#']=duplicate(crumbs)>
						<cfelse>
							<cfset var crumbs=duplicate(request.muraCrumbLookup['#arguments.rawQuery.parentid#'])>
						</cfif>
					</cfif>
					<cfset arrayPrepend(crumbs,{siteid=arguments.siteid,restricted=arguments.rawQuery.restricted,restrictgroups=arguments.rawQuery.restrictgroups,contentid=arguments.rawQuery.contentid})>
				<cfelse>					
					<cfif hasPath>
						<cfset var crumbs=application.contentGateway.getCrumblist('#arguments.rawQuery.contentid#','#arguments.siteid#',false,arguments.rawQuery.path)>
					<cfelse>
						<cfset var crumbs=application.contentGateway.getCrumblist('#arguments.rawQuery.contentid#','#arguments.siteid#',false)>
					</cfif>
				</cfif>
				<cfset request.muraCrumbLookup['#arguments.rawQuery.contentid#']=crumbs>
			</cfif>
			
			<!---
				If not only showing live content
					double check module access
				if not module access 
					only show content it actually live or user have higher than read access

				If the query being filtered doesn't have all the require fields to determine if the content is live
					then do the more expensive filter for all items
			--->
			
			<cfset var doubleCheckPerm=not arguments.hasModuleAccess
				and not arguments.liveOnly and not arguments.allowPublicOffLine
				and (
						hasLiveFields 
						and not (
							arguments.rawQuery.approved 
							and content.getIsOnDisplay(
								display=arguments.rawQuery.display,
								displayStart=arguments.rawQuery.displayStart,
								displayStop=arguments.rawQuery.displayStop,
								type=arguments.rawQuery.type
							)
						)
						or not hasLiveFields
					)>
	
			<cfset var filterMode=(doubleCheckPerm) ? 'default' : 'gateway'>
		
			<cfset r=setRestriction(request.muraCrumbLookup['#arguments.rawQuery.contentid#'],arguments.hasModuleAccess,filterMode)>
	
			<cfif (
					not r.restrict or r.restrict and r.allow
				) and (
					filterMode eq 'gateway'	
					or getPermRank(r.perm) gt getPermRank('read')
				)>
				<cfset rows=rows+1/>
				<cfset queryAddRow(rs,1)/>
				<cfloop list="#rs.columnList#" index="i">
					<cfset querySetCell(rs,
					i,
					arguments.rawQuery[i][arguments.rawQuery.currentrow],
					rows) />
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn rs/>
	</cffunction>

	<cffunction name="newResultQuery" output="false">
	<cfset var rs = "" />
			<cfswitch expression="#variables.configBean.getCompiler()#">
			<cfcase value="adobe">
				<cfset rs=queryNew("contentid,contenthistid,siteid,title,menutitle,targetParams,filename,summary,tags,restricted,type,subType,restrictgroups,target,fileid,fileSize,fileExt,credits,remoteSource,remoteSourceURL,remoteURL,audience,keyPoints,rating,comments,kids,totalVotes,downVotes,upVotes,parentType,displaystart,displaystop,releasedate,nextn,majorVersion,minorVersion,lockID,assocFilename,lockType","CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_INTEGER,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_TIMESTAMP,CF_SQL_TIMESTAMP,CF_SQL_TIMESTAMP,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR,CF_SQL_VARCHAR")/>
			</cfcase>
			<cfdefaultcase>
				<cfset rs=queryNew("contentid,contenthistid,siteid,title,menutitle,targetParams,filename,summary,tags,restricted,type,subType,restrictgroups,target,fileid,fileSize,fileExt,credits,remoteSource,remoteSourceURL,remoteURL,audience,keyPoints,rating,comments,kids,totalVotes,downVotes,upVotes,parentType,displaystart,displaystop,releasedate,nextn,majorVersion,minorVersion,lockID,assocFilename,lockType","VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,INTEGER,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR")/>
			</cfdefaultcase>
			</cfswitch>
		<cfreturn rs/>
	</cffunction>

	<cffunction name="getDisplayObjectPerm" output="false">
		<cfargument name="siteID">
		<cfargument name="object">
		<cfargument name="objectID" required="true" default="">

		<cfset var objectPerm="none">
		<cfset var objectVerdict="none">

		<cfif listFirst(arguments.object,"_") eq "feed">
				<cfset objectPerm = getModulePerm('00000000000000000000000000000000011',arguments.siteid)>
				<cfif objectPerm>
					<cfset objectVerdict = 'editor'>
				<cfelse>
					<cfset objectVerdict = 'none'>
				</cfif>

			<cfelseif arguments.object eq "component">
					<cfset objectPerm = getPerm('00000000000000000000000000000000003',arguments.siteid)>
					<cfif objectPerm neq 'editor'>
						<cfset objectVerdict = getPerm(arguments.objectID, arguments.siteID)>
						<cfif objectVerdict neq 'deny'>
							<cfif objectVerdict eq 'none'>
								<cfset objectVerdict = objectPerm>
							</cfif>
						<cfelse>
							<cfset objectVerdict = 'none'>
						</cfif>
					<cfelse>
						<cfset objectVerdict = 'editor'>
					</cfif>
			<cfelseif arguments.object eq "form">
				<cfset objectPerm = getPerm('00000000000000000000000000000000004',arguments.siteid)>
				<cfif objectPerm neq 'editor'>
					<cfset objectVerdict = getPerm(arguments.objectID, arguments.siteID)>
					<cfif objectVerdict neq 'deny'>
						<cfif objectVerdict eq 'none'>
							<cfset objectVerdict = objectPerm>
						</cfif>
					<cfelse>
						<cfset objectVerdict = 'none'>
					</cfif>
				<cfelse>
					<cfset objectVerdict = 'editor'>
				</cfif>
			</cfif>
		<cfreturn objectVerdict>
	</cffunction>

	<cffunction name="addPermission" output="false">
		<cfargument name="contentID">
		<cfargument name="groupID">
		<cfargument name="siteID">
		<cfargument name="type">

		<cfset removePermission(argumentcollection=arguments)>

		<cfquery>
			Insert Into tpermissions (contentID,groupID,siteID,type) Values (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#"/> ,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.groupID#"/>,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.type#"/>
			)
		</cfquery>
	</cffunction>

	<cffunction name="removePermission" output="false">
		<cfargument name="contentID">
		<cfargument name="groupID">
		<cfargument name="siteID">

		<cfquery>
			Delete From tpermissions
			where contentid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#"/>
			and siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
			and groupID= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.groupID#"/>
		</cfquery>
	</cffunction>

	<cffunction name="grantModuleAccess" output="false">
		<cfargument name="moduleID">
		<cfargument name="groupID">
		<cfargument name="siteID">

		<cfset addPermission(arguments.moduleID,arguments.groupID,arguments.siteID,"module")>
	</cffunction>

	<cffunction name="removeModuleAccess" output="false">
		<cfargument name="moduleID">
		<cfargument name="groupID">
		<cfargument name="siteID">

		<cfset removePermission(arguments.moduleID,arguments.groupID,arguments.siteID)>
	</cffunction>

	<cffunction name="getFilePermissions" output="false">
		<cfargument name="siteId" type="string" required="true">
		<cfargument name="path" type="string" required="true">

		<cfset var loc = StructNew()>
		<cfset var usrGroups="">

		<cfset loc.return = "deny">

		<!--- Check for super admin --->
		<cfif isS2() or isUserInGroup('Admin',getBean('settingsManager').getSite(arguments.siteID).getPrivateUserPoolID(),0)>
			<cfset loc.return = "editor">
		<cfelse>

			<!--- List groups for current user --->
			<cfset usrGroups = application.usermanager.readMemberships(application.usermanager.getCurrentUserID())>
			<cfif usrGroups.RecordCount gt 0>
				<cfloop query="usrGroups">
					<cfset loc.GroupPerm = getFilePermissionsByGroup(usrGroups.groupid, arguments.siteid, arguments.path)>
					<cfif comparePerm(loc.return, loc.GroupPerm)>
						<cfset loc.return = loc.GroupPerm> <!--- Assign higher level, if found --->
					</cfif>
				</cfloop>
			</cfif>
		</cfif>

		<cfreturn loc.return>
	</cffunction>

	<cffunction name="getFilePermissionsByGroup" output="false">
		<cfargument name="groupId" type="string" required="true">
		<cfargument name="siteId" type="string" required="true">
		<cfargument name="path" type="string" required="true">

		<cfset var loc = StructNew()>
		<cfset loc.return = "editor"> <!--- Default --->

		<cfscript>
			// clean up paths
			if (arguments.path eq '/') arguments.path = '';
			if (arguments.path.endsWith('/')) arguments.path = left(arguments.path, len(arguments.path) -1);
			if (arguments.path.startsWith('/')) arguments.path = right(arguments.path, len(arguments.path) -1);

			// Get array of folders
			loc.ary = listtoarray(arguments.path, '/');
		</cfscript>

		<!---
		<cfsavecontent variable="loc.jon">
			<cfoutput><p>Called getFilePermissionsByGroup with these arguments:</p></cfoutput>
			<cfdump var="#arguments#">
		</cfsavecontent>
		<cffile action="append" file="d:\cms_dev_svn\debug\log.htm" output="#loc.jon#">--->

		<!--- Loop through list of folders, trying to find a match --->
		<cfset loc.path = arguments.path>
		<cfloop from="0" to="#ArrayLen(loc.ary) - 1#" index="loc.idx">
			<cfscript>
				loc.editFileName = loc.ary[ArrayLen(loc.ary) - loc.idx];
				loc.folderLength = len(loc.editFileName);
				if (loc.idx eq arraylen(loc.ary) - 1)
					loc.path = "";
				else
					loc.path = left(loc.path, len(loc.path) - loc.folderLength - 1);
			</cfscript>

			<!---
			<cfsavecontent variable="loc.jon">
				<cfoutput><p>Checking tdirectories for subdir='#loc.path#' and editfilename='#loc.editFileName#'</p></cfoutput>
			</cfsavecontent>
			<cffile action="append" file="d:\cms_dev_svn\debug\log.htm" output="#loc.jon#">--->

			<!--- Check if a value exists in the database for this item --->
			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='loc.qExists')#">
				select tdirectories.dirId from tdirectories
				inner join tpermissions on (tdirectories.dirId=tpermissions.contentid)
				where tdirectories.siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
					and tdirectories.subdir = <cfqueryparam cfsqltype="cf_sql_varchar" value="#loc.path#"/>
					and tdirectories.editfilename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#loc.editFileName#"/>
			</cfquery>

			<!--- if a record exists, check for permissions --->
			<cfif loc.qExists.RecordCount gt 0>
				<cfset loc.return = "deny">
				<!---
				<cfsavecontent variable="loc.jon">
					<cfoutput><p>Checking tpermissions for contentid='#qExists.dirId#' and groupid='#arguments.groupId#'</p></cfoutput>
				</cfsavecontent>
				<cffile action="append" file="d:\cms_dev_svn\debug\log.htm" output="#loc.jon#">--->

				<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='loc.perm')#">
					select type from tpermissions
					where siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
						and contentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#loc.qExists.dirId#"/>
						and groupid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.groupId#"/>
				</cfquery>

				<!--- if a permissions record exists, break loop and return value --->
						<cfif loc.perm.RecordCount gt 0>
							<cfset loc.return = loc.perm.type>
							<cfbreak>
						</cfif>
					</cfif>

		</cfloop>

		<cfreturn loc>
	</cffunction>

	<cffunction name="getFolderPermissionsCacheFactory" output="false">
		<cfargument name="siteid">
		<cfreturn variables.settingsManager.getSite(arguments.siteid).getCacheFactory(name="data")>
	</cffunction>

	<cffunction name="getFolderPermissionsCache" output="false">
		<cfargument name="siteId" type="string" required="true">
		<cfargument name="reset" type="boolean" required="true" default="false">

		<cfset var key="folderpermcache_" & arguments.siteid />
		<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset var cacheFactory=getFolderPermissionsCacheFactory(arguments.siteid)/>
		<cfset var loc = StructNew()/>
		<cfset var cacheObj = {}/>
		<cfset var rs = "" />

		<cfif cacheFactory.has( key ) and !arguments.reset>
			<cfset var obj = cacheFactory.get( key )>
			<cfif structKeyExists(obj,'hasperm')>
				<cfset obj['fromCache'] = true />
				<cfreturn obj />
			</cfif>
		</cfif>

		<cfset cacheObj['hasperm'] = false>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='loc.qfolders')#">
			select * from tdirectories
			where tdirectories.siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
		</cfquery>

		<cfif not loc.qfolders.recordCount>
			<cfset cacheFactory.set( key=key,context=cacheObj,obj=cacheObj ) />
			<cfif arguments.reset>
			<cfset getBean('clusterManager').purgeCacheKey(cacheName='data',cacheKey=key,siteid=arguments.siteid)>
			</cfif>
			<cfreturn cacheObj />
		</cfif>

		<cfset cacheObj['hasperm'] = true>
		
		<cfset var permlist = application.permUtility.getGroupList({siteid=arguments.siteid}) />
		<cfset var grouplist = permlist.privategroups />
		<cfset var memberlist = permlist.publicgroups />
		<cfset cacheObj['folders'] = {}>

		<cfset var g = 0 />

		<cfloop index="f" from="1" to="#loc.qfolders.recordCount#">
			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='loc.perm')#">
				select * from tpermissions
				where tpermissions.contentid = '#loc.qfolders.dirid[f]#'
			</cfquery>

			<cfset cacheObj.folders['q'] = loc.perm >

			<cfloop index="g" from="1" to="#grouplist.recordCount#">
				<cfquery name="rs" dbtype="query">
					select type,groupid from loc.perm
					where groupid = '#grouplist.userid[g]#'
				</cfquery>

				<cfif rs.recordcount>
					<cfif not structKeyExists(cacheObj.folders,loc.qfolders.subdir[f])>
						<cfset cacheObj.folders[loc.qfolders.subdir[f]] = {} />
					</cfif>
					<cfset cacheObj.folders[loc.qfolders.subdir[f]][rs.groupid] = rs.type />
					<cfset cacheObj.folders[loc.qfolders.subdir[f]]['q'] = rs />
				</cfif>
			</cfloop>
			<cfloop index="g" from="1" to="#memberlist.recordCount#">
				<cfquery name="rs" dbtype="query">
					select type,groupid from loc.perm
					where groupid = '#memberlist.userid[g]#'
				</cfquery>

				<cfif rs.recordcount>
					<cfif not structKeyExists(cacheObj.folders,loc.qfolders.subdir[f])>
						<cfset cacheObj.folders[loc.qfolders.subdir[f]] = {} />
					</cfif>
					<cfset cacheObj.folders[loc.qfolders.subdir[f]][rs.groupid] = rs.type />
				</cfif>
			</cfloop>
		</cfloop>	

		<cfset cacheFactory.set( key=key,context=cacheObj,obj=cacheObj ) />
		<cfif arguments.reset>
		<cfset getBean('clusterManager').purgeCacheKey(cacheName='data',cacheKey=key,siteid=arguments.siteid)>
		</cfif>
		<cfreturn cacheObj />	
	</cffunction>

	<cffunction name="getFolderPermissions" output="false">
		<cfargument name="siteId" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfargument name="permstruct" type="struct" required="false" default="#StructNew()#">
		<cfargument name="usrGroups" type="query" required="false">
		<cfargument name="recurseFolder" type="boolean" default="false">

		<cfset var loc = StructNew()>
		<cfset arguments.path=replace(arguments.path,"\","/","all")>

		<cfset var folderPermCache = getFolderPermissionsCache(arguments.siteid)>
		<!--- <cfset loc.cache = folderPermCache /> --->
		<cfset loc.permission = "deny">

		<cfif find("node_modules",path)>
			<cfreturn loc>
		</cfif>

		<!--- no folder permissions assigned --->
		<cfif !folderPermCache['hasperm']>
			<cfset loc.permission = "editor">
			<cfreturn loc>
		</cfif>
	
		<cfif isS2() or isUserInGroup('Admin',getBean('settingsManager').getSite(arguments.siteID).getPrivateUserPoolID(),0)>
			<cfset loc.permission = "editor">
			<cfreturn loc>
		<cfelseif len(arguments.path) and folderPermCache.hasperm>
			<!--- Check for super admin --->
			<!--- List groups for current user --->
			<cfif not structKeyExists(arguments,'usrGroups') or not isQuery(arguments.usrGroups)>
				<cfset arguments.usrGroups = application.usermanager.readMemberships(application.usermanager.getCurrentUserID())>
			</cfif>
			
			<cfif arguments.usrGroups.RecordCount gt 0>
				<cfloop query="arguments.usrGroups">
					<cfset loc.GroupPerm = getFolderPermissionsByGroup(arguments.usrGroups.groupid, arguments.siteid, arguments.path)>
					<cfif comparePerm(loc.permission, loc.GroupPerm.return)>
						<cfset loc.permission = loc.GroupPerm.return> <!--- Assign higher level, if found --->
					</cfif>
				</cfloop>
			</cfif>
		<cfelse>
			<cfset loc.permission = 'editor'>
		</cfif>
		
		<cfreturn loc>
	</cffunction>

	<cffunction name="getFolderPermissionsByGroup" output="false">
		<cfargument name="groupId" type="string" required="true">
		<cfargument name="siteId" type="string" required="true">
		<cfargument name="path" type="string" required="true">

		<cfset var loc = StructNew()>
		<cfset loc.return = "editor"> <!--- Default --->
		<cfset var folderPermCache = getFolderPermissionsCache(arguments.siteid)>
		<cfset loc.hasperm = 0 />

		<!--- no folder permissions assigned --->
		<cfif !folderPermCache['hasperm']>
			<cfset loc.return = "editor">
			<cfreturn loc>
		</cfif>

		<cfset loc.return = "deny">

		<cfset var permstruct = folderPermCache.folders />
	
		<cfscript>
			// clean up paths
			if (arguments.path eq '/') arguments.path = '';
			if (arguments.path.endsWith('/')) arguments.path = left(arguments.path, len(arguments.path) -1);

			if(structKeyExists(permstruct,arguments.path)) {
				loc.hasperm = 1;
			}

			if (arguments.path.startsWith('/')) arguments.path = right(arguments.path, len(arguments.path) -1);
			// Get array of folders
			loc.ary = listtoarray(arguments.path, '/');
		</cfscript>

		<!--- Loop through list of folders, trying to find a match --->
		<cfset loc.path = "">
		<cfset var permissionFound=false>
		<cfloop from="1" to="#ArrayLen(loc.ary)#" index="loc.idx">
			<!--- Folder permissions always use "/" --->
			<cfset loc.path = loc.path & "/" & loc.ary[loc.idx] />

			<!--- no record for this folder --->
			<cfif not structKeyExists(permstruct,loc.path) or not structKeyExists(permstruct[loc.path],arguments.groupid)>
				<cfcontinue />
			</cfif>
			
			<cfset permissionFound=true>
			
			<cfif permstruct[loc.path][arguments.groupid] eq 'editor'>
				<cfset loc.return = 'editor' />
				<cfbreak />
			</cfif>
		</cfloop>
	
		<cfif not permissionFound>
			<cfset loc.return = "editor">
		</cfif>

		<cfreturn loc>
	</cffunction>

	<cffunction name="setFolderPermissionsByGroup" output="false">
		<cfargument name="groups" type="array" required="true">
		<cfargument name="haspermissions" type="boolean" required="true">
		<cfargument name="siteId" type="string" required="true">
		<cfargument name="path" type="string" required="true">

		<cfset var loc = StructNew()>
		<cfset var currentUser = application.usermanager.getCurrentUser() />
		<cfset var key="folderpermcache_" & arguments.siteid />
		<cfset var site=variables.settingsManager.getSite(arguments.siteid)/>
		<cfset var cacheFactory=getFolderPermissionsCacheFactory(arguments.siteid)>

		<cfset cacheFactory.set( key,{} ) />

		<cfif !isS2() and !isUserInGroup('Admin',getBean('settingsManager').getSite(arguments.siteID).getPrivateUserPoolID(),0)>
			<cfreturn loc>
		</cfif>

		<cfscript>
			//Folder permissions always use "/"
			arguments.path=replace(arguments.path,"\","/","all");
			// clean up paths
			if (arguments.path eq '/') arguments.path = '';
			if (arguments.path.endsWith('/')) arguments.path = left(arguments.path, len(arguments.path) -1);

			// Get array of folders
			loc.ary = listtoarray(arguments.path, '/');
		</cfscript>

		<cfset loc.path = arguments.path>
		<cfset log.args = arguments>

		<cfif arrayLen(arguments.groups) and arguments.haspermissions>
			<!--- Check if a value exists in the database for this item --->
			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='loc.qExists')#">
				select tdirectories.dirId from tdirectories
				inner join tpermissions on (tdirectories.dirId=tpermissions.contentid)
				where tdirectories.siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
				and tdirectories.subdir = <cfqueryparam cfsqltype="cf_sql_varchar" value="#loc.path#"/>
			</cfquery>

			<cfif loc.qExists.RecordCount eq 0>
				<cfset loc.dirid = CreateUUID() />

				<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='loc.qExists')#">
					insert into tdirectories
					(dirid,siteid,subdir)
					VALUES
					(<cfqueryparam cfsqltype="cf_sql_varchar" value="#loc.dirid#"/>,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>,<cfqueryparam cfsqltype="cf_sql_varchar" value="#loc.path#"/>)
				</cfquery>
			<cfelse>
				<cfset loc.dirid = loc.qExists.dirId />
			</cfif>

			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='loc.qCleanPerm')#">
				delete from tpermissions
				where contentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#loc.dirid#"/>
				and siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
			</cfquery>

			<cfloop from="1" to="#ArrayLen(arguments.groups)#" index="loc.idx">
				<cfset var perm = iif(arguments.groups[loc.idx].perm eq "editor",de("editor"),de("deny")) />
				<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='loc.qExists')#">
					insert into tpermissions
					(contentid,groupid,siteid,type)
					values
					(<cfqueryparam cfsqltype="cf_sql_varchar" value="#loc.dirid#"/>,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.groups[loc.idx].userid#"/>,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>,<cfqueryparam cfsqltype="cf_sql_varchar" value="#perm#"/>)
				</cfquery>
			</cfloop>

		<!--- inherit --->
		<cfelse>
			<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='loc.qExists')#">
				select tdirectories.dirId from tdirectories
				where tdirectories.siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
				and tdirectories.subdir = <cfqueryparam cfsqltype="cf_sql_varchar" value="#loc.path#"/>
			</cfquery>

			<cfif loc.qExists.RecordCount gt 0>
				<cfset loc.dirid = loc.qExists.dirId />
				<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='loc.qCleanPerm')#">
					delete from tpermissions
					where contentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#loc.dirid#"/>
					and siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
				</cfquery>

				<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='loc.qCleanPerm')#">
					delete from tdirectories
					where dirid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#loc.dirid#"/>
					and siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
				</cfquery>
			</cfif>
		</cfif>

		<cfset var folderPermCache = getFolderPermissionsCache(arguments.siteid,true)>
		<cfreturn loc>
	</cffunction>

	<cffunction name="getDirectoryId" output="false">
		<cfargument name="data" type="struct">

		<cfset var ret = "">
		<cfset var qExists="">

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='qExists')#">
			select dirId from tdirectories
			where siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data.siteid#"/>
				and subdir = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data.subdir#"/>
				and editfilename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data.editfilename#"/>
		</cfquery>
		<cfif qExists.RecordCount gt 0>
			<cfset ret = qExists.dirId>
		</cfif>
		<cfreturn ret>
	</cffunction>

	<!--- Returns True if the "right" argument has greater permission level than "left". --->
	<cffunction name="comparePerm" returntype="boolean" access="private" output="false">
		<cfargument name="left" type="string" required="true">
		<cfargument name="right" type="string" required="true">

		<cfset var ret = false>
		<cfset var possibilities = "">

		<cfswitch expression="#arguments.left#">
			<cfcase value="author">
				<cfset possibilities = "Editor">
			</cfcase>
			<cfcase value="read">
				<cfset possibilities = "Editor,Author">
			</cfcase>
			<cfcase value="deny">
				<cfset possibilities = "Editor,Author,Read">
			</cfcase>
		</cfswitch>

		<!--- If "right" argument is "greater" than "left", return True. --->
		<cfif FindNoCase(arguments.right, possibilities) gt 0>
			<cfset ret = true>
		</cfif>

		<cfreturn ret>
	</cffunction>

	<!--- I don't think this is use anymore --->
	<cffunction name="updateFile" output="false">
		<cfargument name="data" type="struct" />
		<cfargument name="siteid" type="string"/>

		<cfset var dirId=""/>
		<cfset var qExists=""/>

		<!--- insert new directory entry, if needed, and get id --->
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='qExists')#">
			select dirId from tdirectories
			where siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
				and subdir = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.subdir#"/>
				and editfilename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.editfilename#"/>
		</cfquery>
		<cfif qExists.RecordCount gt 0>
			<cfset dirId = qExists.dirId>
		<cfelse>
			<cfset dirId = CreateUUID()>
			<cfquery>
				insert into tdirectories (dirId, siteid, subdir, editfilename)
				values (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#dirId#"/>,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.subdir#"/>,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.editfilename#"/>
				)
			</cfquery>
		</cfif>

		<!--- Delete existing entry in permissions table --->
		<cfquery>
			Delete From tpermissions
			where contentid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#dirId#"/>
				and groupid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.groupid#"/>
				and siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
		</cfquery>

		<!--- Update permissions table --->
		<cfif StructKeyExists(arguments.data, "perm") and (ListContains("editor,author,readonly,deny", arguments.data["perm"]))>
			<cfquery>
				Insert Into tpermissions (ContentID, GroupID, Type, siteid)
				values(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#dirId#"/>,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.groupid#"/>,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.perm#"/>,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#"/>
				)
			</cfquery>

		</cfif>

		<cfset getFolderPermissionsCacheFactory(arguments.siteid).purgeCache()>
	</cffunction>

</cfcomponent>

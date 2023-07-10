<!--- License goes here --->
<cfcomponent extends="mura.baseobject" output="false">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="emailDAO" type="any" required="yes"/>
		<cfargument name="emailGateway" type="any" required="yes"/>
		<cfargument name="emailUtility" type="any" required="yes"/>
		<cfargument name="settingsManager" type="any" required="yes"/>
		<cfargument name="utility" type="any" required="yes"/>
		<cfargument name="trashManager" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfset variables.emailDAO=arguments.emailDAO />
		<cfset variables.emailGateway=arguments.emailGateway />
		<cfset variables.emailUtility=arguments.emailUtility />
		<cfset variables.settingsManager=arguments.settingsManager />
		<cfset variables.globalUtility=arguments.utility />
		<cfset variables.trashManager=arguments.trashManager />
		<cfreturn this />	
	</cffunction>

	<cffunction name="getBean" output="false">
		<cfargument name="beanName" default="email">
		<cfreturn super.getBean(arguments.beanName)>
	</cffunction>

	<cffunction name="getList" output="false">
		<cfargument name="data" type="struct"/>
		<cfset var rs ="" />
		<cfset rs=variables.emailGateway.getList(data) />
		<cfreturn rs />
	</cffunction>
	
	<cffunction name="getPrivateGroups" output="false">
		<cfargument name="siteid" type="string"/>
		<cfset var rs ="" />	
		<cfset rs=variables.emailGateway.getPrivateGroups(arguments.siteid) />
		<cfreturn rs />
	</cffunction>

	<cffunction name="getPublicGroups" output="false">
		<cfargument name="siteid" type="string"/>
		<cfset var rs ="" />
		<cfset rs=variables.emailGateway.getPublicGroups(arguments.siteid) />
		<cfreturn rs />
	</cffunction>

	<cffunction name="getMailingLists" output="false">
		<cfargument name="siteid" type="string"/>
		<cfset var rs ="" />
		<cfset rs=variables.emailGateway.getMailingLists(arguments.siteid) />
		<cfreturn rs />
	</cffunction>

	<cffunction name="save" output="false">
		<cfargument name="data" />
		<cfset var rs="">
		<cfset var emailBean="">
		
		<cfif isObject(arguments.data)>
			<cfset arguments.data=arguments.data.getAllValues()>
		</cfif>
		
		<cfquery name="rs" datasource="#variables.configBean.getReadOnlyDatasource()#"  username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#">
			select emailID from temails where emailID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.emailID#">
		</cfquery>
		
		<cfif structKeyExists(arguments.data,"fromMuraTrash")>
			<cfquery name="rs" datasource="#variables.configBean.getDatasource()#"  username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
			update temails set isDeleted=0 where emailID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.emailID#">
			</cfquery>
			<cfset emailBean=read(arguments.data.emailID)>
			<cfset emailBean.setValue("fromMuraTrash",true)>
			<cfset variables.trashManager.takeOut(emailBean)>
			<cfreturn emailBean>
		</cfif>
		
		<cfif rs.recordcount>
			<cfset arguments.data.action="update">
		<cfelse>
			<cfset arguments.data.action="add">
		</cfif>
		
		<cfreturn update(arguments.data) />
	</cffunction>
	
	<cffunction name="update" output="false">
		<cfargument name="args" type="struct"/>	
		<cfset var emailBean = "" /> 
		<cfset var data=arguments.args />
		<cfset var scheme = application.settingsManager.getSite(data.siteid).getScheme() />
		
		<cfswitch expression="#data.action#">
		<cfcase value="Update">
			<cfset data.bodyhtml=replaceNoCase(data.bodyhtml,'src="/','src="#scheme#://#variables.settingsManager.getSite(data.siteid).getDomain("production")##variables.configBean.getServerPort()#/','ALL')>
			<cfset data.bodyhtml=replaceNoCase(data.bodyhtml,"src='/",'src="#scheme#://#variables.settingsManager.getSite(data.siteid).getDomain("production")##variables.configBean.getServerPort()#/','ALL')>
			<cfset data.bodyhtml=replaceNoCase(data.bodyhtml,'href="/','href="#scheme#://#variables.settingsManager.getSite(data.siteid).getDomain("production")##variables.configBean.getServerPort()#/','ALL')>
			<cfset data.bodyhtml=replaceNoCase(data.bodyhtml,"href='/",'href="#scheme#://#variables.settingsManager.getSite(data.siteid).getDomain("production")##variables.configBean.getServerPort()#/','ALL')>
			
			<cfif data.sendNow eq "true">
				<cfset data.deliveryDate = now()>
			</cfif>
			
			<cfset emailBean=getBean("emailBean") />
			<cfset emailBean.set(data) />
			<cfset emailBean.setLastUpdateBy(left(session.mura.fname & " " & session.mura.lname,50)) />
			<cfset emailBean.setLastUpdateByID(session.mura.userID) />
			<cfset variables.globalUtility.logEvent("EmailID: #emailBean.getEmailID()# Subject:#emailBean.getSubject()# was updated","mura-email","Information",true) />
			<cfset variables.emailDAO.update(emailbean) />
			<cfset variables.emailUtility.send() />
		</cfcase>
		
		<cfcase value="Delete">
			<cfset emailBean=read(data.emailid) />
			<cfset variables.trashManager.throwIn(emailBean)>
			<cfset variables.globalUtility.logEvent("EmailID:#data.emailid# Subject:#emailBean.getSubject()# was deleted","mura-email","Information",true) />
			<cfset variables.emailDAO.delete(data.emailid) />
		</cfcase>
		
		<cfcase value="Add">
			<cfset data.bodyhtml=replaceNoCase(data.bodyhtml,'src="/','src="#scheme#://#variables.settingsManager.getSite(data.siteid).getDomain("production")##variables.configBean.getServerPort()#/','ALL')>
			<cfset data.bodyhtml=replaceNoCase(data.bodyhtml,"src='/",'src="#scheme#://#variables.settingsManager.getSite(data.siteid).getDomain("production")##variables.configBean.getServerPort()#/','ALL')>
			<cfset data.bodyhtml=replaceNoCase(data.bodyhtml,'href="/','href="#scheme#://#variables.settingsManager.getSite(data.siteid).getDomain("production")##variables.configBean.getServerPort()#/','ALL')>
			<cfset data.bodyhtml=replaceNoCase(data.bodyhtml,"href='/",'href="#scheme#://#variables.settingsManager.getSite(data.siteid).getDomain("production")##variables.configBean.getServerPort()#/','ALL')>
			
			<cfif data.sendNow eq "true">
				<cfset data.deliveryDate = now()>
			</cfif>
			
			<cfset emailBean=getBean("emailBean") />
			<cfset emailBean.set(data) />
			<cfset emailBean.setLastUpdateBy(left(session.mura.fname & " " & session.mura.lname,50)) />
			<cfset emailBean.setLastUpdateByID(session.mura.userID) />
			<cfset emailBean.setEmailID(createuuid()) />
			<cfset variables.globalUtility.logEvent("Email:#emailBean.getEmailID()# Subject:#emailBean.getSubject()# was created","mura-email","Information",true) />
			<cfset variables.emailDAO.create(emailbean) />
			<cfset variables.emailUtility.send() />
		</cfcase>
		</cfswitch>
	</cffunction>

	<cffunction name="read" output="false">
		<cfargument name="emailid" type="string" default="" required="yes" />
		<cfset var emailBean ="" />
		<cfset emailBean=variables.emailDAO.read(arguments.emailid) />
		<cfreturn emailBean />
	</cffunction>

	<cffunction name="send" output="false">
		<cfset var pluginEvent=""/>
		<cfset variables.emailUtility.send() />
	</cffunction>

	<cffunction name="forward" output="false">
		<cfargument name="data" type="struct"/>
		<cfset var pluginEvent=""/>

		<cfif structKeyExists(request,"servletEvent")>
			<cfset pluginEvent=request.servletEvent>
		<cfelseif structKeyExists(request,"event")>
			<cfset pluginEvent=request.event>
		<cfelse>
			<cfset pluginEvent = new mura.event() />
		</cfif>

		<cfset getPluginManager().announceEvent('onBeforeEmailForward',pluginEvent)/>
		<cfset variables.emailUtility.forward(data) />
		<cfset getPluginManager().announceEvent('onAfterEmailForward',pluginEvent)/>
	</cffunction>

	<cffunction name="track" output="false">
		<cfargument name="emailid" type="string" required="yes">
		<cfargument name="email" type="string" required="yes">
		<cfargument name="type" type="string" required="yes">
		<cfset variables.emailUtility.track(arguments.emailid,arguments.email,arguments.type)/>
	</cffunction>

	<cffunction name="getStat" output="false">
		<cfargument name="emailid" type="string">
		<cfargument name="type" type="string">
		<cfreturn variables.emailGateway.getStat(arguments.emailid,arguments.type) />
	</cffunction>

	<cffunction name="trackBounces" output="false">
		<cfargument name="siteid" type="string" required="yes">
		<cfset variables.emailUtility.trackBounces(arguments.siteid) />
	</cffunction>

	<cffunction name="getBounces" output="false">
		<cfargument name="emailid" type="string">
		<cfreturn variables.emailGateway.getBounces(arguments.emailid) />
	</cffunction>

	<cffunction name="getReturns" output="false">
		<cfargument name="emailid" type="string">
		<cfreturn variables.emailGateway.getReturns(arguments.emailid) />
	</cffunction>

	<cffunction name="getReturnsByUser" output="false">
		<cfargument name="emailid" type="string">
		<cfreturn variables.emailGateway.getReturnsByUser(arguments.emailid) />
	</cffunction>

	<cffunction name="getSentCount" output="false">
		<cfargument name="siteid" type="string" default="">
		<cfargument name="startDate" type="string" default="">
		<cfargument name="stopDate" type="string" default="">
		<cfreturn variables.emailGateway.getSentCount(arguments.siteid, arguments.startDate, arguments.stopDate) />
	</cffunction>

	<cffunction name="getAllBounces" output="false">
		<cfargument name="data" type="struct">
		<cfreturn variables.emailGateway.getAllBounces(arguments.data) />
	</cffunction>

	<cffunction name="deleteBounces" output="false">
		<cfargument name="data" type="struct">
		<cfreturn variables.emailGateway.deleteBounces(arguments.data) />
	</cffunction>

	<cffunction name="getAddresses" output="false">
		<cfargument name="groupList" type="String" required="true">
		<cfargument name="siteID" type="String" required="true">
		<cfreturn variables.emailUtility.getAddresses(arguments.groupList,arguments.siteID) />
	</cffunction>

	<cffunction name="getEmailActivity" output="false" >
		<cfargument name="siteid" type="string" />
		<cfargument name="limit" type="numeric" required="true" default="3">
		<cfargument name="startDate" type="string" required="true" default="">
		<cfargument name="stopDate" type="string" required="true" default="">
		<cfreturn variables.emailGateway.getEmailActivity(arguments.siteID,arguments.limit,arguments.startDate,arguments.stopDate) />
	</cffunction>

	<cffunction name="getTemplates" output="false">
		<cfargument name="siteid" type="string" required="true">
		<cfreturn variables.emailUtility.getTemplates(arguments.siteid)>
	</cffunction>

</cfcomponent>
<!--- license goes here --->
<cfcomponent output="false" extends="mura.baseobject" hint="Deprecated">

<cfif isDefined("url.args") OR isDefined("form.args")>
	<cfset injectMethod("callWithStructArgs",call)>
	<cfset injectMethod("call",callWithStringArgs)>
</cfif>


<cffunction name="login" output="false" access="remote">
	<cfargument name="username">
	<cfargument name="password">
	<cfargument name="siteID">
	<cfset var authToken=hash(createUUID())>
	<cfset var rsSession="">
	<cfset var sessionData="">
	<cfset var loginSuccess = application.loginManager.remoteLogin(arguments)>

	<cfif loginSuccess>
		<cfwddx action="cfml2wddx" output="sessionData" input="#session.mura#">

		<cfquery name="rsSession" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			select * from tuserremotesessions
			where userID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.mura.userID#">
		</cfquery>

		<cfif rsSession.recordcount>

			<cfif rsSession.lastAccessed gte dateAdd("h",-3,now()) and application.configBean.getSharableRemoteSessions()>
				<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
					update tuserremotesessions set
					data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#sessionData#">,
					lastAccessed=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
					where userID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.mura.userID#">
				</cfquery>

				<cfset authToken=rsSession.AuthToken>

			<cfelse>
				<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
					update tuserremotesessions set
					authToken=<cfqueryparam cfsqltype="cf_sql_varchar" value="#authToken#">,
					data=<cfqueryparam cfsqltype="cf_sql_varchar" value="#sessionData#">,
					created=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
					lastAccessed=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
					where userID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.mura.userID#">
				</cfquery>

			</cfif>
		<cfelse>
			<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
				INSERT Into tuserremotesessions (userID,authToken,data,created,lastAccessed)
				values(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#session.mura.userID#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#authToken#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#sessionData#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
				)
			</cfquery>

		</cfif>


		<cfreturn authToken>
	<cfelse>
		<cfif isDate(session.blockLoginUntil) and session.blockLoginUntil gt now()>
			<cfset application.loginManager.logout()>
			<cfreturn "blocked">
		<cfelse>
			<cfset application.loginManager.logout()>
			<cfreturn "false">
		</cfif>
	</cfif>
</cffunction>

<cffunction name="logout" output="false" access="remote">
	<cfargument name="authToken">

	<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		update tuserremotesessions set
		lastAccessed=#createODBCDateTime(dateAdd("h",-3,now()))#
		where authToken=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authToken#">
	</cfquery>

	<cfset application.loginManager.logout()>

</cffunction>

<cffunction name="getService" output="false">
<cfargument name="serviceName">

	<cfif not structKeyExists(application,"proxyServices")>
		<cfset application.proxyServices=structNew()>
	</cfif>

	<cfif not structKeyExists(application.proxyServices, arguments.serviceName)>
		<cfset application.proxyServices[arguments.serviceName]=new "mura.client.api.soap.v1.#arguments.serviceName#"()>
	</cfif>

	<cfreturn application.proxyServices[arguments.serviceName]>
</cffunction>

<cffunction name="isValidSession" output="false" access="remote">
<cfargument name="authToken">
	<cfset var rsSession="">

	<cfif not len(arguments.authToken)>
		<cfreturn false>
	<cfelse>
		<cfquery name="rsSession" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
			select authToken from tuserremotesessions
			where authtoken=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authToken#">
			and lastAccessed > #createODBCDateTime(dateAdd("h",-3,now()))#
		</cfquery>

		<cfreturn rsSession.recordcount>
	</cfif>
</cffunction>

<cffunction name="getSession" output="false">
<cfargument name="authToken">
	<cfset var rsSession="">
	<cfset var sessionData=structNew()>

	<cfquery name="rsSession" datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		select * from tuserremotesessions
		where authtoken=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authToken#">
	</cfquery>

	<cfquery datasource="#application.configBean.getDatasource()#" username="#application.configBean.getDBUsername()#" password="#application.configBean.getDBPassword()#">
		update tuserremotesessions
		set lastAccessed=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
		where authToken=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.authToken#">
	</cfquery>

	<cfwddx action="wddx2cfml" input="#rsSession.data#" output="sessionData">

	<cfreturn sessionData>
</cffunction>

<cffunction name="call" access="remote">
<cfargument name="serviceName" type="string">
<cfargument name="methodName" type="string">
<cfargument name="authToken" type="string" default="">
<cfargument name="args" default="#structNew()#" type="struct">

<cfset var event="">
<cfset var service="">

<cfif (isDefined("session.mura.isLoggedIn") and session.mura.isLoggedIn)
		or (len(arguments.authToken) and isValidSession(arguments.authToken))>

	<cfif len(arguments.authToken)>
		<cfset session.mura=getSession(arguments.authToken)>
		<cfset session.siteID=session.mura.siteID>
		<cfset application.rbFactory.resetSessionLocale()>
	</cfif>

	<cfif not isObject(arguments.args)>
		<cfset event=new mura.event(args)>
		<cfset event.setValue("proxy",this)>
	<cfelse>
		<cfset event=args>
	</cfif>

	<cfset event.setValue("isProxyCall",true)>
	<cfset event.setValue("serviceName",arguments.serviceName)>
	<cfset event.setValue("methodName",arguments.methodName)>
	<cfset service=getService(event.getValue('serviceName'))>

	<cfinvoke component="#service#" method="call">
		<cfinvokeargument name="event" value="#event#" />
	</cfinvoke>

	<cfif len(arguments.authToken)>
		<cfset application.loginManager.logout()>
	</cfif>

	<cfreturn event.getValue("__response__")>

<cfelse>
	<cfreturn "invalid session">
</cfif>
</cffunction>

<cffunction name="callWithStringArgs" access="remote">
	<cfargument name="serviceName" type="string">
	<cfargument name="methodName" type="string">
	<cfargument name="authToken" type="string" default="">
	<cfargument name="args" default="" type="string">

	<cfif isJSON(arguments.args)>
		<cfset arguments.args=deserializeJSON(arguments.args)>
	<cfelseif isWddx(arguments.args)>
		<cfwddx action="wddx2cfml" input="#arguments.args#" output="arguments.args">
	<cfelseif not isStruct(arguments.args)>
		<cfset arguments.args=structNew()>
	</cfif>
	<cfreturn callWithStructArgs(argumentCollection=arguments)>
</cffunction>

</cfcomponent>

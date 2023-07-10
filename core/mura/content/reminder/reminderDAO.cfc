<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides reminder CRUD functionality">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfreturn this />
	</cffunction>

	<cffunction name="create" output="false">
		<cfargument name="reminderBean" type="any" />

		<cfquery>
			insert into tcontenteventreminders (contentid,email,siteid,reminddate,remindHour,remindMinute,isSent,remindInterval)
			values (
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.reminderBean.getcontentID() neq '',de('no'),de('yes'))#" value="#arguments.reminderBean.getcontentID()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.reminderBean.getEmail() neq '',de('no'),de('yes'))#" value="#arguments.reminderBean.getEmail()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.reminderBean.getSiteID() neq '',de('no'),de('yes'))#" value="#arguments.reminderBean.getSiteID()#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" null="#iif(isdate(arguments.reminderBean.getRemindDate()) ,de('no'),de('yes'))#" value="#createodbcdatetime(dateFormat(arguments.reminderBean.getRemindDate(),'mm/dd/yyyy'))#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reminderBean.getRemindHour()#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reminderBean.getRemindMinute()#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reminderBean.getIsSent()#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reminderBean.getRemindInterval()#">
			)
		</cfquery>

	</cffunction>

	<cffunction name="read" output="false">
		<cfargument name="contentid" type="string">
		<cfargument name="siteid" type="string">
		<cfargument name="email" type="string">

		<cfset var rs=""/>
		<cfset var reminderBean=getBean("reminderBean") />

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			select * from tcontenteventreminders
			where contentid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#"/>
			and siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
			and email= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.email#"/>
		</cfquery>

		<cfif rs.recordcount>
			<cfset reminderBean.set(rs) />
			<cfset reminderBean.setIsNew(0) />
		<cfelse>
			<cfset reminderBean.setcontentId(arguments.contentid) />
			<cfset reminderBean.setSiteId(arguments.siteid) />
			<cfset reminderBean.setEmail(arguments.email) />
		</cfif>

		<cfreturn reminderBean />

	</cffunction>

	<cffunction name="update" output="false">
		<cfargument name="reminderBean" type="any" />

		<cfquery>
			update tcontenteventreminders set
			remindDate=<cfqueryparam cfsqltype="cf_sql_timestamp" null="#iif(isdate(arguments.reminderBean.getRemindDate()) ,de('no'),de('yes'))#" value="#createodbcdatetime(dateFormat(arguments.reminderBean.getRemindDate(),'mm/dd/yyyy'))#">,
			remindHour=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reminderBean.getRemindHour()#">,
			remindMinute=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reminderBean.getRemindMinute()#">,
			remindInterval=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.reminderBean.getRemindInterval()#">
			where
			contentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.reminderBean.getcontentID()#"/>
			and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.reminderBean.getSiteID()#"/>
			and email=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.reminderBean.getEmail()#"/>
		</cfquery>

	</cffunction>

</cfcomponent>

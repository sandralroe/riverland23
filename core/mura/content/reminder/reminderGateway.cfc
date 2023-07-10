<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides reminder gateway queries">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfreturn this />
	</cffunction>

	<cffunction name="getReminders" output="false">
		<cfargument name="theTime" default="#now()#" required="yes">
		<cfset var rs=""/>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			select tsettings.site,tsettings.contact,tsettings.mailserverIP,tsettings.mailserverUsername,
			tsettings.domain ,tsettings.contactName,
			tsettings.contactAddress,tsettings.contactCity,tsettings.contactState,tsettings.contactZip,
			tsettings.contactEmail,tsettings.contactPhone,tsettings.mailserverPassword,
			tcontenteventreminders.email,tcontenteventreminders.remindDate,tcontenteventreminders.remindHour,
			tcontenteventreminders.remindMinute,tcontenteventreminders.remindInterval,tcontenteventreminders.contentID,tcontenteventreminders.isSent,
			tcontent.siteid,tcontent.title,tcontent.filename,tcontent.summary,tcontent.type,tcontent.parentid,
			tcontent.displaystart,tcontent.displaystop
			from tcontenteventreminders inner join tcontent
			On (tcontenteventreminders.contentid=tcontent.contentid and tcontenteventreminders.siteid=tcontent.siteid)
			inner join tsettings on (tcontent.siteid=tsettings.siteid)
			where
			tcontent.display=2
			and tcontent.active=1
			and tcontenteventreminders.remindDate<=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#LSDateFormat(theTime,'mm/dd/yyyy')#">
			and tcontenteventreminders.remindHour<=#hour(theTime)#
			and tcontenteventreminders.remindMinute<=#minute(theTime)#
			and isSent=0
		</cfquery>

		<cfreturn rs />
	</cffunction>

	<cffunction name="getRemindersByContentID" output="false">
		<cfargument name="contentid" type="string"/>
		<cfargument name="siteid" type="string"/>
		<cfset var rs=""/>

		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			select * from tcontenteventreminders where contentid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.contentID#"/> and siteid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/>
		</cfquery>

		<cfreturn rs />
	</cffunction>

</cfcomponent>

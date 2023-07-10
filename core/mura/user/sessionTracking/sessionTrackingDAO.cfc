<!--- license goes here --->
<cfcomponent output="false">

<cffunction name="init" output="false">
<cfargument name="configBean" type="any" required="yes"/>

<cfset variables.datasource=arguments.configBean.getDatasource() />
<cfset variables.dbUsername=arguments.configBean.getDbUsername() />
<cfset variables.dbPassword=arguments.configBean.getDbPassword() />
<cfset variables.clearHistory=arguments.configBean.getClearSessionHistory() />
<cfset variables.sessionHistory=arguments.configBean.getSessionHistory() />
<cfset variables.trackSessionInNewThread=arguments.configBean.getTrackSessionInNewThread()>
<cfset variables.longRequests=0>
<cfset variables.lastPurge=now()>
	
<cfreturn this />
</cffunction>

<cffunction name="trackRequest" output="false">
	<cfargument name="remote_addr" type="string" required="yes"/>
	<cfargument name="script_name" type="string" required="yes"/>
	<cfargument name="query_string" type="string" required="yes"/>
	<cfargument name="server_name" type="string" required="yes"/>
	<cfargument name="referer" type="string" required="yes" default=""/>
	<cfargument name="user_agent" type="string" required="yes" default=""/>
	<cfargument name="keywords" type="string" required="yes" default="" />
	<cfargument name="urlToken" type="string" required="yes"/>
	<cfargument name="UserID" type="string" required="yes"/>
	<cfargument name="siteID" type="string" required="yes"/>
	<cfargument name="contentID" type="string" required="yes"/>
	<cfargument name="locale" type="string" required="yes"/>
	<cfargument name="originalURLToken" type="string" required="yes"/>

	<cfset var $ = new mura.MuraScope() />

	<cfif trim(arguments.referer) eq ''>
		<cfset arguments.referer='Unknown' />
	<cfelseif findNoCase(arguments.server_name,arguments.referer)>
		<cfset arguments.referer="Internal" />
	</cfif>
	
	<!---
	<cfif arguments.user_agent neq ''>
		<cfset arguments.user_agent=arguments.user_agent />
	</cfif>
	--->

	<cfset $.init(duplicate(arguments))>
	<cfset $.announceEvent("onSiteSessionTrack")>

	<cfif variables.trackSessionInNewThread>
		<cflock name="MuraSessionTracking#application.instanceID#" timeout="5">
			<cfthread action="run" name="MuraSessionTracking#application.utility.getUUID()#" context="#arguments#" priority="low">
				<cfset createTrackingRecord(argumentCollection=context)>
			</cfthread>
		</cflock>
	<cfelse>
		 <cfset createTrackingRecord(argumentCollection=arguments)>
	</cfif>
</cffunction>

<cffunction name="createTrackingRecord" output="false">
	<cfargument name="remote_addr" type="string" required="yes"/>
	<cfargument name="script_name" type="string" required="yes"/>
	<cfargument name="query_string" type="string" required="yes"/>
	<cfargument name="server_name" type="string" required="yes"/>
	<cfargument name="referer" type="string" required="yes" default=""/>
	<cfargument name="user_agent" type="string" required="yes" default=""/>
	<cfargument name="keywords" type="string" required="yes" default="" />
	<cfargument name="urlToken" type="string" required="yes"/>
	<cfargument name="UserID" type="string" required="yes"/>
	<cfargument name="siteID" type="string" required="yes"/>
	<cfargument name="contentID" type="string" required="yes"/>
	<cfargument name="locale" type="string" required="yes"/>
	<cfargument name="originalURLToken" type="string" required="yes"/>
	<cfargument name="fname" type="string" required="yes"/>
	<cfargument name="lname" type="string" required="yes"/>
	<cfargument name="company" type="string" required="yes"/>

	<cfset arguments.language = 'Unknown' />
	<cfset arguments.country ='Unknown' />
	<cfset arguments.startCount =GetTickCount()>

	<cfset application.scriptProtectionFilter.scan(
					object=arguments,
					objectname="arguments",
					ipAddress=arguments.remote_addr,
					useWordFilter=true,
					useSQLFilter=false,
					useTagFilter=true)>
			
	<cftry>
		<cfquery>
			INSERT INTO tsessiontracking (REMOTE_ADDR,SCRIPT_NAME,QUERY_STRING,SERVER_NAME,URLToken,UserID,siteID,
				country,lang,locale, contentID, referer,keywords,user_agent,Entered,originalURLToken,fname,lname,company)
			values (
				<cfqueryparam  cfsqltype="cf_sql_varchar" value="#arguments.REMOTE_ADDR#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" value="#left(arguments.SCRIPT_NAME,200)#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" value="#arguments.QUERY_STRING#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" value="#left(arguments.SERVER_NAME,50)#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" value="#left(arguments.URLToken,130)#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" null="#iif(arguments.userid neq '',de('no'),de('yes'))#" value="#arguments.userid#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" null="#iif(arguments.siteid neq '',de('no'),de('yes'))#" value="#arguments.siteid#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" value="#arguments.country#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" value="#arguments.language#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" value="#arguments.locale#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" null="#iif(arguments.contentid neq '',de('no'),de('yes'))#" value="#arguments.contentid#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" value="#left(arguments.referer,255)#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" null="#iif(arguments.keywords neq '',de('no'),de('yes'))#" value="#left(arguments.keywords,200)#"/>,
				<cfqueryparam  cfsqltype="cf_sql_varchar" value="#left(arguments.user_agent,200)#"/>,
				<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
				<cfqueryparam  cfsqltype="cf_sql_varchar" value="#left(arguments.originalURLToken,130)#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" null="#iif(arguments.fname neq '',de('no'),de('yes'))#" value="#arguments.fname#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" null="#iif(arguments.lname neq '',de('no'),de('yes'))#" value="#arguments.lname#" />,
				<cfqueryparam  cfsqltype="cf_sql_varchar" null="#iif(arguments.company neq '',de('no'),de('yes'))#" value="#arguments.company#" />
			)	
		</cfquery>
			
		<cfcatch></cfcatch>
	</cftry>
			
			
	<cfset clearOldData(argumentCollection=arguments)/>
	
	<cfset arguments.duration=GetTickCount()-arguments.startCount>
			
	<cfif arguments.duration gt 5000>
		<cfset variables.longRequests=variables.longRequests+1>
	<cfelse>
		<cfset variables.longRequests=0>
	</cfif>
			
	<cfif variables.longRequests gt 20>
		<cfset application.sessionTrackingThrottle=true>
	 </cfif>
			
</cffunction>

<cffunction name="clearOldData">
	<cfset var requestTime=now()>
	
	<cfif variables.clearHistory
		and dateDiff("s", variables.lastPurge,requestTime) gte 60>
		
       	<cfset variables.lastPurge = requestTime>
		
		<cfquery datasource="#variables.datasource#" username="#variables.dbUsername#" password="#variables.dbPassword#">
		delete from tsessiontracking 
		where entered <  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateAdd('d',-variables.sessionHistory,now())#">
		</cfquery>
	</cfif>
</cffunction>

<cffunction name="deleteSession">
	<cfargument name="URLToken" type="string" required="yes"/>
	<cfquery>
	delete from tsessiontracking 
	where urlToken=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.urlToken#" />
	</cfquery>

</cffunction>

</cfcomponent>
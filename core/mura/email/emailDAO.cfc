<!--- License goes here --->
<cfcomponent extends="mura.baseobject" output="false">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfreturn this />
	</cffunction>

	<cffunction name="create" output="false">
		<cfargument name="emailBean" type="any" />
		<cfquery  datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
	        INSERT INTO temails  (EmailID, Subject,BodyText, BodyHtml,
			  CreatedDate, LastUpdateBy, LastUpdateByID, GroupList, Status, DeliveryDate, siteid, replyto,format,fromLabel,template)
	     VALUES(
	             <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.emailBean.getemailid()#" />,
			  <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getSubject() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getSubject()#">, 
			 
			  <cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.emailBean.getBodyText() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getBodyText()#">,
			  <cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.emailBean.getBodyHtml() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getBodyHtml()#">,
			
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, 
			 <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getLastUpdateBy() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getLastUpdateBy()#">,
			  <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getLastUpdateByID() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getLastUpdateByID()#">,
			 <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getGroupID() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getGroupID()#">,
			0,
			<cfif isdate(arguments.emailBean.getdeliverydate())><cfqueryparam cfsqltype="cf_sql_timestamp" value="#createDateTime(year(arguments.emailBean.getdeliverydate()),month(arguments.emailBean.getdeliverydate()),day(arguments.emailBean.getdeliverydate()),hour(arguments.emailBean.getdeliverydate()),minute(arguments.emailBean.getdeliverydate()),0)#"><cfelse>null</cfif>,
			 <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getSiteID() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getSiteID()#">,
			 <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getReplyTo() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getReplyTo()#">,
			 <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getFormat() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getFormat()#">,
			  <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getFromLabel() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getFromLabel()#">,
			  <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getTemplate() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getTemplate()#">
			
			)
			 
	   </cfquery>
	</cffunction> 

	<cffunction name="read" output="false">
		<cfargument name="emailID" type="string" />
		<cfset var emailBean=getBean("email") />
		<cfset var rs ="" />
		
		<cfquery name="rs" datasource="#variables.configBean.getReadOnlyDatasource()#" username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#">
		Select * from temails where 
		emailid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.emailID#" />
		</cfquery>
		
		<cfif rs.recordcount>
		<cfset emailBean.set(rs) />
		</cfif>
		
		<cfreturn emailBean />
	</cffunction>

	<cffunction name="update" output="false" >
		<cfargument name="emailBean" type="any" />
		
	 	<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
	 		UPDATE temails set 
			 subject =  <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getSubject() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getSubject()#">, 
			
			 bodytext =  <cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.emailBean.getBodyText() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getBodyText()#">,
			 bodyhtml = <cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.emailBean.getBodyHtml() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getBodyHtml()#">,
			
			 createddate = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, 
			 lastupdateby = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getLastUpdateBy() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getLastUpdateBy()#">,
			 lastupdatebyid = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getLastUpdateByID() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getLastUpdateByID()#">,
			 grouplist =  <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getGroupID() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getGroupID()#">,
			 status = 0,
			 deliverydate = <cfif isdate(arguments.emailBean.getdeliverydate())><cfqueryparam cfsqltype="cf_sql_timestamp" value="#createDateTime(year(arguments.emailBean.getdeliverydate()),month(arguments.emailBean.getdeliverydate()),day(arguments.emailBean.getdeliverydate()),hour(arguments.emailBean.getdeliverydate()),minute(arguments.emailBean.getdeliverydate()),0)#"><cfelse>null</cfif>,
			 siteid= <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getSiteID() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getSiteID()#">,
			 replyto=  <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getReplyTo() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getReplyTo()#">,
			 format= <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getFormat() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getFormat()#">,
			 fromLabel= <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getFromLabel() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getFromLabel()#">,
			 template = <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.emailBean.getTemplate() neq '',de('no'),de('yes'))#" value="#arguments.emailBean.getTemplate()#">
			where emailid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.emailBean.getemailID()#" />
	   </cfquery>
	</cffunction>

	<cffunction name="delete" output="false" >
		<cfargument name="emailid" type="string" />
		
		<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#" >
		<!---DELETE FROM temails where emailid='#arguments.emailID#'  --->
		UPDATE temails
		SET isDeleted = 1
		where emailid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.emailID#" />
		</cfquery>
		
		<!--- need to track emails, so don't delete from this log
		<cfquery datasource="#variables.configBean.getDatasource()#" username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#" >
		DELETE FROM temailstats where emailid= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.emailID#" />
		</cfquery>
		--->
	</cffunction>

</cfcomponent>

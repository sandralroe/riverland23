<!--- license goes here --->
<cfcomponent extends="mura.bean.bean" output="false">

	<cfproperty name="MLID" type="string" default="" required="true" />
	<cfproperty name="name" type="string" default="" required="true" />
	<cfproperty name="siteID" type="string" default="" required="true" />
	<cfproperty name="description" type="string" default="" required="true" />
	<cfproperty name="isPurge" type="numeric" default="0" required="true" />
	<cfproperty name="isPublic" type="numeric" default="0" required="true" />
	<cfproperty name="isNew" type="numeric" default="1" required="true" />
	<cfproperty name="lastUpdate" type="date" default="" required="true" />
	<cfproperty name="lastUpdateBy" type="string" default="" required="true" />
	<cfproperty name="lastUpdateByID" type="string" default="" required="true" />

	<cfset variables.primaryKey = 'mlid'>
	<cfset variables.entityName = 'mailinglist'>

	<cffunction name="Init" output="false">
		<cfset super.init(argumentCollection=arguments)>
		
		<cfset variables.instance.mlid="" />
		<cfset variables.instance.name="" />
		<cfset variables.instance.siteid="" />
		<cfset variables.instance.description="" />
		<cfset variables.instance.isPurge=0 />
		<cfset variables.instance.isPublic=0 />
		<cfset variables.instance.isNew=1 />
		<cfset variables.instance.lastUpdate=Now() />
		<cfif session.mura.isLoggedIn>
			<cfset variables.instance.LastUpdateBy = left(session.mura.fname & " " & session.mura.lname,50) />
			<cfset variables.instance.LastUpdateByID = session.mura.userID />
		<cfelse>
			<cfset variables.instance.LastUpdateBy = "" />
			<cfset variables.instance.LastUpdateByID = "" />
		</cfif>

		<cfreturn this />
	</cffunction>

	<cffunction name="setMailingListManager">
		<cfargument name="mailingListManager">
		<cfset variables.mailingListManager=arguments.mailingListManager>
		<cfreturn this>
	</cffunction>

	<cffunction name="setLastUpdate" output="false">
		<cfargument name="LastUpdate" type="string" required="true">
		<cfif isDate(arguments.LastUpdate)>
		<cfset variables.instance.LastUpdate = parseDateTime(arguments.LastUpdate) />
		<cfelse>
		<cfset variables.instance.LastUpdate = ""/>
		</cfif>
	</cffunction>

	<cffunction name="getMLID" output="false">
		<cfif not len(variables.instance.MLID)>
			<cfset variables.instance.MLID = createUUID() />
		</cfif>
		<cfreturn variables.instance.MLID />
	</cffunction>
	
	<cffunction name="setLastUpdateBy" output="false">
		<cfargument name="LastUpdateBy" type="string" required="true">
		<cfset variables.instance.LastUpdateBy = left(trim(arguments.LastUpdateBy),50) />
	</cffunction>

	<cffunction name="save" output="false">
		<cfset setAllValues(variables.mailinglistManager.save(this).getAllValues())>
		<cfreturn this>
	</cffunction>

	<cffunction name="delete" output="false">
		<cfset variables.mailinglistManager.delete(getMLID(),getSiteID())>
	</cffunction>

	<cffunction name="loadBy" output="false">
		<cfif not structKeyExists(arguments,"siteID")>
			<cfset arguments.siteID=getSiteID()>
		</cfif>
		
		<cfset arguments.mailinglistBean=this>
			
		<cfreturn variables.mailinglistManager.read(argumentCollection=arguments)>
	</cffunction>

</cfcomponent>
<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides specialized category utility methods">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="settingsManager" type="any" required="yes"/>
		<cfargument name="categoryGateway" type="any" required="yes"/>

		<cfset variables.configBean=arguments.configBean />
		<cfset variables.settingsManager=arguments.settingsManager />
		<cfset variables.categoryGateway=arguments.categoryGateway />
		<cfset variables.dsn=variables.configBean.getDatasource()/>
		<cfreturn this />
	</cffunction>

	<cffunction name="updateGlobalMaterializedPath" output="false">
		<cfargument name="siteID">
		<cfargument name="parentID" required="true" default="">
		<cfargument name="path" required="true" default=""/>
		<cfargument name="datasource" required="true" default="#variables.dsn#"/>

		<cfset var rs="" />
		<cfset var newPath = "" />
		<cfset var updateDSN=arguments.datasource>
		<cfset var updatePWD="">
		<cfset var updateUSER="">

		<cfif updateDSN eq variables.dsn>
			<cfset updatePWD=variables.configBean.getDBPassword()>
			<cfset updateUSER=variables.configBean.getDBUsername()>
		</cfif>

		<cfquery name="rs" datasource="#updateDSN#" username="#updateUSER#" password="#updatePWD#">
			select categoryID from tcontentcategories
			where siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#" />
			<cfif arguments.parentID neq ''>
			and parentID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.parentID#" />
			<cfelse>
			and parentID is null
			</cfif>
		</cfquery>

		<cfloop query="rs">
			<cfset newPath=listappend(arguments.path,rs.categoryID) />
			<cfquery datasource="#updateDSN#" username="#updateUSER#" password="#updatePWD#">
				update tcontentcategories
				set path=<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#newPath#" />
				where siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#" />
				and categoryID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#rs.categoryID#" />
			</cfquery>
			<cfset this.updateGlobalMaterializedPath(arguments.siteID,rs.categoryID,newPath,updateDSN) />
		</cfloop>
	</cffunction>

</cfcomponent>

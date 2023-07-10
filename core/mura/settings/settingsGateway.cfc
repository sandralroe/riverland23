<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides site gateway queries">

	<cfset variables.rslists={}>
	
	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfreturn this />
	</cffunction>

	<cffunction name="invalidateSiteListCache" output=false>
		<cfscript>
			for(var queryKey in variables.rslists){
				variables.rslists['#queryKey#'].isStale=true;
			}
		</cfscript>
	</cffunction>

	<cffunction name="getList" output="false">
		<cfargument name="sortBy" default="orderno">
		<cfargument name="sortDirection" default="asc">
		<cfargument name="cached" default="true" />
		
		<cfset var rs = "" />

		<cfset var isMuraReload=(StructKeyExists(request, 'muraAppreloaded') and isBoolean(request['muraAppreloaded']) && request['muraAppreloaded'])>
		
		<cfif isMuraReload>
			<cfset invalidateSiteListCache()>
		</cfif>
		
		<cfset var queryKey="rs#arguments.sortBy##arguments.sortDirection#">

		<cfif not structKeyExists(variables.rslists,'#queryKey#') 
			or not structKeyExists(variables.rslists['#queryKey#'],'isStale')>
			<cfset variables.rslists['#queryKey#']={
				isStale=true
			}>
		</cfif>

		<cfif variables.rslists['#queryKey#'].isStale or not arguments.cached>
			<cfquery name="rs">
				SELECT * FROM tsettings ORDER BY
				<cfif listFindNoCase("domain,site,orderno",arguments.sortBy)>
					#arguments.sortBy#
				<cfelse>
					orderno
				</cfif>
				<cfif listFindNoCase("asc,desc",arguments.sortDirection)>
					#arguments.sortDirection#
				<cfelse>
					asc
				</cfif>
			</cfquery>
			<cfset variables.rslists["#queryKey#"].query = rs />
			<cfset variables.rslists["#queryKey#"].isStale=false>
		</cfif>
	
		<cfreturn variables.rslists["#queryKey#"].query />
	</cffunction>

</cfcomponent>

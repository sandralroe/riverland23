<!--- license goes here --->
<cfcomponent output="false" extends="mura.baseobject" hint="Deprecated">

<cffunction name="init" output="false">
	<cfset super.init()>
	<cfreturn this>
</cffunction>

<cffunction name="call">
	<cfargument name="event">

	<cfset proceed(event)>

</cffunction>

<cffunction name="proceed">
	<cfargument name="event">

	<cfinvoke component="#this#" method="#event.getValue('methodName')#">
		<cfinvokeargument name="event" value="#event#" />
	</cfinvoke>

</cffunction>

<cffunction name="format">
	<cfargument name="data">

	<cfreturn removeObjects(arguments.data)>
</cffunction>

<cffunction name="removeObjects">
	<cfargument name="data">

	<cfif isstruct(arguments.data)>
		<cfloop collection="#arguments.data#" item="local.dataitem">
			<cfif isobject(arguments.data[local.dataitem])>
				<cfset structdelete(arguments.data,local.dataitem,false)>
			<cfelseif isstruct(arguments.data[local.dataitem])>
				<cfset removeObjects(arguments.data[local.dataitem])>
			</cfif>
		</cfloop>
	</cfif>

	<cfreturn arguments.data>
</cffunction>

<cffunction name="ifOracleFixClobs" output="false">
	<cfargument name="rs">
	<cfif application.configBean.getDbType() eq 'Oracle'>
		<cfreturn application.utility.fixOracleClobs(rs)>
	<cfelse>
		<cfreturn rs>
	</cfif>
</cffunction>

</cfcomponent>

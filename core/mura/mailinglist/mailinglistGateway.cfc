<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfreturn this />
	</cffunction>

	<cffunction name="getListMembers" output="false">
		<cfargument name="mlid" type="string" />
		<cfargument name="siteid" type="string" />
		<cfset var rs = ""/>
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
		select mlid,email,siteid,fname,lname,company,isVerified,created from tmailinglistmembers where mlid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mlid#" /> and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#" /> order by email
		</cfquery>

		<cfreturn rs />
	</cffunction>

	<cffunction name="getList" output="false">
		<cfargument name="siteid" type="string" />
		<cfset var rs = ""/>
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
		select tmailinglist.siteid, tmailinglist.name, tmailinglist.lastupdate, tmailinglist.mlid, tmailinglist.ispurge, tmailinglist.isPublic, count(tmailinglistmembers.mlid) as "Members" from tmailinglist LEFT JOIN tmailinglistmembers ON(tmailinglist.mlid=tmailinglistmembers.mlid and tmailinglist.siteid=tmailinglistmembers.siteid)
		WHERE tmailinglist.siteid =<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#" /> 
		GROUP By tmailinglist.siteid, tmailinglist.name, tmailinglist.mlid, tmailinglist.ispurge, tmailinglist.lastupdate,tmailinglist.isPublic
		ORDER BY tmailinglist.ispurge desc, tmailinglist.name
		</cfquery>
		
		<cfreturn rs />
	</cffunction>


</cfcomponent>
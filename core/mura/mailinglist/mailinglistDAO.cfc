<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfreturn this />
	</cffunction>

	<cffunction name="create" output="false">
		<cfargument name="listBean" type="any" />
		
		<cfquery>
			insert into tmailinglist (mlid,name,lastupdate,siteid,isPublic,description,ispurge)
			values (
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.listBean.getMLID()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.listBean.getName() neq '',de('no'),de('yes'))#" value="#arguments.listBean.getName()#">,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.listBean.getSiteID() neq '',de('no'),de('yes'))#" value="#arguments.listBean.getsiteID()#">,
			#arguments.listBean.getisPublic()#,
			<cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.listBean.getDescription() neq '',de('no'),de('yes'))#" value="#arguments.listBean.getDescription()#">,
			0)
		</cfquery>
	</cffunction> 

	<cffunction name="read" output="false">
		<cfargument name="MLID" type="string" />
		<cfargument name="mailingListBean" default="" />
		<cfset var rs ="" />
		<cfset var bean=arguments.mailinglistBean />
		
		<cfif not isObject(bean)>
			<cfset bean=getBean("mailingList")>
		</cfif>
		
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			Select * from tmailinglist where 
			mlid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.MLID#">
		</cfquery>
		
		<cfif rs.recordcount>
			<cfset bean.set(rs) />
			<cfset bean.setIsNew(0)>
		</cfif>
		
		<cfreturn bean />
	</cffunction>

	<cffunction name="readByName" output="false">
		<cfargument name="name" type="string" />
		<cfargument name="siteid" type="string" />
		<cfargument name="mailingListBean" default="" />
		<cfset var rs ="" />
		<cfset var beanArray=arrayNew(1)>
		<cfset var bean=arguments.mailinglistBean />
		<cfset var utility=""/>
		<cfif not isObject(bean)>
			<cfset bean=getBean("mailingList")>
		</cfif>
		
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			Select * from tmailinglist where 
			name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.name#">
			and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#">
		</cfquery>
		
		<cfif rs.recordcount gt 1>
			<cfset utility=getBean("utility")>
			<cfloop query="rs">
				<cfset bean=getBean("mailingList").set(utility.queryRowToStruct(rs,rs.currentrow))>
				<cfset bean.setIsNew(0)>
				<cfset arrayAppend(beanArray,bean)>		
			</cfloop>
			<cfreturn beanArray>
		<cfelseif rs.recordcount>
			<cfset bean.set(rs) />
			<cfset bean.setIsNew(0)>
		<cfelse>
			<cfset bean.setSiteID(arguments.siteID) />
		</cfif>
		
		<cfreturn bean />
	</cffunction>

	<cffunction name="update" output="false" >
		<cfargument name="listBean" type="any" />
		
		<cfquery>
			update tmailinglist set name=<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.listBean.getName() neq '',de('no'),de('yes'))#" value="#arguments.listBean.getName()#">,
			lastupdate=<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">, 
			isPublic=<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.listBean.getIsPublic()#">,
			description=<cfqueryparam cfsqltype="cf_sql_longvarchar" null="#iif(arguments.listBean.getDescription() neq '',de('no'),de('yes'))#" value="#arguments.listBean.getDescription()#">
			where mlid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.listBean.getMLID()#"> and
			siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.listBean.getSiteID()#">
		</cfquery>

	</cffunction>

	<cffunction name="delete" output="false" >
		<cfargument name="mlid" type="string" />
		<cfargument name="siteid" type="string" />
		
		<cfquery>
			delete from tmailinglist where mlid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mlid#"> and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#">
		</cfquery>

	</cffunction>

	<cffunction name="deleteMembers" output="false" >
		<cfargument name="mlid" type="string" />
		<cfargument name="siteid" type="string" />

		<cfquery>
			delete from tmailinglistmembers where mlid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.mlid#"> and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteid#">
		</cfquery>

	</cffunction>

</cfcomponent>

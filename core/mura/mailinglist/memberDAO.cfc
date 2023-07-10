<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfreturn this />
	</cffunction>

	<cffunction name="create" output="false" >
		<cfargument name="memberBean" type="any" />
		<cfset var L=""/>
		<cfset var currBean=read(arguments.memberBean.getEmail(),arguments.memberBean.getSiteID()) />
		
			<cfif REFindNoCase("^[^@%*<>' ]+@[^@%*<>' ]{1,255}\.[^@%*<>' ]{2,5}", trim(arguments.memberBean.getEmail())) neq 0>			
				<cfloop list="#arguments.memberBean.getMLID()#" index="L">
					<cfif not listfind(currBean.getMLID(),L)>
						<cftry>
						<cfquery>
							insert into tmailinglistmembers (mlid,email,siteid,fname,lname,company,isVerified,created)
							values (<cfqueryparam cfsqltype="cf_sql_varchar" value="#L#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.memberBean.getEmail())#" />
							,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.memberBean.getSiteID()#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.memberBean.getFName() neq '',de('no'),de('yes'))#" value="#arguments.memberBean.getFName()#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.memberBean.getLName() neq '',de('no'),de('yes'))#" value="#arguments.memberBean.getLName()#">
							,<cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.memberBean.getCompany() neq '',de('no'),de('yes'))#" value="#arguments.memberBean.getCompany()#">
							,<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.memberBean.getIsVerified()#">,
							<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
							)
						</cfquery>
						<cfcatch type="database"></cfcatch>
						</cftry>
					</cfif>
				</cfloop>
			</cfif>
			
	</cffunction>

	<cffunction name="read" output="false">
		<cfargument name="email" type="string" />
		<cfargument name="siteID" type="string" />
		<cfset var memberBean=getBean("mailingListMember") />
		<cfset var rs ="" />
		<cfset var data =structNew() />
		
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			Select mlid,siteid,email,fname,lname,company,isVerified,created from tmailinglistmembers where 
			siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.siteID)#">
			and email=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.email)#" />
		</cfquery>
		
		<cfset data.siteid=arguments.siteid>
		<cfset data.email=arguments.email>
		<cfset data.lName=rs.lName>
		<cfset data.fName=rs.fName>
		<cfset data.company=rs.company>
		<cfset data.mlid=valueList(rs.mlid)>
		<cfset data.isVerified=rs.isVerified>
		
		<cfif rs.recordcount>
			<cfset data.isNew=0 />
			<cfset memberBean.set(data) />
		<cfelse>
			<cfset memberBean.setSiteID(arguments.siteID) />
		</cfif>
		
		<cfreturn memberBean />
	</cffunction>

	<cffunction name="update" output="false" >
		<cfargument name="memberBean" type="any" />

		<cfif REFindNoCase("^[^@%*<> ]+@[^@%*<> ]{1,255}\.[^@%*<> ]{2,5}", trim(arguments.memberBean.getEmail())) neq 0>
			<cftry>
			<cfquery>
				update tmailinglistmembers 
				set 
				fName= <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.memberBean.getFName() neq '',de('no'),de('yes'))#" value="#arguments.memberBean.getFName()#">
				,lName= <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.memberBean.getLName() neq '',de('no'),de('yes'))#" value="#arguments.memberBean.getLName()#">
				,company= <cfqueryparam cfsqltype="cf_sql_varchar" null="#iif(arguments.memberBean.getCompany() neq '',de('no'),de('yes'))#" value="#arguments.memberBean.getCompany()#">
				,isVerified= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.memberBean.getIsVerified()#">
				where siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.memberBean.getSiteID())#">
				and email= <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.memberBean.getEmail())#" />
			</cfquery>
			<cfcatch type="database"></cfcatch>
			</cftry>
		</cfif>

	</cffunction>

	<cffunction name="deleteAll" output="false" >
		<cfargument name="memberBean" type="any" />

		<cfif REFindNoCase("^[^@%*<> ]+@[^@%*<> ]{1,255}\.[^@%*<> ]{2,5}", trim(arguments.memberBean.getEmail())) neq 0>
			<cftry>
			<cfquery>
				delete from tmailinglistmembers where email=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.memberBean.getEmail())#" /> and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.memberBean.getsiteID())#" />
			</cfquery>
			<cfcatch type="database"></cfcatch>
			</cftry>
		</cfif>

	</cffunction>

	<cffunction name="delete" output="false" >
		<cfargument name="memberBean" type="any" />
		
		<cfif REFindNoCase("^[^@%*<> ]+@[^@%*<> ]{1,255}\.[^@%*<> ]{2,5}", trim(arguments.memberBean.getEmail())) neq 0>
			<cftry>
			<cfquery>
				delete from tmailinglistmembers where mlid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.memberBean.getMLID()#" /> and email=<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.memberBean.getEmail())#" /> and siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.memberBean.getSiteID()#" />
			</cfquery>
			<cfcatch type="database"></cfcatch>
			</cftry>
		</cfif>

	</cffunction>

</cfcomponent>
<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="mailinglistDAO" type="any" required="yes"/>
		<cfargument name="mailinglistGateway" type="any" required="yes"/>
		<cfargument name="mailinglistUtility" type="any" required="yes"/>
		<cfargument name="memberManager" type="any" required="yes"/>
		<cfargument name="utility" type="any" required="yes"/>
		<cfargument name="settingsManager" type="any" required="yes"/>
		<cfargument name="trashManager" type="any" required="yes"/>
		
		<cfset variables.configBean=arguments.configbean />
		<cfset variables.mailinglistDAO=arguments.mailinglistDAO />
		<cfset variables.mailinglistGateway=arguments.mailinglistGateway />
		<cfset variables.mailinglistUtility=arguments.mailinglistUtility />
		<cfset variables.memberManager=arguments.memberManager />
		<cfset variables.utility=arguments.utility />
		<cfset variables.settingsManager=arguments.settingsManager />
		<cfset variables.trashManager=arguments.trashManager />
		<cfreturn this />
	</cffunction>

	<cffunction name="save" output="false">
		<cfargument name="data">
		<cfset var rs="">
		
			<cfif isObject(arguments.data)>
			<cfif listLast(getMetaData(arguments.data).name,".") eq "mailinglistBean">
				<cfset arguments.data=arguments.data.getAllValues()>
			<cfelse>
				<cfthrow type="custom" message="The attribute 'DATA' is not of type 'mura.mailinglist.mailinglistBean'">
			</cfif>
		</cfif>
		
		<cfif not structKeyExists(arguments.data,"mlid")>
			<cfthrow type="custom" message="The attribute 'NLID' is required when saving a mailing list.">
		</cfif>
		
		<cfquery attributeCollection="#variables.configBean.getReadOnlyQRYAttrs(name='rs')#">
			select * from tmailinglist where mlid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.data.mlid#">
		</cfquery>

		<cfif not rs.recordcount>
			<cfreturn create(arguments.data)>
		<cfelse>
			<cfreturn update(arguments.data)>
		</cfif>
	</cffunction>

	<cffunction name="update" output="false" >
		<cfargument name="data" type="struct"  />
		
		<cfset var listBean=getBean("mailinglist") />
		<cfset listBean.set(arguments.data) />
		<cfset variables.utility.logEvent("MLID:#listBean.getMLID()# Name:#listBean.getName()# was created","mura-mailinglists","Information",true) />
		<cfset variables.mailinglistDAO.update(listbean) />
		<cfif isdefined('arguments.data.listfile') and arguments.data.listfile neq ''>
			<cfset variables.mailinglistUtility.upload(arguments.data.direction,listbean) />
		</cfif>
		<cfif isdefined('arguments.data.clearMembers')>
			<cfset  variables.mailinglistDAO.deleteMembers(arguments.data.mlid,arguments.data.siteid) />
		</cfif>
		<cfset variables.settingsManager.getSite(arguments.data.siteid).purgeCache() />
	</cffunction>

	<cffunction name="create" output="false">
		<cfargument name="data" type="struct"  />
		
		<cfset var listBean=getBean("mailinglist") />
		<cfset listBean.set(arguments.data) />
		<cfif not structKeyExists(arguments.data,"fromMuraTrash")>
			<cfset listBean.setMLID(createuuid()) />
		</cfif>
		<cfset variables.utility.logEvent("MLID:#listBean.getMLID()# Name:#listBean.getName()# was updated","mura-mailinglists","Information",true) />
		<cfset variables.mailinglistDAO.create(listbean) />
		<cfif isdefined('arguments.data.listfile') and arguments.data.listfile neq ''>
			<cfset variables.mailinglistUtility.upload(arguments.data.direction,listbean) />
		</cfif>
		<cfset variables.settingsManager.getSite(arguments.data.siteid).purgeCache() />
		<cfset variables.trashManager.takeOut(listBean)>
		<cfset listbean.setIsNew(0)>
		<cfreturn listBean />
	</cffunction>

	<cffunction name="delete" output="false" >
		<cfargument name="mlid" type="string" />
		<cfargument name="siteid" type="string" />
		
		<cfset var listBean=read(arguments.mlid,arguments.siteid) />
		<cfset variables.trashManager.throwIn(listBean)>
		<cfset variables.utility.logEvent("MLID:#arguments.mlid# Name:#listBean.getName()# was deleted","mura-mailinglists","Information",true) />
		<cfset variables.mailinglistDAO.delete(arguments.mlid,arguments.siteid) />
		<cfset variables.settingsManager.getSite(arguments.siteid).purgeCache() />
		
	</cffunction>

	<cffunction name="deleteMember" output="false" >
		<cfargument name="data" type="struct" />
		
		<cfset variables.memberManager.delete(arguments.data) />
		
	</cffunction>

	<cffunction name="deleteMemberAll" output="false" >
		<cfargument name="data" type="struct" />
		
		<cfset variables.memberManager.deleteAll(arguments.data) />
		
	</cffunction>

	<cffunction name="createMember" output="false" >
		<cfargument name="data" type="struct" />
		
		<cfset variables.memberManager.create(arguments.data,this) />
		
	</cffunction>

	<cffunction name="read" output="false">
		<cfargument name="mlid" type="string" default=""/>
		<cfargument name="siteid" type="string"/>
		<cfargument name="name" required="true" default=""/>
		
		<cfif not len(arguments.mlid) and len(arguments.siteID) and len(arguments.name)>
			<cfreturn variables.mailinglistDAO.readByName(arguments.name, arguments.siteID) />
		</cfif>	
			
		<cfreturn variables.mailinglistDAO.read(arguments.mlid) />
		
	</cffunction>

	<cffunction name="readMember" output="false">
		<cfargument name="data" type="struct" />
		
		<cfset var memberBean = variables.memberManager.read(arguments.data) />
		
		<cfreturn memberBean />
		
	</cffunction>

	<cffunction name="getListMembers" output="false" >
		<cfargument name="mlid" type="string" />
		<cfargument name="siteid" type="string" />
		
		<cfset var rs = variables.mailinglistGateway.getListMembers(arguments.mlid,arguments.siteid) />
		
		<cfreturn rs />
		
	</cffunction>

	<cffunction name="deleteMembers" output="false" >
		<cfargument name="mlid" type="string" />
		<cfargument name="siteid" type="string" />
		
		<cfset  variables.mailinglistDAO.deleteMembers(arguments.mlid,arguments.siteid) />
		
	</cffunction>

	<cffunction name="getList" output="false" >
		<cfargument name="siteid" type="string" />
		
		<cfset var rs = variables.mailinglistGateway.getList(arguments.siteid) />
		
		<cfreturn rs />
		
	</cffunction>

	<cffunction name="masterSubscribe" output="false" >
		<cfargument name="data" type="struct" />

		<cfset variables.memberManager.masterSubscribe(arguments.data,this) />

	</cffunction>

	<cffunction name="validateMember" output="false" >
		<cfargument name="data" type="struct" />

		<cfset variables.memberManager.validateMember(arguments.data) />

	</cffunction>

</cfcomponent>
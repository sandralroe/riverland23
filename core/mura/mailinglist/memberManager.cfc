<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="memberDAO" type="any" required="yes"/>
		<cfargument name="settingsManager" type="any" required="yes"/>
		<cfargument name="contentRenderer" type="any" required="yes"/>

		<cfset variables.configBean=arguments.configBean />
		<cfset variables.memberDAO=arguments.memberDAO />
		<cfset variables.settingsManager=arguments.settingsManager />
		<cfset variables.contentRenderer=arguments.contentRenderer />
			
		<cfreturn this />
	</cffunction>

	<cffunction name="setMailer" output="false">
		<cfargument name="mailer"  required="true">

		<cfset variables.mailer=arguments.mailer />
	</cffunction>

	<cffunction name="delete" output="false" >
		<cfargument name="data" type="struct" />
		
		<cfset var memberBean=getBean("memberBean") />
		<cfset memberBean.set(arguments.data) />
		
		<cfset variables.memberDAO.delete(memberBean) />	
	</cffunction>

	<cffunction name="deleteAll" output="false" >
		<cfargument name="data" type="struct" />
		
		<cfset var memberBean=getBean("memberBean") />
		<cfset memberBean.set(arguments.data) />
		
		<cfset variables.memberDAO.deleteAll(memberBean) />		
	</cffunction>

	<cffunction name="create" output="false" >
		<cfargument name="data" type="struct" />
		<cfargument name="mailingListManager" type="any" required="yes"/>
		
		<cfset var memberBean=""/>
		<cfset var listBean=""/>
		
		<cfif arguments.data.mlid neq ''>
			<cftry>
			<cfset memberBean=variables.memberDAO.read(arguments.data.email,arguments.data.siteid) />
			<cfset memberBean.set(arguments.data) />
			<cfif memberBean.getIsVerified() eq 0>
				<cfset listBean=arguments.mailingListManager.read(arguments.data.mlid,arguments.data.siteid) />
				<cfset sendVerification(arguments.data.email,arguments.data.mlid,arguments.data.siteid,listBean.getName())>
			</cfif>
			<cfset variables.memberDAO.update(memberBean) />
			<cfset variables.memberDAO.create(memberBean) />
			<cfcatch type="database"></cfcatch>
			</cftry>
		</cfif>

	</cffunction>

	<cffunction name="read" output="false">
		<cfargument name="data" type="struct" />
		<cfset var memberBean="">
		
		<cfif not structKeyExists(arguments.data,"mailinglistBean")>
			<cfset arguments.data.mailinglistBean="">	
		</cfif>
		
		<cfset memberBean = variables.memberDAO.read(arguments.data.email,arguments.data.siteid,arguments.data.mailinglistBean) />
		
		<cfreturn memberBean />
		
	</cffunction>

	<cffunction name="masterSubscribe" output="false" >
		<cfargument name="data" type="struct" />
		<cfargument name="mailingListManager" type="any" required="yes"/>

		<cfset deleteAll(arguments.data) />
		<cfset create(arguments.data,arguments.mailingListManager) />
	</cffunction>

	<cffunction name="sendVerification" output="false">
		<cfargument name="sendto" type="string" default="">
		<cfargument name="mlid" type="string" default="">
		<cfargument name="siteid" type="string" default="">
		<cfargument name="mailingListName" type="string" default="">

		<cfset var rsReturnForm=""/>
		<cfset var mailingListConfirmScript=""/>
		<cfset var mailText=""/>
		<cfset var listName=arguments.mailingListName/>
		<cfset var returnURL=""/>
		<cfset var contactEmail=variables.settingsManager.getSite(arguments.siteid).getContact()/>
		<cfset var contactName=variables.settingsManager.getSite(arguments.siteid).getSite()/>
		<cfset var finder=""/>
		<cfset var theString=""/>

		<cfquery name="rsReturnForm" datasource="#variables.configBean.getReadOnlyDatasource()#"  username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#">
		select filename from tcontent where siteid='#arguments.siteid#'  and active =1 and ((display=1) or (display=2  and tcontent.DisplayStart <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#"> AND tcontent.DisplayStop >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">)) 
		and contenthistid in (select contenthistid from tcontentobjects where object='mailing_list_master')	
		</cfquery>

		<cfset returnURL="#application.settingsManager.getSite(arguments.siteID).getScheme()#://#variables.settingsManager.getSite(arguments.siteid).getDomain()##variables.configBean.getServerPort()##variables.configBean.getContext()##variables.contentRenderer.getURLStem(arguments.siteid,rsreturnform.filename)#?doaction=validateMember&mlid=#arguments.mlid#&siteid=#URLEncodedFormat(arguments.siteid)#&email=#arguments.sendto#&nocache=1"/>
		<cfset mailingListConfirmScript = variables.settingsManager.getSite(arguments.siteid).getmailingListConfirmScript()/>

		<cfoutput>
		<cfif mailingListconfirmScript neq ''>
			<cfset theString = mailingListConfirmScript/>
			<cfset finder=refind('##.+?##',theString,1,"true")>
			<cfloop condition="#finder.len[1]#">
				<cftry>
					<cfset theString=replace(theString,mid(theString, finder.pos[1], finder.len[1]),'#trim(evaluate(mid(theString, finder.pos[1], finder.len[1])))#')>
					<cfcatch>
						<cfset theString=replace(theString,mid(theString, finder.pos[1], finder.len[1]),'')>
					</cfcatch>
				</cftry>
				<cfset finder=refind('##.+?##',theString,1,"true")>
			</cfloop>
			<cfset mailingListConfirmScript = theString/>

			<cfsavecontent variable="mailText">
#mailingListConfirmScript#
			</cfsavecontent>

			<cfelse>

			<cfsavecontent variable="mailText">
You've requested to be signed up for the mailing list: #listName#

If this is correct, please verify your email address by entering the following url into your browser window:

#returnURL#

Please contact #contactEmail# if you have any questions or comments on this process.

Thank you,

The #contactName# staff
	</cfsavecontent>

	</cfif>
	</cfoutput>

	<cfset variables.mailer.sendText(mailText,
		arguments.sendto,
		"Mailing List Manager",
		"Mailing List Verification",
		arguments.siteid) />
	</cffunction>

	<cffunction name="validateMember" output="false" >
		<cfargument name="data" type="struct" />
			
		<cfquery>
			update tmailinglistmembers
			set isVerified = 1 
			where email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data.email#"> and
			mlid in (<cfqueryparam list="true" cfsqltype="cf_sql_varchar" value="#data.mlid#">)  and
			siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data.siteid#">
		</cfquery>		
	</cffunction>

</cfcomponent>
<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides the ability to update both core and site files">

	<cffunction name="init" output="false">
		<cfargument name="configBean" required="true" default=""/>
		<cfargument name="fileWriter" required="true" default=""/>
		<cfset variables.configBean=arguments.configBean />
		<cfset variables.fileWriter=arguments.fileWriter>
		<cfset variables.fileDelim=arguments.configBean.getFileDelim() />
		<cfreturn this />
	</cffunction>

	<cffunction name="update" output="false">
		<cfset var baseDir=expandPath("/#variables.configBean.getWebRootMap()#")>
		<cfset var versionDir=expandPath("/#variables.configBean.getWebRootMap()#")>
		<cfset var versionFileContents="">
		<cfset var zipFileName="global">
		<cfset var zipUtil=new mura.Zip()>
		<cfset var rs=queryNew("empty")>
		<cfset var trimLen=0>
		<cfset var trimPath=0>
		<cfset var fileItem="">
		<cfset var currentDir=GetDirectoryFromPath(getCurrentTemplatePath())>
		<cfset var updateVersion=1>
		<cfset var currentVersion=0>
		<cfset var diff="">
		<cfset var returnStruct={currentVersion=currentVersion,files=[]}>
		<cfset var updatedArray=arrayNew(1)>
		<cfset var destination="">
		<cfset var autoUpdateSleep=variables.configBean.getValue("autoUpdateSleep")>

		<cfsetting requestTimeout = "7200">
		<cfset var sessionData=getSession()>

		<cfif listFind(sessionData.mura.memberships,'S2')>
			<cfif updateVersion gt currentVersion>
				<cflock type="exclusive" name="autoUpdate#application.instanceID#" timeout="600">

				<cfhttp attributeCollection='#getHTTPAttrs(
						url="#getAutoUpdateURL()#",
						result="diff",
						getasbinary="yes")#'>
				</cfhttp>

				<cfif not IsBinary(diff.filecontent)>
					<cfthrow message="The current production version code is currently not available. Please try again later.">
				</cfif>

				<cfset variables.fileWriter.writeFile(file="#currentDir##zipFileName#.zip",output="#diff.filecontent#")>
				<cffile action="readBinary" file="#currentDir##zipFileName#.zip" variable="diff">

				<!--- make sure that there are actually any updates--->

				<cfif len(diff)>
					<cfset rs=zipUtil.list("#currentDir##zipFileName#.zip")>

					<cfif directoryExists("#currentDir##zipFileName#")>
						<cfdirectory action="delete" directory="#currentDir##zipFileName#" recurse="true">
					</cfif>

					<cfset variables.fileWriter.createDir(directory="#currentDir##zipFileName#")>

					<cfset zipUtil.extract(zipFilePath:"#currentDir##zipFileName#.zip",
										extractPath: "#currentDir##zipFileName#")>

					<cfset trimPath=listFirst(rs.entry,variables.fileDelim)>
					<cfset trimLen=len(trimPath)>

					<cfquery name="rs" dbType="query">
					select * from rs where entry not like '#trimPath##variables.fileDelim#sites#variables.fileDelim#%'
					and entry not like '#trimPath##variables.fileDelim#modules#variables.fileDelim#%'
					and entry not like '#trimPath##variables.fileDelim#themes#variables.fileDelim#%'
					and entry not like '#trimPath##variables.fileDelim#content_types#variables.fileDelim#%'
					and entry not like '#trimPath##variables.fileDelim#config#variables.fileDelim#%'
					and entry not like '#trimPath##variables.fileDelim#plugins#variables.fileDelim#%'
					</cfquery>

					<cfloop query="rs">
						<cfif not listFind("README.md,.gitignore",listLast(rs.entry,variables.fileDelim))>
							<cfset destination="#baseDir##right(rs.entry,len(rs.entry)-trimLen)#">
							<!---<cftry>--->
								<cfif fileExists(destination)>
									<cffile action="delete" file="#destination#">
								</cfif>
								<cfset destination=left(destination,len(destination)-len(listLast(destination,variables.fileDelim)))>

								<cfif variables.configBean.getAdminDir() neq "/admin">
									<cfset destination=ReplaceNoCase(destination, "#variables.fileDelim#admin#variables.fileDelim#", "#replace(variables.configBean.getAdminDir(),'/',variables.fileDelim,'all')##variables.fileDelim#" )>
								</cfif>

								<cfif not directoryExists(destination)>
									<cfset variables.fileWriter.createDir(directory="#destination#")>
								</cfif>
								<cfset variables.fileWriter.moveFile(source="#currentDir##zipFileName##variables.fileDelim##rs.entry#",destination="#destination#")>
									<!---
								<cfcatch>
									<!--- patch to make sure autoupdates do not stop for mode errors --->
									<cfif not findNoCase("change mode of file",cfcatch.message) and not listFindNoCase('jar,class',listLast(rs.entry,"."))>
										<cfrethrow>
									</cfif>
								</cfcatch>
							</cftry>--->
							<cfset arrayAppend(updatedArray,"#destination##listLast(rs.entry,variables.fileDelim)#")>
						</cfif>
					</cfloop>

					<cfif arrayLen(updatedArray)>
						<cfset application.appInitialized=false>
						<cfset application.appAutoUpdated=true>
						<cfset application.coreversion=application.configBean.getVersionFromFile()>

						<cfif isNumeric(autoUpdateSleep) and autoUpdateSleep>
							<cfset autoUpdateSleep=autoUpdateSleep*1000>
							<cfthread action="sleep" duration="#autoUpdateSleep#"></cfthread>
						</cfif>
					</cfif>

					<cfdirectory action="delete" directory="#currentDir##zipFileName#" recurse="true">
				</cfif>

				<cffile action="delete" file="#currentDir##zipFileName#.zip" >

				<cfset application.configBean.setVersion(application.configBean.getVersionFromFile())>
				<cfset returnStruct.currentVersion=application.configBean.getVersion()/>
				<cfset application.coreversion=application.configBean.getVersion()>

				<cfif len(diff)>
					<cfset returnstruct.files=updatedArray>
				</cfif>

				</cflock>
			</cfif>

			<cfif arrayLen(updatedArray)>
				<cfif server.ColdFusion.ProductName neq "Coldfusion Server">
					<cfscript>pagePoolClear();</cfscript>
				</cfif>
			</cfif>

			<cfreturn returnStruct>

		<cfelse>
			<cfthrow message="The current user does not have permission to update Mura">
		</cfif>

	</cffunction>

	<cffunction name="getAutoUpdateURL" output="false">
		<cfreturn getBean('configBean').getAutoUpdateURL()>
	</cffunction>

</cfcomponent>

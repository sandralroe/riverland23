<!--- license goes here --->
<!---
Build a temporary file, and swap it out at the end, to reduce the potential for
the rest of the app to read a half-written file.
--->
<!--- WILL BE REFACTORED WHEN CF10 SUPPORT IS DROPPED--->
<cflock name="buildPluginCFApplication" type="exclusive" throwontimeout="true" timeout="5" >
<cfset pluginCfapplicationFilePathName = "#variables.baseDir#/plugins/cfapplication.cfm" />
<cfset pluginCfapplicationTempFilePathName = "#variables.baseDir#/plugins/cfapplication.tmp.cfm" />
<cftry>

		<cfif not directoryExists("#variables.baseDir#/plugins")>
    		<cfdirectory action="create" directory="#variables.baseDir#/plugins">
		</cfif>

		<cffile action="write" file="#pluginCfapplicationTempFilePathName#" output="<!--- Do Not Edit --->" addnewline="true" mode="775">
		<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output="<cfif not isDefined('this.name')>" addnewline="true" mode="775">
		<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output="<cfoutput>Access Restricted.</cfoutput>" addnewline="true" mode="775">
		<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output="<cfabort>" addnewline="true" mode="775">
		<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output="</cfif>" addnewline="true" mode="775">
		<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output="<cfset pluginDir=getDirectoryFromPath(getCurrentTemplatePath())/>" addnewline="true" mode="775">
		<cfcatch>
			<cfset canWriteMode=false>
			<cftry>
				<cffile action="write" file="#pluginCfapplicationTempFilePathName#" output="<!--- Do Not Edit --->" addnewline="true">
				<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output="<cfif not isDefined('this.name')>" addnewline="true">
				<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output="<cfoutput>Access Restricted.</cfoutput>">
				<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output="<cfabort>" addnewline="true">
				<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output="</cfif>" addnewline="true">
				<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output="<cfset pluginDir=getDirectoryFromPath(getCurrentTemplatePath())/>" addnewline="true">
				<cfcatch>
					<cfset canWriteMappings=false>
				</cfcatch>
			</cftry>
		</cfcatch>
</cftry>

<cfdirectory action="list" directory="#variables.baseDir#/plugins/" name="rsRequirements">

<cfloop query="rsRequirements">
	<cfif rsRequirements.type eq "dir" and rsRequirements.name neq '.svn'>
		<cfset currentDir="#variables.baseDir#/plugins/#rsRequirements.name#">
		<cfset currentConfigFile="#currentDir#/plugin/config.xml">
		<cfif fileExists(currentConfigFile)>
			<cffile action="read" variable="currentConfig" file="#currentConfigFile#">
			<cftry>
				<cfset currentConfig=xmlParse(currentConfig)>
				<cfcatch>
					<cfset currentConfig=structNew()>
				</cfcatch>
			</cftry>
		<cfelse>
			<cfset currentConfigFile="#currentDir#/plugin/config.xml.cfm">
			<cfif fileExists(currentConfigFile)>
				<cffile action="read" variable="currentConfig" file="#currentConfigFile#">
				<cftry>
					<cfset currentConfig=xmlParse(currentConfig)>
					<cfcatch>
						<cfset currentConfig=structNew()>
					</cfcatch>
				</cftry>
			<cfelse>
				<cfset currentConfig=structNew()>
			</cfif>
		</cfif>
		<cfif isDefined("currentConfig.plugin.customtagpaths.xmlText") and len(currentConfig.plugin.customtagpaths.xmlText)>
			<cfloop list="#currentConfig.plugin.customtagpaths.xmlText#" index="p">
			<cfif listFind("/,\",left(p,1))>
				<cfif len(p) gt 1>
					<cfset p=right(p,len(p)-1)>
				<cfelse>
					<cfset p="">
				</cfif>
			</cfif>
			<cfset currentPath=currentDir & "/" & p>
			<cfif len(p) and directoryExists(currentPath)>
				<cfif canWriteMode>
					<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output='<cfset this.customtagpaths = listAppend(this.customtagpaths, pluginDir & "/#rsRequirements.name#/#p#")>' mode="775">
				<cfelseif canWriteMappings>
					<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output='<cfset this.customtagpaths = listAppend(this.customtagpaths,pluginDir & "/#rsRequirements.name#/#p#")>'>
				</cfif>
				<cfset this.customtagpaths = listAppend(this.customtagpaths,variables.BaseDir & "/plugins/#rsRequirements.name#/#p#")>
			</cfif>
			</cfloop>
		</cfif>
		<cfif isDefined("currentConfig.plugin.ormcfclocation.xmlText") and len(currentConfig.plugin.ormcfclocation.xmlText)>
			<cfloop list="#currentConfig.plugin.ormcfclocation.xmlText#" index="p">
			<cfif listFind("/,\",left(p,1))>
				<cfif len(p) gt 1>
					<cfset p=right(p,len(p)-1)>
				<cfelse>
					<cfset p="">
				</cfif>
			</cfif>
			<cfset currentPath=currentDir & "/" & p>
			<cfif len(p) and directoryExists(currentPath)>
				<cfif canWriteMode>
					<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output='<cfset arrayAppend(this.ormsettings.cfclocation,pluginDir & "/#rsRequirements.name#/#p#")>' mode="775">
				<cfelseif canWriteMappings>
					<cffile action="append" file="#pluginCfapplicationTempFilePathName#" output='<cfset arrayAppend(this.ormsettings.cfclocation,pluginDir & "/#rsRequirements.name#/#p#")>'>
				</cfif>
				<cfset arrayAppend(this.ormsettings.cfclocation,variables.baseDir & "/plugins/#rsRequirements.name#/#p#")>
			</cfif>
			</cfloop>
		</cfif>
	</cfif>
</cfloop>

<!--- Swap out the real file with the temporary file. --->
<cffile action="rename" source="#pluginCfapplicationTempFilePathName#" destination="#pluginCfapplicationFilePathName#" />

</cflock>

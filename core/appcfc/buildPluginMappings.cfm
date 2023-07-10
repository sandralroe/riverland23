<!--- license goes here --->
<!---
Build a temporary file, and swap it out at the end, to reduce the potential for
the rest of the app to read a half-written file.
--->
<!--- WILL BE REFACTORED WHEN CF10 SUPPORT IS DROPPED--->
<cflock name="buildPluginMappings" type="exclusive" throwontimeout="true" timeout="5" >
<cfset pluginMappingsFilePathName = "#variables.baseDir#/plugins/mappings.cfm" />
<cfset pluginMappingsTempFilePathName = "#variables.baseDir#/plugins/mappings.tmp.cfm" />
<cftry>
	<cfif not directoryExists("#variables.baseDir#/plugins")>
		<cfdirectory action="create" directory="#variables.baseDir#/plugins">
	</cfif>

	<cffile action="write" file="#pluginMappingsTempFilePathName#" output="<!--- Do Not Edit --->" addnewline="true" mode="775">
	<cffile action="append" file="#pluginMappingsTempFilePathName#" output="<cfif not isDefined('this.name')>" addnewline="true" mode="775">
	<cffile action="append" file="#pluginMappingsTempFilePathName#" output="<cfoutput>Access Restricted.</cfoutput>" addnewline="true" mode="775">
	<cffile action="append" file="#pluginMappingsTempFilePathName#" output="<cfabort>" addnewline="true" mode="775">
	<cffile action="append" file="#pluginMappingsTempFilePathName#" output="</cfif>" addnewline="true" mode="775">
	<cffile action="append" file="#pluginMappingsTempFilePathName#" output="<cfset pluginDir=getDirectoryFromPath(getCurrentTemplatePath())/>" addnewline="true" mode="775">
	<cffile action="append" file="#pluginMappingsTempFilePathName#" output='<cfset this.mappings["/plugins"] = pluginDir>' mode="775">
	<cfcatch>
		<cfset canWriteMode=false>
		<cftry>
			<cffile action="write" file="#pluginMappingsTempFilePathName#" output="<!--- Do Not Edit --->" addnewline="true">
			<cffile action="append" file="#pluginMappingsTempFilePathName#" output="<cfif not isDefined('this.name')>" addnewline="true">
			<cffile action="append" file="#pluginMappingsTempFilePathName#" output="<cfoutput>Access Restricted.</cfoutput>" addnewline="true">
			<cffile action="append" file="#pluginMappingsTempFilePathName#" output="<cfabort>" addnewline="true">
			<cffile action="append" file="#pluginMappingsTempFilePathName#" output="</cfif>" addnewline="true">
			<cffile action="append" file="#pluginMappingsTempFilePathName#" output="<cfset pluginDir=getDirectoryFromPath(getCurrentTemplatePath())/>" addnewline="true">
			<cffile action="append" file="#pluginMappingsTempFilePathName#" output='<cfset this.mappings["/plugins"] = pluginDir>'>
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
				<cftry>
					<cfsavecontent variable="currentConfig"><cfoutput><cfinclude template="../plugins/#rsRequirements.name#/plugin/config.xml.cfm"></cfoutput></cfsavecontent>
					<cfset currentConfig=xmlParse(currentConfig)>
					<cfcatch>
						<cfset currentConfig=structNew()>
					</cfcatch>
				</cftry>
			<cfelse>
				<cfset currentConfig=structNew()>
			</cfif>
		</cfif>

		<cfset m=listFirst(rsRequirements.name,"_")>

		<cfif not isDefined("currentConfig.plugin.createmapping.xmlText")
				or yesNoFormat(currentConfig.plugin.createmapping.xmlText)>
			<cfif not isNumeric(m) and not structKeyExists(this.mappings,m)>
				<cfif canWriteMode>
					<cffile action="append" file="#pluginMappingsTempFilePathName#" output='<cfset this.mappings["/#m#"] = pluginDir & "#rsRequirements.name#">' mode="775">
				<cfelseif canWriteMappings>
					<cffile action="append" file="#pluginMappingsTempFilePathName#" output='<cfset this.mappings["/#m#"] =pluginDir & "#rsRequirements.name#">'>
				</cfif>
				<cfset this.mappings["/#m#"] = rsRequirements.directory & "/" & rsRequirements.name>
			</cfif>
		</cfif>

		<cfif isDefined("currentConfig.plugin.mappings.mapping") and arrayLen(currentConfig.plugin.mappings.mapping)>
			<cfloop from="1" to="#arrayLen(currentConfig.plugin.mappings.mapping)#" index="m">
			<cfif structkeyExists(currentConfig.plugin.mappings.mapping[m].xmlAttributes,"directory")
			and len(currentConfig.plugin.mappings.mapping[m].xmlAttributes.directory)
			and structkeyExists(currentConfig.plugin.mappings.mapping[m].xmlAttributes,"name")
			and len(currentConfig.plugin.mappings.mapping[m].xmlAttributes.name)>
				<cfset p=currentConfig.plugin.mappings.mapping[m].xmlAttributes.directory>
				<cfif listFind("/,\",left(p,1))>
					<cfif len(p) gt 1>
						<cfset p=right(p,len(p)-1)>
					<cfelse>
						<cfset p="">
					</cfif>
				</cfif>
				<cfset currentPath=currentDir & "/" & p>
				<cfif len(p) and directoryExists(currentPath)>
					<cfset pluginmapping=currentConfig.plugin.mappings.mapping[m].xmlAttributes.name>
					<cfif canWriteMode>
						<cffile action="append" file="#pluginMappingsTempFilePathName#" output='<cfif not structKeyExists(this.mappings,"/#pluginmapping#")><cfset this.mappings["/#pluginmapping#"] = pluginDir & "#rsRequirements.name#/#p#"></cfif>' mode="775">
					<cfelseif canWriteMappings>
						<cffile action="append" file="#pluginMappingsTempFilePathName#" output='<cfif not structKeyExists(this.mappings,"/#pluginmapping#")><cfset this.mappings["/#pluginmapping#"] = pluginDir & "#rsRequirements.name#/#p#"></cfif>'>
					</cfif>
				</cfif>
			</cfif>
			</cfloop>
		</cfif>
	</cfif>
</cfloop>

<!--- Swap out the real file with the temporary file. --->
<cffile action="rename" source="#pluginMappingsTempFilePathName#" destination="#pluginMappingsFilePathName#" />

</cflock>

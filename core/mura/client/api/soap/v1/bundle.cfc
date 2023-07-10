<!--- license goes here --->
<cfcomponent output="false" extends="service" hint="Deprecated">

	<cffunction name="deploy" output="false">
		<cfargument name="event">

		<cfset var fileManager = getBean("fileManager")>
		<cfset var tempfile = "">
		<cfset var errors = structNew()>

		<cftry>
			<cffile action="upload" result="tempFile" filefield="bundleFile" nameconflict="makeunique" destination="#application.configBean.getTempDir()#">

			<cfset application.pluginManager.announceEvent("onBeforeProxyBundleDeploy", event)>
			<cfset application.settingsManager.restoreBundle(
				"#tempfile.serverDirectory#/#tempfile.serverFilename#.#tempfile.serverFileExt#" ,
				arguments.event.getValue('siteID'),
				errors,
				arguments.event.getValue('bundleImportKeyMode'),
				arguments.event.getValue('bundleImportContentMode'),
				arguments.event.getValue('bundleImportRenderingMode'),
				arguments.event.getValue('bundleImportMailingListMembersMode'),
				arguments.event.getValue('bundleImportUsersMode'),
				arguments.event.getValue('bundleImportPluginMode'),
				arguments.event.getValue('bundleImportLastDeployment'),
				arguments.event.getValue('bundleImportModuleID'),
				arguments.event.getValue('bundleImportFormDataMode')
				)>

			<cffile action="delete" file="#tempfile.serverDirectory#/#tempfile.serverFilename#.#tempfile.serverFileExt#">

			<cfset event.setValue("__response__", "success")>

			<cfset application.pluginManager.announceEvent("onAfterProxyBundleDeploy", event)>

			<cfcatch>
				<cfset event.setValue("__response__", cfcatch.Message)>
			</cfcatch>
		</cftry>
	</cffunction>

</cfcomponent>

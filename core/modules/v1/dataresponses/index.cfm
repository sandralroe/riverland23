<!--- license goes here --->
<cfif variables.$.siteConfig('dataCollection')>
<cfsilent>
	<cfparam name="request.dataResponseView" default="list">
	<cfquery datasource="#application.configBean.getDatasource()#" name="variables.rssite">
		SELECT siteid
		FROM tcontent
		WHERE contentid=<cfqueryparam value="#arguments.objectid#" cfsqltype="varchar">
			AND active=1
	</cfquery>
	<cfset variables.formBean=$.getBean('content').loadBy(contentID=arguments.objectID)>
	<cfset variables.fieldlist = application.dataCollectionManager.getCurrentFieldList(variables.formBean.getValue('contentID'))>
</cfsilent>
<cfswitch expression="#$.event('dataResponseView')#">
	<cfcase value="detail">
		<cfinclude template="dsp_detail.cfm" />
	</cfcase>
	<cfdefaultcase>
		<cfinclude template="dsp_list.cfm" />
	</cfdefaultcase>
</cfswitch>
</cfif>

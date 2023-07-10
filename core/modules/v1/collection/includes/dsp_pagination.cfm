<!--- license goes here --->
<cfparam name="objectParams.nextn" default=''>
<cfparam name="objectParams.nextnid" default=''>
<cfif arguments.iterator.getRecordCount()>
	<cfif arguments.iterator.getPageCount() gt 1>
		<cfif isDefined('arguments.objectparams.scrollpages') and isBoolean(arguments.objectparams.scrollpages) and arguments.objectparams.scrollpages>
			<cfparam name="objectparams.pagenum" default="1">
			<cfparam name="objectparams.pagecount" default="#arguments.iterator.getPageCount()#">
			<cfoutput>#variables.$.dspObject_Include(thefile='collection/includes/dsp_scroll.cfm',objectparams=arguments.objectparams)#</cfoutput>
			<!--- We don't want to save these --->
			<cfset structDelete(objectparams,'pagenum')>
			<cfset structDelete(objectparams,'pagecount')>
		<cfelse>
			<cfsilent>
				<cfset variables.$.event("currentNextNID", objectParams.nextnid)>
				<cfif not len(variables.$.event("nextNID")) or variables.$.event("nextNID") eq variables.$.event("currentNextNID")>
					<cfif not(isNumeric(variables.$.event("pageNum")) and variables.$.event("pageNum") gt 1) and objectparams.nextn gt 1>
						<cfset variables.currentNextNIndex = variables.$.event("startRow")>
						<cfset arguments.iterator.setStartRow(variables.currentNextNIndex)>
					<cfelse>
						<cfset variables.currentNextNIndex = variables.$.event("pageNum")>
						<cfset arguments.iterator.setPage(currentNextNIndex)>
					</cfif>
				<cfelse>
					<cfset variables.currentNextNIndex = 1>
					<cfset iterator.setPage(1)>
				</cfif>
				<cfset variables.nextN = variables.$.getBean('utility').getNextN(arguments.iterator.getQuery(),arguments.nextN,variables.currentNextNIndex)>
			</cfsilent>
			<cfoutput>#variables.$.dspObject_Include(thefile='collection/includes/dsp_nextN.cfm')#</cfoutput>
		</cfif>
	</cfif>
</cfif>

 <!--- license goes here --->
<cfsilent>
<cfinclude template="js.cfm">
<cfhtmlhead text="#session.dateKey#">
<cfparam name="session.datakeywords" default="">
<cfparam name="rc.keywords" default="">
<cfparam name="rc.filterBy" default="">
<cfparam name="session.filterBy" default="">

<cfif isDefined('rc.newSearch')>
<cfset session.filterBy=rc.filterBy />
<cfset session.datakeywords=rc.keywords />
</cfif>

<cfparam name="rc.sortBy" default="#rc.contentBean.getSortBy()#">
<cfparam name="rc.sortDirection" default="#rc.contentBean.getSortDirection()#">

<cfset rc.perm=application.permUtility.getnodePerm(rc.crumbdata)>

<cfif isDefined('rc.responseid') and rc.action eq 'Update' and rc.$.validateCSRFTokens(context=rc.responseid)>
	<cfset application.dataCollectionManager.update(rc)/>
<cfelseif isDefined('rc.responseid') and rc.action eq 'Delete' and rc.$.validateCSRFTokens(context=rc.responseid)>
	<cfset application.dataCollectionManager.delete('#rc.responseID#')/>
<cfelseif  rc.action eq 'setDisplay'>
	<cfset rc.contentBean.setResponseDisplayFields("#rc.detailList2#~#rc.summaryList2#")/>
	<cfset rc.contentBean.setNextN(rc.nextn)/>
	<cfset rc.contentBean.setSortBy(rc.sortBy)/>
	<cfset rc.contentBean.setSortDirection(rc.sortDirection)/>
	<cfset application.dataCollectionManager.setDisplay(rc.contentBean)/>
	<cfset rc.action=""/>
</cfif>
<cfset rc.rsDataInfo=application.contentManager.getDownloadselect(rc.contentid,rc.siteid) />
</cfsilent>


<cfset isNewForm = false />

<cfif isJSON( rc.contentBean.getBody())>
	<cfset local.formJSON = deserializeJSON( rc.contentBean.getBody() )>

	<cftry>
		<cfif structKeyExists(local.formJSON.form,"muraormentities") and structKeyExists(local.formJSON.form.formattributes,"muraormentities") and local.formJSON.form.formattributes.muraormentities eq true>
			<cfset isNewForm = true />
		</cfif>
	<cfcatch>
		<cfdump var="#cfcatch#">
		<cfabort>
	</cfcatch>
	</cftry>
</cfif>



<cfif isNewForm>
	<cfset objectname = rereplacenocase( rc.contentBean.getValue('filename'),"[^[:alnum:]]","","all" ) />

	<cfinclude template="dsp_secondary_menu.cfm">
	<cfoutput>
	<ul class="metadata"><li>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.title')#: <strong>#rc.contentBean.gettitle()#</strong></li>
	</ul></cfoutput>

	<cfinclude template="data_manager/dsp_ormform.cfm">
<cfelse>
	<cfoutput>

	<div class="mura-header">
		<h1>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.managedata')#</h1>
		<cfinclude template="dsp_secondary_menu.cfm">
		<div class="mura-item-metadata">
			<div class="label-group">
				<span class="label">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.title')#: <strong>#rc.contentBean.gettitle()#</strong></span>
				<span class="label">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.totalrecordsavailable')#: <strong>#rc.rsDataInfo.CountEntered#</strong></span>
			</div>
		</div><!-- /.mura-item-metadata -->
	</div> <!-- /.mura-header -->
	</cfoutput>

	<div class="block block-constrain">
		<div class="block block-bordered">
		  <div class="block-content">
					<cfif rc.action eq "edit">
						<cfset rc.fieldnames=application.dataCollectionManager.getCurrentFieldList(rc.contentid)/>
						<cfinclude template="data_manager/dsp_edit.cfm">
					<cfelseif rc.action eq "display">
						<cfset rc.fieldnames=application.dataCollectionManager.getFullFieldList(rc.contentid)/>
						<cfinclude template="data_manager/dsp_display.cfm">
					<cfelse>
						<cfset rc.fieldnames=application.dataCollectionManager.getCurrentFieldList(rc.contentid)/>
						<cfinclude template="data_manager/dsp_response.cfm">
					</cfif>
			</div> <!-- /.block-content -->
		</div> <!-- /.block-bordered -->
	</div> <!-- /.block-constrain -->
</cfif>
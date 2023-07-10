<!--- license goes here --->

<cfsilent>
	<cfquery datasource="#application.configBean.getDatasource(mode='readOnly')#" username="#application.configBean.getDBUsername(mode='readOnly')#" password="#application.configBean.getDBPassword(mode='readOnly')#" name="rsSection">
		select contentid,filename,menutitle,target,restricted,restrictgroups,type,sortBy,sortDirection from tcontent where siteid=<cfqueryparam value="#variables.$.event('siteID')#" cfsqltype="varchar"> and contentid=<cfqueryparam value="#arguments.objectid#" cfsqltype="varchar"> and approved=1 and active=1 and display=1
		</cfquery>
	<cfif variables.rsSection.recordcount>
	<cfset variables.menutype=iif(variables.rsSection.type eq 'Portal',de('default'),de('calendar_features'))/>
	<cfset rsPreFeatures=variables.$.getBean('contentGateway').getkids('00000000000000000000000000000000000','#variables.$.event('siteID')#','#arguments.objectid#',variables.menutype,now(),0,"",0,iif(variables.rsSection.type eq 'Portal',de('#variables.rsSection.sortBy#'),de('displaystart')),iif(variables.rsSection.type eq 'Portal',de('#variables.rsSection.sortDirection#'),de('desc')),'','#variables.$.content('contentID')#')>
		<cfif variables.$.siteConfig('extranet') eq 1 and variables.$.event('r').restrict eq 1>
			<cfset variables.rsFeatures=variables.$.queryPermFIlter(variables.rsPreFeatures)/>
		<cfelse>
			<cfset variables.rsFeatures=rsPreFeatures/>
		</cfif>
	</cfif>
</cfsilent>
<cfoutput>
<cfif variables.rsSection.recordcount and variables.rsFeatures.recordcount>
<cfsilent>
	<cfset variables.iterator=variables.$.getBean("contentIterator")>
	<cfset variables.iterator.setQuery(rsFeatures)>
	<cfset variables.cssID=variables.$.createCSSid(variables.rsSection.menuTitle)>
</cfsilent>
<div id="#variables.cssID#" class="svRelSecContent svIndex mura-rel-sec-content mura-index">
	<#variables.$.getHeaderTag('subHead1')#>#rsSection.menutitle#</#variables.$.getHeaderTag('subHead1')#>
	<cfif not structIsEmpty(objectparams)>
		#variables.$.dspObject_Include(
				thefile='collection/includes/dsp_content_list.cfm',
				fields=params.displayList,
				type='objectparams',
				iterator=variables.iterator,
				imageSize=objectparams.imageSize,
				imageHeight=objectparams.imageHeight,
				imageWidth=objectparams.imageWidth
				)#
	<cfelse>
		<cfsilent>
		<cfset variables.contentListFields="Title">

		<cfif variables.$.getBean('contentGateway').getHasComments(variables.$.event('siteID'),arguments.objectid) >
			<cfset variables.contentListFields=listAppend(variables.contentListFields,"Comments")>
		</cfif>
		</cfsilent>
		#variables.$.dspObject_Include(
			thefile='collection/includes/dsp_content_list.cfm',
			fields=variables.contentListFields,
			type='Related',
			iterator= variables.iterator
			)#
	</cfif>

	<dl class="moreResults">
		<dt><a href="#variables.siteConfig('context')##getURLStem(variables.$.event('siteID'),variables.rsSection.filename)#">View All</a></dt>
	</dl>
</div>
<cfelse>
	<!-- Empty Related Section Content '#rsSection.menutitle#' -->
</cfif>
</cfoutput>

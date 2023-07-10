<!--- license goes here --->

<cfoutput>
<cfset variables.isConfigured=not structIsEmpty(objectparams)>
<cfparam name="objectparams.sortBy" default="created">
<cfparam name="objectparams.sortDirection" default="desc">
<cfparam name="objectparams.imagesize" default="small">
<cfparam name="objectparams.imageHeight" default="#$.siteConfig('smallImageHeight')#">
<cfparam name="objectparams.imageWidth" default="#$.siteConfig('smallImageWidth')#">
<cfparam name="objectparams.relatedContentSetName" default="default">
<cfparam name="objectparams.displaylist" default="title">
<cfset variables.iterator=variables.$.content().getRelatedContentIterator(liveOnly=true,sortBy=objectparams.sortBy,sortDirection=objectparams.sortDirection,name=objectparams.relatedContentSetName)>
<cfif variables.iterator.getRecordCount()>
	<div class="svRelContent svIndex mura-rel-content mura-index">
	<#variables.$.getHeaderTag('subHead1')#>
		<cfif len(objectparams.relatedContentSetName) and objectparams.relatedContentSetName neq "default">
			#objectparams.relatedContentSetName#
		<cfelse>
			#variables.$.rbKey('list.relatedcontent')#
		</cfif>
	</#variables.$.getHeaderTag('subHead1')#>
	<cfif variables.isConfigured>
		#variables.$.dspObject_Include(
				thefile='collection/includes/dsp_content_list.cfm',
				fields=objectparams.displayList,
				type='Related',
				iterator=variables.iterator,
				imageSize=objectparams.imageSize,
				imageHeight=objectparams.imageHeight,
				imageWidth=objectparams.imageWidth
				)#
	<cfelse>
		#variables.$.dspObject_Include(
				thefile='collection/includes/dsp_content_list.cfm',
				fields='Title',
				type='Related',
				iterator= variables.iterator
				)#
	</cfif>
	</div>
<cfelse>
	<!-- Empty Related Content -->
</cfif>
</cfoutput>

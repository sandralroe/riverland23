 <!--- license goes here --->
<cfparam name="arguments.objectParams.imageSize" default="small">
<cfparam name="arguments.objectParams.imageHeight" default="auto">
<cfparam name="arguments.objectParams.imageWidth" default="auto">
<cfparam name="arguments.objectParams.modalimages" default="false">
<cfparam name="arguments.objectParams.scrollpages" default="false">
<cfoutput>
<div id="svIndex" class="mura-index #this.folderWrapperClass#">
#variables.$.dspObject_include(
	theFile='collection/includes/dsp_content_list.cfm',
	type=arguments.objectParams.sourcetype,
	iterator=iterator,
	imageSize=arguments.objectParams.imageSize,
	imageWidth=arguments.objectParams.imageWidth,
	imageHeight=arguments.objectParams.imageHeight,
	fields=arguments.objectParams.displaylist,
	modalimages=arguments.objectParams.modalimages
)#
</div>

#variables.$.dspObject_include(
	theFile='collection/includes/dsp_pagination.cfm',
	iterator=iterator,
	nextN=iterator.getNextN(),
	source=arguments.objectParams.source,
	objectparams=objectParams
)#
<cfif len(arguments.objectParams.viewalllink)>
	<a class="view-all" href="#arguments.objectParams.viewalllink#">#HTMLEditFormat(arguments.objectParams.viewalllabel)#</a>
</cfif>
<div style="clear:both"></div>
</cfoutput>

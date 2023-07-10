 <!--- license goes here --->
<cfparam name="arguments.objectParams.imageSize" default="small">
<cfparam name="arguments.objectParams.imageHeight" default="auto">
<cfparam name="arguments.objectParams.imageWidth" default="auto">
<cfparam name="arguments.objectParams.scrollpages" default="false">
<cfoutput>
#variables.$.dspObject_include(
	theFile='collection/layouts/list/index.cfm', 
	objectParams=arguments.objectParams,
	iterator=arguments.iterator
)#
</cfoutput>
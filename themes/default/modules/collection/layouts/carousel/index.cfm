<cfinclude template="_defaults.cfm">
<cfset args=structCopy(objectparams)>
<cfset args.iterator=arguments.iterator>
<cfoutput>

#Mura.dspCarouselByFeedName(argumentCollection=args)#

#m.dspObject_include(
	theFile='collection/includes/dsp_pagination.cfm',
	iterator=iterator,
	nextN=iterator.getNextN(),
	source=objectParams.source,
	objectparams=objectParams
)#

<cfif len(objectParams.viewalllink)>
	<a class="view-all" href="#objectParams.viewalllink#">#HTMLEditFormat(objectParams.viewalllabel)#</a>
</cfif>
</cfoutput>

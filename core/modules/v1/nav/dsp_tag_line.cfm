<!--- license goes here --->
<cfif not isDefined("$")>
<cfset $=request.servletEvent.getValue("muraScope")>
</cfif>
<cfset rbFactory=application.settingsManager.getSite($.event('siteID')).getRBFactory()/>
<cfparam name="attributes.tags" default="">
<cfset tagLen=listLen(attributes.tags) />
<cfif len(tagLen)><cfoutput>#$.rbKey('tagcloud.tags')#: <cfloop from="1" to="#tagLen#" index="t"><cfset tag=trim(listgetAt(attributes.tags,t))><a href="#request.contentRenderer.createHREF(filename='#request.currentFilenameAdjusted#/tag/#urlEncodedFormat(tag)#')#">#HTMLEditFormat(tag)#</a><cfif tagLen gt t>, </cfif></cfloop></cfoutput></cfif>
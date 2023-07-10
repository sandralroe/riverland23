<!--- license goes here --->

<cfsetting enablecfoutputonly="yes">
<cfset myRate=application.raterManager.saveRate(
form.contentID,
form.siteID,
form.userID,
form.rate) /><cfoutput>#application.contentRenderer.jsonencode(application.raterManager.getAvgRating(form.contentID,form.siteid))#</cfoutput>
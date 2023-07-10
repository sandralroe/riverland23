<!--- license goes here --->

<cfsetting enablecfoutputonly="yes">
<cfset application.favoriteManager.deleteFavorite(URL.favoriteID) />
<cfoutput>Your favorite has been removed.</cfoutput>



<!---<cfoutput>#application.contentRenderer.jsonencode(application.raterManager.getAvgRating(form.contentID,form.siteid))#</cfoutput>--->
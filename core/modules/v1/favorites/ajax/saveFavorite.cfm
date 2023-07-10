<!--- license goes here --->

<cfsetting enablecfoutputonly="yes">
<cfparam name="url.columnNumber" default="">
<cfparam name="url.rowNumber" default="">
<cfparam name="url.maxRssItems" default="">
<cfset $=application.serviceFactory.getBean("MuraScope").init(url.siteID)>
<cfset favorite = application.favoriteManager.saveFavorite('', url.userID, url.siteid, url.favoriteName, url.favoriteLocation, url.favoritetype, url.columnNumber, url.rowNumber, url.maxRssItems) />
<cfset contentLink = "" />
<cfset lid = replace(favorite.getFavoriteID(), "-", "", "ALL") />
<cfset contentBean = $.getBean("content").loadBy(contentID=favorite.getFavorite()) />
<cfset contentLink = $.createHref(contentBean.getType(), contentBean.getFilename(), url.siteid, favorite.getfavorite(), '', '', '', '#$.globalConfig('context')#', '#$.globalConfig('stub')#', '', 'false') />
<cfset contentLink = "<a href='#contentLink#'>#url.favoriteName#</a>" />
<cfset contentLink = "<a href="""" onClick=""return deleteFavorite('#favorite.getfavoriteID()#', 'favorite#lid#');"" title=""#xmlformat($.rbKey('favorites.removefromfavorites'))#"" class=""remove""></a> " & contentLink />
<cfset favoriteStruct = structNew() />
<cfset favoriteStruct.lid = lid />
<cfset favoriteStruct.link = contentLink />
<cfset favoriteStruct.favoriteID = favorite.getFavoriteID() />
<cfoutput>#$.jsonencode(favoriteStruct)#</cfoutput>

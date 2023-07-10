<!--- license goes here --->
<cfparam name="objectparams" default="#structNew()#">
<cfparam name="objectparams.displayRSS" default="false">
<cfparam name="useRss" default="#objectparams.displayRSS#">
<cfif not isValid('uuid',arguments.objectid)>
	<cfset crumbIterator=$.content().getCrumbIterator()>

	<cfloop condition="crumbIterator.hasNext()">
		<cfset crumb=crumbIterator.next()>
		<cfif listFindNoCase('Folder',crumb.getType())>
			<cfset arguments.objectid=crumb.getContentID()>
			<cfbreak>
		</cfif>
	</cfloop>
</cfif>
<cfset section=$.getBean('content').loadBy(contentid=arguments.objectid)>
<cfif section.exists()>
	<cfsilent>
	<cfif section.gettype() neq "Calendar">
	<cfset today=now() />
	<cfelse>
	<cfset today=createDate($.event('year'),$.event('month'),1) />
	</cfif>
	<cfset rs=section.getKidsCategoryQuery()>

	<cfset viewAllURL="#$.siteConfig('context')##getURLStem($.event('siteID'),section.getFilename())#">
	<cfif len($.event('relatedID'))>
		<cfset viewAllURL=viewAllURL & "?relatedID=#HTMLEditFormat($.event('relatedID'))#">
	</cfif>
</cfsilent>
	<cfif rs.recordcount>
	<cfoutput>
	<div class="svCatSummary mura-category-summary #this.navWrapperClass#">
	<cfif len(this.navCategoryWrapperBodyClass)><div class="#this.navCategoryWrapperBodyClass#"></cfif>
	<#$.getHeaderTag('subHead1')#>#$.rbKey('list.categories')#</#$.getHeaderTag('subHead1')#>
	<ul class="#this.ulTopClass#"><cfloop query="rs">
		<cfsilent>
		<cfif len(rs.filename)>
			<cfset categoryURL="#$.siteConfig('context')##getURLStem($.event('siteID'),section.getFilename() & '/category/' & rs.filename)#">
			<cfif len($.event('relatedID'))>
				<cfset categoryURL=categoryURL & "?relatedID=#HTMLEditFormat($.event('relatedID'))#">
			</cfif>
		<cfelse>
			<cfset categoryURL="#$.siteConfig('context')##getURLStem($.event('siteID'),section.getFilename())#?categoryID=#rs.categoryID#">
			<cfif len($.event('relatedID'))>
				<cfset categoryURL=categoryURL & "&relatedID=#HTMLEditFormat($.event('relatedID'))#">
			</cfif>
		</cfif>
		</cfsilent>
		<cfset class=iif(rs.currentrow eq 1,de('first'),de(''))>
			<li class="#this.navLiClass#<cfif len(class)> #class#</cfif><cfif listFind($.event('categoryID'),rs.categoryID)> #this.liCurrentClass#</cfif>">
				<a <cfif listFind($.event('categoryID'),rs.categoryID)>class="#this.aCurrentClass#"<cfelse>class="#this.aNotCurrentClass#"</cfif> href="#categoryURL#">#rs.name# <span>(#rs.count#)</span></a>
				<cfif useRss>
					<a class="rss" href="#$.globalConfig('context')#/index.cfm/feed/v1/?siteid=#$.event('siteID')#&contentID=#section.getContentID()#&categoryID=#rs.categoryID#"
					<cfif listFind($.event('categoryID'),rs.categoryID)>class="#this.aCurrentClass#"<cfelse>class="#this.aNotCurrentClass#"</cfif>>RSS</a>
				</cfif>
			</li>
		</cfloop>
		<li class="last #this.navLiClass#"><a href="#viewAllURL#" <cfif not len($.event('categoryID'))>class="#this.aCurrentClass#"<cfelse>class="#this.aNotCurrentClass#"</cfif>>#$.rbKey('list.viewall')#</a><cfif useRss><a class="rss" href="#$.globalConfig('context')#/index.cfm/feed/v1/?siteid=#$.event('siteID')#&contentID=#rsSection.contentid#">RSS</a></cfif></li>
	</ul>
	</div>
	<cfif len(this.navCategoryWrapperBodyClass)></div></cfif>
	</cfoutput>
	</cfif>
</cfif>

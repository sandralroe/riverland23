<!--- license goes here --->

<!--- This outputs peer nav and the sub nav of the page you are on if there is any. It omits top level nav for the sake of redundancy and dead-ends if there is no content below the page you are on. Usually works best when used in conjunction with the breadcrumb nav since it changes as you get deeper into a site. --->
<cfset navOutput=dspNestedNav(
	contentID=variables.$.getTopVar("contentID"),
	viewDepth=4,
	currDepth=1,
	sortBy=variables.$.getTopVar("sortBy"),
	sortDirection=variables.$.getTopVar("sortDirection"),
	subNavExpression="listFindNoCase('Page,Calendar',rsSection.type) and listFind(variables.$.content('path'),rsSection.contentID) and arguments.currDepth lt arguments.viewDepth"
)>
<cfif len(navOutput)>
<cfoutput>
	<nav id="navMultilevel" role="navigation" aria-label="Secondary"<cfif this.navMultiLevelWrapperClass neq ""> class="mura-nav-multi-level #this.navMultiLevelWrapperClass#"</cfif>>
		<cfif len(this.navMultiLevelWrapperBodyClass)><div class="#this.navMultiLevelWrapperBodyClass#"></cfif>
		#navOutput#
		<cfif len(this.navMultiLevelWrapperBodyClass)></div></cfif>
	</nav>
</cfoutput>
</cfif>

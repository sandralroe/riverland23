<!--- license goes here --->
<cfsilent>

<cfset variables.archiveFilter=listFindNoCase("releaseMonth,releaseDate,releaseYear",variables.$.event("filterBy"))>
<cfif arguments.objectID eq variables.$.content("contentID")>
	<cfset variables.archive=variables.$.content()>
<cfelseif isValid('uuid',arguments.objectid)>
	<cfset variables.archive=variables.$.getBean("content").loadBy(contentID=arguments.objectID)>
<cfelse>
	<cfset variables.archive=variables.$.content()>
	<cfset variables.crumbIterator=variables.archive.getCrumbIterator()>
	<cfloop condition="variables.crumbIterator.hasNext()">
		<cfset variables.crumb=variables.crumbIterator.next()>
		<cfif listFindNoCase('Folder,Calendar',variables.crumb.getType())>
			<cfset variables.archive=variables.$.getBean('content').loadBy(contentid=crumb.getContentID())>
			<cfbreak>
		</cfif>
	</cfloop>

</cfif>

<cfset variables.rsArchive=variables.$.getBean('contentGateway').getReleaseCountByMonth(variables.$.event('siteID'),variables.archive.getContentID())>
</cfsilent>
<cfif variables.rsArchive.recordcount>
<cfoutput>
<nav id="navArchive" class="mura-nav-archive<cfif this.navWrapperClass neq ""> #this.navArchiveWrapperClass#"</cfif>>
<cfif len(this.navArchiveWrapperBodyClass)><div class="#this.navArchiveWrapperBodyClass#"></cfif>
<#variables.$.getHeaderTag('subHead1')#>#variables.$.rbKey('list.archive')#</#variables.$.getHeaderTag('subHead1')#>
<ul class="#this.ulTopClass#">
	<cfloop query="variables.rsArchive">
		<cfset isCurrentArchive=variables.archiveFilter and variables.$.event("month") eq variables.rsArchive.month and variables.$.event("year") eq variables.rsArchive.year>
		<cfsilent>
			<cfscript>
				thisLiClass = variables.rsArchive.currentRow == 1 ? 'first' : variables.rsArchive.currentRow == variables.rsArchive.recordcount ? 'last' : '';
				thisAClass=thisLiClass;

				if(isCurrentArchive){
					thisLiClass &= ' ' & this.navliClass & ' ' & this.liCurrentClass;
					thisAClass &= ' ' & this.aCurrentClass;
				} else {
					thisLiClass &= ' ' & this.navliClass;
					thisAClass &= ' ' & this.aNotCurrentClass;
				}
			</cfscript>
		</cfsilent>
		<li class="#thisLiClass#">
			<a href="#variables.$.createHREF(filename='#variables.archive.getFilename()#/')#date/#variables.rsArchive.year#/#variables.rsArchive.month#/" class="#thisAClass#">
				#monthasstring(variables.rsArchive.month)# #variables.rsArchive.year# (#variables.rsArchive.items#)
			</a>
		</li>
	</cfloop>
</ul>
<cfif len(this.navArchiveWrapperBodyClass)></div></cfif>
</nav>
</cfoutput>
</cfif>

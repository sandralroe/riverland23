<!--- license goes here --->
<cfsilent>
	<!--- In case someone is attempting to use the search box after clicking a tag --->
	<cfif Len($.event('tag')) and Len($.event('keywords'))>
		<cfset $.event('tag', '') />
	</cfif>

	<cfparam name="variables.rsnewsearch" default="#queryNew('empty')#"/>
	<cfparam name="request.aggregation" default="false">
	<cfparam name="request.searchSectionID" default="">
	<cfparam name="session.rsSearch" default="#queryNew('empty')#">
	<cfset validCSRFTokens=true>

	<cfif (len(request.keywords) or len(request.tag) ) and isdefined('request.newSearch')>
		<!---
		<cfif variables.$.getContentRenderer().validateCSRFTokens and not variables.$.validateCSRFTokens(context='search')>
			<cfset session.rsSearch=newResultQuery()/>
			<cfset validCSRFTokens=false>
		<cfelse>
		--->
			<cfset session.aggregation=request.aggregation />
			<cfset variables.rsNewSearch=application.contentManager.getPublicSearch(variables.$.event('siteID'),request.keywords,request.tag,request.searchSectionID) />

			<cfif getSite().getExtranet() eq 1>
				<cfset session.rsSearch=variables.$.queryPermFIlter(variables.rsnewsearch)/>
			<cfelse>
				<cfset session.rsSearch=variables.rsnewsearch/>
			</cfif>
		<!---</cfif>--->
	<cfelseif request.keywords eq '' and isdefined('request.newSearch')>
		<cfset session.rsSearch=newResultQuery()/>
	</cfif>

	<cfset variables.totalrecords=session.rsSearch.RecordCount>
	<cfset variables.recordsperpage=10>
	<cfset variables.NumberOfPages=Ceiling(variables.totalrecords/variables.recordsperpage)>
	<cfset variables.CurrentPageNumber=Ceiling(request.StartRow/variables.recordsperpage)>
	<cfset variables.next=evaluate((request.startrow+variables.recordsperpage))	>
	<cfset variables.previous=evaluate((request.startrow-variables.recordsperpage))	>
	<cfset variables.through=iif(variables.totalrecords lt variables.next,variables.totalrecords,variables.next-1)>

	<cfset variables.iterator=variables.$.getBean("contentIterator")>
	<cfset variables.iterator.setQuery(session.rsSearch,variables.recordsperpage)>
	<cfset variables.iterator.setStartRow(variables.$.event("startrow"))>

	<cfif len(request.searchSectionID)>
	<cfset variables.sectionBean=application.contentManager.getActiveContent(request.searchSectionID,variables.$.event('siteID')) />
	</cfif>

	<cfset variables.contentListFieldsType="Search">
	<cfset variables.contentListFields="Title,Summary,Tags,Credits">
</cfsilent>
<cfoutput>

	<#variables.$.getHeaderTag('headline')#>#variables.$.rbKey('search.searchresults')#</#variables.$.getHeaderTag('headline')#>

	<div id="svSearchResults" class="mura-search-results #this.searchResultWrapperClass#">
		<div class="#this.searchResultInnerClass#">
			<cfif validCSRFTokens>
				<cfset variables.args=arrayNew(1)>
				<cfset variables.args[1]=session.rsSearch.recordcount>
				<cfif len(request.tag)>
					<cfset variables.args[2]=htmlEditFormat(request.tag)>
					<cfif len(request.searchSectionID)>
						<cfset variables.args[3]=htmlEditFormat(variables.sectionBean.getTitle())>
						<p>#variables.$.siteConfig("rbFactory").getResourceBundle().messageFormat(variables.$.rbKey('search.searchtagsection'),variables.args)#</p>
					<cfelse>
						<p>#variables.$.siteConfig("rbFactory").getResourceBundle().messageFormat(variables.$.rbKey('search.searchtag'),variables.args)#</p>
					</cfif>
				<cfelse>
					<cfset variables.args[2]=htmlEditFormat(request.keywords)>
					<cfif len(request.searchSectionID)>
						<cfset variables.args[3]=htmlEditFormat(variables.sectionBean.getTitle())>
				 		<p>#variables.$.siteConfig("rbFactory").getResourceBundle().messageFormat(variables.$.rbKey('search.searchkeywordsection'),variables.args)#</p>
					<cfelse>
						<p>#variables.$.siteConfig("rbFactory").getResourceBundle().messageFormat(variables.$.rbKey('search.searchkeyword'),variables.args)#</p>
					</cfif>
				</cfif>
			<cfelse>
				<p>Your request contained invalid tokens</p>
			</cfif>
		</div>


		<cfif variables.totalrecords>
			<!--- more results --->
			<div class="#this.searchResultsMoreResultsRowClass#">
				<div class="moreResults">
					<p>#variables.$.rbKey('search.displaying')#: #request.startrow# - #variables.through# #variables.$.rbKey('search.of')# #session.rsSearch.recordcount#</p>
					<cfif ( session.rsSearch.recordcount gt 0 and  variables.through lt session.rsSearch.recordcount ) OR variables.previous gte 1>
						<ul class="pager">
						<cfif variables.previous gte 1>
							<li class="navPrev">
								<a href="?startrow=#variables.previous#&amp;display=search&amp;keywords=#HTMLEditFormat(request.keywords)#&amp;searchSectionID=#HTMLEditFormat(request.searchSectionID)#&amp;tag=#HTMLEditFormat(request.tag)#" aria-label="Previous page">#variables.$.rbKey('search.prev')#</a>
							</li>
						</cfif>
						<cfif session.rsSearch.recordcount gt 0 and variables.through lt session.rsSearch.recordcount>
							<li class="navNext">
								<a href="?startrow=#next#&amp;display=search&amp;keywords=#HTMLEditFormat(request.keywords)#&amp;searchSectionID=#HTMLEditFormat(request.searchSectionID)#&amp;tag=#HTMLEditFormat(request.tag)#" aria-label="Next page">#variables.$.rbKey('search.next')#</a>
							</li>
						</cfif>
						</ul>
					</cfif>
				</div>
			</div>

			<!--- RESULTS --->
			<div class="#this.searchResultsRowClass#">
				<div id="svPortal" class="mura-index #this.searchResultsListClass#">
					#variables.$.dspObject_Include(
						thefile='collection/includes/dsp_content_list.cfm'
						, fields=variables.contentListFields
						, type=variables.contentListFieldsType
						, iterator= variables.iterator
					)#
				</div>
			</div>
			<!--- @END RESULTS --->

			<!--- more results --->
			<div class="#this.searchResultsMoreResultsRowClass#">
				<div class="moreResults">
					<p>#variables.$.rbKey('search.displaying')#: #request.startrow# - #variables.through# #variables.$.rbKey('search.of')# #session.rsSearch.recordcount#</p>
					<cfif ( session.rsSearch.recordcount gt 0 and  variables.through lt session.rsSearch.recordcount ) OR variables.previous gte 1>
						<ul class="#this.searchResultsPagerClass#">
						<cfif variables.previous gte 1>
							<li class="navPrev">
								<a href="./?startrow=#variables.previous#&amp;display=search&amp;keywords=#HTMLEditFormat(request.keywords)#&amp;searchSectionID=#HTMLEditFormat(request.searchSectionID)#&amp;tag=#HTMLEditFormat(request.tag)#" aria-label="Previous page">#variables.$.rbKey('search.prev')#</a>
							</li>
						</cfif>
						<cfif session.rsSearch.recordcount gt 0 and  variables.through lt session.rsSearch.recordcount>
							<li class="navNext">
								<a href="./?startrow=#next#&amp;display=search&amp;keywords=#HTMLEditFormat(request.keywords)#&amp;searchSectionID=#HTMLEditFormat(request.searchSectionID)#&amp;tag=#HTMLEditFormat(request.tag)#" aria-label="Next page">#variables.$.rbKey('search.next')#</a>
							</li>
						</cfif>
						</ul>
					</cfif>
				</div>
			</div>
		</cfif>

		<!--- SEARCH AGAIN --->
		<div class="#this.searchAgainRowClass#">
			<div class="#this.searchAgainInnerClass#">
				<form method="post" id="svSearchAgain" name="searchForm" class="mura-search-again #this.searchAgainFormClass#" role="search">
					<p>#variables.$.rbKey('search.didnotfind')#</p>
					<label for="txtKeywords">#variables.$.rbKey('search.keywords')#</label>
					<div class="#this.searchAgainInputWrapperClass#">
						<input type="text" name="Keywords" id="txtKeywords" class="#this.searchAgainFormInputClass#" value="#esapiEncode('html_attr',request.keywords)#" placeholder="#variables.$.rbKey('search.search')#">
						<span class="#this.searchAgainButtonWrapperClass#">
							<button type="submit" class="#this.searchAgainSubmitClass#">
								#$.rbKey('search.search')#
							</button>
						</span>
					</div>
					<input type="hidden" name="display" value="search">
					<input type="hidden" name="newSearch" value="true">
					<input type="hidden" name="noCache" value="1">
					<input type="hidden" name="searchSectionID" value="#HTMLEditFormat(request.searchSectionID)#">
					#variables.$.renderCSRFTokens(format='form',context='search')#
				</form>
			</div>
		</div>
	</div>
</cfoutput>

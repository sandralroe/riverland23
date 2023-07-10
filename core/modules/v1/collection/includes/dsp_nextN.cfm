<!--- license goes here --->

<cfsilent>
	<cfif variables.nextN.recordsPerPage gt 1>
		<cfset variables.paginationKey="startRow">
	<cfelse>
		<cfset variables.paginationKey="pageNum">
	</cfif>

	<cfset variables.qrystr="" />

	<cfif len(trim($.event("keywords")))>
		<cfset variables.qrystr="&keywords=" & esapiEncode('html_attr', $.event("keywords")) />
	</cfif>
	<cfif len($.event('sortBy'))>
		<cfset variables.qrystr=variables.qrystr & "&sortBy=#esapiEncode('url',$.event('sortBy'))#&sortDirection=#esapiEncode('url',$.event('sortDirection'))#"/>
	</cfif>
	<cfif len(variables.$.event('categoryID'))>
		<cfset variables.qrystr=variables.qrystr & "&categoryID=#esapiEncode('url',variables.$.event('categoryID'))#"/>
	</cfif>
	<cfif len($.event('relatedid'))>
		<cfset variables.qrystr=variables.qrystr & "&relatedID=#esapiEncode('url',$.event('relatedid'))#"/>
	</cfif>
	<cfif len($.event('currentNextNID'))>
		<cfset variables.qrystr=variables.qrystr & "&nextNID=#esapiEncode('url',$.event('currentNextNID'))#"/>
	</cfif>
	<cfif listFindNoCase('releaseMonth,releaseDate,releaseYear',$.event('filterBy'))>
		<cfset variables.qrystr=variables.qrystr & "&month=#esapiEncode('url',$.event('month'))#&year=#esapiEncode('url',$.event('year'))#&day=#esapiEncode('url',$.event('day'))#&filterBy=#esapiEncode('url',$.event('filterBy'))#">
	<cfelseif isNumeric($.event('day')) and $.event('day')>
		<cfset variables.qrystr=variables.qrystr & "&month=#esapiEncode('url',$.event('month'))#&year=#esapiEncode('url',$.event('year'))#&day=#esapiEncode('url',$.event('day'))#">
	</cfif>
</cfsilent>
<cfoutput>
<cfif variables.nextN.lastPage gt 1>
	<div class="mura-next-n #this.nextNWrapperClass#">
			<ul <cfif this.ulPaginationClass neq "">class="#this.ulPaginationClass#"</cfif>>
			<cfif variables.nextN.currentpagenumber gt 1>
				<cfif isBoolean($.event('muraExportHtml')) and $.event('muraExportHtml')>
					<cfif variables.nextN.currentpagenumber eq 2>
						<li class="navPrev #this.liPaginationNotCurrentClass#">
							<a class="#this.aPaginationNotCurrentClass#" href="index.html" aria-label="Previous page">&laquo;&nbsp;#variables.$.rbKey('list.previous')#</a>
						</li>
					<cfelse>
						<li class="navPrev #this.liPaginationNotCurrentClass#">
							<a class="#this.aPaginationNotCurrentClass#" href="index#evaluate('#variables.nextn.currentpagenumber#-1')#.html" aria-label="Previous page">#this.navPrevDecoration##variables.$.rbKey('list.previous')#</a>
						</li>
					</cfif>
				<cfelse>
					<li class="navPrev #this.liPaginationNotCurrentClass#">
						<a class="#this.aPaginationNotCurrentClass#" href="#xmlFormat('?#paginationKey#=#variables.nextN.previous##variables.qrystr#')#" aria-label="Previous page">#this.navPrevDecoration##variables.$.rbKey('list.previous')#</a>
					</li>
				</cfif>
			</cfif>
			<cfloop from="#variables.nextN.firstPage#" to="#variables.nextN.lastPage#" index="i">
				<cfif variables.nextn.currentpagenumber eq i>
					<li class="#this.liPaginationCurrentClass#"><a class="#this.aPaginationCurrentClass#" href="##">#i#</a></li>
				<cfelse>
					<cfif isBoolean($.event('muraExportHtml')) and $.event('muraExportHtml')>
						<cfif i eq 1>
						<li class="#this.liPaginationNotCurrentClass#"><a class="#this.aPaginationNotCurrentClass#" href="index.html">#i#</a></li>
						<cfelse>
						<li class="#this.liPaginationNotCurrentClass#"><a class="#this.aPaginationNotCurrentClass#" href="index#i#.html">#i#</a></li>
						</cfif>
					<cfelse>
						<li class="#this.liPaginationNotCurrentClass#"><a class="#this.aPaginationNotCurrentClass#" href="?#xmlFormat('#paginationKey#=#evaluate('(#i#*#variables.nextN.recordsperpage#)-#variables.nextN.recordsperpage#+1')##variables.qrystr#')#" aria-label="<cfif i eq 1>Current page<cfelse>Page #i#</cfif>">#i#</a></li>
					</cfif>
				</cfif>
			</cfloop>
			<cfif variables.nextN.currentpagenumber lt variables.nextN.NumberOfPages>
				<cfif isBoolean($.event('muraExportHtml')) and $.event('muraExportHtml')>
					<li class="navNext #this.liPaginationNotCurrentClass#"><a class="#this.aPaginationNotCurrentClass#" href="index#evaluate('#variables.nextn.currentpagenumber#+1')#.html" aria-label="Next page">#variables.$.rbKey('list.next')#&nbsp;&raquo;</a></li>
				<cfelse>
					<li class="navNext #this.liPaginationNotCurrentClass#"><a class="#this.aPaginationNotCurrentClass#" href="?#xmlFormat('#paginationKey#=#variables.nextN.next##variables.qrystr#')#" aria-label="Next page">#variables.$.rbKey('list.next')##this.navNextDecoration#</a></li>
				</cfif>
			</cfif>
			</ul>
	</div>
</cfif>
</cfoutput>
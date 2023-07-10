<cfcomponent extends="mura.cfobject" output="false">

	<cffunction name="publicSearch" output="false">
	<cfargument name="siteid" type="string" required="true">
	<cfargument name="keywords" type="string" required="true">
	<cfargument name="tag" type="string" required="true" default="">
	<cfargument name="sectionID" type="string" required="true" default="">
	<cfargument name="categoryID" type="string" required="true" default="">
	<cfargument name="tagGroup" type="string" required="true" default="">

	<cfset var rsPublicSearch = "">
	<cfset var w = "">
	<cfset var c = "">
	<cfset var categoryListLen=listLen(arguments.categoryID)>
		<!--- Make call to elasticSearch with keywords and siteid --->
	<cfset var rsElasticSearch=getBean('elasticSearchService').searchAsQuery(arguments.keywords,arguments.siteID)>

	<cfquery name="rsPublicSearch" maxRows="500" datasource="#variables.configBean.getDatasource()#" >
		<!--- Find direct matches with no releasedate --->

		select tcontent.contentid,tcontent.contenthistid,tcontent.siteid,tcontent.title,tcontent.menutitle,tcontent.targetParams,tcontent.filename,tcontent.summary,tcontent.tags,
		tcontent.restricted,tcontent.releaseDate,tcontent.type,tcontent.subType,
		tcontent.restrictgroups,tcontent.target ,tcontent.displaystart,tcontent.displaystop,0 as Comments,
		tcontent.credits, tcontent.remoteSource, tcontent.remoteSourceURL,
		tcontent.remoteURL,tfiles.fileSize,tfiles.fileExt,tcontent.fileID,tcontent.audience,tcontent.keyPoints,
		tcontentstats.rating,tcontentstats.totalVotes,tcontentstats.downVotes,tcontentstats.upVotes, 0 as kids,
		tparent.type parentType,tcontent.nextn,tcontent.path,tcontent.orderno,tcontent.lastupdate,tcontent.created,
		tcontent.created sortdate, 0 score,tfiles.filename as AssocFilename,tcontentstats.lockID,tcontentstats.majorVersion,tcontentstats.minorVersion
		from tcontent Left Join tfiles ON (tcontent.fileID=tfiles.fileID)
		Left Join tcontent tparent on (tcontent.parentid=tparent.contentid
							    			and tcontent.siteid=tparent.siteid
							    			and tparent.active=1)
		LEFT JOIN tcontentstats ON (tcontent.contentid=tcontentstats.contentid
								and tcontent.siteID=tcontentstats.SiteID)

		<cfif len(arguments.tag)>
			Inner Join tcontenttags on (tcontent.contentHistID=tcontenttags.contentHistID)
		</cfif>
			where

				(tcontent.Active = 1
					AND tcontent.Approved = 1
					AND tcontent.siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/> )

							AND

							(
							  tcontent.Display = 2
								AND
								(
									(tcontent.DisplayStart <= #createodbcdate(now())#
									AND (tcontent.DisplayStop >= #createodbcdate(now())# or tcontent.DisplayStop is null)
									)
									OR  tparent.type='Calendar'
								)

								OR tcontent.Display = 1
							)

					AND
					tcontent.type in ('Page','Folder','Portal','Calendar','File','Link')

					AND tcontent.releaseDate is null

					<cfif len(arguments.sectionID)>
					and tcontent.path like  <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.sectionID#%">
					</cfif>

					<cfif len(arguments.tag)>
						and tcontenttags.Tag= <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.tag)#"/>
					<cfelse>
						and
						(
						<!--- Add in returns from ElasticSearch, if any --->
						<cfif rsElasticSearch.recordcount>
							<!--- List of ContentIDs from ElasticSearch --->
								<cfif rsElasticSearch.recordcount>
									tcontent.contentID in (#QuotedvalueList(rsElasticSearch.contentID)#)
								<cfelse>
									0=1
								</cfif>

						<cfelse>
							0=1
						</cfif>

						)
					</cfif>

					and tcontent.searchExclude=0

					<cfif categoryListLen>
						  and tcontent.contentHistID in (
								select tcontentcategoryassign.contentHistID from
								tcontentcategoryassign
								inner join tcontentcategories
								ON (tcontentcategoryassign.categoryID=tcontentcategories.categoryID)
								where (<cfloop from="1" to="#categoryListLen#" index="c">
										tcontentcategories.path like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#listgetat(arguments.categoryID,c)#%"/>
										<cfif c lt categoryListLen> or </cfif>
										</cfloop>)
						  )
					</cfif>

					<cfif request.muraMobileRequest>
					    and (tcontent.mobileExclude!=1 or tcontent.mobileExclude is null)
					</cfif>

		union all

		<!--- Find direct matches with releasedate --->

		select tcontent.contentid,tcontent.contenthistid,tcontent.siteid,tcontent.title,tcontent.menutitle,tcontent.targetParams,tcontent.filename,tcontent.summary,tcontent.tags,
		tcontent.restricted,tcontent.releaseDate,tcontent.type,tcontent.subType,
		tcontent.restrictgroups,tcontent.target ,tcontent.displaystart,tcontent.displaystop,0 as Comments,
		tcontent.credits, tcontent.remoteSource, tcontent.remoteSourceURL,
		tcontent.remoteURL,tfiles.fileSize,tfiles.fileExt,tcontent.fileID,tcontent.audience,tcontent.keyPoints,
		tcontentstats.rating,tcontentstats.totalVotes,tcontentstats.downVotes,tcontentstats.upVotes, 0 as kids,
		tparent.type parentType,tcontent.nextn,tcontent.path,tcontent.orderno,tcontent.lastupdate,tcontent.created,
		tcontent.releaseDate sortdate, 0 score,tfiles.filename as AssocFilename,tcontentstats.lockID,tcontentstats.majorVersion,tcontentstats.minorVersion
		from tcontent Left Join tfiles ON (tcontent.fileID=tfiles.fileID)
		Left Join tcontent tparent on (tcontent.parentid=tparent.contentid
							    			and tcontent.siteid=tparent.siteid
							    			and tparent.active=1)
		Left Join tcontentstats on (tcontent.contentid=tcontentstats.contentid
						    and tcontent.siteid=tcontentstats.siteid)


		<cfif len(arguments.tag)>
			Inner Join tcontenttags on (tcontent.contentHistID=tcontenttags.contentHistID)
		</cfif>
			where

					(tcontent.Active = 1
					AND tcontent.Approved = 1
					AND tcontent.siteid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.siteID#"/> )

							AND

							(
							  tcontent.Display = 2
								AND
								(
									(tcontent.DisplayStart <= #createodbcdate(now())#
									AND (tcontent.DisplayStop >= #createodbcdate(now())# or tcontent.DisplayStop is null)
									)
									OR  tparent.type='Calendar'
								)

								OR tcontent.Display = 1
							)


					AND
					tcontent.type in ('Page','Folder','Portal','Calendar','File','Link')

					AND tcontent.releaseDate is not null

					<cfif len(arguments.sectionID)>
					and tcontent.path like  <cfqueryparam cfsqltype="cf_sql_varchar" value="%#arguments.sectionID#%">
					</cfif>

					<cfif len(arguments.tag)>
						and tcontenttags.Tag= <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.tag)#"/>
					<cfelse>
						and
						(
						<!--- Add in returns from ElasticSearch, if any --->
						<cfif rsElasticSearch.recordcount>
							<!--- List of ContentIDs from ElasticSearch --->
								<cfif rsElasticSearch.recordcount>
									tcontent.contentID in (<cfqueryparam cfsqltype="cf_sql_varchar" value="#valueList(rsElasticSearch.contentID)#" list="true">)
								<cfelse>
									0=1
								</cfif>

						<cfelse>
							0=1
						</cfif>

						)
					</cfif>

					and tcontent.searchExclude=0

					<cfif categoryListLen>
						  and tcontent.contentHistID in (
								select tcontentcategoryassign.contentHistID from
								tcontentcategoryassign
								inner join tcontentcategories
								ON (tcontentcategoryassign.categoryID=tcontentcategories.categoryID)
								where (
									<cfloop from="1" to="#categoryListLen#" index="c">
										tcontentcategories.path like <cfqueryparam cfsqltype="cf_sql_varchar" value="%#listgetat(arguments.categoryID,c)#%"/>
									<cfif c lt categoryListLen> or </cfif>
									</cfloop>)
						  )
					</cfif>

					<cfif request.muraMobileRequest>
					 	and (tcontent.mobileExclude!=1 or tcontent.mobileExclude is null)
					</cfif>

		</cfquery>

		<!--- Loop query of results above to highlight words --->
		<cfloop query="rsPublicSearch">
		<cfset fileScore=0>
		<cfset dbScore=0>

		<cfquery name="rsScore" dbtype="query">
			select score,body from rsElasticSearch
			where contentID=<cfqueryparam cfsqltype="cf_sql_varchar" value="#rsPublicSearch.contentID#">
		</cfquery>

		<cfif rsScore.recordcount>
			<cfset DBScore = (rsScore.score * 1000)>
			<cfset querySetCell(rsPublicSearch,"score", DBScore, rsPublicSearch.currentRow)>
			<cfif len(trim(rsScore.body))>
				<!--- Added to higlight text from search --->
				<cfset highlightSearchTerms = fullLeft(trim(rsScore.body),90)>
				<!--- Added to higlight text from search --->
				<cfloop list="#arguments.keywords#" index="searchWord" delimiters=" ">
				<!--- loop through the search arguments using spaces as the delimiter. and wrap with <strong></strong>--->
					<cfset highlightSearchTerms = reReplaceNoCase(highlightSearchTerms, "\b#searchWord#\b", "<strong>"& searchWord &"</strong>", "ALL")>
				</cfloop>
				<!--- Set the summary to the new highlighted text --->
				<cfset querySetCell(rsPublicSearch,"summary","<p>" & trim(highlightSearchTerms) & " ...</p>",rsPublicSearch.currentRow)>
			</cfif>
		</cfif>

	</cfloop>

	<!--- Loop query of results above to reorder based on score from ElasticSearch --->
	<cfquery name="rsPublicSearch" dbtype="query">
		select *
		from rsPublicSearch
		order by score desc
	</cfquery>

	<cfreturn rsPublicSearch />

</cffunction>

<!--- Added to prevent cutting off of text --->
<!--- http://cflib.org/udf/FullLeft (converted to tag from script)--->
<cffunction name="fullLeft" >
	<cfargument name="str" />
	<cfargument name="count" />

	<cfif not refind("[[:space:]]", str) or (count gte len(str))>
		<cfreturn Left(str, count)>
	<cfelseif reFind("[[:space:]]",mid(str,count+1,1))>
	  	<cfreturn  left(str,count)>
	<cfelse>
		<cfif count-refind("[[:space:]]", reverse(mid(str,1,count))) >
		<cfreturn Left( str, (count-refind("[[:space:]]", reverse(mid(str,1,count)))) ) >
		<cfelse>
		 <cfreturn left(str,1)>
		</cfif>
	</cfif>

</cffunction>


</cfcomponent>

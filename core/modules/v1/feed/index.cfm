<!--- license goes here --->
<!--- <cftry> --->
<cfsilent>
	<cfif isValid("UUID", arguments.objectID)>
		<cfset variables.feedBean = variables.$.getBean("feed").loadBy(feedID=arguments.objectID,siteID=arguments.siteID)>
	<cfelse>
		<cfset variables.feedBean = variables.$.getBean("feed").loadBy(name=arguments.objectID,siteID=arguments.siteID)>
	</cfif>
	<cfif not structIsEmpty(objectparams)>
		<cfset variables.feedBean.set(objectparams)>
	<cfelseif variables.feedBean.getType() eq "Local" and not arguments.hasSummary>
		<cfset variables.contentListFields=listDeleteAt(variables.feedBean.getDisplayList(),listFindNoCase(variables.feedBean.getDisplayList(),"Summary"))>
		<cfset variables.feedBean.setDisplayList(variables.contentListFields)>
	</cfif>
	<cfparam name="objectparams.displaySummaries" default="true">
	<cfparam name="objectparams.viewalllink" default="">
	<cfparam name="objectparams.viewalllabel" default="#$.rbKey('list.viewall')#">
</cfsilent>

<cfif not variables.feedBean.getIsNew() and variables.feedBean.getIsActive()>

	<cfset variables.cssID = variables.$.createCSSid(variables.feedBean.renderName())>

	<cfif variables.feedBean.getType() eq 'local'>
		<cfsilent>
			<cfif variables.$.siteConfig('extranet') eq 1 and variables.$.event('r').restrict eq 1>
				<cfset variables.iterator=variables.feedBean.getIterator(applyPermFilter=true)/>
			<cfelse>
				<cfset variables.iterator=variables.feedBean.getIterator(applyPermFilter=false)/>
			</cfif>

			<cfset variables.checkMeta = variables.feedBean.getDisplayRatings() or variables.feedBean.getDisplayComments()>
			<cfset variables.doMeta = 0/>
			<cfset variables.$.event("currentNextNID", variables.feedBean.getFeedID())>

			<cfif not len(variables.$.event("nextNID")) or variables.$.event("nextNID") eq variables.$.event("currentNextNID")>
				<cfif variables.$.content('NextN') gt 1>
					<cfset variables.currentNextNIndex = variables.$.event("startRow")>
					<cfset variables.iterator.setStartRow(variables.currentNextNIndex)>
				<cfelse>
					<cfset variables.currentNextNIndex = variables.$.event("pageNum")>
					<cfset variables.iterator.setPage(currentNextNIndex)>
				</cfif>
			<cfelse>
				<cfset variables.currentNextNIndex = 1>
				<cfset variables.iterator.setPage(1)>
			</cfif>
			<cfset variables.nextN = variables.$.getBean('utility').getNextN(variables.iterator.getQuery(),variables.feedBean.getNextN(),variables.currentNextNIndex)>
		</cfsilent>

		<cfif variables.iterator.getRecordCount()>
			<cfoutput>
				<div class="mura-synd-local mura-feed mura-index #this.localIndexWrapperClass# #variables.feedBean.getCssClass()#" id="#variables.cssID#">
					<cfif variables.feedBean.getDisplayName()>
						<#variables.$.getHeaderTag('subHead1')#>#HTMLEditFormat(variables.feedBean.renderName())#</#variables.$.getHeaderTag('subHead1')#>
					</cfif>
					#variables.$.dspObject_Include(
									thefile='collection/includes/dsp_content_list.cfm',
									fields=variables.feedBean.getDisplayList(),
				                    type="Feed",
									iterator=variables.iterator,
				                    imageSize=variables.feedBean.getImageSize(),
				                    imageHeight=variables.feedBean.getImageHeight(),
				                    imageWidth=variables.feedBean.getImageWidth()
								)#
					<cfif variables.nextN.numberofpages gt 1>
						#variables.$.dspObject_Include(thefile='collection/includes/dsp_nextN.cfm')#
					</cfif>

					<cfif len(objectParams.viewalllink)>
						<a class="view-all" href="#objectParams.viewalllink#">#HTMLEditFormat(objectParams.viewalllabel)#</a>
					</cfif>
				</div>
			</cfoutput>
		<cfelse>
			<cfoutput>#dspObject("component", "[placeholder] #variables.feedBean.getName()#", arguments.siteID)#</cfoutput>
			<!-- Empty Collection '
			<cfoutput>#feedBean.getName()#</cfoutput>
			' -->
		</cfif>
	<cfelse>
		<!--- REMOTE FEED OUTPUT --->
		<!---<cftry> --->
		<cfsilent>
			<cfset request.cacheItemTimespan = createTimeSpan(0, 0, 5, 0)>
			<cfset variables.feedData = variables.feedBean.getRemoteData()>
			<cfif not structIsEmpty(objectparams) and structKeyExists(objectparams,'displaySummaries')>
				<cfset arguments.hasSummary=objectparams.displaySummaries>
			</cfif>
		</cfsilent>

		<cfoutput>
			<cfif isDefined("variables.feedData.maxItems") and variables.feedData.maxItems>
				<div class="mura-synd-remote mura-index mura-feed #this.remoteFeedWrapperClass# #variables.feedBean.getCssClass()#" id="#variables.cssID#">
					<#variables.$.getHeaderTag('subHead1')#>#HTMLEditFormat(variables.feedBean.getName())#</#variables.$.getHeaderTag('subHead1')#>
					<!--- UL MARKUP --->
					<cfif variables.$.getListFormat() eq 'ul'>
						<ul>
							<cfif variables.feedData.type neq "atom">
								<cfloop from="1" to="#variables.feedData.maxItems#" index="i">
									<li<cfif (i EQ 1)> class="first"<cfelseif (i EQ variables.feedData.maxItems)> class="last"</cfif>>
										<!--- Date stuff--->
										<cfif structKeyExists(variables.feedData.itemArray[i],"pubDate")>
											<cftry>
											<cfset variables.itemDate=parseDateTime(variables.feedData.itemArray[i].pubDate.xmlText)>
											<p class="releaseDate"><cfif isDate(variables.itemDate)>#LSDateFormat(variables.itemDate,variables.$.getLongDateFormat())#<cfelse>#variables.feedData.itemArray[i].pubDate.xmlText#</cfif></p>
											<cfcatch></cfcatch>
											</cftry>
										<cfelseif structKeyExists(variables.feedData.itemArray[i],"dc:date")>
											<cftry>
											<cfset itemDate=parseDateTime(variables.feedData.itemArray[i]["dc:date"].xmlText)>
											<p class="releaseDate"><cfif isDate(variables.itemDate)>#LSDateFormat(variables.itemDate,variables.$.getLongDateFormat())#<cfelse>#variables.feedData.itemArray[i]["dc:date"].xmlText#</cfif></p>
											<cfcatch></cfcatch>
											</cftry>
										</cfif>
										<h3><a href="#variables.feedData.itemArray[i].link.xmlText#" onclick="window.open(this.href); return false;">#variables.feedData.itemArray[i].title.xmlText#</a></h3>
										<cfif arguments.hasSummary and structKeyExists(variables.feedData.itemArray[i],"description")><p class="summary">#variables.feedData.itemArray[i].description.xmlText#</p></cfif>
									</li>
								</cfloop>
							<cfelse>
								<cfloop from="1" to="#variables.feedData.maxItems#" index="i">
									<li<cfif (i EQ 1)> class="first"<cfelseif (i EQ variables.feedData.maxItems)> class="last"</cfif>>
										<!--- Date stuff--->
										<cfif structKeyExists(variables.feedData.itemArray[i],"updated")>
											<cftry>
											<cfset variables.itemDate=parseDateTime(variables.feedData.itemArray[i].updated.xmlText)>
											<p class="releaseDate"><cfif isDate(variables.itemDate)>#LSDateFormat(variables.itemDate,variables.$.getLongDateFormat())#<cfelse>#variables.feedData.itemArray[i].updated.xmlText#</cfif></p>
											<cfcatch></cfcatch>
											</cftry>
										</cfif>
										<h3><a href="#variables.feedData.itemArray[i].link.XmlAttributes.href#" onclick="window.open(this.href); return false;">#variables.feedData.itemArray[i].title.xmlText#</a></h3>
										<cfif arguments.hasSummary and structKeyExists(variables.feedData.itemArray[i],"summary")><p class="summary">#variables.feedData.itemArray[i].summary.xmlText#</p></cfif>
									</li>
								</cfloop>
							</cfif>
						</ul>
					<cfelse>
					<!--- DL MARKUP --->
						<cfif variables.feedData.type neq "atom">
							<cfloop from="1" to="#variables.feedData.maxItems#" index="i">
								<dl<cfif (i EQ 1)> class="first"<cfelseif (i EQ variables.feedData.maxItems)> class="last"</cfif>>
									<!--- Date stuff--->
									<cfif structKeyExists(variables.feedData.itemArray[i],"pubDate")>
										<cftry>
										<cfset variables.itemDate=parseDateTime(variables.feedData.itemArray[i].pubDate.xmlText)>
										<dt class="releaseDate"><cfif isDate(variables.itemDate)>#LSDateFormat(variables.itemDate,variables.$.getLongDateFormat())#<cfelse>#variables.feedData.itemArray[i].pubDate.xmlText#</cfif></dt>
										<cfcatch></cfcatch>
										</cftry>
									<cfelseif structKeyExists(variables.feedData.itemArray[i],"dc:date")>
										<cftry>
										<cfset itemDate=parseDateTime(variables.feedData.itemArray[i]["dc:date"].xmlText)>
										<dt class="releaseDate"><cfif isDate(variables.itemDate)>#LSDateFormat(variables.itemDate,variables.$.getLongDateFormat())#<cfelse>#variables.feedData.itemArray[i]["dc:date"].xmlText#</cfif></dt>
										<cfcatch></cfcatch>
										</cftry>
									</cfif>
									<dt><a href="#variables.feedData.itemArray[i].link.xmlText#" onclick="window.open(this.href); return false;">#variables.feedData.itemArray[i].title.xmlText#</a></dt>
									<cfif arguments.hasSummary and structKeyExists(variables.feedData.itemArray[i],"description")><dd class="summary">#variables.feedData.itemArray[i].description.xmlText#</dd></cfif>
								</dl>
							</cfloop>
						<cfelse>
							<cfloop from="1" to="#variables.feedData.maxItems#" index="i">
								<dl<cfif (i EQ 1)> class="first"<cfelseif (i EQ variables.feedData.maxItems)> class="last"</cfif>>
									<!--- Date stuff--->
									<cfif structKeyExists(variables.feedData.itemArray[i],"updated")>
										<cftry>
										<cfset variables.itemDate=parseDateTime(variables.feedData.itemArray[i].updated.xmlText)>
										<dt class="releaseDate"><cfif isDate(variables.itemDate)>#LSDateFormat(variables.itemDate,variables.$.getLongDateFormat())#<cfelse>#variables.feedData.itemArray[i].updated.xmlText#</cfif></dt>
										<cfcatch></cfcatch>
										</cftry>
									</cfif>
									<dt><a href="#variables.feedData.itemArray[i].link.XmlAttributes.href#" onclick="window.open(this.href); return false;">#variables.feedData.itemArray[i].title.xmlText#</a></dt>
									<cfif arguments.hasSummary and structKeyExists(variables.feedData.itemArray[i],"summary")><dd class="summary">#variables.feedData.itemArray[i].summary.xmlText#</dd></cfif>
								</dl>
							</cfloop>
						</cfif>
					</cfif>
					<cfif len(objectParams.viewalllink)>
						<a class="view-all" href="#objectParams.viewalllink#">#HTMLEditFormat(objectParams.viewalllabel)#</a>
					</cfif>
				</div>
			<cfelse>
				#dspObject("component", "[placeholder] #variables.feedBean.getName()#", arguments.siteID)#
				<!-- Empty Feed
				<cfoutput>'#feedBean.getName()#'</cfoutput>
				-->
			</cfif>
		</cfoutput>
		<!---
		<cfcatch><!-- Error getting Feed <cfoutput>'#feedBean.getName()#'</cfoutput> --></cfcatch>
		</cftry>---->
	</cfif>
<cfelseif variables.feedBean.getIsNew()>
	<cfset request.muraValidObject=false>
<cfelse>
	<!-- Inactive Feed '
	<cfoutput>#feedBean.getName()#</cfoutput>
	' -->
</cfif>
<!---   <cfcatch>
  </cfcatch>
</cftry> --->

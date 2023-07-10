 <!--- license goes here --->
<cfsilent>
	<cfparam name="objectParams.sourcetype" default="">
	<cfparam name="objectParams.source" default="">
	<cfparam name="objectParams.layout" default="#this.collectionDefaultLayout#">
	<cfparam name="this.collectionDefaultLayout" default="default">
	<cfparam name="objectParams.layout" default="#this.collectionDefaultLayout#">
	<cfparam name="this.defaultCollectionDisplayList" default="Image,Date,Title,Summary,Credits,Tags">
	<cfparam name="objectParams.displayList" default="#this.defaultCollectionDisplayList#">
	<cfparam name="objectParams.items" default="">
	<cfparam name="objectParams.maxitems" default="4">
	<cfparam name="objectParams.nextN" default="20">
	<cfparam name="objectParams.sortBy" default="">
	<cfparam name="objectParams.nextnid" default="#createUUID()#">
	<cfparam name="objectParams.sortDirection" default="">
	<cfparam name="objectParams.viewalllink" default="">
	<cfparam name="objectParams.viewalllabel" default="">
	<cfparam name="objectParams.modalimages" default="false">
	<cfparam name="objectParams.useCategoryIntersect" default="false">
	<cfparam name="objectParams.scrollpages" default="false">
	<cfset isInSecureArea=$.siteConfig('extranet') eq 1 and $.event('r').restrict eq 1>
	<cfset hasPermFilterOption=not $.siteConfig('isRemote') and not isInSecureArea>
	<cfif hasPermFilterOption>
		<cfparam name="objectParams.applypermfilter" default="false">
	</cfif>
	<cfif not len(objectparams.layout)>
		<cfset objectParams.layout='default'>
	</cfif>

	<cfset objectParams.layout=listLast(replace(objectParams.layout, "\", "/", "ALL"),"/")>

</cfsilent>
<cfif objectParams.sourcetype neq 'remotefeed'>
	<cfif $.siteConfig().hasDisplayObject(objectParams.layout) and $.siteConfig().getDisplayObject(objectParams.layout).external>
		<cfset objectParams.render="client">
	<cfelseif objectparams.layout eq 'default' and  $.siteConfig().hasDisplayObject('list') and $.siteConfig().getDisplayObject('list').external>
		<cfset objectParams.render="client">
	<cfelse>
		<cfset objectParams.render="server">
	</cfif>
	<cfif objectParams.render neq 'client'>
	<cfsilent>
		<cfset variables.pagination=''>
		<cfswitch expression="#objectParams.sourceType#">
			<cfcase value="relatedcontent">
				<cfif objectParams.source eq 'custom'>
					<cfif isJson(objectParams.items)>
						<cfset objectParams.items=deserializeJSON(objectParams.items)>
					</cfif>
					<cfif isArray(objectParams.items)>
						<cfset objectparams.items=arrayToList(objectparams.items)>
					</cfif>
					<cfset objectParams.contentids=objectParams.items>
					<cfset objectParams.siteid=$.event('siteid')>
					<cfset iterator=$.getBean('contentManager')
						.findMany(
							argumentCollection=objectParams
						)>
				<cfelseif objectParams.source eq 'reverse'>
					<cfif hasPermFilterOption>
						<cfset iterator=$.content().getRelatedContentIterator(reverse=true,appyPermFilter=objectParams.applyPermfilter)>
					<cfelse>
						<cfset iterator=$.content().getRelatedContentIterator(reverse=true,appyPermFilter=isInSecureArea)>
					</cfif>
				<cfelse>
					<cfif objectParams.source eq '0'>
						<cfset objectParams.source='00000000000000000000000000000000000'>
					</cfif>
					<cfif hasPermFilterOption>
						<cfset iterator=$.content().getRelatedContentIterator(relatedcontentsetid=objectParams.source,appyPermFilter=objectParams.applyPermfilter)>
					<cfelse>
						<cfset iterator=$.content().getRelatedContentIterator(relatedcontentsetid=objectParams.source,appyPermFilter=isInSecureArea)>
					</cfif>
				</cfif>

				<cfset iterator.setNextN(objectparams.nextn)>

				<cfif isNumeric(objectparams.maxItems) and objectparams.maxItems and iterator.hasNext() and iterator.getQuery().recordCount gt objectparams.maxItems>
					<cfset temptable=iterator.getQuery()>
					<cfquery name="trimquery" dbtype="query" maxrows="#objectparams.maxItems#">
						select * from temptable
					</cfquery>
					<cfset iterator.setQuery(trimquery).setNextN(objectparams.nextn)>
				</cfif>
				
				<cfif isBoolean(objectParams.scrollpages) and objectParams.scrollpages or variables.$.event('nextnid') eq objectParams.nextnid>
					<cfif isNumeric(variables.$.event('pageNum')) and variables.$.event('pageNum') gt 1>
						<cfset iterator.setPage(variables.$.event('pageNum'))>
					<cfelseif isNumeric(variables.$.event('startrow')) and variables.$.event('startrow') gt 1>
						<cfset iterator.setStartRow(variables.$.event('startrow'))>
					<cfelse>
						<cfset iterator.setPage(1)>
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="calendar">
				<cfset objectParams.nextnid=''>

				<cfset calendarUtility=variables.$.getCalendarUtility()>

				<cfif not isNumeric(variables.$.event('year'))>
					<cfset variables.$.event('year',year(now()))>
				</cfif>

				<cfif isNumeric(variables.$.event('day')) and variables.$.event('day')
					and variables.$.event('filterBy') eq "releaseDate">
					<cfset variables.menuType="releaseDate">
					<cfset variables.menuDate=createDate(variables.$.event('year'),variables.$.event('month'),variables.$.event('day'))>
					<cfset iterator=calendarUtility.getCalendarItems(
						calendarid=arrayToList(objectParams.items),
						tag=variables.$.event('tag'),
						categoryid=variables.$.event('categoryid'),
						start=variables.menuDate,
						end=variables.menuDate,
						returnFormat='iterator'
					)>
				<cfelseif variables.$.event('filterBy') eq "releaseMonth">
					<cfset variables.menuType="releaseMonth">

					<cfset variables.menuDate=createDate(variables.$.event('year'),variables.$.event('month'),1)>
					<cfset iterator=calendarUtility.getCalendarItems(
						calendarid=arrayToList(objectParams.items),
						tag=variables.$.event('tag'),
						categoryid=variables.$.event('categoryid'),
						start=createDate(year(variables.menudate),month(variables.menudate),1),
						end=createDate(year(variables.menudate),month(variables.menudate),daysInMonth(variables.menudate)),
						returnFormat='iterator'
					)>
				<cfelseif variables.$.event('filterBy') eq "releaseYear">
					<cfset variables.menuType="releaseYear">
					<cfset variables.menuDate=createDate(variables.$.event('year'),1,1)>
					<cfset iterator=calendarUtility.getCalendarItems(
						calendarid=arrayToList(objectParams.items),
						tag=variables.$.event('tag'),
						categoryid=variables.$.event('categoryid'),
						start=createDate(year(variables.menudate),1,1),
						end=createDate(year(variables.menudate),12,31),
						returnFormat='iterator'
					)>
				<cfelse>
					<cfset variables.menuDate=now()>
					<cfset variables.menuType="default">
					<cfset iterator=calendarUtility.getCalendarItems(
						calendarid=arrayToList(objectParams.items),
						tag=variables.$.event('tag'),
						categoryid=variables.$.event('categoryid'),
						start=createDate(year(variables.menudate),month(variables.menudate),1),
						end=createDate(year(variables.menudate),month(variables.menudate),daysInMonth(variables.menudate)),
						returnFormat='iterator'
					)>
				</cfif>
				<cfset iterator.setNextN(objectParams.nextn)>
				
				<cfif isBoolean(objectParams.scrollpages) and objectParams.scrollpages or variables.$.event('nextnid') eq objectParams.nextnid>
					<cfif isNumeric(variables.$.event('pageNum')) and variables.$.event('pageNum') gt 1>
						<cfset iterator.setPage(variables.$.event('pageNum'))>
					<cfelseif isNumeric(variables.$.event('startrow')) and variables.$.event('startrow') gt 1>
						<cfset iterator.setStartRow(variables.$.event('startrow'))>
					<cfelse>
						<cfset iterator.setPage(1)>
					</cfif>
				</cfif>
			</cfcase>
			<cfcase value="children">
				<cfset objectParams.nextnid=''>
				<cfif not isNumeric(variables.$.event('year'))>
					<cfset variables.$.event('year',year(now()))>
				</cfif>
				<cfset args=structCopy(objectParams)>
				<cfif isNumeric(variables.$.event('day')) and variables.$.event('day')
					and variables.$.event('filterBy') eq "releaseDate">
					<cfset args.type="releaseDate">
					<cfset args.today=createDate(variables.$.event('year'),variables.$.event('month'),variables.$.event('day'))>
				<cfelseif variables.$.event('filterBy') eq "releaseMonth">
					<cfset args.type="releaseMonth">
					<cfset args.today=createDate(variables.$.event('year'),variables.$.event('month'),1)>
				<cfelseif variables.$.event('filterBy') eq "releaseYear">
					<cfset args.type="releaseYear">
					<cfset args.today=createDate(variables.$.event('year'),1,1)>
				<cfelse>
					<cfset args.today=now()>
					<cfset args.type="default">
				</cfif>
				<cfset args.categoryid=$.event('categoryid')>

				<cfset variables.maxPortalItems=variables.$.globalConfig("maxPortalItems")>
				<cfif not isNumeric(variables.maxPortalItems)>
					<cfset variables.maxPortalItems=100>
				</cfif>

				<cfif hasPermFilterOption>
					<cfif (
							(not isBoolean(objectparams.applypermfilter) and variables.$.event('r').restrict eq 1)
							or (isBoolean(objectparams.applypermfilter) and objectparams.applypermfilter)
						)>
						<cfset args.applyPermFilter=true/>
					<cfelse>
						<cfset args.applyPermFilter=false/>
					</cfif>
				<cfelse>
					<cfset args.applyPermFilter=isInSecureArea>
				</cfif>

				<cfif not len(objectParams.sortBy)>
					<cfset args.sortBy=$.content('sortBy')>
				</cfif>

				<cfif not len(objectParams.sortDirection)>
					<cfset args.sortDirection=$.content('sortDirection')>
				</cfif>

				<cfset args.parentid=$.content('contentid')>
				<cfset args.siteid=$.content('siteid')>

				<cfif not (structkeyExists(objectParams,'targetattr') and objectParams.targetattr eq 'objectparams') and isNumeric(objectParams.maxItems)>
					<cfset args.size=objectParams.maxItems>
				<cfelse>
					<cfset args.size=variables.maxPortalItems>
					<cfset objectParams.maxItems="">
				</cfif>

				<cfif not isNumeric(args.size) or not args.size or args.size gt variables.maxPortalItems>
					<cfset args.size=variables.maxPortalItems>
				</cfif>
				
				<cfset iterator=$.getBean('contentManager').getKidsIterator(argumentCollection=args)>
				<cfset iterator.setNextN(objectParams.nextN)>
				
				<cfif isBoolean(objectParams.scrollpages) and objectParams.scrollpages or variables.$.event('nextnid') eq objectParams.nextnid>
					<cfif isNumeric(variables.$.event('pageNum')) and variables.$.event('pageNum') gt 1>
						<cfset iterator.setPage(variables.$.event('pageNum'))>
					<cfelseif isNumeric(variables.$.event('startrow')) and variables.$.event('startrow') gt 1>
						<cfset iterator.setStartRow(variables.$.event('startrow'))>
					<cfelse>
						<cfset iterator.setPage(1)>
					</cfif>
				</cfif>

			</cfcase>
			<cfdefaultcase>
				<cfif isValid("uuid",objectParams.source)>
					<cfset objectParams.nextnid=objectParams.source>
				</cfif>
				<cfif not len(objectParams.sortBy)>
					<cfset structDelete(objectParams,'sortby')>
				</cfif>

				<cfif not len(objectParams.sortDirection)>
					<cfset structDelete(objectParams,'sortDirection')>
				</cfif>

				<cfif hasPermFilterOption>
					<cfif isBoolean(objectparams.applypermfilter) and objectparams.applypermfilter>
						<cfset applyPermFilter=true/>
					<cfelse>
						<cfset applyPermFilter=isInSecureArea/>
					</cfif>
					<cfset iterator=$.getBean('feed')
						.loadBy(feedid=objectParams.source)
						.set(objectParams)
						.getIterator(applyPermFilter=applyPermFilter)>
				<cfelse>
					<cfset iterator=$.getBean('feed')
						.loadBy(feedid=objectParams.source)
						.set(objectParams)
						.getIterator(applyPermFilter=isInSecureArea)>
				</cfif>

				<cfset iterator.setNextN(objectParams.nextn)>
				
				<cfif isBoolean(objectParams.scrollpages) and objectParams.scrollpages or variables.$.event('nextnid') eq objectParams.nextnid>
					<cfif isNumeric(variables.$.event('pageNum')) and variables.$.event('pageNum') gt 1>
						<cfset iterator.setPage(variables.$.event('pageNum'))>
					<cfelseif isNumeric(variables.$.event('startrow')) and variables.$.event('startrow') gt 1>
						<cfset iterator.setStartRow(variables.$.event('startrow'))>
					<cfelse>
						<cfset iterator.setPage(1)>
					</cfif>
				</cfif>
				
			</cfdefaultcase>
		</cfswitch>
	</cfsilent>
	<cfoutput>
		<cfif iterator.getRecordCount()>
			#variables.$.dspObject_include(
					theFile='collection/layouts/#objectParams.layout#/index.cfm',
					propertyMap=this.contentGridPropertyMap,
					iterator=iterator,
					objectParams=objectParams
				)#
		<cfelse>
			<cfoutput>#variables.dspObject_include(thefile='collection/includes/dsp_empty.cfm',objectid=objectParams.source,objectParams=objectParams)#</cfoutput>
		</cfif>
	</cfoutput>
	</cfif>
<cfelse>
	<cfoutput>#variables.dspObject_include(thefile='feed/index.cfm',objectid=objectParams.source,objectParams=objectParams)#</cfoutput>
</cfif>
<cfsilent>
<!-- delete params that we don't want to persist --->
<cfset structDelete(objectParams,'categoryid')>
<cfset structDelete(objectParams,'type')>
<cfset structDelete(objectParams,'today')>
<cfset structDelete(objectParams,'tag')>
<cfset structDelete(objectParams,'startrow')>
<cfset structDelete(objectParams,'sortby')>
<cfset structDelete(objectParams,'sortdirection')>
</cfsilent>

<!--- license goes here --->
<cfsilent>
	<cfif not structKeyExists(arguments,"type")>
		<cfset arguments.type="Feed">
	</cfif>

	<cfif not structKeyExists(arguments,"fields")>
		<cfset arguments.fields="Date,Title,Image,Summary,Credits,Tags">
	</cfif>

	<cfset arguments.hasImages=listFindNoCase(arguments.fields,"Image")>

	<cfif arguments.hasImages>
		<cfset arguments.isCustomImage= false />

		<cfif not structKeyExists(arguments,"imageSize") or variables.$.event("muraMobileTemplate")>
			<cfset arguments.imageSize="small">
		<cfelseif not listFindNoCase('small,medium,large,custom',arguments.imagesize)>
			<cfset arguments.customImageSize=getBean('imageSize').loadBy(name=arguments.imageSize,siteID=variables.$.event('siteID'))>
			<cfset arguments.imageWidth= arguments.customImageSize.getWidth() />
			<cfset arguments.imageHeight= arguments.customImageSize.getHeight() />
			<cfset arguments.isCustomImage= true />
		</cfif>


		<cfif not structKeyExists(arguments,"imageHeight")>
			<cfset arguments.imageHeight="auto">
		</cfif>
		<cfif not structKeyExists(arguments,"imageWidth")>
			<cfset arguments.imageWidth="auto">
		</cfif>

		<cfif not structKeyExists(arguments,"modalimages")>
			<cfset arguments.modalimages=false>
		</cfif>

		<cfif not structKeyExists(arguments,"imagePadding")>
			<cfset arguments.imagePadding=20>
		</cfif>

		<cfif this.contentListImageStyles>
			<cfif arguments.isCustomImage>
				<cfset arguments.imageStyles='style="#variables.$.generateListImageSyles(size='custom',width=arguments.imageWidth,height=arguments.imageHeight,padding=arguments.imagePadding)#"'>
			<cfelse>
				<cfset arguments.imageStyles='style="#variables.$.generateListImageSyles(size=arguments.imageSize,width=arguments.imageWidth,height=arguments.imageHeight,padding=arguments.imagePadding)#"'>
			</cfif>
		</cfif>
	<cfelse>
		<cfset arguments.imageStyles="">
	</cfif>
</cfsilent>

 <cfoutput>
 	#variables.$.getContentListPropertyValue('containerEl',"openingOuterMarkUp")#
 	<#variables.$.getContentListPropertyValue('containerEl','tag')# #variables.$.getContentListAttributes('containerEl')#>
 	#variables.$.getContentListPropertyValue('containerEl',"openingInnerMarkUp")#
 </cfoutput>

<cfloop condition="arguments.iterator.hasNext()">
	<cfsilent>
		<cfset arguments.item=arguments.iterator.next()>
		<cfset arguments.class=""/>

		<cfif not arguments.iterator.hasPrevious()>
			<cfset arguments.class=listAppend(arguments.class,"first"," ")/>
		</cfif>

		<cfif not arguments.iterator.hasNext()>
			<cfset arguments.class=listAppend(arguments.class,"last"," ")/>
		</cfif>

		<cfset arguments.hasImage=arguments.hasImages and len(arguments.item.getValue('fileID')) and variables.$.showImageInList(arguments.item.getValue('fileEXT')) or len($.siteConfig('placeholderImgID')) />

		<cfif arguments.hasImage>
			<cfset arguments.class=listAppend(arguments.class,"hasImage"," ")>
		</cfif>
		<cfset hasNonTitle=false>
	</cfsilent>
	<cfoutput>
		#variables.$.getContentListPropertyValue('itemEl','openingOuterMarkUp')#
		<#variables.$.getContentListPropertyValue('itemEl','tag')# #variables.$.getContentListAttributes('itemEl',arguments.class)#<cfif this.contentListImageStyles and arguments.hasImage> #arguments.imageStyles#</cfif>>
			#variables.$.getContentListPropertyValue('itemEL',"openingInnerMarkUp")#
			<cfloop list="#arguments.fields#" index="arguments.field">
				<cfset arguments.field=trim(arguments.field)>
				<!---<cfset metaitemtracepoint=initTracePoint("contentlist:{field:#arguments.field#, title:#arguments.item.get('title')#, contentid:#arguments.item.get('contentid')#, contenthistid:#arguments.item.get('contenthistid')#}")/>--->
				#variables.$.getContentListPropertyValue(arguments.field,"openingOuterMarkUp")#
				<cfswitch expression="#arguments.field#">
					<cfcase value="Date">
						<cfif listFindNoCase("Folder,Portal,Children",arguments.type) and isDate(arguments.item.getValue('releaseDate'))>
							<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field,'releaseDate')#>
							#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
								#variables.$.getContentListLabel(arguments.field)#
								#LSDateFormat(arguments.item.getValue('releaseDate'),variables.$.getLongDateFormat())#<cfset hasNonTitle=true>
							#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
							</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						<cfelseif listFind("Search,Feed,Related",arguments.type) and arguments.item.getValue('parentType') eq 'Calendar' and isDate(arguments.item.getValue('displayStart'))>
							<#variables.$.getContentListPropertyValue(arguments.field,'tag')# class="releaseDate">
								#variables.$.getContentListLabel(arguments.field)#
								<cfif LSDateFormat(arguments.item.getValue('displayStart'),"short") lt LSDateFormat(arguments.item.getValue('displayStop'),"short")>#LSDateFormat(arguments.item.getValue('displayStart'),variables.$.getShortDateFormat())# - #LSDateFormat(arguments.item.getValue('displayStop'),variables.$.getShortDateFormat())#<cfelse>#LSDateFormat(arguments.item.getValue('displayStart'),variables.$.getLongDateFormat())#</cfif><cfset hasNonTitle=true>
							#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
							</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						<cfelseif arguments.type eq "Calendar">
							<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field,'releaseDate')#>
							#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
								#variables.$.getContentListLabel(arguments.field)#
								#arguments.item.getDisplayIntervalDesc(showTitle=this.calendarTitleInDesc)#
								#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
							</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						<cfelseif LSisDate(arguments.item.getValue('releaseDate'))><cfset hasNonTitle=true>
							<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field,'releaseDate')#>
							#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
								#variables.$.getContentListLabel(arguments.field)#
								#LSDateFormat(arguments.item.getValue('releaseDate'),variables.$.getLongDateFormat())#<cfset hasNonTitle=true>
							#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
							</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						</cfif>
					</cfcase>
					<cfcase value="Title">
						<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field)# data-value="#esapiEncode('html_attr',left(arguments.item.getValue(arguments.field),20))#">
						#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
							#variables.$.getContentListLabel(arguments.field)#
							<cfif arguments.type eq "Search" && this.searchShowNumbers eq 1><span class="record-index">#arguments.iterator.getRecordIndex()#.</span> </cfif>
							<a href="#arguments.item.getURL(complete=true)#"<cfif arguments.item.getTarget() eq '_blank'> target="_blank"</cfif>>#HTMLEditFormat(arguments.item.getMenuTitle())#</a>
						#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
						</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
					</cfcase>
					<cfcase value="Image">
						<cfif arguments.hasImage>
						<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field)#>
						#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#<cfset hasNonTitle=true>
							<cfif variables.$.event('muraMobileTemplate')>
							<img src="#arguments.item.getImageURL(size=arguments.imageSize,width=arguments.imageWidth,height=arguments.imageHeight)#"  alt="#htmlEditFormat(arguments.item.getValue('title'))#" loading="lazy"/>
							<cfelseif arguments.modalimages>
							<a href="#arguments.item.getImageURL(size='large')#" title="#HTMLEditFormat(arguments.item.getValue('title'))#" data-rel="shadowbox[gallery]" class="#this.contentListItemImageLinkClass#"><img src="#arguments.item.getImageURL(size=arguments.imageSize,width=arguments.imageWidth,height=arguments.imageHeight)#" alt="#HTMLEditFormat(arguments.item.getValue('title'))#" loading="lazy"/></a>
							<cfelse>
							<a href="#arguments.item.getURL(complete=true)#"<cfif arguments.item.getTarget() eq '_blank'> target="_blank"</cfif> title="#HTMLEditFormat(arguments.item.getValue('title'))#" class="#this.contentListItemImageLinkClass#"><img src="#arguments.item.getImageURL(size=arguments.imageSize,width=arguments.imageWidth,height=arguments.imageHeight)#"  alt="#htmlEditFormat(arguments.item.getValue('title'))#" loading="lazy"/></a>
							</cfif>
						#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
						</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						</cfif>
					</cfcase>
					<cfcase value="Summary">
						<cfif len(arguments.item.getValue('summary')) and arguments.item.getValue('summary') neq "<p></p>">
						 	<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field)#>
						 	#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
						 		#variables.$.getContentListLabel(arguments.field)#
						 		#variables.$.setDynamicContent(arguments.item.getValue('summary'))#<cfset hasNonTitle=true>
						 	#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
						 	</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						</cfif>
					</cfcase>
					<cfcase value="Body">
						<cfif not listFindNoCase('File,Link',arguments.item.getValue('type'))>
							<cfif len(arguments.item.getValue('body')) and arguments.item.getValue('body') neq "<p></p>">
						 		<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field)#>
						 		#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
						 			#variables.$.getContentListLabel(arguments.field)#
						 			#variables.$.setDynamicContent(arguments.item.getValue('body'))#<cfset hasNonTitle=true>
						 		#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
						 		</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
							 </cfif>
						<cfelse>
							 <cfif len(arguments.item.getValue('summary')) and arguments.item.getValue('summary') neq "<p></p>">
						 		<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field)#>
						 		#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
						 			#variables.$.getContentListLabel(arguments.field)#<cfset hasNonTitle=true>
						 			#variables.$.setDynamicContent(arguments.item.getValue('summary'))#
						 		#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
						 		</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						 	</cfif>
						</cfif>
					</cfcase>
					<cfcase value="ReadMore">
					 	<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field,"readMore")#>
					 	#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
					 	#variables.$.addLink(
							type=arguments.item.getValue('type'),
							filename=arguments.item.getValue('filename'),
							title=variables.$.rbKey('list.readmore'),
							target=arguments.item.getValue('target'),
							contentid=arguments.item.getValue('contentID'),
							siteid=arguments.item.getValue('siteID'),
							aHasKidsClass='',
							aHasKidsAttributes='',
							aCurrentClass=this.aContentListCurrentClass,
							aCurrentAttributes=this.aContentListCurrentAttributes,
							aNotCurrentClass=this.aContentListNotCurrentClass
						)#<cfset hasNonTitle=true>
					 	#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
					 	</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
					</cfcase>
					<cfcase value="Credits">
						<cfif len(arguments.item.getValue('credits'))>
						 	<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field)#>
						 	#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
						 		#variables.$.getContentListLabel(arguments.field)#
						 		#HTMLEditFormat(arguments.item.getValue('credits'))#<cfset hasNonTitle=true>
						 	#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
						 	</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						</cfif>
					</cfcase>
					<cfcase value="Comments">
						<cfif not variables.$.event('muraMobileTemplate') and (arguments.item.getValue('type') eq 'Page' or showItemMeta(arguments.item.getValue('type')) or (len(arguments.item.getValue('fileID')) and showItemMeta(arguments.item.getValue('fileEXT')))) >
						 	<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field)#>
						 	#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
						 	#variables.$.addLink(
								type=arguments.item.getValue('type'),
								filename=arguments.item.getValue('filename'),
								title='#variables.$.rbKey("list.comments")# (#variables.$.getBean('contentGateway').getCommentCount(variables.$.event('siteID'),arguments.item.getValue('contentID'))#)',
								target=arguments.item.getValue('target'),
								contentid=arguments.item.getValue('contentID'),
								siteid=arguments.item.getValue('siteID'),
								queryString='##mura-comments',
								aHasKidsClass='',
								aHasKidsAttributes='',
								aCurrentClass=this.aContentListCurrentClass,
								aCurrentAttributes=this.aContentListCurrentAttributes,
								aNotCurrentClass=this.aContentListNotCurrentClass
							)#<cfset hasNonTitle=true>
						 	#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
						 	</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						</cfif>
					</cfcase>
					<cfcase value="Tags">
						<cfif len(arguments.item.getValue('tags'))>
							<cfset arguments.tagLen=listLen(arguments.item.getValue('tags')) />
							<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field)#>
							#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
								#variables.$.getContentListLabel(arguments.field)#
								<cfloop from="1" to="#arguments.tagLen#" index="t">
								<cfset arguments.tag=#trim(listgetAt(arguments.item.getValue('tags'),t))#>
								<a href="#variables.$.createHREF(filename='#variables.$.event('currentFilenameAdjusted')#/tag/#urlEncodedFormat(arguments.tag)#')#">#HTMLEditFormat(arguments.tag)#</a><cfif arguments.tagLen gt t>, </cfif>
								</cfloop><cfset hasNonTitle=true>
							#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
							</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						</cfif>
					</cfcase>
					<cfcase value="Rating">
						<cfif (arguments.item.getValue('type') eq 'Page' or showItemMeta(arguments.item.getValue('type')) or (len(arguments.item.getValue('fileID')) and showItemMeta(arguments.item.getValue('fileEXT'))))>
						 	<#variables.$.getContentListPropertyValue(arguments.field,'tag')# class="rating #application.raterManager.getStarText(arguments.item.getValue('rating'))#">
						 	#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
						 		#variables.$.getContentListLabel(arguments.field)#
						 		<span><cfif isNumeric(arguments.item.getValue('rating'))>#arguments.item.getValue('rating')# star<cfif arguments.item.getValue('rating') gt 1>s</cfif> <cfelse>Zero stars</cfif></span><cfset hasNonTitle=true>
						 	#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
						 	</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						</cfif>
					</cfcase>
					<cfdefaultcase>
						<cfif len(arguments.item.getValue(arguments.field))>
							<!--- sys based dynamic classes are deprecated --->
						 	<#variables.$.getContentListPropertyValue(arguments.field,'tag')# #variables.$.getContentListAttributes(arguments.field)# data-value="#esapiEncode('html_attr',left(arguments.item.getValue(arguments.field),20))#">
						 	#variables.$.getContentListPropertyValue(arguments.field,"openingInnerMarkUp")#
						 			#variables.$.getContentListLabel(arguments.field)#
						 			#HTMLEditFormat(arguments.item.getValue(arguments.field))#<cfset hasNonTitle=true>
						 	#variables.$.getContentListPropertyValue(arguments.field,"closingInnerMarkUp")#
						 	</#variables.$.getContentListPropertyValue(arguments.field,'tag')#>
						</cfif>
					</cfdefaultcase>
				</cfswitch>
				#variables.$.getContentListPropertyValue(arguments.field,"closingOuterMarkUp")#
				<!---<cfset commitTracePoint(metaitemtracepoint)>--->
			</cfloop>
			<cfif isDefined('this.contentListPropertyMap.itemEL.tag') and this.contentListPropertyMap.itemEL.tag eq 'dl' and not hasNonTitle><dd></dd></cfif>
		#variables.$.getContentListPropertyValue('itemEl',"closingInnerMarkUp")#
		</#variables.$.getContentListPropertyValue('itemEl',"tag")#>
		#variables.$.getContentListPropertyValue('itemEl',"closingOuterMarkUp")#
	</cfoutput>
</cfloop>
 <cfoutput>
 	#variables.$.getContentListPropertyValue('containerEl',"closingInnerMarkUp")#
 	</#variables.$.getContentListPropertyValue('containerEl','tag')#>
 	#variables.$.getContentListPropertyValue('containerEl',"closingOuterMarkUp")#
 </cfoutput>

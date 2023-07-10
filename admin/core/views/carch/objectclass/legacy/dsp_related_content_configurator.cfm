<!--- license goes here --->

<cfset $=application.serviceFactory.getBean("muraScope").init(rc.siteID)>
<cfset feed=$.getBean("feed").loadBy(name=createUUID())>
<cfset rc.contentBean = $.getBean('content').loadBy(contentID=rc.contentID, siteID=rc.siteID)>
<cfset subtype = application.classExtensionManager.getSubTypeByName(rc.contentBean.getType(), rc.contentBean.getSubType(), rc.contentBean.getSiteID())>
<cfset relatedContentSets = subtype.getRelatedContentSets()>
<cfset imageSizes=application.settingsManager.getSite(rc.siteid).getCustomImageSizeIterator()>

<cfif isDefined("form.params") and isJSON(form.params)>
	<cfset feed.set(deserializeJSON(form.params))>
<cfelse>
	<cfset feed.setDisplayList("Title")>
</cfif>

<cfoutput>
	<cfif rc.classid eq "related_content">
		<div id="availableObjectParams"
		data-object="#rc.classid#"
		data-name="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.relatedcontent'))#"
		data-objectid="#createUUID()#">
	<cfelse>
		<cfset menutitle=$.getBean("content").loadBy(contentID=rc.contentID).getMenuTitle()>
		<div id="availableObjectParams"
		data-object="#rc.classid#"
		data-name="#esapiEncode('html_attr','#menutitle# - #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.relatedcontent')#')#"
		data-objectid="#hash('related_content')#">
	</cfif>

<!---<cfif rc.classid eq "related_content">
<h2>#esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.relatedcontent'))#</h2>
	<cfelse>
		<h2>#esapiEncode('html','#menutitle# - #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.relatedcontent')#')#</h2>
	</cfif>
--->
	<div class="mura-layout-row">
		<cfif rc.classid eq "related_content">
			<div class="mura-control-group">
				<label>
					Related Content Set
				</label>
					<select name="relatedContentSetName" class="objectParam">
						<option value=""<cfif feed.getRelatedContentSetName() eq ""> selected</cfif>>All</option>
						<cfloop from="1" to="#arrayLen(relatedContentSets)#" index="s">
							<cfset rcsBean = relatedContentSets[s]/>
							<option value="#rcsBean.getName()#"<cfif feed.getRelatedContentSetName() eq rcsBean.getName()> selected</cfif>>#rcsBean.getName()#</option>
						</cfloop>
					</select>
			</div>
		</cfif>

		<div class="mura-control-group">
    	<label>#application.rbFactory.getKeyValue(session.rb,'collections.imagesize')#</label>
			<select name="imageSize" data-displayobjectparam="imageSize" class="objectParam" onchange="if(this.value=='custom'){jQuery('##feedCustomImageOptions').fadeIn('fast')}else{jQuery('##feedCustomImageOptions').hide();jQuery('##feedCustomImageOptions').find(':input').val('AUTO');}">
				<cfloop list="Small,Medium,Large" index="i">
					<option value="#lcase(i)#"<cfif i eq feed.getImageSize()> selected</cfif>>#I#</option>
				</cfloop>
				<cfloop condition="imageSizes.hasNext()">
					<cfset image=imageSizes.next()>
					<option value="#lcase(image.getName())#"<cfif image.getName() eq feed.getImageSize()> selected</cfif>>#esapiEncode('html',image.getName())#</option>
				</cfloop>
					<option value="custom"<cfif "custom" eq feed.getImageSize()> selected</cfif>>Custom</option>
			</select>
		</div>	

		<div id="feedCustomImageOptions"<cfif feed.getImageSize() neq "custom"> style="display:none"</cfif>>
			<div class="mura-control-group half">		
				<label>#application.rbFactory.getKeyValue(session.rb,'collections.imagewidth')#
			      </label>
				<input class="objectParam" name="imageWidth" data-displayobjectparam="imageWidth" type="text" value="#feed.getImageWidth()#" />
			</div>	
			<div class="mura-control-group half">		
			    <label>#application.rbFactory.getKeyValue(session.rb,'collections.imageheight')#</label>
			    <input class="objectParam" name="imageHeight" data-displayobjectparam="imageHeight" type="text" value="#feed.getImageHeight()#" />
			</div>	
		</div>

		<cfif rc.classid neq "related_content">
			<div class="mura-control-group">
				<label>
					#application.rbFactory.getKeyValue(session.rb,'collections.sortby')#
				</label>
				<select name="sortBy" class="objectParam">
					<option value="lastUpdate" <cfif feed.getsortBy() eq 'lastUpdate'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.lastupdate')#</option>
					<option value="releaseDate" <cfif feed.getsortBy() eq 'releaseDate'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.releasedate')#</option>
					<option value="displayStart" <cfif feed.getsortBy() eq 'displayStart'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.startdatetime')#</option>
					<option value="menuTitle" <cfif feed.getsortBy() eq 'menuTitle'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.menutitle')#</option>
					<option value="title" <cfif feed.getsortBy() eq 'title'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.longtitle')#</option>
					<!---
					<option value="rating" <cfif feed.getsortBy() eq 'rating'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.rating')#</option>
					<option value="comments" <cfif feed.getsortBy() eq 'comments'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.comments')#</option>
					--->
					<option value="created" <cfif feed.getsortBy() eq 'created'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.created')#</option>
					<option value="orderno" <cfif feed.getsortBy() eq 'orderno'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.orderno')#</option>
					<!---
					<option value="random" <cfif feed.getsortBy() eq 'random'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.random')#</option>

					<cfloop query="rsExtend"><option value="#esapiEncode('html_attr',rsExtend.attribute)#" <cfif feed.getsortBy() eq rsExtend.attribute>selected</cfif>>#rsExtend.Type#/#rsExtend.subType# - #rsExtend.attribute#</option>
					</cfloop>
				--->
				</select>
			</div>

			<div class="mura-control-group">
				<label>
					#application.rbFactory.getKeyValue(session.rb,'collections.sortdirection')#
				</label>
				<select name="sortDirection" class="objectParam">
					<option value="asc" <cfif feed.getsortDirection() eq 'asc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'collections.ascending')#</option>
					<option value="desc" <cfif feed.getsortDirection() eq 'desc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'collections.descending')#</option>
				</select>
			</div>
		</cfif>

		<div class="mura-control-group" id="availableFields">
			<label>
				<span class="half">Available Fields</span> <span class="half">Selected Fields</span>
			</label>
			<div class="sortableFields">
				<p class="dragMsg">
					<span class="dragFrom half">Drag Fields from Here&hellip;</span><span class="half">&hellip;and Drop Them Here.</span>
				</p>

				<cfset displayList=feed.getDisplayList()>
				<cfset availableList=feed.getAvailableDisplayList()>

						<ul id="availableListSort" class="displayListSortOptions">
							<cfloop list="#availableList#" index="i">
								<li class="ui-state-default">#trim(i)#</li>
							</cfloop>
						</ul>
						<ul id="displayListSort" class="displayListSortOptions">
							<cfloop list="#displayList#" index="i">
								<li class="ui-state-highlight">#trim(i)#</li>
							</cfloop>
						</ul>

				<input type="hidden" id="displayList" class="objectParam " value="#displayList#" name="displayList"/>
			</div>
		</div>

	</div> <!--- /.mura-layout-row --->
</div> <!--- /availableObjectParams --->
</cfoutput>

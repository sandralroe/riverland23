<!--- license goes here --->

<cfset $=application.serviceFactory.getBean("muraScope").init(rc.siteID)>
<cfparam name="rc.feedid" default="#rc.objectid#">
<cfset feed=$.getBean("feed").loadBy(feedID=rc.feedID)>

<cfif isDefined("form.params") and isJSON(form.params)>
	<cfset feed.set(deserializeJSON(form.params))>
</cfif>

<cfset data=structNew()>
<cfsavecontent variable="data.html">
<cfoutput>

	<cfif feed.getType() eq "local">
	<div id="availableObjectParams"
	data-object="feed"
	data-name="#esapiEncode('html_attr','#feed.getName()# - #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.localindex')#')#"
	data-objectid="#feed.getFeedID()#">
	<cfelse>
	<div id="availableObjectParams"
	data-object="feed"
	data-name="#esapiEncode('html_attr','#feed.getName()# - #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remotefeed')#')#"
	data-objectid="#feed.getFeedID()#">
	</cfif>

	<h2>#esapiEncode('html',feed.getName())#</h2>
	<cfif rc.configuratorMode eq "frontEnd"
				and application.permUtility.getDisplayObjectPerm(feed.getSiteID(),"feed",feed.getFeedD()) eq "editor">
		<cfsilent>
			<cfset editlink = "?muraAction=cFeed.edit">
			<cfset editlink = editlink & "&amp;siteid=" & feed.getSiteID()>
			<cfset editlink = editlink & "&amp;feedid=" & feed.getFeedID()>
			<cfset editlink = editlink & "&amp;type=" & feed.getType()>
			<cfset editlink = editlink & "&amp;homeID=" & rc.homeID>
			<cfset editlink = editlink & "&amp;compactDisplay=true">
		</cfsilent>
		<ul class="navTask nav nav-pills">
			<li><a href="#editlink#">#application.rbFactory.getKeyValue(session.rb,'collections.editdefaultsettings')#</a></li>
		</ul>
	</cfif>
	<cfif feed.getType() eq "local">
		<div class="mura-layout-row">
			<div class="mura-control-group">
		      	<label>#application.rbFactory.getKeyValue(session.rb,'collections.imagesize')#</label>
				<select name="imageSize" data-displayobjectparam="imageSize" class="objectParam" onchange="if(this.value=='custom'){jQuery('##feedCustomImageOptions').fadeIn('fast')}else{jQuery('##feedCustomImageOptions').hide();jQuery('##feedCustomImageOptions').find(':input').val('AUTO');}">
					<cfloop list="Small,Medium,Large" index="i">
						<option value="#lcase(i)#"<cfif i eq feed.getImageSize()> selected</cfif>>#I#</option>
					</cfloop>

					<cfset imageSizes=application.settingsManager.getSite(rc.siteid).getCustomImageSizeIterator()>

					<cfloop condition="imageSizes.hasNext()">
						<cfset image=imageSizes.next()>
						<option value="#lcase(image.getName())#"<cfif image.getName() eq feed.getImageSize()> selected</cfif>>#esapiEncode('html',image.getName())#</option>
					</cfloop>
						<option value="custom"<cfif "custom" eq feed.getImageSize()> selected</cfif>>Custom</option>
				</select>
			</div>

			<div id="feedCustomImageOptions" class=""<cfif feed.getImageSize() neq "custom"> style="display:none"</cfif>>
				<div class="mura-control-group half">			
					<label>#application.rbFactory.getKeyValue(session.rb,'collections.imagewidth')#</label>
					<input class="objectParam" name="imageWidth" data-displayobjectparam="imageWidth" type="text" value="#feed.getImageWidth()#" />
				</div>
				<div class="mura-control-group half">			
					<label>#application.rbFactory.getKeyValue(session.rb,'collections.imageheight')#</label>
					<input class="objectParam" name="imageHeight" data-displayobjectparam="imageHeight" type="text" value="#feed.getImageHeight()#" />
				</div>
			</div>

			<div class="mura-control-group">
				<label>#application.rbFactory.getKeyValue(session.rb,'collections.displayname')#</label>
				<label class="radio inline">
				<input name="displayName" data-displayobjectparam="displayName" type="radio" value="1" class="objectParam radio" onchange="jQuery('##altNameContainer').toggle();"<cfif feed.getDisplayName()>checked</cfif>>
					#application.rbFactory.getKeyValue(session.rb,'collections.yes')#
				</label>
				<label class="radio inline">
				<input name="displayName" data-displayobjectparam="displayName" type="radio" value="0" class="objectParam radio" onchange="jQuery('##altNameContainer').toggle();" <cfif not feed.getDisplayName()>checked</cfif>>
				#application.rbFactory.getKeyValue(session.rb,'collections.no')#
				</label>
			</div>
			<div id="altNameContainer" class="mura-control-group"<cfif NOT feed.getDisplayName()> style="display:none;"</cfif>>
				<label>#application.rbFactory.getKeyValue(session.rb,'collections.altname')#</label>
				<input class="objectParam" name="altName" data-displayobjectparam="altName" type="text" value="#esapiEncode('html_attr',feed.getAltName())#" maxlength="250">
			</div>

			<div class="mura-control-group">
				<label>
					#application.rbFactory.getKeyValue(session.rb,'collections.cssclass')#
				</label>
				<input name="cssclass" class="objectParam" type="text" value="#esapiEncode('html_attr',feed.getCssClass())#" maxlength="255">
			</div>

			<div class="mura-control-group">
				<label>
					#application.rbFactory.getKeyValue(session.rb,'collections.viewalllink')#
				</label>
				<input name="viewalllink" class="objectParam" type="text" value="#esapiEncode('html_attr',feed.getViewAllLink())#" maxlength="255">
				<label>
					#application.rbFactory.getKeyValue(session.rb,'collections.viewalllabel')#
				</label>
				<input name="viewalllabel" class="objectParam" type="text" value="#esapiEncode('html_attr',feed.getViewAllLabel())#" maxlength="100">
			</div>

			<div class="mura-control-group">
				<label>#application.rbFactory.getKeyValue(session.rb,'collections.maxitems')#</label>
					<select name="maxItems" data-displayobjectparam="maxItems" class="objectParam">
					<cfloop list="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,50,100" index="m">
					<option value="#m#" <cfif feed.getMaxItems() eq m>selected</cfif>>#m#</option>
					</cfloop>
					<option value="100000" <cfif feed.getMaxItems() eq 100000>selected</cfif>>All</option>
				</select>
			    <label>#application.rbFactory.getKeyValue(session.rb,'collections.itemsperpage')#</label>
				<select name="nextN" data-displayobjectparam="nextN" class="objectParam">
					<cfloop list="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,50,100" index="r">
					<option value="#r#" <cfif r eq feed.getNextN()>selected</cfif>>#r#</option>
					</cfloop>
					<option value="100000" <cfif feed.getNextN() eq 100000>selected</cfif>>All</option>
				</select>
			</div>
			<div class="mura-control-group" id="availableFields">
				<label>
					<span class="half">Available Fields</span> <span class="half">Selected Fields</span>
				</label>
				<div id="sortableFields">
					<p class="dragMsg">
						<span class="dragFrom half">Drag Fields from Here&hellip;</span><span class="half">&hellip;and Drop Them Here.</span>
					</p>

					<cfset displayList=feed.getDisplayList()>
					<cfset availableList=feed.getAvailableDisplayList()>
					<div class="half">
						<ul id="availableListSort" class="displayListSortOptions">
							<cfloop list="#availableList#" index="i">
								<li class="ui-state-default">#trim(i)#</li>
							</cfloop>
						</ul>
					</div>
					<div class="half">
						<ul id="displayListSort" class="displayListSortOptions">
							<cfloop list="#displayList#" index="i">
								<li class="ui-state-highlight">#trim(i)#</li>
							</cfloop>
						</ul>
					</div>

					<input type="hidden" id="displayList" class="objectParam" value="#displayList#" name="displayList"  data-displayobjectparam="displayList"/>
				</div>
			</div>
		</div>
	<cfelse>
		<div class="mura-layout-row">
			<div class="mura-control-group">
			<cfset displaySummaries=yesNoFormat(feed.getValue("displaySummaries"))>
				<label>
					#application.rbFactory.getKeyValue(session.rb,'collections.displaysummaries')#
				</label>
				<label class="radio inline">
					<input name="displaySummaries" type="radio" value="1" class="objectParam radio" onchange="jQuery('##altNameContainer').toggle();"<cfif displaySummaries>checked</cfif>>
					#application.rbFactory.getKeyValue(session.rb,'collections.yes')#
				</label>
				<label class="radio inline">
					<input name="displaySummaries" type="radio" value="0" class="objectParam radio" onchange="jQuery('##altNameContainer').toggle();" <cfif not displaySummaries>checked</cfif>>
					#application.rbFactory.getKeyValue(session.rb,'collections.no')#
				</label>
			</div>
			<div class="mura-control-group">
				<label>
					#application.rbFactory.getKeyValue(session.rb,'collections.viewalllink')#
				</label>
				<input name="viewalllink" class="objectParam" type="text" value="#esapiEncode('html_attr',feed.getViewAllLink())#" maxlength="255">
				<label>
					#application.rbFactory.getKeyValue(session.rb,'collections.viewalllabel')#
				</label>
				<input name="viewalllabel" class="objectParam" type="text" value="#esapiEncode('html_attr',feed.getViewAllLabel())#" maxlength="100">
			</div>
		</div>
	</cfif>
</div> <!--- /availableObjectParams --->
</cfoutput>
</cfsavecontent>
<cfset data.type=feed.getType()>
<cfoutput>#serializeJSON(data)#</cfoutput>
<cfabort>

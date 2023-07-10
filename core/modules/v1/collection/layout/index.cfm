 <!--- license goes here --->
<cfsilent>
<cfset collectionDefaultLayout=rc.$.getContentRenderer().collectionDefaultLayout>
<cfparam name="objectParams.maxitems" default="4">
<cfparam name="objectParams.source" default="">
<cfparam name="objectParams.layout" default="#collectionDefaultLayout#">
<cfparam name="objectParams.forcelayout" default="false">
<cfparam name="objectParams.sortby" default="Title">
<cfparam name="objectParams.sortdirection" default="ASC">
<cfparam name="objectParams.object" default="">
<cfparam name="objectParams.scrollpages" default="false">

<cfif not rc.$.siteConfig('isRemote') and rc.$.siteConfig('extranet')>
	<cfset 
		rc.$.event(
			'r',
			rc.$.getBean('permUtility').setRestriction(
				$.content().getCrumbArray()
			)
		)>
	<cfset hasPermFilterOption=not rc.$.event('r').restrict>
	<cfif hasPermFilterOption>
		<cfparam name="objectParams.applypermfilter" default="false">
	</cfif>
<cfelse>
	<cfset hasPermFilterOption=false>
</cfif>
<cfif not isDefined('objectParams.displayList')>
	<cfset renderer=rc.$.siteConfig().getContentRenderer()>
	<cfif isDefined('renderer.defaultCollectionDisplayList')>
		<cfset objectParams.displayList=renderer.defaultCollectionDisplayList>
	<cfelse>
		<cfset objectParams.displayList="Image,Date,Title,Summary,Credits,Tags">
	</cfif>
</cfif>

<cfset feed=rc.$.getBean("feed").loadBy(feedID=objectParams.source)>
<cfset feed.set(objectParams)>
<cfset Mura=rc.$>

<cfparam name="objectParams.sourcetype" default="local">
<cfparam name="objectParams.render" default="server">
<cfparam name="objectParams.async" default="false">

<cfset isExternal=false>
</cfsilent>
<cfoutput>
	<cfif objectParams.sourcetype neq "remotefeed">
		<cfset isExternal=false>
		<cfif $.siteConfig().hasDisplayObject(objectParams.layout)>
			<cfset isExternal= $.siteConfig().getDisplayObject(objectParams.layout).external>
		<cfelseif objectparams.layout eq 'default'>
			<cfset isExternal= $.siteConfig().hasDisplayObject(collectionDefaultLayout) and $.siteConfig().getDisplayObject(collectionDefaultLayout).external>
			
			<cfif isExternal>
				<cfset feed.setLayout(collectionDefaultLayout)>
			</cfif>

		</cfif>
		<cfif not objectParams.forcelayout>
			<div class="mura-control-group">
				<label class="mura-control-label">
					#application.rbFactory.getKeyValue(session.rb,'collections.layout')#
				</label>
				<cfset layouts=rc.$.siteConfig().getLayouts('collection/layouts')>
				<cfset layout=feed.getLayout()>
				<cfset layout=(len(layout)) ? layout : collectionDefaultLayout>
				<select name="layoutSel" id="layoutSel">
					<cfloop query="layouts">
						<cfif layouts.name eq collectionDefaultLayout>
						<option value="#layouts.name#"<cfif feed.getLayout() eq layouts.name> selected</cfif>>#reReplace(layouts.name, "\b([a-zA-Z])(\w{2,})\b", "\U\1\E\2", "all")#</option>
						</cfif>
					</cfloop>
					<cfloop query="layouts">
						<cfif layouts.name neq collectionDefaultLayout>
						<option value="#layouts.name#"<cfif feed.getLayout() eq layouts.name> selected</cfif>>#reReplace(layouts.name, "\b([a-zA-Z])(\w{2,})\b", "\U\1\E\2", "all")#</option>
						</cfif>
					</cfloop>
				</select>
			</div>
		</cfif>

		<cfset layout=feed.getLayout()>
		<cfset layout=(len(layout)) ? layout :' default'>
		<input type="hidden" name="layout" class="objectParam" value="#esapiEncode('html_attr',layout)#">

		<!---- Begin layout based configuration --->
		<cfif isExternal>
			<cfscript>
				configuratorMarkup='';
				objectConfig=$.siteConfig().getDisplayObject(layout);
				if(isValid("url", objectConfig.configurator)){
					httpService=application.configBean.getHTTPService();
					httpService.setMethod("get");
					httpService.setCharset("utf-8");
					httpService.setURL(objectConfig.configurator);
					configuratorMarkup=httpService.send().getPrefix().filecontent;
				} else {
					configuratorMarkup=objectConfig.configurator;
				}
			
				if(isJSON(configuratorMarkup)){
					configuratorMarkup=deserializeJSON(configuratorMarkup);
				}
			</cfscript>
			<cfif isArray(configuratorMarkup) or isSimpleValue(configuratorMarkup) and len(configuratorMarkup)>
				<cfif isArray(configuratorMarkup)>
					<cfset request.associatedImageURL=Mura.content().getImageURL(complete=Mura.siteConfig('isRemote'))>
					<cfimport prefix="ui" taglib="../../../../mura/customtags/configurator/ui">
					<cfloop from="1" to="#arrayLen(configuratorMarkup)#" index="idx">
						<cfif structKeyExists(configuratorMarkup[idx],'name') and configuratorMarkup[idx].name neq 'label'>
							<cfset params=configuratorMarkup[idx]>
							<cfset params.instanceid=objectparams.instanceid>
							<cfset params.contentid=Mura.content('contentid')>
							<cfset params.contenthistid=Mura.content('contenthistid')>
							<cfset params.siteid=Mura.content('siteid')>
							<cfif structKeyExists(objectparams,params.name)>
								<cfset params.value=objectparams[params.name]>
							</cfif>
							<ui:param attributecollection="#configuratorMarkup[idx]#">
						</cfif>
					</cfloop>
				<cfelse>
					<cfoutput>#configuratorMarkup#</cfoutput>
				</cfif>
			</cfif>
			<input name="render" type="hidden" class="objectParam" value="client">
		<cfelse>
			<input name="render" type="hidden" class="objectParam" value="server">
			<cfset configFile=rc.$.siteConfig().lookupDisplayObjectFilePath('collection/layouts/#layout#/configurator.cfm')>
			<cfif fileExists(expandPath(configFile))>
				<cfinclude template="#configFile#">
			<cfelse>
				<cfset configFile=rc.$.siteConfig('includePath') & "/includes/display_objects/custom/collection/layouts/#layout#/configurator.cfm">
				<cfif fileExists(expandPath(configFile))>
					<cfinclude template="#configFile#">
				<cfelse>
					<cfset configFile=rc.$.siteConfig('includePath') & "/includes/display_objects/collection/layouts/#layout#/configurator.cfm">
					<cfif fileExists(expandPath(configFile))>
						<cfinclude template="#configFile#">
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		<script>
			$(function(){
				$('##layoutSel').on('change',function() {
					$('input[name="layout"]').val($('##layoutSel').val())
					setLayoutOptions();
				});
				if(typeof configuratorInited != 'undefined'){
					$('input[name="render"]').trigger('change');
				}
				configuratorInited=true;
			});
		</script>
		<!---  End layout based configuration --->
		<cfif objectParams.object neq 'folder'>
			<cfif not isExternal and objectparams.sourcetype eq "collection">
			<div class="mura-control-group container-viewalllink">
				<label class="mura-control-label">
					#application.rbFactory.getKeyValue(session.rb,'collections.viewalllink')#
				</label>
				<input name="viewalllink" class="objectParam" type="text" value="#esapiEncode('html_attr',feed.getViewAllLink())#" maxlength="255">
			</div>
			<div class="mura-control-group">
				<label class="mura-control-label container-viewalllabel">
					#application.rbFactory.getKeyValue(session.rb,'collections.viewalllabel')#
				</label>
				<input name="viewalllabel" class="objectParam" type="text" value="#esapiEncode('html_attr',feed.getViewAllLabel())#" maxlength="100">
			</div>
			</cfif>
			<div class="mura-control-group">
				<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'collections.maxitems')#</label>
				<select name="maxItems" data-param="maxItems" class="objectParam">
					<cfloop list="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,50,100" index="m">
					<option value="#m#" <cfif feed.getMaxItems() eq m>selected</cfif>>#m#</option>
					</cfloop>
					<option value="100000" <cfif feed.getMaxItems() eq 100000>selected</cfif>>All</option>
				</select>
			</div>
			<div class="mura-control-group container-nextn">
			    <label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'collections.itemsperpage')#</label>
				<select name="nextN" data-param="nextN" class="objectParam">
					<cfloop list="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,50,100" index="r">
					<option value="#r#" <cfif r eq feed.getNextN()>selected</cfif>>#r#</option>
					</cfloop>
					<option value="100000" <cfif feed.getNextN() eq 100000>selected</cfif>>All</option>
				</select>
			</div>
			<div class="mura-control-group">
				<label>Auto Scroll Pages</label>
				<select name="scrollpages" data-param="scrollpages" class="objectParam">
					<cfloop list="True,False" index="i">
						<option value="#lcase(i)#"<cfif objectparams.scrollpages eq i> selected</cfif>>#i#</option>
					</cfloop>
				</select>
			</div>
		  </div>
			<cfif objectparams.sourcetype eq "relatedcontent" and objectparams.source eq 'reverse'>
				<div class="mura-control-group">
					<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'collections.sortby')#</label>
					<select name="sortby" class="objectParam">
					<option value="orderno" <cfif objectparams.sortby eq 'orderno'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.manual")#</option>
					<option value="releaseDate" <cfif objectparams.sortby eq 'releaseDate'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.releasedate")#</option>
					<option value="lastUpdate" <cfif objectparams.sortby eq 'lastUpdate'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.updatedate")#</option>
					<option value="created" <cfif objectparams.sortby eq 'created'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.created")#</option>
					<option value="menuTitle" <cfif objectparams.sortby eq 'menuTitle'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.menutitle")#</option>
					<option value="title" <cfif objectparams.sortby eq 'title'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.longtitle")#</option>
					<option value="rating" <cfif objectparams.sortby eq 'rating'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.rating")#</option>
					<cfif rc.$.getServiceFactory().containsBean('marketingManager')>
						<option value="mxpRelevance" <cfif objectparams.sortby eq 'mxpRelevance'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.mxpRelevance')#</option>
					</cfif>
					<option value="comments" <cfif objectparams.sortby eq 'comments'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.comments")#</option>
					<cfset rsExtend=application.configBean.getClassExtensionManager().getExtendedAttributeList(rc.siteid)>
					<cfloop query="rsExtend">
					  <option value="#esapiEncode('html_attr',rsExtend.attribute)#" <cfif objectparams.sortby eq rsExtend.attribute>selected</cfif>>#esapiEncode('html',rsExtend.Type)#/#esapiEncode('html',rsExtend.subType)# - #esapiEncode('html',rsExtend.attribute)#</option>
					</cfloop>
					</select>
				</div>
				<div class="mura-control-group sort-container" style="display:none">
					<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'collections.sortdirection')#</label>
					<select name="sortdirection" class="sort-param">
						<option value="asc" <cfif objectparams.sortDirection eq 'asc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.ascending")#</option>
						<option value="desc" <cfif objectparams.sortDirection  eq 'desc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.descending")#</option>
					</select>
				</div>
			</cfif>
		</cfif>
		<cfif hasPermFilterOption>
			<div class="mura-control-group">
				<label class="mura-control-label">Apply Permission Filter</label>
				<select name="applypermfilter" data-param="applypermfilter" class="objectParam">
					<option value="true" <cfif isBoolean(objectparams.applypermfilter) and objectparams.applypermfilter>selected</cfif>>True</option>
					<option value="false" <cfif  not isBoolean(objectparams.applypermfilter) or not objectparams.applypermfilter>selected</cfif>>False</option>
				</select>
			</div>
		<cfelse>
			<input type="hidden" name="applypermfilter" class="objectParam" value=""/>
		</cfif>
	<cfelse>
		<!--- REMOTE FEEDS --->
		<input name="render" type="hidden" class="objectParam" value="server"/>
		<cfset displaySummaries=yesNoFormat(feed.getValue("displaySummaries"))>
		<div class="mura-control-group">
			<label class="mura-control-label">
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
			<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'collections.maxitems')#</label>
			<select name="maxItems" data-param="maxItems" class="objectParam">
				<cfloop list="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,50,100" index="m">
				<option value="#m#" <cfif feed.getMaxItems() eq m>selected</cfif>>#m#</option>
				</cfloop>
				<option value="100000" <cfif feed.getMaxItems() eq 100000>selected</cfif>>All</option>
			</select>
		</div>
		<div class="mura-control-group">
				<label class="mura-control-label">
					#application.rbFactory.getKeyValue(session.rb,'collections.viewalllink')#
				</label>
				<input name="viewalllink" class="objectParam" type="text" value="#esapiEncode('html_attr',feed.getViewAllLink())#" maxlength="255">
			</div>
		</div>
		<div class="mura-control-group">
			<label class="mura-control-label">
				#application.rbFactory.getKeyValue(session.rb,'collections.viewalllabel')#
			</label>
			<input name="viewalllabel" class="objectParam" type="text" value="#esapiEncode('html_attr',feed.getViewAllLabel())#" maxlength="100">
		</div>
		
</cfif>
</cfoutput>

<!--- license goes here --->
<cfimport prefix="ui" taglib="../../../mura/customtags/configurator/ui">

<cfif rc.layoutmanager>
	<cfscript>
		categories=Mura.getFeed('category')
			.where()
			.sort('filename')
			.getIterator();
		categoryOptions=[];
	
		if(categories.hasNext()){
			while(categories.hasNext()){
				category=categories.next();
				arrayAppend(
					categoryOptions,
					{
						name=category.get('filename'),
						value=category.get('categoryid')
					}
				);
			}
		}

		//search bar
		searchBarOptions=[{name="Yes",value="true"},{name="No",value="false"}];
	</cfscript>
	<cfsilent>
		<cfset content=rc.$.getBean('content').loadBy(contenthistid=rc.contenthistid)>
		<cfset content.set(objectParams)>
		<cfparam name="objectParams.items" default="#arrayNew(1)#">
		<cfparam name="objectParams.viewoptions" default="">
		<cfparam name="objectParams.format" default="calendar">
		<cfparam name="objectParams.forcelayout" default="false">
		<cfparam name="objectParams.categoryids" default="">
		<cfparam name="objectParams.searchBar" default="false">

		<cfif not len(objectParams.viewoptions)>
			<cfset objectParams.viewoptions='dayGridMonth,dayGridWeek,dayGridDay,timeGridWeek,timeGridDay,listMonth,listWeek'>
		</cfif>

		<cfparam name="objectParams.viewdefault" default="">

		<cfif not len(objectParams.viewdefault)>
			<cfset objectParams.viewdefault='dayGridMonth'>
		</cfif>

		<cfset objectParams.source=content.getContentID()>
		<cfset objectParams.sourcetype='calendar'>

	</cfsilent>
	
	<cf_objectconfigurator>
    <cfoutput>
	<div id="availableObjectParams"
		data-object="calendar"
		data-name="Calendar"
		data-objectid="#esapiEncode('html_attr',rc.contentid)#"
		data-forcelayout="#esapiEncode('html_attr',objectParams.forcelayout)#">

		<cfif rc.$.getBean('configBean').getClassExtensionManager().getSubTypeByName(content.get('type'),content.get('subtype'),content.get('siteid')).getHasConfigurator()>
		<div class="mura-layout-row">
			<div class="mura-control-group">
				<label>
					#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.format')#
				</label>
				<select id="formatselector" name="format" class="objectParam">
					<cfloop list="Calendar,List" index="i">
						<option name="#i#"<cfif objectparams.format eq i> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.#i#')#</option>
					</cfloop>
				</select>
			</div>
			<div class="mura-control-group">
				<label>#application.rbFactory.getKeyValue(session.rb,'calendar.additionalcalendars')#</label>
				<button class="btn" id="editBtnRelatedContent"><i class="mi-pencil"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.edit')#</button>
				<cfif arrayLen(objectParams.items)>
				<cfset calendars=rc.$.getFeed('content')
					.setContentPoolID(rc.$.siteConfig('contentpoolid'))
					.setShowNavOnly(0)
					.setShowExcludeSearch(1)
					.where()
					.prop('contentid').isIn(arrayToList(objectParams.items))
					.getIterator()>
				<ul class="configurator-options">
				<cfloop array="#objectParams.items#" index="i">
					<cfset found=false>
					<cfif i neq content.getContentID()>
						<cfset calendars.reset()>
						<cfloop condition="calendars.hasNext()">
							<cfset item=calendars.next()>
							<cfif item.get('contentid') eq i>
								<cfset found=true>
								<cfbreak>
							</cfif>
						</cfloop>
						<cfif found>
							<li><a href="#item.getURL(complete=true)#" target="_top">#esapiEncode('html',item.getMenuTitle())#</a></li>
						</cfif>
					</cfif>
				</cfloop>
				</ul>
				<cfelse>
				<div class="help-block-empty">#application.rbFactory.getKeyValue(session.rb,'calendar.noadditional')#</div>
				</cfif>
			</div>

			<div id="calendarformatoptions" style="display:none">
				<div class="mura-control-group">
					<label>
						#application.rbFactory.getKeyValue(session.rb,'calendar.availableviews')#
					</label>
					<ul class="configurator-options">
					<cfloop list="dayGridMonth,dayGridWeek,dayGridDay,timeGridWeek,timeGridDay,listMonth,listWeek" index="i">
					<li><label class="checkbox">
						<input type="checkbox" class="objectParam" name="viewoptions" value="#i#" <cfif listFindNoCase(objectParams.viewoptions,i)> checked</cfif>/> #m.rbKey('calendar.#i#')#</label></li>
                    </cfloop>
					</ul>
				</div>
				<div class="mura-control-group">
					<label>
						#application.rbFactory.getKeyValue(session.rb,'calendar.defaultview')#
					</label>
					<select name="viewdefault" class="objectParam">
					<cfloop list="dayGridMonth,dayGridWeek,dayGridDay,timeGridWeek,timeGridDay,listMonth,listWeek" index="i">
						<option value="#i#" <cfif objectParams.viewdefault eq i> selected</cfif>> #m.rbKey('calendar.#i#')#</option>
					</cfloop>
					</select>
				</div>

			<input type="hidden" class="objectParam" name="items" id="items" value="#esapiEncode('html_attr',serializeJSON(objectParams.items))#">
		</div>

		<div id="listformatoptions" style="display:none">
				<div id="layoutcontainer"></div>
				<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,'collections.itemsperpage')#</label>
					<select name="nextn" data-displayobjectparam="nextn" class="objectParam">
					<cfloop list="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,50,100" index="r">
						<option value="#r#" <cfif r eq content.getNextN()>selected</cfif>>#r#</option>
						</cfloop>
						<option value="100000" <cfif content.getNextN() eq 100000>selected</cfif>>All</option>
					</select>
				</div>
			</div>
		</div>
		<!---
		<div id="categories">
			<cfif arrayLen(categoryOptions)>
				<ui:dispenser name="categoryids" label="Categories" options="#categoryOptions#" value="#objectparams.categoryids#">
			</cfif>
		</div>
		<div id="searchBar">
			<ui:radio label="Search Bar" name="searchBar" options="#searchBarOptions#" value="#objectParams.searchBar#" >
		</div>
		--->
	</div>
	<script>
		$(function(){

			function setOptionDisplay(){
				if($('##formatselector').val().toLowerCase()=='list'){
					$('##listformatoptions').show();
					$('##calendarformatoptions').hide();
				} else {
					$('##listformatoptions').hide();
					$('##calendarformatoptions').show();
				}
			}

			$('##formatselector').change(setOptionDisplay);

			$('##editBtnRelatedContent').click(function(){
				frontEndProxy.post({
					cmd:'openModal',
					src:'?muraAction=cArch.relatedcontent&siteid=#esapiEncode("url",rc.siteid)#&contenthistid=#esapiEncode("url",rc.contenthistid)#&instanceid=#esapiEncode("url",rc.instanceid)#&compactDisplay=true&relatedcontentsetid=calendar&items=#esapiEncode("url",serializeJSON(objectparams.items))#'
					}
				);

			});

			setColorPickers(".mura-colorpicker");
			setOptionDisplay();

			setLayoutOptions=function(){

				siteManager.updateAvailableObject();

				siteManager.availableObject.params.source = siteManager.availableObject.params.source || '';

				var params=siteManager.availableObject.params;

				$.ajax(
					{
					type: 'post',
					dataType: 'text',
					url: './?muraAction=cArch.loadclassconfigurator&compactDisplay=true&siteid=' + configOptions.siteid + '&instanceid=#esapiEncode("url",rc.instanceid)#&classid=calendar&contentid=' + contentid + '&parentid=' + configOptions.parentid + '&contenthistid=' + configOptions.contenthistid + '&regionid=' + configOptions.regionid + '&objectid=' + configOptions.objectid + '&contenttype=' + configOptions.contenttype + '&contentsubtype=' + configOptions.contentsubtype + '&container=layout&cacheid=' + Math.random(),

					data:{params:encodeURIComponent(JSON.stringify(params))},
					success:function(response){
						$('##layoutcontainer').html(response);
						$('.mura ##configurator select').niceSelect();
					}
				})
			}

			setLayoutOptions();
		});
	</script>
	<cfelse>
	</div>
	</cfif>
	</cfoutput>
</cf_objectconfigurator>
<cfabort>
<cfelse>
<cfsilent>
	<cfset feed=rc.$.getBean("content").loadBy(contenthistid=rc.contenthistid)>
	<cfset feed.set(objectParams)>
</cfsilent>
<cfoutput>
<div id="availableObjectParams"
	data-object="calendar"
	data-name="Calendar"
	data-objectid="#rc.contentid#">

	<h2>Edit Calendar Listing</h2>

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

			<span id="feedCustomImageOptions" <cfif feed.getImageSize() neq "custom"> style="display:none"</cfif>>
				<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,'collections.imagewidth')#</label>
					<input class="objectParam half" name="imageWidth" data-displayobjectparam="imageWidth" type="text" value="#feed.getImageWidth()#" />
				</div>
				<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,'collections.imageheight')#</label>
			<input class="objectParam half" name="imageHeight" data-displayobjectparam="imageHeight" type="text" value="#feed.getImageHeight()#" />
			</div>
		</span>

			<div class="mura-control-group" id="availableFields">
				<label>
					<span class="half">Available Fields</span> <span class="half">Selected Fields</span>
				</label>
				<div id="sortableFields">
					<p class="dragMsg">
						<span class="dragFrom half">Drag Fields from Here&hellip;</span><span class="half">&hellip;and Drop Them Here.</span>
					</p>

					<cfset displaylist=feed.getdisplaylist()>
					<cfset availableList=feed.getAvailabledisplaylist()>

					<ul id="availableListSort" class="displayListSortOptions">
						<cfloop list="#availableList#" index="i">
							<li class="ui-state-default">#trim(i)#</li>
						</cfloop>
					</ul>

					<ul id="displayListSort" class="displayListSortOptions">
						<cfloop list="#displaylist#" index="i">
							<li class="ui-state-highlight">#trim(i)#</li>
						</cfloop>
					</ul>
					<input type="hidden" id="displaylist" class="objectParam" value="#displaylist#" name="displaylist"  data-displayobjectparam="displaylist"/>
				</div>
		</div>
	</div>
</div>
</cfoutput>
<cfabort>
</cfif>

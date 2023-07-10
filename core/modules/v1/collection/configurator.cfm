<!--- license goes here --->
<cfsilent>
	<cfparam name="objectParams.sourcetype" default="">
	<cfparam name="objectParams.source" default="">
	<cfparam name="objectParams.items" default="#arrayNew(1)#">
	<cfparam name="objectParams.layout" default="#rc.$.getContentRenderer().collectionDefaultLayout#">
	<cfparam name="objectParams.forcelayout" default="false">
	<cfparam name="objectParams.sortby" default="Title">
	<cfparam name="objectParams.sortdirection" default="ASC">
	<cfparam name="objectParams.render" default="server">
	<cfparam name="objectParams.async" default="false">
	<cfset hasFeedManagerAccess=rc.configuratormode neq 'backend' and rc.$.getBean('permUtility').getModulePerm('00000000000000000000000000000000011',rc.siteid)>
</cfsilent>
<cf_objectconfigurator params="#objectparams#">
	<cfoutput>
	<div id="availableObjectParams"
		data-object="collection"
		data-name="#esapiEncode('html_attr','#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.collection')#')#"
		data-objectid="none"
		data-forcelayout="#esapiEncode('html_attr',objectParams.forcelayout)#">

		<input type="hidden" name="startrow" class="objectParam" value="1">
		<input type="hidden" name="pagenum" class="objectParam" value="">
		
		<div class="mura-layout-row">
			<div class="mura-control-group">
				<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.contentsource')#</label>
				<select class="objectParam" name="sourcetype" data-param="sourcetype">
					<option value="">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.contentsource')#</option>
					<option <cfif objectParams.sourcetype eq 'localindex'>selected </cfif>value="localindex">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.localindex')#</option>
					<cfif not rc.$.siteConfig('isremote') && application.configBean.getValue('rsscollections')><option <cfif objectParams.sourcetype eq 'remotefeed'>selected </cfif>value="remotefeed">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remotefeed')#</option></cfif>
					<option <cfif objectParams.sourcetype eq 'relatedcontent'>selected </cfif>value="relatedcontent">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.relatedcontent')#</option>
					<option <cfif objectParams.sourcetype eq 'children'>selected </cfif>value="children">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.children')#</option>
				</select>
			</div>
			<div id="localindexcontainer" class="mura-control-group source-container" style="display:none">
				<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectlocalindex')#</label>
				<cfset rs=rc.$.getBean('feedManager').getFeeds(type='Local',siteid=rc.$.event('siteid'),activeOnly=true)>
				<select name="source1" id="localindex" data-param="source">
					<option value="">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectcontentcollection'))#</option>
					<cfloop query="rs">
						<option value="#rs.feedid#"<cfif rs.feedid eq objectParams.source> selected</cfif>>#esapiEncode('html',rs.name)#</option>
					</cfloop>
				</select>

				<cfif hasFeedManagerAccess>
					<button class="btn" id="editBtnLocalIndex"><i class="mi-plus-circle"></i> Create New</button>
				</cfif>
			</div>

			<cfif not rc.$.siteConfig('isremote')>
				<div id="remotefeedcontainer" class="mura-control-group source-container" style="display:none">
					<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectremotefeed')#</label>
					<cfset rs=rc.$.getBean('feedManager').getFeeds(type='Remote',siteid=rc.$.event('siteid'),activeOnly=true)>
					<select name="source2" id="remotefeed" data-param="source">
						<option value="">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectremotefeed')#</option>
						<cfloop query="rs">
							<option value="#rs.feedid#"<cfif rs.feedid eq objectParams.source> selected</cfif>>#esapiEncode('html',rs.name)#</option>
						</cfloop>
					</select>

					<cfif hasFeedManagerAccess>
						<button class="btn" id="editBtnRemoteFeed"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.createnew')#</button>
					</cfif>
				</div>
			</cfif>

			<div id="relatedcontentcontainer" class="mura-control-group source-container" style="display:none">
				<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectrelatedcontentset')#</label>
				<cfset subtype = application.classExtensionManager.getSubTypeByName(rc.$.content('type'), rc.$.content('subtype'),rc.siteid)>
				<cfset relatedContentSets = subtype.getRelatedContentSets()>
				<select name="source3" id="relatedcontent" data-param="source">
					<cfloop from="1" to="#arrayLen(relatedContentSets)#" index="s">
						<cfset rcsBean = relatedContentSets[s]/>
						<cfif rcsBean.getEntityType() eq "content">
							<option value="#rcsBean.getRelatedContentSetId()#"<cfif objectParams.source eq rcsBean.getRelatedContentSetId()> selected</cfif>>#rcsBean.getName()#</option>
						</cfif>
					</cfloop>
					<option value="custom"<cfif objectParams.source eq 'custom'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.custom')#</option>
					<option value="reverse"<cfif objectParams.source eq 'reverse'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.reverse')#</option>
				</select>
				<input type="hidden" name="items" id="items" value="#esapiEncode('html_attr',serializeJSON(objectParams.items))#">
				<button class="btn" id="editBtnRelatedContent"><i class="mi-pencil"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.edit')#</button>
			</div>
		</div>
		<div class="mura-layout-row" id="layoutcontainer">
		</div>

		</div>
		<!--- Include global config object options --->
		<cfinclude template="#$.siteConfig().lookupDisplayObjectFilePath('object/configurator.cfm')#">


	<script>
		$(function(){

			function setRemoteFeedEditOption(){
				var selector=$('##remotefeed');
			 	if(selector.val()){
			 		$('##editBtnRemoteFeed').html('<i class="mi-pencil"></i> Edit');
			 	} else {
			 		$('##editBtnRemoteFeed').html('<i class="mi-plus-circle"></i> Create New');
			 	}
			}

			function setLocalIndexEditOption(){
				var selector=$('##localindex');
			 	if(selector.val()){
			 		$('##editBtnLocalIndex').html('<i class="mi-pencil"></i> Edit');
			 	} else {
			 		$('##editBtnLocalIndex').html('<i class="mi-plus-circle"></i> Create New');
			 	}
			}

			function setRelatedContentEditOption(){
				var selector=$('##relatedcontent');
			 	if(selector.val()=='custom'){
			 		$('##editBtnRelatedContent').show();
			 		$('##editBtnRelatedContent').html('<i class="mi-pencil"></i> Edit');
			 		$('##items').addClass('objectParam');

			 	} else {
			 		$('##editBtnRelatedContent').hide();
			 		$('##items').removeClass('objectParam');
			 	}
			}

			function setContentSourceVisibility(){
				<cfif rc.configuratormode neq 'backend'>
				<cfset content=rc.$.getBean('content').loadBy(contenthistid=rc.contenthistid)>

				function getType(){
					var type=$('input[name="type"]');

					if(type.length){
						return type.val();
					} else {
						return '#esapiEncode("javascript",content.getType())#';
					}
				}

				function getSubType(){
					var subtype=$('input[name="subtype"]');

					if(subtype.length){
						return subtype.val();
					} else {
						return '#esapiEncode("javascript",content.getSubType())#';
					}
				}

				function getContentID(){
					return '#esapiEncode("javascript",content.getContentID())#';
				}

				function getContentHistID(){
					return '#esapiEncode("javascript",content.getContentHistID())#';
				}

				function getSiteID(){
					return '#esapiEncode("javascript",rc.siteid)#';
				}
				</cfif>

				$('select[data-param="source"], ##items').removeClass('objectParam');
				$('.source-container').hide();
				$('.sort-container').hide();

				var val=$('select[name="sourcetype"]').val();

				if(val=='localindex'){
					$('##localindex').addClass('objectParam');
					$('##localindexcontainer').show();
				} else if(val=='remotefeed'){
					$('##remotefeed').addClass('objectParam');
					$('##remotefeedcontainer').show();
				} else if(val=='relatedcontent'){
					$('##relatedContentSetData').val('');
					$('##selectRelatedContent').html('');
					$('##selectedRelatedContent').html('');
					$('##relatedcontentcontainer').show();
					$('##relatedcontent').addClass('objectParam');
				}
			}

			setLayoutOptions=function(){
				$('input[name="layout"]').val($('##layoutSel').val());
				siteManager.updateAvailableObject();
				siteManager.availableObject.params.source = siteManager.availableObject.params.source || '';

				var params=siteManager.availableObject.params;

			  params.layout=params.layout || 'default';

				//console.log(params)

				$.ajax(
				 {
				 	type: 'post',
				 	dataType: 'text',
					url: './?muraAction=cArch.loadclassconfigurator&compactDisplay=true&siteid=' + configOptions.siteid + '&instanceid=#esapiEncode("url",rc.instanceid)#&classid=' + configOptions.object + '&contentid=' + contentid + '&parentid=' + configOptions.parentid + '&contenthistid=' + configOptions.contenthistid + '&regionid=' + configOptions.regionid + '&objectid=' + configOptions.objectid + '&contenttype=' + configOptions.contenttype + '&contentsubtype=' + configOptions.contentsubtype + '&container=layout&cacheid=' + Math.random(),

					data:{params:encodeURIComponent(JSON.stringify(params))},
					success:function(response){
						$('##layoutcontainer').html(response);
						
						$('.mura ##configurator select').each(function(){
						 	var self=$(this);
							self.addClass('ns-' + self.attr('name')).niceSelect();
						});
				
						wireupExterndalUIWidgets();
					
						$('##layoutcontainer .mura-html:not(textarea').each(function(){
							var self=$(this);
							self.click(function(){
								siteManager.openDisplayObjectModal('object/html.cfm',self.data());
							});
						})
	
						$('##layoutcontainer .mura-markdown:not(textarea').each(function(){
							var self=$(this);
							self.click(function(){
								siteManager.openDisplayObjectModal('object/markdown.cfm',self.data());
							});
						})
	
						$('##layoutcontainer .mura-associmage').each(function(){
							var self=$(this);
							self.click(function(){
								siteManager.openDisplayObjectModal('object/associmage.cfm',self.data());
							});
						})

						setTimeout(
							function(){
								window.configuratorInited=true;
							},
							50
						);
						
					}
				})
			}

			$('select[name="sourcetype"]').on('change', function() {
				setContentSourceVisibility();
				setLayoutOptions();
			});

			$('select[data-param="source"]').on('change', function() {
				setLayoutOptions();


				if($('select[name="sourcetype"]').val()=='relatedcontent'){
					setContentSourceVisibility();
				}
			});

			$('##localindex').change(setLocalIndexEditOption);
			$('##remotefeed').change(setRemoteFeedEditOption);
			$('##relatedcontent').change(setRelatedContentEditOption);


			$('##editBtnLocalIndex').click(function(){
				frontEndProxy.post({
					cmd:'openModal',
					src:'?muraAction=cFeed.edit&feedid=' +$('##localindex').val() + '&type=Local&siteId=#esapiEncode("url",rc.siteid)#&instanceid=#esapiEncode("url",rc.instanceid)#&compactDisplay=true'
					}
				);
			});

			$('##editBtnRemoteFeed').click(function(){
				frontEndProxy.post({
					cmd:'openModal',
					src:'?muraAction=cFeed.edit&feedid=' +$('##remotefeed').val() + '&type=Remote&siteId=#esapiEncode("url",rc.siteid)#&instanceid=#esapiEncode("url",rc.instanceid)#&compactDisplay=true'
					}
				);
			});

			$('##editBtnRelatedContent').click(function(){
				frontEndProxy.post({
					cmd:'openModal',
					src:'?muraAction=cArch.relatedcontent&siteid=#esapiEncode("url",rc.siteid)#&contenthistid=#esapiEncode("url",rc.contenthistid)#&instanceid=#esapiEncode("url",rc.instanceid)#&compactDisplay=true&relatedcontentsetid=' + $('##relatedcontent').val() + '&items=#esapiEncode("url",serializeJSON(objectparams.items))#'
					}
				);

			});

			setContentSourceVisibility();
			setLayoutOptions();
			setLocalIndexEditOption()
			setRemoteFeedEditOption()
			setRelatedContentEditOption()

		});
	</script>
	</cfoutput>
</cf_objectconfigurator>
<cfabort>

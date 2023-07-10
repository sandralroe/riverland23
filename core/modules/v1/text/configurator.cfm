<!--- license goes here --->
<cfsilent>
	<cfparam name="objectParams.sourcetype" default="custom">
	<cfparam name="objectParams.async" default="false">
	<cfparam name="objectParams.source" default="">
	<cfset content=rc.$.getBean('content').loadBy(contentid=rc.objectid)>
	<cfset content.setType('Component')>
	<cfset rc.rsComponents = application.contentManager.getComponentType(rc.siteid, 'Component','00000000000000000000000000000000000')/>
	<cfset hasModulePerm=rc.configuratormode neq 'backend' and listFindNocase('editor,author',rc.$.getBean('permUtility').getPerm('00000000000000000000000000000000003',rc.siteid))>
</cfsilent>
<cf_objectconfigurator params="#objectparams#">
<cfoutput>
<div id="availableObjectParams"
	data-object="collection"
	data-name="#esapiEncode('html_attr','#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.text')#')#"
	data-objectid="none">
<div class="mura-layout-row">
	<div class="mura-control-group">
		<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.contentsource')#</label>
		<select class="objectParam" name="sourcetype">
			<option <cfif objectParams.sourcetype eq 'custom'>selected </cfif>value="custom">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.texteditor')#</option>
			<option <cfif objectParams.sourcetype eq 'component'>selected </cfif>value="component">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.component')#</option>
			<option <cfif objectParams.sourcetype eq 'boundattribute'>selected </cfif>value="boundattribute">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.boundattribute')#</option>
		</select>
		<button id="editSource" class="btn"><i class="mi-pencil"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.edit')#</button>
	</div>
	<div id="componentcontainer" class="mura-control-group source-container" style="display:none">
		<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.type.component')#</label>
		<cfset rs=rc.$.getBean('contentManager').getList(args={moduleid='00000000000000000000000000000000003',siteid=session.siteid})>
		<select name="source1" id="component" data-param="source">
			<option value="unconfigured">
				#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectcomponent')#
			</option>`
			<cfloop query="rc.rsComponents">
				<cfset title=rc.rsComponents.menutitle>
				<option <cfif objectparams.source eq rc.rsComponents.contentid and objectparams.sourcetype eq 'component'>selected </cfif>title="#esapiEncode('html_attr',title)#" value="#rc.rsComponents.contentid#">
					#esapiEncode('html',title)#
				</option>
			</cfloop>
		</select>
		<cfif hasModulePerm>
			<button class="btn" id="editBtnComponent"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.createnew')#</button>
			<script>
			$('##editBtnComponent').click(function(){
					frontEndProxy.post({
						cmd:'openModal',
						src:'?muraAction=cArch.editLive&contentId=' + $('##component').val() + '&type=Component&siteId=#esapiEncode("javascript",rc.siteid)#&instanceid=#esapiEncode("javascript",rc.instanceid)#&compactDisplay=true'
						}
					);
			})
			</script>
		</cfif>
	</div>
	<div id="customcontainer" class="mura-control-group source-container" style="display:none">
		<textarea name="source" id="custom" style="display:none;"><cfif objectParams.sourceType eq 'custom'>#objectParams.source#</cfif></textarea>
		<script>
		$(function(){
			$('##editSource').click(function(){
				frontEndProxy.post({
					cmd:'openModal',
					src:'?muraAction=cArch.edittext&siteid=#esapiEncode("url",rc.siteid)#&contenthistid=#esapiEncode("url",rc.contenthistid)#&instanceid=#esapiEncode("url",rc.instanceid)#&compactDisplay=true'
					}
				);
			});
		});
		</script>

	</div>
	<div id="boundattributecontainer" class="mura-control-group source-container" style="display:none">
		<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.boundattribute')#</label>
			<cfsilent>
			<cfset offset=1>
			<cfset options[1][1]="summary">
			<cfset options[1][2]=application.rbFactory.getKeyValue(session.rb,'params.summary')>
			<cfif len(rc.$.content('body')) and rc.$.content('body') neq '<p></p>'>
				<cfset options[2][1]="body">
				<cfset options[2][2]=application.rbFactory.getKeyValue(session.rb,'params.body')>
			</cfif>
			<cfset rsExtend=application.configBean.getClassExtensionManager().getExtendedAttributeList(siteID=rc.siteid,baseTable="tcontent",activeOnly=true,type=content.getType(),subtype=content.getSubType())>
			<cfset optionslen = arraylen(options) />
			<cfloop query="rsExtend">
			<cfset options[rsExtend.currentRow + optionslen][1]=rsExtend.attribute>
			<cfset options[rsExtend.currentRow + optionslen][2]=rsExtend.label/>
			</cfloop>
		</cfsilent>
		<select name="source2" id="boundattribute" data-param="source">
			<option value="">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectboundattribute')#</option>
			<cfloop from="1" to="#arrayLen(options)#" index="i">
				<option value="#esapiEncode('html_attr',options[i][1])#"<cfif objectParams.source eq options[i][1]> selected</cfif>>#esapiEncode('html',options[i][2])#</option>
			</cfloop>
		</select>
	</div>
</div>
</div>

<!--- Include global config object options --->
<cfinclude template="#$.siteConfig().lookupDisplayObjectFilePath('object/configurator.cfm')#">

<cfparam name="objectParams.render" default="server">
<input type="hidden" class="objectParam" name="render" value="#esapiEncode('html_attr',objectParams.render)#">
<input type="hidden" class="objectParam" name="async" value="#esapiEncode('html_attr',objectParams.async)#">
<script>
	$(function(){

		function setContentSourceVisibility(){
			<cfif rc.configuratormode neq 'backend'>

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

			function setEditOption(){
				var selector=$('##component');
				var val=selector.val();

				if(val && val !='unconfigured'){
					$('##editBtnComponent').html('<i class="mi-pencil"></i> Edit');
				} else {
					$('##editBtnComponent').html('<i class="mi-plus-circle"></i> Create New');
				}
			}

			$('select[name="source1"], select[name="source2"], textarea[name="source"]').removeClass('objectParam');
			$('.source-container').hide();
			$('##editSource').hide();

			var val=$('select[name="sourcetype"]').val();

			$('##component').on('change',setEditOption);

			if(val=='custom'){
				$('##custom').addClass('objectParam');
				$('##editSource').show();
				$('input[name="render"]').val('client');
				$('input[name="async"]').val('false');
			} else if(val=='boundattribute'){
				$('##boundattribute').addClass('objectParam');
				$('##boundattributecontainer').show();
				$('input[name="render"]').val('server');
				$('input[name="async"]').val('true');
			} else if(val=='component'){
				$('##component').addClass('objectParam');
				$('##componentcontainer').show();
				$('input[name="render"]').val('server');
				$('input[name="async"]').val('true');
			}

			setEditOption();
		}

		$('select[name="sourcetype"]').on('change', function() {
			setContentSourceVisibility();
		});

		setContentSourceVisibility();

	});
</script>
</cfoutput>
</cf_objectconfigurator>
<cfabort>

<!--- License goes here --->
<cfsilent>
	<cfset content=rc.$.getBean('content').loadBy(contentid=rc.objectid)>
	<cfset content.setType('Form')>
	<cfset rc.rsForms = application.contentManager.getComponentType(rc.siteid, 'Form')/>

<!---
	<cfif isJSON( content.getValue('body') )>
		<cfset isFormbuilder = true />
		<cfset formJSON = serializeJSON( content.getValue('body') ) />
	</cfif>
--->

	<cfset hasModulePerm=rc.configuratormode neq 'backend' and listFindNocase('editor,author',rc.$.getBean('permUtility').getPerm('00000000000000000000000000000000004',rc.siteid))>

	<cfparam name="objectParams.view" default="">
	<cfparam name="objectParams.followupurl" default="">
</cfsilent>
<cf_objectconfigurator>
<cfoutput>
<div class="mura-layout-row">
	<div class="mura-control-group">
		<label class="mura-control-label">Select Form</label>

		<select name="objectid" class="objectParam">
			<option value="unconfigured">
				#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectform')#
			</option>
			<cfloop query="rc.rsForms">
				<cfset title=rc.rsForms.menutitle>
				<option
					<cfif rc.objectid eq rc.rsForms.contentid>selected </cfif>
					value="#rc.rsForms.contentid#">
					#esapiEncode('html',title)#
				</option>
			</cfloop>
		</select>
		<cfif hasModulePerm>
			<button class="btn" id="editBtn">#application.rbFactory.getKeyValue(session.rb,'sitemanager.edit')#</button>
		</cfif>
	</div>
	<div class="mura-layout-row">
		<div class="mura-control-group">
			<label class="mura-control-label">Follow Up URL</label>
			<input name="followupurl" type="text" class="objectParam" value="#esapiEncode('html_attr',objectParams.followupurl)#">
		</div>
	</div>
	<cfif content.getValue('subtype') eq 'marketo'>
		<div class="mura-layout-row">
			
			<cfimport prefix="ui" taglib="../../../mura/customtags/configurator/ui">
			<cfset params.instanceid=rc.instanceid>
			<cfset params.contentid=content.getValue('contentid')>
			<cfset params.contenthistid=content.getValue('contenthistid')>
			<cfset params.siteid=rc.$.event('siteid')>


			<cfparam name="objectparams.customsubmitlabel" default="">
			<cfset params.label="Custom Submit Label">
			<cfset params.name="customsubmitlabel">
			<cfset params.value=objectparams.customsubmitlabel>
			<cfset params.type="text">
			<ui:param attributecollection="#params#">

			<!---
			<cfparam name="objectparams.privateemails" default="#rc.$.globalConfig().getValue(property='allowprivateemails',defaultValue=1)#">
			<cfset params.label="Allow Private Emails">
			<cfset params.name="privateemails">
			<cfset params.value=objectparams.privateemails>
			<cfset params.type="select">
			<cfset params.options=[{name='Yes',value=1},{name='No',value=0}]>
			<ui:param attributecollection="#params#">
			--->

			<cfparam name="objectparams.customfields" default="">
			<cfset params.name="customfields">
			<cfset params.label="Custom Hidden Fields">
			<cfset params.value=objectparams.customfields>
			<cfset params.type="name_value_array">
			<ui:param attributecollection="#params#">

		</div>
	</cfif>
</div>
<input type="hidden" name="render" value="server" class="objectParam" />
<input type="hidden" name="async" value="true" class="objectParam" />
<input type="hidden" name="view" value="form" class="objectParam" />
<cfif hasModulePerm>
<script>
	$(function(){
		function setEditOption(){
			var selector=$('select[name="objectid"]');
			var val=selector.val();
			if(val && val !='unconfigured'){
		 		$('##editBtn').html('<i class="mi-pencil"></i>Edit');
		 	} else {
		 		$('##editBtn').html('<i class="mi-plus-circle"></i> Create New');
			 }

		}

		$('select[name="objectid"]').change(setEditOption);
		setEditOption();

		$('##editBtn').click(function(){
				frontEndProxy.post({
					cmd:'openModal',
					src:'?muraAction=cArch.editLive&contentId=' +  $('select[name="objectid"]').val()  + '&type=Form&siteId=#esapiEncode("javascript",rc.siteid)#&instanceid=#esapiEncode("javascript",rc.instanceid)#&compactDisplay=true'
					}
				);
		})

	});
</script>
</cfif>

<!--- Include global config object options --->
<cfinclude template="#$.siteConfig().lookupDisplayObjectFilePath('object/configurator.cfm')#">
</cfoutput>
</cf_objectconfigurator>

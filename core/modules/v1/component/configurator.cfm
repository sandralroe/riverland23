 <!--- license goes here --->
<cfsilent>
	<cfset content=rc.$.getBean('content').loadBy(contentid=rc.objectid)>
	<cfset content.setType('Component')>
	<cfset rc.rsComponents = application.contentManager.getComponentType(rc.siteid, 'Component','00000000000000000000000000000000000')/>
	<cfset hasModulePerm=rc.configuratormode neq 'backend' and listFindNocase('editor,author',rc.$.getBean('permUtility').getPerm('00000000000000000000000000000000003',rc.siteid))>
</cfsilent>
<cf_objectconfigurator>
<cfoutput>
<div class="mura-layout-row">
	<div class="mura-control-group">
		<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectcomponent')#</label>
		<select id="availableObjectSelector">
			<option value="{object:'component',objectid:'unconfigured'}">
				#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectcomponent')#
			</option>`
			<cfloop query="rc.rsComponents">
				<cfset title=rc.rsComponents.menutitle>
				<option <cfif rc.objectid eq rc.rsComponents.contentid and rc.object eq 'component'>selected </cfif>title="#esapiEncode('html_attr',title)#" value="{object:'component',objectid:'#rc.rsComponents.contentid#'}">
					#esapiEncode('html',title)#
				</option>
			</cfloop>
		</select>
		<cfif hasModulePerm>
			<button class="btn" id="editBtn"><i class="mi-pencil"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.edit')#</button>
		</cfif>
	</div>
</div>
<cfif hasModulePerm>
<script>
	$(function(){
		function setEditOption(){
			var selector=$('##availableObjectSelector');
			var val=eval('(' + selector.val() + ')').objectid;
			if(val && val !='unconfigured'){
		 		$('##editBtn').html('<i class="mi-pencil"></i> Edit');
		 	} else {
		 		$('##editBtn').html('<i class="mi-plus-circle"></i> Create New');
		 	}
		}

		$('##availableObjectSelector').change(setEditOption);

		setEditOption();

		$('##editBtn').click(function(){
				frontEndProxy.post({
					cmd:'openModal',
					src:'?muraAction=cArch.editLive&contentId=' + eval('(' + $('##availableObjectSelector').val() + ')').objectid  + '&type=Component&siteId=#esapiEncode("javascript",rc.siteid)#&instanceid=#esapiEncode("javascript",rc.instanceid)#&compactDisplay=true'
					}
				);
		})

	});
</script>
</cfif>
</cfoutput>
</cf_objectconfigurator>

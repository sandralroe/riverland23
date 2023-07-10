<!--- license goes here --->
<cfoutput>
	<script>
		function exportPartial(){
			var message = jQuery('input[name="doChildrenOnly"]').prop('checked')
				? "#rc.$.rbKey('sitemanager.content.exportchildrenonlymessage')#"
				: "#rc.$.rbKey('sitemanager.content.exportnodeandchildrenmessage')#";

			jQuery('##alertDialogMessage').html(message);
			jQuery('##alertDialog').dialog({
					resizable: false,
					modal: true,
					buttons: {
						'No': function() {
							jQuery(this).dialog('close');
						},
						Yes: 
							{click: function() {
								jQuery(this).dialog('close');
								jQuery('##partialExportForm').submit();
							}
							, text: 'Yes'
							, class: 'mura-primary'
						} // /Yes
					}
				});

			return false;
		}
	</script>

	</div>

	<div class="mura-header">
		<h1>#rc.$.rbKey('sitemanager.content.exportcontent')#</h1>

		<div class="nav-module-specific btn-group">
		</div>

		#rc.$.dspZoom(crumbdata=rc.crumbdata,class="breadcrumb")#
	</div> <!-- /.mura-header -->

	<form id="partialExportForm" novalidate="novalidate" name="form1" method="post" action="index.cfm" onsubit="return validateForm(this);"  enctype="multipart/form-data">
		<div class="block block-constrain">

			<h2>#rc.$.rbKey('sitemanager.content.exportoptions')#</h2>
			<div class="block-content">
				<div class="mura-control-group">
					<label class="mura-control-group">
						#rc.$.rbKey('sitemanager.content.exportinstructions')#
					</label>

					<div class="mura-control">
						<label class="radio-inline radio inline">
							<input type="radio" name="doChildrenOnly" id="doChildrenOnly1" value="1" checked="checked">
							#rc.$.rbKey('sitemanager.content.exportchildrenonly')#
						</label>
						<label class="radio-inline radio inline">
							<input type="radio" name="doChildrenOnly" id="doChildrenOnly0" value="0">
							#rc.$.rbKey('sitemanager.content.exportall')#
						</label>
					</div>
				</div>
			</div>

			<div class="mura-actions">
				<div class="form-actions">
					<button type="button" class="btn" onclick="return history.go(-1);">
						<i class="mi-arrow-circle-left"></i>
						#rc.$.rbKey('sitemanager.cancel')#
					</button>
					<button type="button" class="btn mura-primary" onClick="return exportPartial();">
						<i class="mi-sign-out"></i>
						#rc.$.rbKey('sitemanager.content.exportcontent')#
					</button>
				</div>
			</div>

		</div>
		<input type="hidden" name="action" value="import">
		<input name="muraAction" value="cArch.exportcontent" type="hidden">
		<input name="siteID" value="#esapiEncode('html_attr',session.siteid)#" type="hidden">
		<input name="moduleid" value="#esapiEncode('html_attr',rc.moduleid)#" type="hidden">
		<input name="contentid" value="#esapiEncode('html_attr',rc.contentid)#" type="hidden">
		#rc.$.renderCSRFTokens(context=rc.contentid,format="form")#
	</form>
</cfoutput>

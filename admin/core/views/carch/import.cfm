<!--- license goes here --->
<cfsilent>
	<cfset hasChangesets = $.getBean('settingsManager').getSite($.event('siteID')).getValue('hasChangesets') />
	<cfset enforceChangesets = $.getBean('settingsManager').getSite($.event('siteID')).getValue('enforceChangesets') />
</cfsilent>
<cfoutput>
	<script>
		jQuery(document).ready(function($) {

			$("##savetochangesetname").hide();
			$("##import_status").change(function() {
				if( $("##import_status").val() == "Changeset" ) {
					$("##savetochangesetname").show();
				} else {
					$("##savetochangesetname").hide();
				}
			});

			$('##frmSubmit').click(function(e) {
				var newFile = $('input[name="newFile"]').val();
				if ( newFile === '' || newFile.split('.').pop() !== 'zip' ) {
					var msg = '#rc.$.rbKey('sitemanager.content.importnofilemessage')#';
					$('##alertDialogMessage').html(msg);

					$('##alertDialog').dialog({
						resizable: false,
						modal: true,
						buttons: {
							#rc.$.rbKey('sitemanager.extension.ok')#: 
							{click: function() {
									jQuery(this).dialog('close');
								}
							, text: '#rc.$.rbKey('sitemanager.extension.ok')#'
							, class: 'mura-primary'
							} // /Yes
						}
					});

				} else {
					submitForm(document.forms.form1,'import')
				}
			});

		});
	</script>

	<div class="mura-header">
		<h1>#rc.$.rbKey('sitemanager.content.importcontent')#</h1>

		<div class="nav-module-specific btn-group">
		</div>
		
		#rc.$.dspZoom(crumbdata=rc.$.getBean('content').loadBy(contentid=rc.contentid).getCrumbArray(),class="breadcrumb")#
	</div> <!-- /.mura-header -->

	<form novalidate="novalidate" name="form1" method="post" onsubmit="return validateForm(this);" enctype="multipart/form-data">
		<div class="block block-constrain">
			<div class="block-content">
				<div class="mura-control-group">
					<label class="mura-control-label">
						#rc.$.rbKey('sitemanager.content.importcontent')#
					</label>
					<input type="file" name="newFile">
				</div>

				<cfif not enforceChangesets>
					<div class="mura-control-group">
						<label class="mura-control-label">
							#rc.$.rbKey('sitemanager.content.contentstatus')#
						</label>

						<select name="import_status" id="import_status">
							<option value="Approved">#rc.$.rbKey('sitemanager.content.published')#</option>
							<option value="Draft">#rc.$.rbKey('sitemanager.content.draft')#</option>
							<cfif hasChangesets or enforceChangesets>
							<option value="Changeset">#rc.$.rbKey('sitemanager.content.savetochangeset')#</option>
							</cfif>
						</select>

					</div>
				<cfelse>
					<input type="hidden" name="import_status" value="Changeset" />
				</cfif>

				<div id="savetochangesetname">
					<div class="mura-control-group">
						<label class="mura-control-label">
							#rc.$.rbKey('sitemanager.content.changesetname')#
						</label>
						<div class="mura-control">
							<input type="text" name="changeset_name">
						</div>
					</div>
				</div>
			</div>

			<div class="mura-actions">
				<div class="form-actions">
					<button id="frmSubmit" class="btn mura-primary"><i class="mi-sign-in"></i>Import</button>
				</div>
			</div>

			<input type="hidden" name="action" value="import">
			<input name="muraAction" value="cArch.importcontent" type="hidden">
			<input name="siteID" value="#esapiEncode('html_attr',session.siteid)#" type="hidden">
			<input name="moduleid" value="#esapiEncode('html_attr',rc.moduleid)#" type="hidden">
			<input name="contentid" value="#esapiEncode('html_attr',rc.contentid)#" type="hidden">
			#rc.$.renderCSRFTokens(context=rc.contentid,format="form")#
		</div>
	</form>

</cfoutput>

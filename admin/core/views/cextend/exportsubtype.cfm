<!--- License goes here --->
<cfoutput>
	<script>
		jQuery(function ($) {
			$("##checkall").click(function(){
				$('input:checkbox').not(this).prop('checked', this.checked);
			});

			// make sure at least one class extension has been selected
			$('##btnSubmit').on('click', function(e){
				var n = $('.checkbox:checkbox:checked').map(function(){
					return $(this).val();
				}).get();

				if ( n.length === 0 ) {
					jQuery('##alertDialogMessage').html("#rc.$.rbKey('sitemanager.extension.selectatleastone')#");
					jQuery('##alertDialog').dialog({
						resizable: false,
						modal: true,
						buttons: {
							#rc.$.rbKey('sitemanager.extension.ok')#: 
								{click: function() {
										jQuery(this).dialog('close');
									}
								, text: 'OK'
								, class: 'mura-primary'
								} // /ok
							}						
					});
					return false;
				} else {
					submitForm(document.forms.form1, 'add');
				}
			});

		});
</script>


<div class="mura-header">
	<h1>#rc.$.rbKey('sitemanager.extension.exportclassextensions')#</h1>
	<div class="nav-module-specific btn-group">
		<a class="btn" href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.listSubTypes&amp;siteid=#esapiEncode('url',rc.siteid)#">
					<i class="mi-arrow-circle-left"></i> 
			#rc.$.rbKey('sitemanager.extension.backtoclassextensions')#
		</a>
	</div>
</div> <!-- /.mura-header -->

<div class="block block-constrain">
		<div class="block block-bordered">
		  <div class="block-content">
			<form novalidate="novalidate" name="form1" method="post" onsubmit="return validateForm(this);">
					<div class="mura-control-group">
					<label class="checkbox">
						<input type="checkbox" name="checkall" id="checkall" /> 
						<strong>#rc.$.rbKey('sitemanager.extension.selectall')#</strong>
					</label>
				</div>

					<div class="mura-control-group">
					<cfloop query="rc.subtypes">
						<label class="checkbox">
							<input name="exportClassExtensionID" type="checkbox" class="checkbox" value="#subtypeid#">
							#esapiEncode('html', application.classExtensionManager.getTypeAsString(type))# / #esapiEncode('html', subtype)#
						</label>
					</cfloop>
				</div>

		<div class="mura-actions">		
			<div class="form-actions">
				<button id="btnSubmit" class="btn mura-primary"><i class="mi-sign-out"></i>#rc.$.rbKey('sitemanager.extension.export')#</button>
			</div>
		</div>

		<input type="hidden" name="action" value="export">
		<input name="muraAction" value="cExtend.export" type="hidden">
		<input name="siteID" value="#esapiEncode('html_attr',rc.siteid)#" type="hidden">
		#rc.$.renderCSRFTokens(context=rc.extendSetID,format="form")#
	</form>
		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->

</cfoutput>
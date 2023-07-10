<!--- license goes here --->
<cfoutput>
	<script>
		// for environments that don't support indexOf()
		if (!Array.prototype.indexOf) {
			Array.prototype.indexOf = function (searchElement /*, fromIndex */ ) {
				"use strict";

				if (this === void 0 || this === null) throw new TypeError();

				var t = Object(this);
				var len = t.length >>> 0;
				if (len === 0) return -1;

				var n = 0;
				if (arguments.length > 0) {
						n = Number(arguments[1]);
						if (n !== n) // shortcut for verifying if it's NaN
						n = 0;
				else if (n !== 0 && n !== (1 / 0) && n !== -(1 / 0)) n = (n > 0 || -1) * Math.floor(Math.abs(n));
				}

				if (n >= len) return -1;
				var k = n >= 0 ? n : Math.max(len - Math.abs(n), 0);
				for (; k < len; k++) {
					if (k in t && t[k] === searchElement) return k;
				}
				return -1;
			};
		}

		jQuery(document).ready(function($) {

			$('##frmSubmit').click(function(e) {
				var newFile = $('input[name="newFile"]').val();
				var validExtensions = ['xml','XML','cfm','CFM'];
				var ext = newFile.split('.').pop();
				var extIdx = validExtensions.indexOf(ext);

				if ( newFile === '' || extIdx == -1 ) {
					var msg = '#rc.$.rbKey('sitemanager.content.importnofilemessage')#';
					$('##alertDialogMessage').html(msg);

					$('##alertDialog').dialog({
						resizable: false,
						modal: true,
						buttons: {
							#rc.$.rbKey('sitemanager.extension.ok')#:
								{click: function() {
										$(this).dialog('close');
									}
								, text: 'OK'
								, class: 'mura-primary'
								} // /ok
							}


					});

				} else {
					submitForm(document.forms.form1,'import')
				}
			});

		});
	</script>
<div class="mura-header">
	<h1>#rc.$.rbKey('sitemanager.extension.importclassextensions')#</h1>

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

					<form novalidate="novalidate" name="form1" method="post" onsubmit="return validateForm(this);"  enctype="multipart/form-data">
						<div class="mura-control-group">
							<label>
					#rc.$.rbKey('sitemanager.extension.uploadfile')#
				</label>
					<input type="file" name="newFile">
				</div>

		<div class="mura-actions">
			<div class="form-actions">
				<button id="frmSubmit" class="btn mura-primary"><i class="mi-sign-in"></i>#rc.$.rbKey('sitemanager.extension.import')#</button>
			</div>
		</div>

		<input type="hidden" name="action" value="import">
		<input name="muraAction" value="cExtend.importsubtypes" type="hidden">
		<input name="siteID" value="#esapiEncode('html_attr',rc.siteid)#" type="hidden">
		#rc.$.renderCSRFTokens(context='import',format="form")#
	</form>

				</div> <!-- /.block-content -->
		</div> <!-- /.block-bordered -->
	</div> <!-- /.block-constrain -->
</cfoutput>

<!--- License goes here --->
<cfoutput>
	<script>
		jQuery(document).ready(function($){

			var $defaultmsg, $thecode, $clipboardContainer, $doc, $focusInput, $infoBox, onKeydown, onKeyup, value;

			$defaultmsg = "#rc.$.rbKey('sitemanager.extension.copymessage.default')#";
			$copiedmsg = "#rc.$.rbKey('sitemanager.extension.copymessage.copied')#";
			$focusInput = $('<input class="absolute-hidden" type="text"/>').appendTo(document.body).focus().remove();
			$doc = $(document);
			$thecode = $('##thecode');
			$infoBox = $('.info-box');
			$clipboardContainer = $("##clipboard-container");
			value = '';

			$infoBox.html($defaultmsg);

			onKeydown = function(e) {
			  var $target;
			  $target = $(e.target);

			  return setTimeout((function() {
			    $clipboardContainer.empty().show();
			    $("<textarea id='clipboard'></textarea>").val(value).appendTo($clipboardContainer).focus().select();
			    $infoBox.html($copiedmsg);
			    return setTimeout((function() {
			      return true;
			    }), 0);
			  }), 0);
			};

			onKeyup = function(e) {
			  if ($(e.target).is('##clipboard')) {
			    return $('##clipboard-container').empty().hide();
			  }
			};

			$doc.on('keydown', function(e) {
			  if (value && (e.ctrlKey || e.metaKey) && (e.which === 67)) {
			    return onKeydown(e);
			  }
			}).on('keyup', onKeyup);

			$thecode.bind('mouseenter focusin', function(e){
				return value = $(this).val();
			});

			$thecode.bind('mouseleave focusout', function(e){
				$infoBox.html($defaultmsg);
				return value = '';
			});
		});
	</script>

	<div id="clipboard-container" style="position:fixed;left:0px;top:0px;width:0px;height:0px;z-index:100;display:none;opacity:0;"><textarea id="clipboard" style="width:1px;height:1px;padding:0px;margin:0px;"></textarea></div>

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

	<form novalidate="novalidate" name="form1" method="post">
		<div class="mura-control-group">
			<div id="copymessage">
				<div class="info-box help-block"></div>
			</div>
				<textarea id="thecode" rows="20" style="width: 100%; height:100% !important;">#esapiEncode('html', rc.exportXML)#</textarea>
		</div>
		<div class="mura-actions">
			<div class="form-actions">
				<button id="btnSubmit" type="submit" class="btn mura-primary"><i class="mi-sign-out"></i>#rc.$.rbKey('sitemanager.extension.download')#</button>
			</div>
		</div>

		<input name="exportClassExtensionID" value="#rc.exportClassExtensionID#" type="hidden">
		<input name="action" value="download" type="hidden">
		<input name="muraAction" value="cExtend.download" type="hidden">
		<input name="siteID" value="#esapiEncode('html_attr',rc.siteid)#" type="hidden">
		#rc.$.renderCSRFTokens(context=rc.extendSetID,format="form")#

	</form>

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->

</cfoutput>

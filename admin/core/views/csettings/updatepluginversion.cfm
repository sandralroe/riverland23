<!--- license goes here --->
<cfoutput>
<div class="mura-header">
	<h1>Update Plugin Version</h1>
</div> <!-- /.mura-header -->


<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">

			<ul class="metadata">
			<li><strong>Name:</strong> #esapiEncode('html',rc.pluginConfig.getName())#</li>
			<li><strong>Category:</strong> #esapiEncode('html',rc.pluginConfig.getCategory())#</li>
			<li><strong>Version:</strong> #esapiEncode('html',rc.pluginConfig.getVersion())#</li>
			<li><strong>Provider:</strong> #esapiEncode('html',rc.pluginConfig.getProvider())#</li>
			<li><strong>Provider URL:</strong> <a href="#rc.pluginConfig.getProviderURL()#" target="_blank">#esapiEncode('html',rc.pluginConfig.getProviderURL())#</a></li>
			<li><strong>Plugin ID:</strong> #rc.pluginConfig.getPluginID()#</li>
			<li><strong>Package:</strong> <cfif len(rc.pluginConfig.getPackage())>#rc.pluginConfig.getPackage()#<cfelse>N/A</cfif></li>
			</ul>

			<form novalidate="novalidate" name="frmNewPlugin" action="./?muraAction=cSettings.deployPlugin" enctype="multipart/form-data" method="post" onsubmit="return submitForm(document.frmNewPlugin);">

			<div class="mura-control-group">
				<label>Upload New Plugin Version</label>
				<input name="newPlugin" type="file" required="true" message="Please select a plugin file.">
			</div>

			<div class="mura-actions">
				<div class="form-actions">
					<button type="submit" class="btn mura-primary"><i class="mi-check-circle"></i>Deploy</button>
				</div>
			</div>

			<input type="hidden" name="moduleID" value="#rc.pluginConfig.getModuleID()#">
			#rc.$.renderCSRFTokens(context=rc.pluginConfig.getModuleID(),format="form")#
			</form>

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->

</cfoutput>
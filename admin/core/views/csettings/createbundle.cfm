 <!--- license goes here --->
<cfoutput>
<div class="alert alert-success">The bundle that you have requested has been created and is now available on your server at <strong>#rc.bundleFilePath#</strong></div>
<div class="mura-header">
	<h1>Bundle Created</h1>
	<div class="nav-module-specific btn-group">
		<a class="btn" href="./?muraAction=cSettings.editSite&siteID=#esapiEncode('url',rc.siteID)#"><i class="mi-arrow-circle-left"></i> Back to Site Settings</a>
	</div>
</div>
<div class="block block-constrain">
	<div class="block block-bordered">
		<div class="block-content">
			<div class="help-block"><strong>Important:</strong> Leaving large bundle files on server can lead to excessive disk space usage.</div>
			<cfif findNoCase(application.configBean.getWebRoot(),rc.bundleFilePath)>
				<cfset downloadURL=replace(application.configBean.getContext() & right(rc.bundleFilePath,len(rc.bundleFilePath)-len(application.configBean.getWebRoot())),"\","/","All")>
					<p><a href="#downloadURL#" class="btn btn-primary">Download Bundle</a></p>
			</cfif>
		</div>
	</div>
</div>
</cfoutput>
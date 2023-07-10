<!--- license goes here --->

<cfoutput><div class="mura-header"><h1>Access Denied</h1></div>
<div class="block block-constrain">
		<div class="block block-bordered">
		  <div class="block-content">
				<p>You have successfully logged in. However, your user account has not been granted permission to access any sites. <br/> If you believe this is an error, contact the system <a href="mailto:#esapiEncode('url',application.configBean.getAdminEmail())#">administrator</a> for assistance.</p>
			</div>
		</div>
</div>

</cfoutput>

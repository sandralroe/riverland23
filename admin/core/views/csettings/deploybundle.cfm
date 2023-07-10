<!--- License goes here --->
<cfoutput>
<script>
	/*jQuery(document).ready(function(){
		jQuery.ajax({
			url: '#application.configBean.getContext()##application.configBean.getAdminDir()#/core/utilities/bundle/feedback.cfm?siteID=<cfoutput>#rc.siteID#</cfoutput>',
			success: function(data) {
				jQuery('##feedbackLoop').html(data);
			}
		});
	});*/
</script>
<h1>Deploy Bundle</h1>
<iframe frameborder="0" src="#application.configBean.getContext()##application.configBean.getAdminDir()#/core/utilities/bundle/feedback.cfm?siteID=<cfoutput>#esapiEncode('url',rc.siteID)#</cfoutput>"></iframe>
</cfoutput>
<!---<cfoutput>#application.pluginManager.announceEvent("onAfterSiteDeployRender",event)#</cfoutput>--->

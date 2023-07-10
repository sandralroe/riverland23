<!--- license goes here --->
<cfset event=request.event>
<cfif rc.action neq  'delete' and not structIsEmpty(rc.feedBean.getErrors())>
<cfinclude template="edit.cfm">
<cfelse>
<cfset request.layout=false>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Close</title>
<cfset contentRenderer=application.settingsManager.getSite(event.getValue("siteID")).getContentRenderer()>
<cfset homeBean = application.contentManager.getActiveContent(event.getValue('homeID'), event.getValue('siteID'))>
<cfset href = contentRenderer.createHREF(homeBean.getType(), homeBean.getFilename(), homeBean.getSiteId(), homeBean.getcontentId())>
<cfoutput>
<script src="#application.configBean.getContext()#/core/vendor/jquery/jquery.min.js?coreversion=#application.coreversion#" type="text/javascript"></script>
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/porthole/porthole.min.js?coreversion=#application.coreversion#" type="text/javascript"></script>
<script>
	function reload(){
		if (top.location != self.location) {

			<cfif rc.$.getContentRenderer().useLayoutmanager()>
				<cfif len(rc.instanceid)>
					var cmd={cmd:'setObjectParams',reinit:true,instanceid:'#rc.instanceid#',params:{sourceid:'#rc.feedBean.getFeedId()#'}};

					<cfif rc.feedBean.getType() eq 'Local'>
						cmd.params.sourcetype='localindex';
					<cfelse>
						cmd.params.sourcetype='remotefeed';
					</cfif>
				<cfelse>
					var cmd={cmd:'reloadObjectAndClose',objectid:'#rc.feedBean.getFeedId()#'};
				</cfif>
				
			<cfelse>
				var cmd={cmd:'setLocation',location:encodeURIComponent("#esapiEncode('javascript',href)#")};
			</cfif>

			frontEndProxy = new Porthole.WindowProxy("#esapiEncode('javascript',session.frontEndProxyLoc)##application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/porthole/proxy.html?cacheid=" + Math.random());

			if (jQuery("##ProxyIFrame").length) {
				jQuery("##ProxyIFrame").load(function(){
					frontEndProxy.post({cmd:'scrollToTop'});
					frontEndProxy.post(cmd);
				});
			} else {
				frontEndProxy.post({cmd:'scrollToTop'});
				frontEndProxy.post(cmd);
			}

		} else {
			location.href="#esapiEncode('javascript',href)#";
		}
	}
	
</script>
</cfoutput>
</head>
<body onload="reload()">
</body>
</html>
</cfif>
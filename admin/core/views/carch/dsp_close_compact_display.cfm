<!--- license goes here --->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<cfsilent>
<cfparam name="session.frontEndProxyLoc" default="">
<cfparam name="rc.parenthistid" default="">
<cfset event=request.event>
<cfset href = "">
<cfif rc.action eq "add">
	<cfif rc.contentBean.getActive()>
		<cfset currentBean = application.contentManager.getActiveContent(rc.contentBean.getContentID(), rc.contentBean.getSiteID())>
	<cfelse>
		<cfset currentBean=rc.contentBean>
	</cfif>
</cfif>
<cfif rc.contentBean.getType() eq 'Variation'>
	<cfset href = rc.contentBean.getRemoteURL()>
<cfelseif len(rc.homeID) gt 0>
	<cfset homeBean = application.contentManager.getActiveContent(event.getValue('homeID'), event.getValue('siteID'))>
	<cfset href = homeBean.getURL(useEditRoute=true)>
<cfelseif rc.action eq "add" and rc.contentBean.getType() neq "File" and rc.contentBean.getType() neq "Link">
	<cfif rc.preview eq 1>
		<cfset href =currentBean.getURL(queryString='previewID=#rc.contentBean.getContentHistID()#',useEditRoute=true)>
	<cfelseif currentBean.getActive() and currentBean.getIsOnDisplay()>
		<cfset href =currentBean.getURL(useEditRoute=true)>
	<cfelse>
		<cfset href =currentBean.getURL(queryString="previewid=#currentBean.getContentHistID()#",useEditRoute=true)>
	</cfif>
<cfelseif rc.action eq "add" and (rc.contentBean.getType() eq "File" or rc.contentBean.getType() eq "Link")>
	<cfset parentBean = application.contentManager.getActiveContent(currentBean.getParentID(), currentBean.getSiteID())>
	<cfif len(rc.parenthistid)
		and parentBean.getContentHistID() neq rc.parenthistid
		and rc.$.getBean('content').loadBy(contenthistid=rc.parenthistid).exists()>
		<cfset href = parentBean.getURL(queryString="previewid=#rc.parenthistid#",useEditRoute=true)>
	<cfelseif parentBean.getActive() and parentBean.getIsOnDisplay()>
		<cfset href = parentBean.getURL(useEditRoute=true)>
	<cfelse>
		<cfset href = parentBean.getURL(queryString="previewid=#parentBean.getContentHistID()#",useEditRoute=true)>
	</cfif>
<cfelseif rc.action eq "multiFileUpload">
	<cfset parentBean = application.contentManager.getActiveContent(rc.parentID, rc.siteID)>
	<cfif len(rc.parenthistid)
		and parentBean.getContentHistID() neq rc.parenthistid
		and rc.$.getBean('content').loadBy(contenthistid=rc.parenthistid).exists()>
		<cfset href = parentBean.getURL(queryString="previewid=#rc.parenthistid#",useEditRoute=true)>
	<cfelseif parentBean.getActive() and parentBean.getIsOnDisplay()>
		<cfset href = parentBean.getURL(useEditRoute=true)>
	<cfelse>
		<cfset href = parentBean.getURL(queryString="previewid=#parentBean.getContentHistID()#",useEditRoute=true)>
	</cfif>
<cfelse>
	<cfset rc.contentBean = application.contentManager.getActiveContent(rc.parentid, rc.siteid)>
	<cfif rc.contentBean.getActive() and rc.contentBean.getIsOnDisplay()>
		<cfset href = rc.contentBean.getURL(useEditRoute=true)>
	<cfelse>
		<cfset href = rc.contentBean.getURL(queryString="previewid=#rc.contentBean.getContentHistID()#",useEditRoute=true)>
	</cfif>
</cfif>
</cfsilent>
<cfoutput>
<script src="#application.configBean.getContext()#/core/vendor/jquery/jquery.min.js?coreversion=#application.coreversion#" type="text/javascript"></script>
<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/porthole/porthole.min.js?coreversion=#application.coreversion#" type="text/javascript"></script>
<script>
	<cfparam name="session.mura.objectInstanceId" default="">
	<cfif rc.$.getContentRenderer().useLayoutmanager() and len(session.mura.objectInstanceId)>
		<cfif rc.contentBean.getType() eq 'Form'>
			var cmd={cmd:'setObjectParams',reinit:true,instanceid:'#session.mura.objectInstanceId#',params:{objectid:'#rc.contentBean.getContentId()#'}};
		<cfelseif rc.contentBean.getType() eq 'Component'>
			var cmd={cmd:'setObjectParams',reinit:true,instanceid:'#session.mura.objectInstanceId#',params:{objectid:'#rc.contentBean.getContentId()#'}};
		<cfelseif len(session.mura.objectInstanceId)>
			var cmd={cmd:'setObjectParams',reinit:true,instanceid:'#session.mura.objectInstanceId#',params:{}};
		<cfelse>
			var cmd={cmd:'setLocation',location:encodeURIComponent("#esapiEncode('javascript',href)#")};
		</cfif>

	<cfelse>
		var cmd={cmd:'setLocation',location:encodeURIComponent("#esapiEncode('javascript',href)#")};
	</cfif>
	<cfset session.mura.objectInstanceId=''>
	function reload(){
		if (top.location != self.location) {
			frontEndProxy = new Porthole.WindowProxy("#esapiEncode('javascript',session.frontEndProxyLoc)##application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/porthole/proxy.html");
			if (jQuery("##ProxyIFrame").length) {
				jQuery("##ProxyIFrame").load(function(){
					frontEndProxy.post({cmd:'scrollToTop'});
					frontEndProxy.post(cmd);
				});
			}
			else {
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

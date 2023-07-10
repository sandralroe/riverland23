<cfscript>
/* license goes here */
if ( isDefined("arguments.ApplicationScope") ) {
	param name="request.muraFrontEndRequest" default=false;
	param name="request.muraChangesetPreview" default=false;
	param name="request.muraChangesetPreviewToolbar" default=false;
	param name="request.muraExportHtml" default=false;
	param name="request.muraMobileRequest" default=false;
	param name="request.muraMobileTemplate" default=false;
	param name="request.muraHandledEvents" default=structNew();
	param name="request.altTHeme" default="";
	param name="request.customMuraScopeKeys" default=structNew();
	param name="request.muraTraceRoute" default=arrayNew(1);
	param name="request.muraRequestStart" default=getTickCount();
	param name="request.muraShowTrace" default=true;
	param name="request.muraValidateDomain" default=true;
	param name="request.muraAppreloaded" default=false;
	param name="request.muratransaction" default=0;
	param name="request.muraDynamicContentError" default=false;
	param name="request.muraPreviewDomain" default="";
	param name="request.muraOutputCacheOffset" default="";
	request.muraSessionManagement=false;

	if(isDefined('arguments.SessionScope')){
		try {
			request.muraSessionPlaceholder=arguments.SessionScope;
			application=arguments.ApplicationScope;
			local.pluginEvent=new mura.event();
			local.pluginEvent.setValue("ApplicationScope",arguments.ApplicationScope);
			local.pluginEvent.setValue("SessionScope",arguments.SessionScope);
			if ( structKeyExists(arguments.SessionScope,"mura") && len(arguments.SessionScope.mura.siteid) ) {
				local.pluginEvent.setValue("siteid",arguments.SessionScope.siteid);
				arguments.ApplicationScope.pluginManager.announceEvent("onSiteSessionEnd",local.pluginEvent);
			} else {
				arguments.ApplicationScope.pluginManager.announceEvent("onGlobalSessionEnd",local.pluginEvent);
			}
		} catch (any cfcatch) {
		}
	}
}
</cfscript>

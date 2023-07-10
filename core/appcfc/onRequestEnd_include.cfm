<cfscript>
/* license goes here */

if ( isDefined("request.servletEvent") ) {
	event=request.servletEvent;
} else if ( isDefined("request.event") ) {
	event=request.event;
} else {
	event=new mura.event();
}

if ( isDefined("application.eventManager") ) {
	application.eventManager.announceEvent("onGlobalRequestEnd",event);
	if(request.muraSessionManagement && isDefined('application.Mura')){
		application.Mura.getBean('utility').checkOutputCacheState(event);
		new mura.executor().execute('/muraWRM/core/appcfc/onRequestEnd_session.cfm');	
	}
}

</cfscript>

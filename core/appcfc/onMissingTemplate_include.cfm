<cfscript>
/* license goes here */
param name="local" default=structNew();
local.pluginEvent="";
if ( structKeyExists(application,"pluginManager") && structKeyExists(application.pluginManager,"announceEvent") ) {
	if ( structKeyExists(request,"servletEvent") ) {
		local.pluginEvent=request.servletEvent;
	} else if ( structKeyExists(request,"event") ) {
		local.pluginEvent=request.event;
	} else {
		local.pluginEvent=new mura.event();
	}
	local.pluginEvent.setValue("targetPage",arguments.targetPage);
	if ( len(local.pluginEvent.getValue("siteID")) ) {
		local.response=application.pluginManager.renderEvent("onSiteMissingTemplate",local.pluginEvent);
		if ( len(local.response) ) {
			writeOutput("#local.response#");
			return true;
		}
		if ( structKeyExists(request.muraHandledEvents,'onSiteMissingTemplate') ) {
			structKeyDelete(request.muraHandledEvents,'onSiteMissingTemplate');
			return true;
		}
	}
	local.response=application.pluginManager.renderEvent("onGlobalMissingTemplate",local.pluginEvent);
	if ( len(local.response) ) {
		writeOutput("#local.response#");
		return true;
	}
	if ( structKeyExists(request.muraHandledEvents,'onGlobalMissingTemplate') ) {
		structKeyDelete(request.muraHandledEvents,'onGlobalMissingTemplate');
		return true;
	}
}
if ( isDefined("application.contentServer") ) {
	request.muraTemplateMissing=true;
	onRequestStart();
	local.fileArray=listToArray(cgi.script_name,"/");
	local.filename="";
	if ( len(application.configBean.getValue('context')) ) {
		local.contextArray=listToArray(application.configBean.getValue('context'),"/");
		local.contextArrayLen=arrayLen(local.contextArray);
		for ( local.i=1 ; local.i<=local.contextArrayLen ; local.i++ ) {
			arrayDeleteAt(local.fileArray, 1);
		}
	}

	if ( local.fileArray[1] != 'index.cfm' && application.settingsManager.siteExists(local.fileArray[1])) {
		siteid=local.fileArray[1];
	} else if (arrayLen(local.fileArray) > 1 && application.settingsManager.siteExists(local.fileArray[2])) {
		siteid=local.fileArray[2];;
	} else {
		siteid=application.contentServer.bindToDomain();
	}

	if(len(cgi.path_info)){
		local.fileArray=ListToArray(cgi.path_info ,"/,\");
	}

	if(arrayLen(local.fileArray) && application.settingsManager.siteExists(local.fileArray[1])){
		local.fileArray=arrayToList(local.fileArray);
		local.fileArray=listToArray(listRest(local.fileArray));
	}

	for ( local.i=1 ; local.i<=arrayLen(local.fileArray) ; local.i++ ) {
		if ( find(".",local.fileArray[local.i]) && local.i < arrayLen(local.fileArray) ) {
			local.filename="";
		} else if ( !(find(".",local.fileArray[local.i]) && listFind(application.configBean.getAllowedIndexFiles(),local.fileArray[local.i])) ) {
			local.filename=listAppend(local.filename,local.fileArray[local.i] , "/");
		}
	}
	firstItem=listFirst(local.filename,'/');
	if ( listFind('_api,tasks',firstItem) ) {
		writeOutput("#application.contentServer.handleAPIRequest('/' & local.filename)#");
		abort;
	} else if ( !len(cgi.path_info) ) {
		// handle /missing.cfm/ file with 404 
		application.contentServer.render404();
	} else {
	
		local.fileArray=ListToArray(cgi.path_info,'\,/');
		local.last=local.fileArray[arrayLen(local.fileArray)];
		local.hasAllowedFile=find(".",local.last) and (application.configBean.getAllowedIndexFiles() eq '*' or listFind(application.configBean.getAllowedIndexFiles(),local.last));

		if (find(".",local.last) and local.hasAllowedFile){
			if (local.last eq 'index.json'){
				request.returnFormat="JSON";
			}
		}
		if( len(cgi.path_info) && right(cgi.path_info,1) != '/' && !local.hasAllowedFile ) {
			url.path=local.filename & '/';
			application.contentServer.forcePathDirectoryStructure(local.filename,siteID);
		}
		application.contentServer.renderFilename(filename=local.filename,siteid=siteid);
	}
	return true;
}
return false;
</cfscript>

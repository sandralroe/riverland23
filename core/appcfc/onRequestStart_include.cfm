<cfprocessingdirective pageencoding="utf-8">
<cfscript>
/* license goes here */
param name="application.setupComplete" default=false;
param name="application.appInitialized" default=false;
param name="application.instanceID" default=createUUID();

setEncoding("url", "utf-8");
setEncoding("form", "utf-8");

/*  Double check that the application has started properly.
If it has not, set application.appInitialized=false. */

try {
	if (  !(
			structKeyExists(application.settingsManager,'validate')
			and application.settingsManager.validate()
			and structKeyExists(application.contentManager,'validate')
			and application.contentManager.validate()
			and application.serviceFactory.containsBean('contentManager')
			and isStruct(application.configBean.getAllValues())
		) ) {
		
		application.appInitialized=false;
		application.broadcastInit=false;

	}
	application.clusterManager.runCommands();
	if ( !application.appInitialized ) {
		request.muraAppreloaded=false;
	}
} catch (any cfcatch) {
	application.appInitialized=false;
	request.muraAppreloaded=false;
	application.broadcastInit=false;
}


if ( isDefined("onApplicationStart") ) {
	if ( (
			not application.setupComplete
		OR
		(
			not request.muraAppreloaded
			and
				(
					not application.appInitialized
					or structKeyExists(url,application.appReloadKey)
				)
		)
	) ) {
		//this lock name needs to match the one in /app/admin/core/controlers/csettings.cfc update
		lock name="appInitBlock#application.instanceID#" type="exclusive" timeout="600" {
			if(!(isDefined('url.method') && url.method == 'processAsyncObject')){
			//  Since the request may have had to wait twice, this code still needs to run
				if ( (not application.appInitialized || structKeyExists(url,application.appReloadKey)) ) {
					include "onApplicationStart_include.cfm";
					if ( isdefined("setupApplication") ) {
						setupApplication();
					}
				}
			}
		}
	}
	if ( !application.setupComplete ) {
		request.renderMuraSetup = true;
		//  go to the index.cfm page (setup)
		include "/muraWRM/core/appcfc/setup_check.cfm";
		include "/muraWRM/core/setup/index.cfm";
		abort;
	}
}

/* Potentially Clear Out Secrets, also in onApplicationStart_include
for(secret in listToArray(structKeyList(request.muraSecrets))){
	structDelete(request.muraSysEnv,'#secret#');
}
*/

for(handlerKey in application.appHandlerLookUp){
	handler=application.appHandlerLookUp['#handlerKey#'];
	if(structKeyExists(handler,'onApplicationLoad') 
		&& (!structKeyExists(handler,'appliedAppLoad') || !handler.appliedAppLoad)
	){
		lock name="appInitBlock#application.instanceID#" type="exclusive" timeout="600" {
			lock name="setSites#application.instanceID#" type="exclusive" timeout="600" {
				if((!structKeyExists(handler,'appliedAppLoad') || !handler.appliedAppLoad)){
					try{
						$=getBean('$').init();
						handler.onApplicationLoad($=$,m=$,Mura=$,event=$.event());
						handler.appliedAppLoad=true;
					} catch(any e){
						writeLog(type="Error", log="exception", text="Error Registering Handler");
						writeLog(type="Error", log="exception", text="#serializeJSON(e)#");
					}
				}
			}
		}
	}
}

application.userManager.setUserStructDefaults();
sessionData=application.userManager.getSession();
if ( isDefined("url.showTrace") && isBoolean(url.showTrace) ) {
	sessionData.mura.showTrace=url.showTrace;
} else if ( !isDefined("sessionData.mura.showTrace") ) {
	sessionData.mura.showTrace=false;
}
request.muraShowTrace=sessionData.mura.showTrace;
if ( !isDefined("application.cfstatic") ) {
	application.cfstatic=structNew();
}
//  Making sure that session is valid
try {
	if ( yesNoFormat(application.configBean.getValue("useLegacySessions")) && structKeyExists(sessionData,"mura") ) {
		if ( (not sessionData.mura.isLoggedIn && isValid("UUID",listFirst(getAuthUser(),"^")))
			or
		(sessionData.mura.isLoggedIn && !isValid("UUID",listFirst(getAuthUser(),"^"))) ) {
			variables.tempcookieuserID=cookie.userID;
			application.loginManager.logout();
		}
	}
} catch (any cfcatch) {
	application.loginManager.logout();
}

if (getSystemEnvironmentSetting('MURA_ENABLEDEVELOPMENTSETTINGS') == "true" && structKeyExists(application, "settingsManager")){
	variables.allSitesEDS = application.settingsManager.getSites();
	for (variables.siteEDS in variables.allSitesEDS) {
		variables.allSitesEDS[variables.siteEDS].setEnableLockdown('');
		variables.allSitesEDS[variables.siteEDS].setUseSSL(0);
	}
}

// settings.custom.vars.cfm reference is for backwards compatability
if ( fileExists(expandPath("/muraWRM/config/settings.custom.vars.cfm")) ) {
	include "/muraWRM/config/settings.custom.vars.cfm";
}

if(application.configBean.getValue(property='rememberme',defaultValue=true)){
	try {
		if ( (not isdefined('cookie.userid') || cookie.userid == '') && structKeyExists(sessionData,"rememberMe") && session.rememberMe == 1 && sessionData.mura.isLoggedIn ) {
			application.utility.setCookie(name="userid",value=sessionData.mura.userID);
			application.utility.setCookie(name="userHash",value=encrypt(application.userManager.readUserHash(sessionData.mura.userID).userHash,application.userManager.readUserPassword(cookie.userid),'cfmx_compat','hex'));
		}
	} catch (any cfcatch) {
		application.utility.deleteCookie(name="userHash");
		application.utility.deleteCookie(name="userid");
	}
	try {
		if ( isDefined('cookie.userid') && cookie.userid != ''
			&& isDefined('cookie.userHash') && cookie.userHash != ''
			&& !sessionData.mura.isLoggedIn ) {
			application.loginManager.rememberMe(cookie.userid,decrypt(cookie.userHash,application.userManager.readUserPassword(cookie.userid),"cfmx_compat",'hex'));
		}
	} catch (any cfcatch) {
	}
	try {
		if ( isDefined('cookie.userid') && cookie.userid != '' && structKeyExists(sessionData,"rememberMe") && sessionData.rememberMe == 0 && sessionData.mura.isLoggedIn ) {
			application.utility.deleteCookie(name="userHash");
			application.utility.deleteCookie(name="userid");
		}
	} catch (any cfcatch) {
		application.utility.deleteCookie(name="userHash");
		application.utility.deleteCookie(name="userid");
	}
}

if(request.muraSessionManagement){
	try {
		param name="sessionData.muraSessionID" default=application.utility.getUUID();
		if ( !structKeyExists(cookie,"MXP_TRACKINGID") ) {
			if ( structKeyExists(cookie,"originalURLToken") ) {
				application.utility.setCookie(name="MXP_TRACKINGID", value=cookie.originalURLToken);
				StructDelete(cookie, 'originalURLToken');
			} else {
				application.utility.setCookie(name="MXP_TRACKINGID", value=sessionData.muraSessionID);
			}
		}
		param name="sessionData.muraTrackingID" default=cookie.MXP_TRACKINGID;
	} catch (any cfcatch) {
	}
}
//  look to see is there is a custom remote IP header in the settings.ini.cfm
variables.remoteIPHeader=application.configBean.getValue("remoteIPHeader");
if ( len(variables.remoteIPHeader) ) {
	try {
		if ( StructKeyExists(GetHttpRequestData().headers, variables.remoteIPHeader) ) {
			request.remoteAddr = GetHttpRequestData().headers[remoteIPHeader];
		} else {
			request.remoteAddr = CGI.REMOTE_ADDR;
		}
	} catch (any cfcatch) {
		request.remoteAddr = CGI.REMOTE_ADDR;
	}
} else {
	request.remoteAddr = CGI.REMOTE_ADDR;
}

if ( findNoCase("iphone",CGI.HTTP_USER_AGENT)
	or
		(
			findNoCase("mobile",CGI.HTTP_USER_AGENT)
			and !reFindNoCase("tablet|ipad|xoom",CGI.HTTP_USER_AGENT)
		) ) {
	request.muraMobileRequest=true;
} else {
	request.muraMobileRequest=false;
}

if ( !request.hasCFApplicationCFM && !fileExists("#expandPath('/muraWRM/config')#/cfapplication.cfm") ) {
	variables.tracePoint=initTracePoint("Writing config/cfapplication.cfm");
	application.serviceFactory.getBean("fileWriter").writeFile(file="#expandPath('/muraWRM/config')#/cfapplication.cfm", output='<!--- Add Custom Application.cfc Vars Here --->');
	commitTracePoint(variables.tracePoint);
}

param name="sessionData.mura.requestcount" default=0;
sessionData.mura.requestcount=sessionData.mura.requestcount+1;
param name="sessionData.mura.csrfsecretkey" default=createUUID();
param name="sessionData.mura.csrfusedtokens" default=structNew();
param name="application.coreversion" default=application.configBean.getVersion();

if (
		request.muraSessionManagement
			&& (
				structKeyExists(request,"doMuraGlobalSessionStart")
				|| !(
					isDefined('cookie.cfid') || isDefined('cookie.cftoken') || isDefined('cookie.jsessionid')
					)
			)
		) {
	application.utility.setSessionCookies();
	application.pluginManager.executeScripts('onGlobalSessionStart');
}
application.pluginManager.executeScripts('onGlobalRequestStart');

// HSTS: https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security
local.HSTSMaxAge=application.configBean.getValue(property='HSTSMaxAge',defaultValue=1200);
local.responseObject=getPageContext().getResponse();

if(local.HSTSMaxAge){
	local.responseObject
		.setHeader('Strict-Transport-Security', 'max-age=#application.configBean.getValue(property='HSTSMaxAge',defaultValue=1200)#');
}
if(application.configBean.getValue(property='generatorheader',defaultValue=true)){
	getPageContext()
		.getResponse()
		.setHeader('Generator', 'Mura #application.serviceFactory.getBean('configBean').getVersion()#');
}

getpagecontext().getResponse().setHeader( 'Cache-Control', 'no-cache="Set-Cookie"' );

</cfscript>
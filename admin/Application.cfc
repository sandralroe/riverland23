/* License goes here */
component extends="framework" output="false" {

	include "../core/appcfc/applicationSettings.cfm";

	if(server.coldfusion.productname != 'ColdFusion Server'){
		backportdir='';
		include "../core/mura/backport/backport.cfm";
	} else {
		backportdir='../core/mura/backport/';
		include "#backportdir#backport.cfm";
	}

	if(not hasPluginMappings){
		//Try and include plugin mappings
		canWriteMode=true;
		hasMappings=true;
		canWriteMappings=true;
		try{
			include "../plugins/mappings.cfm";
		}
		catch(any e){
			if(e.type eq 'missingInclude'){
				hasMappings=false;
			}
		}

		if(not hasMappings){
			include "../core/appcfc/buildPluginMappings.cfm";
		}

	}

	if(not hasPluginCFApplication){
		//Try and include plugin mappings
		canWriteMode=true;
		hasMappings=true;
		canWriteMappings=true;
		try{
			include "../plugins/cfapplication.cfm";
		}
		catch(any e){
			if(e.type eq 'missingInclude'){
				hasMappings=false;
			}
		}

		if(not hasMappings){
			include "../core/appcfc/buildPluginCFApplication.cfm";
		}

	}

	variables.framework=structNew();
	variables.framework.home = "core:home.redirect";
	variables.framework.action="muraAction";
	variables.framework.base="/muraWRM/admin/";
	variables.framework.defaultSubsystem="core";
	variables.framework.usingSubsystems=true;
	variables.framework.applicationKey="muraAdmin";
	variables.framework.siteWideLayoutSubsystem='common';
	variables.framework.diEngine='mura';


	if(structKeyExists(form,"fuseaction")){
		form.muraAction=form.fuseaction;
	}

	if(structKeyExists(url,"fuseaction")){
		url.muraAction=url.fuseaction;
	}

	function setFrameWorkBaseDir(){
		if(isDefined('application.configBean') && len(application.configBean.getAdminDir())){
			variables.framework.base="/muraWRM#application.configBean.getAdminDir()#/";
		} else {
			variables.framework.base="/muraWRM/admin/";
		}
	}

	function setupApplication() output="false"{
		
		param name="application.appInitialized" default=false;

		if(!application.appInitialized){
			param name="application.instanceID" default=createUUID();
			lock name="appInitBlock#application.instanceID#" type="exclusive" timeout="200" {
				include "../core/appcfc/onApplicationStart_include.cfm";
			}
		}

		if(not structKeyExists(application,"muraAdmin") or not hasBeanFactory()){
			setupFrameworkDefaults();
			setupRequestDefaults();
			variables.framework.cache = structNew();
			variables.framework.cache.lastReload = now();
			variables.framework.cache.controllers = structNew();
			variables.framework.cache.services = structNew();
			variables.framework.diEngine = "none";
			application[variables.framework.applicationKey] = variables.framework;
			variables.framework.password=application.appreloadkey;
			try {
				if(not hasBeanFactory()){
					setBeanFactory( application.serviceFactory );
				}
			} catch (any e){}
		}

		setFrameWorkBaseDir();

	}

	function onRequestStart() output="false"{
		

		setFrameWorkBaseDir();


		include "../core/appcfc/onRequestStart_include.cfm";

		try{
			if(not (structKeyExists(application.settingsManager,'validate') and application.settingsManager.validate() and isStruct(application.configBean.getAllValues()))){
				application.appInitialized=false;
			}
		} catch(any e){
			application.appInitialized=false;
			request.muraAppreloaded=false;
		}
		
		try{

			if(application.appInitialized and isDefined('application.scriptProtectionFilter') and application.configBean.getScriptProtect()){

				variables.remoteIPHeader=application.configBean.getValue("remoteIPHeader");

				if(len(variables.remoteIPHeader)){
					try{
						if(StructKeyExists(GetHttpRequestData().headers, variables.remoteIPHeader)){
					    	request.remoteAddr = GetHttpRequestData().headers[remoteIPHeader];
					   	} else {
							request.remoteAddr = CGI.REMOTE_ADDR;
					   	}
					   }
						catch(any e){
							request.remoteAddr = CGI.REMOTE_ADDR;
						}
				} else {
					request.remoteAddr = CGI.REMOTE_ADDR;
				}

				if(application.configBean.getScriptProtect()){

					for(var u in url){
						//url['#u#']=tempCanonicalize(url['#u#'],true,false);
					}

					if(isDefined("url")){
						application.scriptProtectionFilter.scan(
													object=url,
													objectname="url",
													ipAddress=request.remoteAddr,
													useTagFilter=true,
													useWordFilter=true);
					}

					for(var f in form){
						//form['#f#']=tempCanonicalize(form['#f#'],true,false);
					}

					if(isDefined("form")){
						application.scriptProtectionFilter.scan(
													object=form,
													objectname="form",
													ipAddress=request.remoteAddr,
													useTagFilter=true,
													useWordFilter=true);
					}
					try{
						if(isDefined("cgi")){
							application.scriptProtectionFilter.scan(
														object=cgi,
														objectname="cgi",
														ipAddress=request.remoteAddr,
														useTagFilter=true,
														useWordFilter=true,
														fixValues=false);
						}

						for(var c in cookie){
							//cookie['#c#']=tempCanonicalize(cookie['#c#'],true,false);
						}

						if(isDefined("cookie")){
							application.scriptProtectionFilter.scan(
														object=cookie,
														objectname="cookie",
														ipAddress=request.remoteAddr,
														useTagFilter=true,
														useWordFilter=true,
														fixValues=false);
						}
					} catch(any e){}

				}

			}
		} catch(any e){}

		setFrameWorkBaseDir();
		
		super.onRequestStart(argumentCollection=arguments);
	}

	function setupRequest() output="false"{

		if(application.configBean.getAdminSSL() and application.configBean.getForceAdminSSL() and not application.utility.isHTTPS()){
			if(cgi.query_string eq ''){
				page='#cgi.script_name#';
			} else {
				page='#cgi.script_name#?#cgi.QUERY_STRING#';
			}
			location(addtoken="false", url="https://" & listFirst(cgi.http_host,':') & page);
		}

		var httpRequestData = getHttpRequestData();

		if(structKeyExists(httpRequestData.headers,'Origin')){
			var PC = getpagecontext().getresponse();

			if(application.configBean.getValue(property="cors",defaultValue=true)){
				var origin = httpRequestData.headers['Origin'];
				if(application.configBean.getValue(property="individualsitebuilds",defaultValue=false)){
					PC.setHeader( 'Access-Control-Allow-Origin', origin );
				} else {
					var originDomain =reReplace(origin, "^\w+://([^\/:]+)[\w\W]*$", "\1", "one");
					// If the Origin is okay, then echo it back, otherwise leave out the header key
					for(var domain in application.settingsManager.getAccessControlOriginDomainArray() ){
						if( domain == originDomain || len(originDomain) > len(domain) && right(originDomain,len(domain)+1)=='.' & domain ){
							PC.setHeader( 'Access-Control-Allow-Origin', origin );
						}
					}
				}
			}
			
			PC.setHeader( 'Access-Control-Allow-Credentials', 'true' );
		}

		if(httpRequestData.method=='OPTIONS'){
			abort;
		}
		
		var theParam="";
		var temp="";
		var page="";
		var i="";
		var site="";

		if(right(cgi.script_name, Len("index.cfm")) NEQ "index.cfm" and right(cgi.script_name, Len("error.cfm")) NEQ "error.cfm" AND right(cgi.script_name, 3) NEQ "cfc"){
			location(url="./", addtoken="false");
		}

		request.context.currentURL="./";

		var qrystr="";
		var item="";

		for(item in url){
			try{
				qrystr="#qrystr#&#item#=#url[item]#";
			}
			catch(any e){}
		}

		if(len(qrystr)){
			request.context.currentURL=request.context.currentURL & "?" & qrystr;
		}

		StructAppend(request.context, url, "no");
		StructAppend(request.context, form, "no");

		if (IsDefined("request.muraGlobalEvent")){
			StructAppend(request, request.muraGlobalEvent.getAllValues(), "no");
			StructDelete(request,"muraGlobalEvent");
		}

		param name="request.context.moduleid" default="";
		param name="request.context.siteid" default="";
		param name="request.context.muraAction" default="";
		param name="request.context.layout" default="";
		param name="request.context.activetab" default="0";
		param name="request.context.activepanel" default="0";
		param name="request.context.ajax" default="";
		param name="request.context.rb" default="";
		param name="request.context.closeCompactDisplay" default="false";
		param name="request.context.compactDisplay" default="false";
		param name="session.siteid" default="";
		param name="session.keywords" default="";
		param name="session.alerts" default=structNew();

		request.muraAdminRequest=true;

		var sessionData=application.Mura.getSession();

		if(!isDefined('cookie.rb')){
			application.serviceFactory.getBean('utility').setCookie(argumentCollection={name='rb',value='',expires='never',httponly=true,secure=application.configBean.getSecureCookies()});
		}

		application.serviceFactory.getBean('utility').suppressDebugging();

		if(len(request.context.rb)){
			sessionData.rb=request.context.rb;
			if(ListFirst(server.coldfusion.productVersion) >= 10){
				cookie.rb={value="#sessionData.rb#",expires="never",httponly=true,secure=application.configBean.getSecureCookies()};
			}
		}

		if(not application.configBean.getSessionHistory() or application.configBean.getSessionHistory() gte 180){
			param name="sessionData.dashboardSpan" default="30";
		} else {
			param name="sessionData.dashboardSpan" default="#application.configBean.getSessionHistory()#";
		}

		if(not application.configBean.getSessionHistory() or application.configBean.getSessionHistory() gte 180){
			sessionData.dashboardSpan=30;
		} else {
			sessionData.dashboardSpan=application.configBean.getSessionHistory();
		}

		if(request.context.siteid neq '' and (sessionData.siteid neq request.context.siteID)){
			if(application.Mura.getBean('settingsManager').siteExists(request.context.siteid)){
				sessionData.siteid = request.context.siteid;
				sessionData.userFilesPath = "#application.configBean.getAssetPath()#/#request.context.siteid#/assets/";
				sessionData.topID="00000000000000000000000000000000001";
				sessionData.openSectionList="";
			}
		} else if(not len(sessionData.siteID)){
			sessionData.siteID="default";
			sessionData.userFilesPath = "#application.configBean.getAssetPath()#/default/assets/";
			sessionData.topID="00000000000000000000000000000000001";
			sessionData.openSectionList="";
		}

		application.rbFactory.resetSessionLocale();

		if(not structKeyExists(request.context,"siteid")){
			request.context.siteID=sessionData.siteID;
		}

		if(not structKeyExists(sessionData.alerts,'#sessionData.siteid#')){
			sessionData.alerts['#sessionData.siteid#']=structNew();
		}

		if(request.action neq 'core:csettings.editSite'
			&& !len(request.context.siteid) && len(session.siteid)){
			request.context.siteid=session.siteid;
		}

		request.event=new mura.event(request.context);
		request.context.$=request.event.getValue('MuraScope');
		request.muraScope=request.context.$;
		request.m=request.context.$;

		if(request.context.moduleid neq ''){
			sessionData.moduleid = request.context.moduleid;
		}
		
		request.muraScope.siteConfig().holdIfBuilding();

		if(application.serviceFactory.containsBean("userUtility")){
			application.serviceFactory.getBean("userUtility").returnLoginCheck(request.event.getValue("MuraScope"));
		}

		if(application.configBean.getValue(property="disableAdmin",defaultValue=false) or application.configBean.getAdminDomain() neq '' and application.configBean.getAdminDomain() neq listFirst(application.Mura.getBean('utility').getRequestHost())){
			application.contentServer.renderFilename("#application.configBean.getAdminDir()#/",false);
			abort;
		}

		if(sessionData.mura.isLoggedIn and not structKeyExists(sessionData,"siteArray")){
			sessionData.siteArray=[];

			for(site in application.settingsManager.getList()){
				if(application.permUtility.getModulePerm(
					"00000000000000000000000000000000000",
					site.siteid,
					site.publicUserPoolID,
					site.privateUserPoolID
					)
				){
					arrayAppend(sessionData.siteArray,site.siteid);
				}
			}
		}

		if(sessionData.mura.isLoggedIn and structKeyExists(sessionData,"siteArray") and not arrayLen(sessionData.siteArray)){
			if(not listFind(sessionData.mura.memberships,'S2IsPrivate') and not listLast(listFirst(request.context.muraAction,"."),":") eq 'clogin'){
				location(url="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=clogin.logout", addtoken="false");
			} else if(not len(request.context.muraAction)
					or (
							len(request.context.muraAction)
							and not listfindNoCase("clogin,cMessage,cEditprofile",listLast(listFirst(request.context.muraAction,"."),":") )
						)){
				location(url="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cMessage.noaccess", addtoken="false");
			}
		}

		if(not structKeyExists(sessionData,"siteArray")){
			sessionData.siteArray=[];
		}

		param name="sessionData.paramArray" default="#arrayNew(1)#";
		param name="sessionData.paramCount" default="0";
		param name="sessionData.paramCircuit" default="";
		param name="sessionData.paramCategories" default="";
		param name="sessionData.paramGroups" default="";
		param name="sessionData.inActive" default="";
		param name="sessionData.membersOnly" default="false";
		param name="sessionData.visitorStatus" default="All";

		param name="request.context.param" default="";
		param name="request.context.inActive" default="0";
		param name="request.context.categoryID" default="";
		param name="request.context.groupID" default="";
		param name="request.context.membersOnly" default="false";
		param name="request.context.visitorStatus" default="All";

		if(request.context.param neq ''){
			sessionData.paramArray=arrayNew(1);
			sessionData.paramCircuit=listLast(listFirst(request.context.muraAction,'.'),':');
			for(i=1;i lte listLen(request.context.param);i=i+1){
				theParam=listGetAt(request.context.param,i);
				if(request.context['paramField#theParam#'] neq 'Select Field'
				and request.context['paramField#theParam#'] neq ''
				and request.context['paramCriteria#theParam#'] neq ''){
					temp={};
					temp.Field=request.context['paramField#theParam#'];
					temp.Relationship=request.context['paramRelationship#theParam#'];
					temp.Criteria=request.context['paramCriteria#theParam#'];
					temp.Condition=request.context['paramCondition#theParam#'];
					arrayAppend(sessionData.paramArray,temp);
				}
			}

			sessionData.paramCount =arrayLen(sessionData.paramArray);
			sessionData.inActive = request.context.inActive;
			sessionData.paramCategories = request.context.categoryID;
			sessionData.paramGroups = request.context.groupID;
			sessionData.membersOnly = request.context.membersOnly;
			sessionData.visitorStatus = request.context.visitorStatus;

		}

		application.Mura.getBean('utility').setPreviewDomain();

		application.rbFactory.setAdminLocale();

		var previewData=application.serviceFactory.getBean('$').getCurrentUser().getValue("ChangesetPreviewData");
		request.muraChangesetPreview=isStruct(previewData) and previewData.siteID eq request.context.siteid;
		
		application.pluginManager.announceEvent("onAdminRequestStart",request.event);
		
	}	

	function setupSession() output="false"{
		include "../core/appcfc/onSessionStart_include.cfm";
	}

	include "../core/appcfc/onSessionEnd_method.cfm";

	function onError(exception,eventname) output="false"{
		include "../core/appcfc/onError_include.cfm";
	}

	include "../core/appcfc/onMissingTemplate_method.cfm";

	function onRequestEnd(targetPage) output="false"{
		if(isdefined("request.event")){
			application.pluginManager.announceEvent("onAdminRequestEnd",request.event);
			include "../core/appcfc/onRequestEnd_include.cfm";
		}
	}

	function rbKey(key){
		var sessionData=application.Mura.getSession();
		return application.rbFactory.getKeyValue(sessionData.rb,arguments.key);
	}

	public struct function getSubsystemConfig( string subsystem ) {
        if ( structKeyExists( variables.framework.subsystems, subsystem ) && isStruct(variables.framework.subsystems[subsystem])) {
            // return a copy to make it read only from outside the framework:
            return structCopy( variables.framework.subsystems[ subsystem ] );
        }
        return { };
    }

}

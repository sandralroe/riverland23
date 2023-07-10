<!--- license goes here --->
<cftry>
<cfheader statustext="An Error Occurred" statuscode="500">
<cfcatch></cfcatch>
</cftry>
<cfscript>
if ( isDefined('arguments.exception.rootcause.type') && arguments.exception.rootcause.type == 'coldfusion.runtime.AbortException' ) {
	return;
}

errorKeyString='';

if(server.ColdFusion.ProductName != 'Coldfusion Server'){
	backportdir='';
	include "/mura/backport/backport.cfm";

} 

if ( isDefined("arguments.exception.Cause") ) {
	errorData=arguments.exception.Cause;
} else {
	errorData=arguments.exception;
}

errorInstanceCode=createUUID();
errorKeyString="<h3>Error Instance Code: #errorInstanceCode#<br/></h3>";

param name="request.muraTemplateMissing" default=false;
if ( !request.muraTemplateMissing ) {
	param name="local" default=structNew();
	local.pluginEvent="";

	try{
		esapiencode('html','test');

		hasesapiencode=true;
	} catch (Any e){
		hasesapiencode=false;

		try{
			encodeForHTML('html');
			hasencodeforhtml=true;
		} catch (Any e){
			hasencodeforhtml=false;
		}
	};

	writeLog(type="information",file='exception',text="The following error pertains to error instance code: #errorInstanceCode#");
	
	if(server.ColdFusion.ProductName != 'Coldfusion Server'){
		//already gets logged
		logError(errorData);
	} else {
		writeLog(text=serializeJSON(arguments), log="exception", type="Error" );
	}

	if ( structKeyExists(application,"pluginManager") && structKeyExists(application.pluginManager,"announceEvent") ) {
		if ( structKeyExists(request,"servletEvent") ) {
			local.pluginEvent=request.servletEvent;
		} else if ( structKeyExists(request,"event") && isObject(request.event) ) {
			local.pluginEvent=request.event;
		} else {
			try {
				local.pluginEvent=new mura.event();
			} catch (any cfcatch) {}
		}
		if ( isObject(local.pluginEvent) ) {
			local.pluginEvent.setValue("exception",arguments.exception);
			local.pluginEvent.setValue("error",arguments.exception);
			local.pluginEvent.setValue("eventname",arguments.eventname);
			try {
				if ( len(local.pluginEvent.getValue("siteID")) ) {
					application.pluginManager.announceEvent("onSiteError",local.pluginEvent);
				}
				application.pluginManager.announceEvent("onGlobalError",local.pluginEvent);
			} catch (any cfcatch) {
				if(application.configBean.getDebuggingEnabled()){
					arguments.exception=cfcatch;
				}
			}
		}
	}
	if ( structKeyExists(application,"configBean") ) {
		try {
			if ( !application.configBean.getDebuggingEnabled() ) {
				mailto=application.configBean.getMailserverusername();
				if(isDefined('application.serviceFactory')){
					application.serviceFactory.getBean('utility').resetContent();
					application.serviceFactory.getBean('utility').setHeader( statustext="An Error Occurred", statuscode=500 );
				}
				if ( len(application.configBean.getValue("errorTemplate")) ) {
					include application.configBean.getValue('errorTemplate');
				} else {
					include "/muraWRM/core/templates/error.html";
				}
				abort;
			}
		} catch (any cfcatch) {
		}
	} else {
		jvmProps=createObject('java','java.lang.System').getProperties();
		cfcontent(reset="true");
		cfheader(statustext="An Error Occurred", statuscode=500);
		if(structKeyExists(jvmProps,'MURA_ERRORTEMPLATE')){
			include jvmProps['MURA_ERRORTEMPLATE'];
		}else {
			include "/muraWRM/core/templates/error.html";
		}
		abort;
	}
	try {
		if(isDefined('application.serviceFactory')){
			application.serviceFactory.getBean('utility').setHeader( statustext="An Error Occurred", statuscode=500 );
		}
	} catch (any cfcatch) {
	}

	writeOutput('<style type=""text/css"">
		.errorBox {
			margin: 10px auto 10px auto;
			width: 90%;
		}

		.errorBox h1 {
			font-size: 100px;
			margin: 5px 0px 5px 0px;
		}

	</style>
	<div class=""errorBox"">
		<h1>500 Error</h1>
		#errorKeyString#
		<h3>Error Time: #now()#<br/></h3>');
	if ( isdefined('errorData.Message') && len(errorData.Message) ) {

		writeOutput("<h2>");

		if ( hasesapiencode ) {

			writeOutput("#esapiEncode('html',errorData.Message)#");
		} else if ( hasencodeforhtml ) {

			writeOutput("#encodeForHTML(errorData.Message)#");
		} else {

			writeOutput("#htmlEditFormat(errorData.Message)#");
		}

		writeOutput("<br /></h2>");
	}
	if ( isdefined('errorData.DataSource') && len(errorData.DataSource) ) {

		writeOutput("<h3>");

		writeOutput("Datasource:");
		if ( hasesapiencode ) {

			writeOutput("#esapiEncode('html',errorData.DataSource)#");
		} else if ( hasencodeforhtml ) {

			writeOutput("#encodeForHTML(errorData.DataSource)#");
		} else {

			writeOutput("#htmlEditFormat(errorData.DataSource)#");
		}

		writeOutput("<br /></h3>");
	}
	if ( isdefined('errorData.sql') && len(errorData.sql) ) {

		writeOutput("<h4>");

		writeOutput("SQL:");
		if ( hasesapiencode ) {

			writeOutput("#esapiEncode('html',errorData.sql)#");
		} else if ( hasencodeforhtml ) {

			writeOutput("#encodeForHTML(errorData.sql)#");
		} else {

			writeOutput("#htmlEditFormat(errorData.sql)#");
		}

		writeOutput("<br /></h4>");
	}
	if ( isdefined('errorData.errorCode') && len(errorData.errorCode) ) {

		writeOutput("<h3>");

		writeOutput("Code:");
		if ( hasesapiencode ) {

			writeOutput("#esapiEncode('html',errorData.errorCode)#");
		} else if ( hasencodeforhtml ) {

			writeOutput("#encodeForHTML(errorData.errorCode)#");
		} else {

			writeOutput("#htmlEditFormat(errorData.errorCode)#");
		}

		writeOutput("<br /></h3>");
	}
	if ( isdefined('errorData.type') && len(errorData.type) ) {

		writeOutput("<h3>");

		writeOutput("Type:");
		if ( hasesapiencode ) {

			writeOutput("#esapiEncode('html',errorData.type)#");
		} else if ( hasencodeforhtml ) {

			writeOutput("#encodeForHTML(errorData.type)#");
		} else {

			writeOutput("#htmlEditFormat(errorData.type)#");
		}

		writeOutput("<br /></h3>");
	}
	if ( isdefined('errorData.Detail') && len(errorData.Detail) ) {

		writeOutput("<h3>");

		if ( hasesapiencode ) {

			writeOutput("#esapiEncode('html',errorData.Detail)#");
		} else if ( hasencodeforhtml ) {

			writeOutput("#encodeForHTML(errorData.Detail)#");
		} else {

			writeOutput("#htmlEditFormat(errorData.Detail)#");
		}

		writeOutput("<br /></h3>");
	}
	if ( isdefined('errorData.extendedInfo') && len(errorData.extendedInfo) ) {

		writeOutput("<h3>");

		if ( hasesapiencode ) {

			writeOutput("#esapiEncode('html',errorData.extendedInfo)#");
		} else if ( hasencodeforhtml ) {

			writeOutput("#encodeForHTML(errorData.extendedInfo)#");
		} else {

			writeOutput("#htmlEditFormat(errorData.extendedInfo)#");
		}

		writeOutput("<br /></h3>");
	}
	if ( isdefined('errorData.StackTrace') ) {

		writeOutput("<pre>");

		if ( hasesapiencode ) {

			writeOutput("#esapiEncode('html',errorData.StackTrace)#");
		} else if ( hasencodeforhtml ) {

			writeOutput("#encodeForHTML(errorData.StackTrace)#");
		} else {

			writeOutput("#htmlEditFormat(errorData.StackTrace)#");
		}

		writeOutput("</pre><br />");
	}
	if ( isDefined('errorData.TagContext') && isArray(errorData.TagContext) ) {
		for ( errorContexts in errorData.TagContext ) {

			writeOutput("<hr />");
			if ( hasesapiencode ) {
				if ( isDefined('errorContexts.COLUMN') ) {

					writeOutput("Column: #esapiEncode('html',errorContexts.COLUMN)#<br />");
				}
				if ( isDefined('errorContexts.ID') ) {

					writeOutput("ID: #esapiEncode('html',errorContexts.ID)#<br />");
				}
				if ( isDefined('errorContexts.Line') ) {

					writeOutput("Line: #esapiEncode('html',errorContexts.Line)#<br />");
				}
				if ( isDefined('errorContexts.RAW_TRACE') ) {

					writeOutput("Raw Trace: #esapiEncode('html',errorContexts.RAW_TRACE)#<br />");
				}
				if ( isDefined('errorContexts.TEMPLATE') ) {

					writeOutput("Template: #esapiEncode('html',errorContexts.TEMPLATE)#<br />");
				}
				if ( isDefined('errorContexts.TYPE') ) {

					writeOutput("Type: #esapiEncode('html',errorContexts.TYPE)#<br />");
				}
			} else if ( hasencodeforhtml ) {
				if ( isDefined('errorContexts.COLUMN') ) {

					writeOutput("Column: #encodeForHTML(errorContexts.COLUMN)#<br />");
				}
				if ( isDefined('errorContexts.ID') ) {

					writeOutput("ID: #encodeForHTML(errorContexts.ID)#<br />");
				}
				if ( isDefined('errorContexts.Line') ) {

					writeOutput("Line: #encodeForHTML(errorContexts.Line)#<br />");
				}
				if ( isDefined('errorContexts.RAW_TRACE') ) {

					writeOutput("Raw Trace: #encodeForHTML(errorContexts.RAW_TRACE)#<br />");
				}
				if ( isDefined('errorContexts.TEMPLATE') ) {

					writeOutput("Template: #encodeForHTML(errorContexts.TEMPLATE)#<br />");
				}
				if ( isDefined('errorContexts.TYPE') ) {

					writeOutput("Type: #encodeForHTML(errorContexts.TYPE)#<br />");
				}
			} else {
				if ( isDefined('errorContexts.COLUMN') ) {

					writeOutput("Column: #htmlEditFormat(errorContexts.COLUMN)#<br />");
				}
				if ( isDefined('errorContexts.ID') ) {

					writeOutput("ID: #htmlEditFormat(errorContexts.ID)#<br />");
				}
				if ( isDefined('errorContexts.Line') ) {

					writeOutput("Line: #htmlEditFormat(errorContexts.Line)#<br />");
				}
				if ( isDefined('errorContexts.RAW_TRACE') ) {

					writeOutput("Raw Trace: #htmlEditFormat(errorContexts.RAW_TRACE)#<br />");
				}
				if ( isDefined('errorContexts.TEMPLATE') ) {

					writeOutput("Template: #htmlEditFormat(errorContexts.TEMPLATE)#<br />");
				}
				if ( isDefined('errorContexts.TYPE') ) {

					writeOutput("Type: #htmlEditFormat(errorContexts.TYPE)#<br />");
				}
			}

			writeOutput("<br />");
		}
	}

	writeOutput("</div>");
	abort;
}
request.muraTemplateMissing=false;
</cfscript>

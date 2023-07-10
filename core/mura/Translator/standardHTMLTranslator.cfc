/* license goes here */
/**
 * This handles translating a frontend request to html
 */
component extends="mura.baseobject" output="false" hint="This handles translating a frontend request to html" {

	public function translate(required event) output=false {
		var page = "";
		var themePath=arguments.event.getSite().getThemeAssetPath();
		var $=arguments.event.getValue("MuraScope");
		var m=$;
		var mura=arguments.event.getValue("MuraScope");
		var renderer="";
		var siteRenderer=arguments.event.getContentRenderer();
		var themeRenderer=arguments.event.getThemeRenderer();
		var modal="";
		var tracePoint=0;
		var inheritedObjectsPerm="";
		var inheritedObjectsContentID="";
		var defaultTemplatePath = arguments.event.getSite().getTemplateIncludePath() & '/default.cfm';
		var sessionData=getSession();
		request.muraActiveRegions="";
		variables.$=$;
		variables.m=$;
		variables.mura=$;
		
		//Remote site must be rendered via the json api
		if($.siteConfig('isRemote')){
			if(isDefined('url.lockdown')){
				$.redirect($.content().getURL(complete=true,queryString=cgi.query_string), false, 302 );
				$.getBean('utility').excludeFromClientCache();
			} else {
				$.redirect($.content().getURL(complete=true,queryString=cgi.query_string), false, 301 );
			}
		}

		if ( !isNumeric(arguments.event.getValue('startRow')) ) {
			arguments.event.setValue('startRow',1);
		}
		if ( !isNumeric(arguments.event.getValue('pageNum')) ) {
			arguments.event.setValue('pageNum',1);
		}
		if ( sessionData.mura.isLoggedIn && siteRenderer.getShowEditableObjects() ) {
			inheritedObjectsContentID=$.getBean("contentGateway").getContentIDFromContentHistID(contentHistID=$.event('inheritedObjects') );
			if ( len(inheritedObjectsContentID) ) {
				inheritedObjectsPerm=$.getBean('permUtility').getNodePerm($.getBean('contentGateway').getCrumblist(inheritedObjectsContentID,$.event('siteID')));
			} else {
				inheritedObjectsPerm="none";
			}
			$.event("inheritedObjectsPerm",inheritedObjectsPerm);
		}
		
		if ( isObject(themeRenderer) && structKeyExists(themeRenderer,"renderHTMLHeadQueue") ) {
			renderer=themeRenderer;
		} else {
			renderer=siteRenderer;
		}
		
		arguments.event.setValue('themePath',themePath);
		savecontent variable="page" {
			if ( fileExists(expandPath("#$.siteConfig('templateIncludePath')#/#renderer.getTemplate()#") ) ) {
				tracePoint=initTracePoint("#arguments.event.getSite().getTemplateIncludePath()#/#renderer.getTemplate()#");
				include "#arguments.event.getSite().getTemplateIncludePath()#/#renderer.getTemplate()#";
				commitTracePoint(tracePoint);
			} else {
				tracePoint=initTracePoint("#defaultTemplatePath#");
				try {
					include defaultTemplatePath;
				} catch (any cfcatch) {
						writeOutput("#$.getBean('resourceBundle').messageFormat($.rbKey('sitemanager.missingDefaultTemplate'), ['<strong>/#ListRest(defaultTemplatePath, '/')#</strong>'])#");
				}
				commitTracePoint(tracePoint);
			}
		}
		tracePoint=initTracePoint("Rendering HTML Head Queue");
		var renderedQueue=renderer.renderHTMLQueue("Head");
		commitTracePoint(tracePoint);
		var pageLen=len(page);
		tracePoint=initTracePoint("Placing Head Queue");
		page=replace(page,"</head>", renderedQueue & "</head>");
		if(pageLen==len(page)){
			replace(page,"</HEAD>", renderedQueue & "</HEAD>");
		}
		commitTracePoint(tracePoint);
		pageLen=len(page);
		tracePoint=initTracePoint("Rendering HTML Foot Queue");
		renderedQueue=renderer.renderHTMLQueue("Foot");
		commitTracePoint(tracePoint);
		tracePoint=initTracePoint("Placing Foot Queue");
		page=replace(page,"</body>", renderedQueue & "</body>");
		if(pageLen==len(page)){
			replace(page,"</BODY>", renderedQueue & "</BODY>");
		}
		commitTracePoint(tracePoint);
		pageLen=len(page);
		tracePoint=initTracePoint("Rendering HTML BodyStart Queue");
		renderedQueue=renderer.renderHTMLQueue("BodyStart");
		commitTracePoint(tracePoint);
		tracePoint=initTracePoint("Placing BodyStart Queue");
		if(len(renderedQueue)){
			page=reReplace(page, '<body([^>]+)>', '<body\1>#renderedQueue#', 'ALL');
			if(pageLen==len(page)){
				page=reReplace(page, '<BODY([^>]+)>', '<BODY\1>#renderedQueue#', 'ALL');
			}
		}
		commitTracePoint(tracePoint);
		arguments.event.setValue('__MuraResponse__',trim(page));
	}

}

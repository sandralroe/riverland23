component extends="mura.baseobject" accessors=true output=false {

	public function init() {
		return this;
	}

	function getSearchIDX($){
		if(len($.siteConfig('elasticIDX'))){
			return $.siteConfig('elasticIDX');
		} else if (len($.siteConfig('elasticIDXPrefix'))){
			return $.siteConfig('elasticIDXPrefix') & "_" & $.siteConfig('siteid');
		} else {
			return "mura_" & $.siteConfig('siteid');
		}
	}

	//Index an item in ElasticSearch Collection
	public any function addESIndex(string contentId, struct esContent, string contentType, boolean isFullIndex = false) {
		var $ = application.serviceFactory.getBean('$').init(arguments.esContent.siteID);
		var esReturn = "";
		var esRecord = "";
		var r = "";
		var esRecord = $.getbean('content').loadBy(contentid = arguments.esContent.contentid,siteid=arguments.esContent.siteid);
		//For updating the content with the elascticsearch _id
		var queryService = new Query();
		var urs = "";
		var esURL = $.siteConfig('elasticAPI');

		var esCollection = getSearchIDX($);
		var collectionExtensions = "pdf,xls,xlsm,xlsx,xltx,doc,docx,docm,pages,rtf,ppt,pptx,key,txt";

		try {

			if (arguments.contentType eq 'File') {	
				// If it's type file we send to the ingest plugin for indexing
				if (listfindnocase(collectionExtensions,arguments.esContent.fileExt)){
					addESIndexFiles(contentId, arguments.esContent,esRecord);
				}
			} else  {
				// We send to ElasticSearch Directly for indexing

				$.event('esData',arguments.esContent);
				$.announceEvent('onElasticSearchSave');
				
				if(len($.siteConfig('elasticAPIKEY'))){
					cfhttp(method = "POST", url = "#esURL#/#esCollection#/_doc/"&contentId, result = "r") {		
						cfhttpparam(type="header", name="Content-Type", value="application/json");
						cfhttpparam(type="header", name="Authoriztion",value="apikey #$.siteConfig('elasticAPIKEY')#");
						cfhttpparam(type = "body", value = "#serializeJSON(arguments.esContent)#");
					}
				} else {
					cfhttp(method = "POST", url = "#esURL#/#esCollection#/_doc/"&contentId, result = "r") {		
						cfhttpparam(type="header", name="Content-Type", value="application/json");
						cfhttpparam(type = "body", value = "#serializeJSON(arguments.esContent)#");
					}
				}
				

				// If 200 we'll add the es id to the content for future updates
				if (r.responseheader.status_code eq '200' or r.responseheader.status_code eq '201') {
				// Get the index id from the return call and add it to content
					esReturn = deserializeJSON(r.fileContent);


				} else {
					esReturn = "Failed ElasticSearch Request, Error Code:" & r.statuscode & '(' & arguments.esContent.title & '.' & arguments.esContent.contentID & ')';
					writeLog(type="Error", log="exception", text="ElasticSearch Request Error");
					logError(r);
				}

			}

		} catch (any e) {
			esReturn = "Error:" & e.message;
			writeDump(e);
			abort;
		}

		// return esReturn
	}

	//Index file items using the Ingest plugin in Elastic Search.  This parses and indexes files
	public any function addESIndexFiles(string contentId, struct esFileContent, esFileRecord, boolean isFullIndex = false) {
		var $ = application.serviceFactory.getBean('$').init(arguments.esFileContent.siteID);
		var elasticSearchContent = "";
		var esReturn = "";
		var esURL = $.siteConfig('elasticAPI');
		var esCollection =  getSearchIDX($);
		var theFile = $.globalConfig('fileDir') & '/' & arguments.esFileContent.siteID & '/cache/file/' & arguments.esFileContent.fileID & '.' & arguments.esFileContent.fileExt;
		var theURL = "#esURL#/#esCollection#/_doc/" & contentId;
		var dataAttachment = {};
		var r = '';
		//For updating the content with the elascticsearch _id
		var queryService = new Query();
		var urs = "";
	
		try {
			
			if(fileExists(theFile)) {
				//Read the file in Binary
				
				var fileData = fileReadBinary(theFile);
				//Add items to the Body call for the File
			
				dataAttachment['data'] = toBase64(fileData);
				dataAttachment['type'] = "attachment";
				dataAttachment['indexed_chars'] = '-1';
				dataAttachment['contentid'] = arguments.esFileContent.contentid;
				dataAttachment['contenthistid'] = arguments.esFileContent.contenthistid;
				dataAttachment['siteid'] = arguments.esFileContent.siteid;
				dataAttachment['esid'] = arguments.esFileContent.contentid;
				dataAttachment['fileid'] = arguments.esFileContent.fileid;
				dataAttachment['fileExt'] = arguments.esFileContent.fileExt;
				dataAttachment['title'] = arguments.esFileContent.title;
				dataAttachment['summary'] = arguments.esFileContent.summary;
				dataAttachment['metakeywords'] = arguments.esFileContent.metakeywords;
				dataAttachment['tags'] = arguments.esFileContent.tags;
				dataAttachment['categories'] = arguments.esFileContent.categories;
				dataAttachment['restricted'] = arguments.esFileContent.restricted;
				dataAttachment['restrictgroups'] = arguments.esFileContent.restrictgroups;
				
				$.event('esData',dataAttachment);
				$.announceEvent('onElasticSearchSave');

				// Make the call to ES
				if(len($.siteConfig('elasticAPIKEY'))){
					cfhttp(method = "POST", url = "#theURL#"&'?pipeline=attachment', result = "r") {
						cfhttpparam(type="header", name="Content-Type", value="application/json");
						cfhttpparam(type="header", name="Authoriztion",value="apikey #$.siteConfig('elasticAPIKEY')#");
						cfhttpparam(type = "body", value = "#serializeJSON(dataAttachment)#");
					}
				} else {
					cfhttp(method = "POST", url = "#theURL#"&'?pipeline=attachment', result = "r") {
						cfhttpparam(type="header", name="Content-Type", value="application/json");
						cfhttpparam(type = "body", value = "#serializeJSON(dataAttachment)#");
					}
				}
				
				//201 for Created and 200 fur Update
				//If 200 we'll add the es id to the content for future updates
				if (r.responseheader.status_code eq '200' or r.responseheader.status_code eq '201') {
					//Get the index id from the return call and add it to content
					esReturn = deserializeJSON(r.fileContent);
				} else {
					writeLog(type="Error", log="exception", text="ElasticSearch Request Error");
					logError(r);
				}
			} else {
				elasticSearchContent = "Error: File does not exist.";
			}

			savecontent variable="esprocess" {
				writeOutput("<html><body>");
				writeOutput("<p>#esURL#/#esCollection#/_doc/" & arguments.esFileContent.esID & "</p>");
				writeDump(arguments.esFileContent);
				writeOutput("<p></p>");
				writeDump(r);
				writeOutput("<p></p>");
				writeDump(esReturn);
				writeOutput("<p></p>");
				writeDump(eaID);
				writeOutput("<p></p>");
				writeDump(attributeSQL);
				writeOutput("</body></html>");
			}

		} catch (any e) {
			writeLog(type="Error", log="exception", text="ElasticSearch Request Error");
			logError(r);
			elasticSearchContent = "Error: " & e.message;
		}

		// return elasticSearchContent;

	}

	// Deletes individual indexed items
	public any function removeESIndex(string esItemIDs, string siteID) {
	    // Accepts a list of ids to delete from elasticSearch
		var $ = application.serviceFactory.getBean('$').init(arguments.siteID);
		var esURL = $.siteConfig('elasticAPI');
		var esCollection = getSearchIDX($);

		var deleted = {};

		if( len(arguments.esItemIDs) ) {
			try {

				for ( id in arguments.esItemIDs ) {
					// We send to ElasticSearch Directly to delete
					if(len($.siteConfig('elasticAPIKEY'))){
						cfhttp(method = "Delete", url = "#esURL#/#esCollection#/_doc/"&id, result = "r") {
							cfhttpparam(type="header", name="Content-Type", value="application/json");
							cfhttpparam(type="header", name="Authoriztion",value="apikey #$.siteConfig('elasticAPIKEY')#");
						}
					} else {
						cfhttp(method = "Delete", url = "#esURL#/#esCollection#/_doc/"&id, result = "r") {
							cfhttpparam(type="header", name="Content-Type", value="application/json");
						}
					}
					if (r.responseheader.status_code eq '200') {
						//Get the index id from the return call and add it to content
						deletedItem = deserializeJSON(r.fileContent);
						deleted['#id#'] = deletedItem.result;
					} else {
						deleted = "Failed ElasticSearch Request, Error Code:" & r.responseheader.status_code & '(' & id & ')';
					}
				}

			} catch (any e) {
				writeLog(type="Error", log="exception", text="ElasticSearch Request Error");
				logError(r);
				deleted = "Error:" & e.message;
			}
		}

		return deleted;
	}

	// Search call to ElasticSearch Server
	public any function search(keywords, siteid) {
		var $ = application.serviceFactory.getBean('$').init(arguments.siteID);
		var search = "";
		var rtn = StructNew();
		var toQueryString = "";
		var makeFuzzy = "";
		var esURL = $.siteConfig('elasticAPI');
		var esCollection = getSearchIDX($);

		if( len(arguments.keywords) ) {
				// delims = ' ^,'; // loop over words separated by either a space OR a comma
				// for ( x=1; x <= ListLen(delims, '^'); x++ ) {
				// 	delim = ListGetAt(delims, x, '^');
				// 	// let's loop over the keywords...
				// 	for ( i=1; i <= ListLen(arguments.keywords, '#delim#'); i++ ) {
				// 		local.keyword = ListGetAt(arguments.keywords, i, '#delim#');
				// 		local.keyword = replaceNoCase(local.keyword, ',', '', 'ALL');
				// 		//Adds the '~' to each item as well as the full phrase to allow the Fuzzy Search to work
				// 		makeFuzzy = listAppend(makeFuzzy, local.keyword&'~');
				//
				// 	}
				// }
				//
				// //Replaces any , or ' ' with the 'OR' operator to search
				// toQueryString = reReplaceNoCase(trim(makeFuzzy), '([,]+)', ' OR ', 'ALL');

			toQueryString = "(#arguments.keywords#) OR (#getBean('contentGateway').serializeJSONParam(arguments.keywords)#)";
			toQueryString = replace(toQueryString,'"','','all');
		}

		var fieldsList = 'title^5","body^3","summary","attachment.content';
		// { "query" : { "query_string" : { "fields" : [#fieldsList#] , "query" : "#toQueryString#" } } }
		// { "query" : { "query_string" : { "fields" : ["attachment.content","body" ,"title*^5"] , "query" : "Word OR Lorem" } } }

		// {
		// 	"query": {
		// 		"multi_match" : {
		// 		"query": "Pre",
		// 		"fields": [ "body^3", "title^5", "attachment.content^3" ],
		// 		"fuzziness": "AUTO",
		// 		"tie_breaker": 0,
		// 		"type": "most_fields",
		// 		"operator": "OR"
		// 		}
		// 	}
		// }

		var queryStruct = {};
			queryStruct['query'] = {};
			queryStruct['query']['multi_match'] = {}; //https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html
			queryStruct['query']['multi_match']['query'] = "#toQueryString#"; //keywords passed in from search
			queryStruct['query']['multi_match']['fields'] = [#fieldsList#]; //fields to search on
			queryStruct['query']['multi_match']['fuzziness'] = "AUTO"; // https://www.elastic.co/guide/en/elasticsearch/reference/6.0/common-options.html#fuzziness
			queryStruct['query']['multi_match']['tie_breaker'] = 1;
			queryStruct['query']['multi_match']['type'] = "most_fields";
			queryStruct['query']['multi_match']['operator'] = "OR";

		try {

			// Searches are made with a post call with the query in the body
			if(len($.siteConfig('elasticAPIKEY'))){
				cfhttp(method = "POST", url = "#esURL#/#esCollection#/_doc/_search?scroll=10m&size=100", result = "r") {
					cfhttpparam(type="header", name="Content-Type", value="application/json");
					cfhttpparam(type="header", name="Authoriztion",value="apikey #$.siteConfig('elasticAPIKEY')#");
					// serialize keeps the escaped characters in the call.  It was necessary to replace them for the call to work.
					cfhttpparam(type = "body", value = #replaceNoCase(serializeJSON(queryStruct), '\','','ALL')#);
				}
			} else {
				cfhttp(method = "POST", url = "#esURL#/#esCollection#/_doc/_search?scroll=10m&size=100", result = "r") {
					cfhttpparam(type="header", name="Content-Type", value="application/json");
					// serialize keeps the escaped characters in the call.  It was necessary to replace them for the call to work.
					cfhttpparam(type = "body", value = #replaceNoCase(serializeJSON(queryStruct), '\','','ALL')#);
				}
			}
			
			if (r.responseheader.status_code eq '200') {
				//Get the index id from the return call and add it to content
				rtn.results = deserializeJSON(r.fileContent);
				rtn.search = rtn.results.hits.hits;
			} else {
				writeLog(type="Error", log="exception", text="ElasticSearch Request Error");
				logError(r);
				rtn.search[1] = "Failed ElasticSearch Request, Error Code:" & r.responseheader.status_code & '(' & toQueryString & ')';
			}

		} catch (any e) {
			rtn.search[1] = "Error:" & e.message;
		}
		return rtn;
	}


	//helper methods
	public query function searchAsQuery(keywords, siteID) output="true" {
		var $ = application.serviceFactory.getBean('$').init(arguments.siteID);
		var rsESResult=queryNew("contentID,score,body,type,esID","varchar,decimal,varchar,varchar,varchar");
		var rsRaw="";

		if (len(arguments.keywords)) {
			searchCall = search(arguments.keywords,arguments.siteID);
			rsRaw = searchCall.search;
			if(arrayLen(rsRaw) && !structKeyExists(rsRaw[1],"_source")){
				writeDump(rsRaw);
				abort;
			}
			for (i=1;i LTE ArrayLen(rsRaw);i=i+1) {
				queryAddRow(rsESResult,1);
				querysetcell(rsESResult,"contentID",rsRaw[i]._source.contentID,i);
				querysetcell(rsESResult,"score",rsRaw[i]._score,i);
				// Edited to Allow for body to be populated by the attachment.content returned from rsRaw
				// or summary for filetypes indexed but not read in.
				if (!structKeyExists(rsRaw[i]._source, 'attachment') ) {
					// if not contentType File, use the body stored in ElasticSearch
					querysetcell(rsESResult,"body",rsRaw[i]._source.body,i);
				} else {
					// do a check for the attachment.content struct key
					if( structKeyExists(rsRaw[i]._source.attachment, 'content') ) {
						// if it exists use it for the body col
						querysetcell(rsESResult,"body",rsRaw[i]._source.attachment.content,i);
					} else {
						// if it doesnt use the summary for the body
						querysetcell(rsESResult,"body",rsRaw[i]._source.summary,i);
					}
				}
				//querysetcell(rsESResult,"type",rsRaw[i]._source.contentType,i);
				querysetcell(rsESResult,"esID",rsRaw[i]._source.contentid,i);
				if (i eq 400) {
					break;
				}
			}
		}

		return rsESResult;
	}


	public any function stripMarkUp(str) {
		var body=ReReplace(arguments.str, "<[^>]*>","","all");
				body=reReplace(body, '<?[a-zA-Z]*"[^>]*>',"","all");
		var errorStr="";
		var regex1="(\[sava\]|\[mura\]|\[m\]).+?(\[/sava\]|\[/mura\]|\[/m\])";
		var regex2="";
		var finder=reFindNoCase(regex1,body,1,"true");

		while (finder.len[1]) {
			body=replaceNoCase(body,mid(body, finder.pos[1], finder.len[1]),'');
			finder=reFindNoCase(regex1,body,1,"true");
		}

		return body;
	}

	//Used to get plugin id for updateing Plugin Class Extensiong after indexing on Elastic Search
	private any function getExtensionID(siteid,attributeset) {
		var queryService=new Query();
		var rs = "";

		queryService.setSQL(
			"select tca.attributeID from tclassextend tc
			inner join tclassextendsets tcs on tc.subTypeID = tcs.subTypeID
			inner join tclassextendattributes tca on tcs.extendSetID = tca.extendSetID
			where tc.siteID = :siteID and
			Lower(tc.type) = 'base' and
			Lower(tc.subType) = 'default' and
			tca.name = :attributeSet"
		);
		queryService.addParam(
			name='siteID'
			, cfsqltype='cf_sql_varchar'
			, value=arguments.siteID
		);
		queryService.addParam(
			name='attributeSet'
			, cfsqltype='cf_sql_varchar'
			, value=arguments.attributeset
		);
		rs=queryService.execute().getResult();
		return rs.attributeID;
	}

	
	function processContentForElastic(content) output=false {
			
			//  // Elastic Work - Add any new item saved in Mura to the ElasticSearch Collection // 
			//  // activeBean, currentBean, newBean // 
			var esBean = '';
			var rsCategories = '';
			var tags = '';
			var contentCategories = '';
			var esItemsStruct = {};
			var siteid = content.get('siteid');
			if ( !content.getActive() || content.getSearchExclude() ) {
				//  // Content was indexed by Elastic but was removed from search or made inactive, so delete Elastic Index // 
				removeESIndex(esItemIDs=content.getContentID(), siteID=siteid);
			} else if ( ( content.getActive() && listFindNoCase("Page,Folder,Portal,Calendar,Gallery,Link,File", content.getType()) ) ) {
				//  // Add or Update index in Elastic // 
				//  // Get Content Categories // 
				rsCategories = application.contentManager.getCategoriesByHistID(content.getContentHistID());
				//  // Conditional check on the return from rsCategories // 
				contentCategories = [];
				if ( isQuery(rsCategories) ) {
					contentCategories = ListToArray(valueList(rsCategories.Name));
				}

				//  // Get Content Tags // 
				tags = ListToArray(Trim(content.getTags()));
				
				//  //Create a struct of the data we want to send to Elastic Search // 
				esItemsStruct['esid'] = content.getContentID();
				esItemsStruct['contentid'] = content.getContentID();
				esItemsStruct['contenthistid'] = content.getContentHistID();
				esItemsStruct['parentid'] = content.getParentID();
				esItemsStruct['siteid'] = siteid;
				esItemsStruct['fileid'] = content.getFileID();
				esItemsStruct['fileExt'] = content.getFileExt();
				esItemsStruct['title'] = content.getTitle();
				esItemsStruct['menutitle'] = content.getMenuTitle();
				esItemsStruct['filename'] = content.getFileName();
				esItemsStruct['summary'] = stripMarkUp(content.getSummary());
				esItemsStruct['body'] = stripMarkUp(content.getBody());
				esItemsStruct['metakeywords'] = content.getMetakeywords();
				esItemsStruct['tags'] = tags;
				esItemsStruct['categories'] = contentCategories;
				esItemsStruct['restricted'] = yesNoFormat(content.getRestricted());
				esItemsStruct['restrictgroups'] = content.getRestrictgroups();
				esItemsStruct['depth'] = listLen(content.getPath());
				esItemsStruct['orderno'] = ParseNumber(content.get('orderno'));
			
				//  //Send to be indexed // 

				var rs = queryExecute("SELECT * FROM tcontentobjects WHERE contenthistid = :contenthistid ",
					{
						contenthistid: content.get('contenthistid')
					}
				);
				if(rs.recordCount) {
					for(var i = 1; i <= rs.recordCount; i++) {
						
						var params = rs.params[i];
						if(isJSON(params)) {
							params = deserializeJSON(params);

							switch(rs.object[i]) {
								case "text":
									param name = "params.sourcetype" default = "custom";
									param name = "params.source" default = "";
									switch(params.sourcetype) {
										case "custom": 
											esItemsStruct['body'] &= " "&stripMarkUp(params.source);
											break;
										case "component": 
											esItemsStruct['body'] &= " "&stripMarkUp(getBean('content').loadBy(contentid=params.source,siteid=siteid,type="Component").getBody());
											break;
									}
									break;
								case "container":
									param name = "params.content" default = "";
									esItemsStruct['body'] &= " "&params.content;
									break;
							}
						}
					}
				}

				addESIndex(contentId=content.getContentID(), esContent=esItemsStruct, contentType=content.getType());
			}
			//  // End Elastic Work // 
	}

	function removeFromElastic(content) output=false {
		removeESIndex(esItemIDs=content.getContentID(), siteID=content.get('siteid'));
	}

	function rebuildIndex(siteid) {
		var Mura = getBean("mura").init(arguments.siteid);
		var items = Mura.getFeed("content")
			.maxItems(0)
			.itemsPerPage(0)
			.includeHomepage(1)
			.getIterator();
		if(items.hasNext()) {
			while(items.hasNext()) {
				var nextItem = items.next().getContentBean();
				removeFromElastic(nextItem);
				processContentForElastic(nextItem);
			}
		}
	}

}

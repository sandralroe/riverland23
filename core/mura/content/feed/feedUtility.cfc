//  license goes here 
/**
 * This provide content feed utility functionality
 */
component extends="mura.baseobject" output="false" hint="This provide content feed utility functionality" {

	public function init(required any configBean, required any feedDAO, required any contentManager, required any utility) output=false {
		variables.configBean=arguments.configBean;
		variables.feedDAO=arguments.feedDAO;
		variables.contentManager=arguments.contentManager;
		variables.globalUtility=arguments.utility;
		return this;
	}

	public struct function doImport(struct data) output=false {
		var feedItem = structNew();
		var theImport = structNew();
		var xmlFeed = "";
		var items = "";
		var maxItems = 0;
		var content = "";
		var contentBean = "";
		var i = "";
		var c = "";
		var feedItemId = "";
		theImport.feedBean=variables.feedDAO.read(arguments.data.feedID);
		if ( !len(theImport.feedBean.getParentID()) ) {
			theImport.success=false;
			return theImport;
		}
		theImport.ParentBean=variables.contentManager.getActiveContent(theImport.feedBean.getParentID(),theImport.feedBean.getSiteID());
		if ( theImport.ParentBean.getIsNew() || theImport.feedBean.getParentID() == '' ) {
			theImport.success=false;
			return theImport;
		} else {
			cfhttp( attributeCollection=getHTTPAttrs(
			url=theImport.feedBean.getChannelLink(),
			authtype=theImport.feedBean.getAuthType(),
			method="GET",
			resolveurl="Yes",
			throwOnError="Yes") );
			xmlFeed=xmlParse(CFHTTP.FileContent);
			switch ( theImport.feedBean.getVersion() ) {
				case  "RSS 0.920,RSS 2.0":
					items = xmlFeed.rss.channel.item;
					maxItems=arrayLen(items);
					if ( maxItems > theImport.feedBean.getMaxItems() ) {
						maxItems=theImport.feedBean.getMaxItems();
					}
					for ( i=maxItems ; i<=1 ; i+-1 ) {
						try {
							feedItemId=hash(left(items[i].guid.xmlText,255));
						} catch (any cfcatch) {
							feedItemId=hash(left(items[i].link.xmlText,255));
						}
						if ( isdefined('arguments.data.remoteID') && (arguments.data.remoteID == 'All' || listFind(arguments.data.remoteID,feedItemId)) ) {
							contentBean=getBean('content').loadBy(remoteID=feedItemId,siteID=theImport.feedBean.getSiteID());
							feedItem = structNew();
							feedItem.remoteURL=left(items[i].link.xmlText,255);
							feedItem.title=left(items[i].title.xmlText,255);
							feedItem.summary="";
							if ( structKeyExists(items[i],"description") ) {
								feedItem.summary=items[i].description.xmlText;
							} else if ( structKeyExists(items[i],"summary") ) {
								feedItem.summary=items[i].summary.xmlText;
							}
							feedItem.remotePubDate=items[i].pubDate.xmlText;
							if ( isDate(items[i].pubDate.xmlText) ) {
								feedItem.releaseDate=parseDateTime(items[i].pubDate.xmlText);
							}
							feedItem.remoteID=feedItemId;
							try {
								content = xmlFeed.rss.channel.item[i]["content:encoded"];
								if ( ArrayLen(content) ) {
									feedItem.body = content[1].xmlText;
								} else {
									if ( structKeyExists(items[i],"description") ) {
										feedItem.body=items[i].description.xmlText;
									} else if ( structKeyExists(items[i],"summary") ) {
										feedItem.body=items[i].summary.xmlText;
									}
								}
							} catch (any cfcatch) {
								if ( structKeyExists(items[i],"description") ) {
									feedItem.body=items[i].description.xmlText;
								} else if ( structKeyExists(items[i],"summary") ) {
									feedItem.body=items[i].summary.xmlText;
								}
							}
							feedItem.parentID=theImport.feedBean.getParentID();
							feedItem.siteID=theImport.feedBean.getSiteID();
							feedItem.approved=1;
							feedItem.type='Page';
							feedItem.display=1;
							feedItem.isNav=1;
							feedItem.moduleID='00000000000000000000000000000000000';
							feedItem.mode='import';

							if ( theImport.feedBean.getCategoryID() != '' ) {
								for ( c=1 ; c<=listLen(theImport.feedBean.getCategoryID()) ; c++ ) {
									feedItem["categoryAssign#replace(listGetAt(theImport.feedBean.getCategoryID(),c),'-','','ALL')#"]=0;
								}
							}
							contentBean.set(feedItem).save();
							if ( !contentBean.getIsNew() && arguments.data.remoteID == 'All' ) {
								contentBean.deleteVersionHistory();
							}
						}
					}
					theImport.success=true;
					break;
				case  "atom":
				
					break;
			}
		}
		return theImport;
	}

	public function getRemoteFeedData(required feedURL, required maxItems, required timeout="5", required authtype="") output=false {
		var data = "";
		var temp = 0;
		var response=structNew();
		response.maxItems = 0;
		try {
			cfhttp( attributeCollection=getHTTPAttrs(result="temp",
						url=arguments.feedURL,
						authtype=arguments.authtype,
						method="GET",
						resolveurl="Yes",
						throwOnError="Yes",
						charset="UTF-8",
						cachedwithin=createTimeSpan(0,0,1,0),
						timeout="#arguments.timeout#") );
		} catch (any cfcatch) {
			return '';
		}
		data=replace(temp.FileContent,chr(20),'','ALL');
		data=REReplace( data, "^[^<]*", "", "all" );
		if ( isXML(data) ) {
			response.xml=XMLParse(data);
			if ( StructKeyExists(response.xml, "rss") ) {
				response.channelTitle =  response.xml.rss.channel.title.xmlText;
				if ( isdefined("response.xml.rss.channel.item") ) {
					response.itemArray = response.xml.rss.channel.item;
					response.maxItems = arrayLen(response.itemArray);
				} else {
					response.maxItems = 0;
				}
				response.type = "rss";
			} else if ( StructKeyExists(response.xml, "rdf:RDF") ) {
				response.channelArray = XMLSearch(response.xml, "//:channel");
				response.channelTitle =  response.channelArray[1].title.xmlText;
				response.itemArray = XMLSearch(response.channelArray[1], "//:item");
				response.maxItems = arrayLen(response.itemArray);
				response.type = "rdf";
			} else if ( StructKeyExists(response.xml, "feed") ) {
				response.channelTitle =  response.xml.feed.title.xmlText;
				if ( isdefined("response.xml.feed.entry") ) {
					response.itemArray = response.xml.feed.entry;
					response.maxItems = arrayLen(response.itemArray);
				} else {
					response.maxItems = 0;
				}
				response.type = "atom";
			}
			if ( response.maxItems > arguments.MaxItems ) {
				response.maxItems=arguments.MaxItems;
			}
		}
		return response;
	}

}

<!---  license goes here  --->
<!---
 * This provides content feed service level logic functionality
--->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides content feed service level logic functionality">
	<cfscript>

	public function init(required any configBean, required any feedGateway, required any feedDAO, required any utility, required any feedUtility, required any pluginManager, required any trashManager) output=false {
		variables.configBean=arguments.configBean;
		variables.feedgateway=arguments.feedGateway;
		variables.feedDAO=arguments.feedDAO;
		variables.globalUtility=arguments.utility;
		variables.feedUtility=arguments.feedUtility;
		variables.pluginManager=arguments.pluginManager;
		variables.trashManager=arguments.trashManager;
		return this;
	}

	public function getBean(beanName="feed") output=false {
		return super.getBean(arguments.beanName);
	}

	public function getFeeds(string siteID, string type, required boolean publicOnly="false", required boolean activeOnly="false") output=false {
		return variables.feedgateway.getFeeds(arguments.siteID,arguments.type,arguments.publicOnly,arguments.activeOnly);
	}

	public function getFeed(any feedBean, required tag="", required aggregation="false", required applyPermFilter="false", countOnly="false", menuType="default", required from="", required to="", required boolean applyIntervals="true", required boolean allowPublicOffLine=false) output=false {
		return variables.feedgateway.getFeed(
			feedBean=arguments.feedBean
			, tag=arguments.tag
			, aggregation=arguments.aggregation
			, applyPermFilter=arguments.applyPermFilter
			, countOnly=arguments.countOnly
			, menuType=arguments.menuType
			, from=arguments.from
			, to=arguments.to
			, applyIntervals=arguments.applyIntervals
			, allowPublicOffLine=arguments.allowPublicOffLine
		);
	}

	public function getFeedIterator(any feedBean, required tag="", required aggregation="false", required applyPermFilter="false", required from="#now()#", required to="#now()#") output=false {
		var rs =  variables.feedgateway.getFeed(arguments.feedBean,arguments.tag,arguments.aggregation,arguments.applyPermFilter,arguments.from,arguments.to);
		var it = getBean("contentIterator");
		it.setQuery(rs);
		return it;
	}

	public function getcontentItems(feedBean) output=false {
		return variables.feedgateway.getcontentItems(arguments.feedBean);
	}

	public function create(struct data="#structnew()#") output=false {
		var feedBean=getBean("feed");
		var pluginEvent = new mura.event(arguments.data);
		var sessionData=getSession();
		feedBean.set(arguments.data);
		feedBean.validate();
		pluginEvent.setValue("feedBean",feedBean);
		pluginEvent.setValue("bean",feedBean);
		pluginEvent.setValue("siteID",feedBean.getSiteID());
		variables.pluginManager.announceEvent(eventToAnnounce="onBeforeFeedSave",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
		variables.pluginManager.announceEvent(eventToAnnounce="onBeforeFeedCreate",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
		if ( structIsEmpty(feedBean.getErrors()) ) {
			feedBean.setLastUpdate(now());
			feedBean.setLastUpdateBy(left(sessionData.mura.fname & " " & sessionData.mura.lname,50) );
			if ( !(structKeyExists(arguments.data,"feedID") && len(arguments.data.feedID)) ) {
				feedBean.setFeedID("#createUUID()#");
			}
			variables.globalUtility.logEvent("feedID:#feedBean.getfeedID()# Name:#feedBean.getName()# was created","mura-content","Information",true);
			variables.feedDAO.create(feedBean);
			feedBean.setIsNew(0);
			variables.pluginManager.announceEvent(eventToAnnounce="onFeedSave",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
			variables.pluginManager.announceEvent(eventToAnnounce="onFeedCreate",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
			variables.pluginManager.announceEvent(eventToAnnounce="onAfterFeedSave",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
			variables.pluginManager.announceEvent(eventToAnnounce="onAfterFeedCreate",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
		}
		return feedBean;
	}

	public function read(required feedID="", required name="", required remoteID="", required siteID="", required feedBean="") output=false {
		if ( !len(arguments.feedID) && len(arguments.siteid) ) {
			if ( len(arguments.name) ) {
				return readByName(arguments.name,arguments.siteid,arguments.feedBean);
			} else if ( len(arguments.remoteID) ) {
				return readByRemoteID(arguments.remoteID,arguments.siteid,arguments.feedBean);
			}
		}
		var key= "feed" & arguments.siteid & arguments.feedid;
		var site=getBean('settingsManager').getSite(arguments.siteid);
		var cacheFactory=site.getCacheFactory(name="data");
		var bean=arguments.feedBean;
		if ( site.getCache() ) {
			//  check to see if it is cached. if not then pass in the context 
			//  otherwise grab it from the cache 
			if ( !cacheFactory.has( key ) ) {
				bean=variables.feedDAO.read(arguments.feedID,bean);
				if ( !isArray(bean) && !bean.getIsNew() ) {
					cacheFactory.get( key, structCopy(bean.getAllValues()) );
				}
				commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: feedBean, key: #key#}"));
				return bean;
			} else {
				try {
					if ( !isObject(bean) ) {
						bean=getBean("feed");
					}
					commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: feedBean, key: #key#}"));
					bean.setValue('frommuracache',true);
					bean.setAllValues( duplicate(cacheFactory.get( key )) );
					return bean;
				} catch (any cfcatch) {
					bean=variables.feedDAO.read(arguments.feedID,bean);
					if ( !isArray(bean) && !bean.getIsNew() ) {
						cacheFactory.get( key, duplicate(bean.getAllValues()) );
					}
					commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: feedBean, key: #key#}"));
					return bean;
				}
			}
		} else {
			commitTracePoint(initTracePoint(detail="Loading feedBean"));
			return variables.feedDAO.read(arguments.feedID,bean);
		}
	}

	public function readByName(String name, String siteid, required feedBean="") output=false {
		var key= "feed" & arguments.siteid & arguments.name;
		var site=getBean('settingsManager').getSite(arguments.siteid);
		var cacheFactory=site.getCacheFactory(name="data");
		var bean=arguments.feedBean;
		if ( site.getCache() ) {
			//  check to see if it is cached. if not then pass in the context 
			//  otherwise grab it from the cache 
			if ( !cacheFactory.has( key ) ) {
				bean=variables.feedDAO.readByName(arguments.name,arguments.siteid,bean);
				if ( !isArray(bean) && !bean.getIsNew() ) {
					cacheFactory.get( key, duplicate(bean.getAllValues()) );
				}
				commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: contentBean, key: #key#}"));
				return bean;
			} else {
				try {
					if ( !isObject(bean) ) {
						bean=getBean("feed");
					}
					commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: feedBean, key: #key#}"));
					bean.setAllValues( duplicate(cacheFactory.get( key )) );
					bean.setValue('frommuracache',true);
					return bean;
				} catch (any cfcatch) {
					bean=variables.feedDAO.readByName(arguments.name,arguments.siteid,bean);
					if ( !isArray(bean) && !bean.getIsNew() ) {
						cacheFactory.get( key, duplicate(bean.getAllValues()) );
					}
					commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: feedBean, key: #key#}"));
					return bean;
				}
			}
		} else {
			commitTracePoint(initTracePoint(detail="Loading feedBean"));
			return variables.feedDAO.readByName(arguments.name,arguments.siteid,bean);
		}
	}

	public function readByRemoteID(String remoteID, String siteid, required feedBean="") output=false {
		var key= "feed" & arguments.siteid & arguments.remoteid;
		var site=getBean('settingsManager').getSite(arguments.siteid);
		var cacheFactory=site.getCacheFactory(name="data");
		var bean=arguments.feedBean;
		if ( site.getCache() ) {
			//  check to see if it is cached. if not then pass in the context 
			//  otherwise grab it from the cache 
			if ( !cacheFactory.has( key ) ) {
				bean=variables.feedDAO.readByRemoteID(arguments.remoteID,arguments.siteid,bean);
				if ( !isArray(bean) && !bean.getIsNew() ) {
					cacheFactory.get( key, structCopy(bean.getAllValues()) );
				}
				commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: feedBean, key: #key#}"));
				return bean;
			} else {
				try {
					if ( !isObject(bean) ) {
						bean=getBean("feed");
					}
					commitTracePoint(initTracePoint(detail="DATA CACHE HIT: {class: feedBean, key: #key#}"));
					bean.setAllValues( structCopy(cacheFactory.get( key )) );
					bean.setValue('frommuracache',true);
					return bean;
				} catch (any cfcatch) {
					bean=variables.feedDAO.readByRemoteID(arguments.remoteID,arguments.siteid,bean);
					if ( !isArray(bean) && !bean.getIsNew() ) {
						cacheFactory.get( key, structCopy(bean.getAllValues()) );
					}
					commitTracePoint(initTracePoint(detail="DATA CACHE MISS: {class: feedBean, key: #key#}"));
					return bean;
				}
			}
		} else {
			commitTracePoint(initTracePoint(detail="Loading feedBean"));
			return variables.feedDAO.readByRemoteID(arguments.remoteID,arguments.siteid,bean);
		}
	}

	public function purgeFeedCache(feedID, feedBean, broadcast="true") output=false {
		if ( !isDefined("arguments.feedBean") ) {
			arguments.feedBean=read(feedID=arguments.feedID);
		}
		if ( arguments.feedBean.exists() ) {
			var siteid=arguments.feedBean.getSiteid();
			var cache=getBean('settingsManager').getSite(siteid).getCacheFactory(name="data");
			cache.purge("feed" & siteid & arguments.feedBean.getFeedID());
			if ( len(arguments.feedBean.getRemoteID()) ) {
				cache.purge("feed" & siteid & arguments.feedBean.getRemoteID());
			}
			if ( len(arguments.feedBean.getName()) ) {
				cache.purge("feed" & siteid & arguments.feedBean.getName());
			}
		}
		if ( arguments.broadcast ) {
			getBean('clusterManager').purgeFeedCache(userID=arguments.feedBean.getFeedID());
		}
	}

	public struct function doImport(struct data) output=false {
		return variables.feedUtility.doImport(arguments.data);
	}

	public function doAutoImport(siteid) output=false {
		var rs=getFeeds(arguments.siteid,'Remote',0,1);
		var importArgs=structNew();
		importArgs.remoteID='All';

		if(rs.recordcount){
			for (var i = 1; i <= rs.recordcount; i++) { 
				if(rs.autoimport[i] == 1){
					importArgs.feedID=rs.feedID[i];
					variables.feedUtility.doImport(importArgs);
				}
			}
		}
	}

	public function update(struct data="#structnew()#") output=false {
		var feedBean=variables.feedDAO.read(arguments.data.feedID);
		var pluginEvent = new mura.event(arguments.data);
		var sessionData=getSession();
		feedBean.set(arguments.data);
		feedBean.validate();
		pluginEvent.setValue("feedBean",feedBean);
		pluginEvent.setValue("bean",feedBean);
		pluginEvent.setValue("siteID",feedBean.getSiteID());
		variables.pluginManager.announceEvent(eventToAnnounce="onBeforeFeedSave",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
		variables.pluginManager.announceEvent(eventToAnnounce="onBeforeFeedUpdate",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
		if ( structIsEmpty(feedBean.getErrors()) ) {
			variables.globalUtility.logEvent("feedID:#feedBean.getfeedID()# Name:#feedBean.getName()# was updated","mura-content","Information",true);
			feedBean.setLastUpdate(now());
			feedBean.setLastUpdateBy(left(sessionData.mura.fname & " " & sessionData.mura.lname,50) );
			variables.feedDAO.update(feedBean);
			purgeFeedCache(feedBean=feedBean);
			variables.pluginManager.announceEvent(eventToAnnounce="onFeedSave",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
			variables.pluginManager.announceEvent(eventToAnnounce="onFeedUpdate",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
			variables.pluginManager.announceEvent(eventToAnnounce="onAfterFeedSave",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
			variables.pluginManager.announceEvent(eventToAnnounce="onAfterFeedUpdate",currentEventObject=pluginEvent,objectid=feedBean.getFeedID());
		}
		return feedBean;
	}

	public function save(any data="#structnew()#") output=false {
		var feedID="";
		var rs="";
		if ( isObject(arguments.data) ) {
			if ( listLast(getMetaData(arguments.data).name,".") == "feedBean" ) {
				arguments.data=arguments.data.getAllValues();
			} else {
				throw( message="The attribute 'DATA' is not of type 'mura.content.feed.feedBean'", type="custom" );
			}
		}
		if ( structKeyExists(arguments.data,"feedID") ) {
			feedID=arguments.data.feedID;
		} else {
			throw( message="The attribute 'FEEDID' is required when saving a feed.", type="custom" );
		}

		rs=queryExecute(
			"select feedID from tcontentfeeds where feedID= :feedid",
			{
				feedid={cfsqltype='cf_sql_varchar',value=feedID}
			}

		);

		if ( rs.recordcount ) {
			return update(arguments.data);
		} else {
			return create(arguments.data);
		}
	}

	public function delete(String feedID) output=false {
		var feedBean=read(arguments.feedID);
		var pluginEvent = new mura.event(arguments);
		if ( !feedBean.getIsLocked() ) {
			pluginEvent.setValue("feedBean",feedBean);
			pluginEvent.setValue("bean",feedBean);
			pluginEvent.setValue("siteID",feedBean.getSiteID());
			variables.pluginManager.announceEvent(eventToAnnounce="onBeforeFeedDelete",currentEventObject=pluginEvent,objectid=feedBean.getContentID());
			variables.trashManager.throwIn(feedBean,'feed');
			variables.globalUtility.logEvent("feedID:#feedBean.getfeedID()# Name:#feedBean.getName()# was deleted","mura-content","Information",true);
			variables.feedDAO.delete(arguments.feedID);
			purgeFeedCache(feedBean=feedBean);
			variables.pluginManager.announceEvent(eventToAnnounce="onFeedDelete",currentEventObject=pluginEvent,objectid=feedBean.getContentID());
			variables.pluginManager.announceEvent(eventToAnnounce="onAfterFeedDelete",currentEventObject=pluginEvent,objectid=feedBean.getContentID());
		}
	}

	public function getDefaultFeeds(string siteID) output=false {
		return variables.feedgateway.getDefaultFeeds(arguments.siteID);
	}

	public function getFeedsByCategoryID(string categoryID, string siteID) output=false {
		return variables.feedgateway.getFeedsByCategoryID(arguments.categoryID, arguments.siteID);
	}

	</cfscript>

	<cffunction name="allowFeed" output="false" returntype="boolean">
		<cfargument name="feedBean" type="any"  />
		<cfargument name="username"  type="string" default="" />
		<cfargument name="password"  type="string" default="" />
		<cfargument name="userID"  type="string" default="" />

		<cfset var rs="" />
		<cfset var rLen=listLen(arguments.feedBean.getRestrictGroups()) />
		<cfset var G = 0 />
		<cfset var sessionData=getSession()>

		<cfif listFind(sessionData.mura.memberships,'S2IsPrivate;#arguments.feedBean.getSiteID()#')>
			<cfreturn true />
		<cfelseif arguments.feedBean.getIsNew()>
			<cfreturn false>
		<cfelseif  arguments.feedBean.getRestricted()>
			<cfquery name="rs" datasource="#variables.configBean.getReadOnlyDatasource()#"  username="#variables.configBean.getReadOnlyDbUsername()#" password="#variables.configBean.getReadOnlyDbPassword()#">
				select tusers.userid from tusers
				<cfif rLen> inner join tusersmemb
				on(tusers.userid=tusersmemb.userid)</cfif>
				where tusers.type=2
				<cfif len(arguments.userID)>
					tusers.userID=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.userID#">
				<cfelse>
				and tusers.username=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.username#">
				and (tusers.password=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#arguments.password#">
					or
						tusers.password=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#trim(hash(arguments.password))#">)
				</cfif>
				and tusers.siteid='#application.settingsManager.getSite(arguments.feedBean.getSiteID()).getPublicUserPoolID()#'

				<cfif rLen>
				and tusersmemb.groupid in (
				<cfloop from="1" to="#rlen#" index="g">
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#listGetAt(arguments.feedBean.getRestrictGroups(),g)#">
				<cfif g lt rlen>,</cfif>
				</cfloop>)
				</cfif>
			</cfquery>

			<cfif not rs.recordcount>
				<cfreturn false />
			</cfif>
		<cfelse>
			<cfreturn true>
		</cfif>
	</cffunction>

</cfcomponent>

//  license goes here 
/**
 * This provides communication between Mura instances within a cluster
 */
component extends="mura.baseobject" hint="This provides communication between Mura instances within a cluster" {

	public function init(required any configBean) output=false {
		variables.configBean=arguments.configBean;
		variables.broadcastClusterCommands= variables.configBean.getValue(property='broadcastClusterCommands',defaultValue=true) && !variables.configBean.getValue(property='readonly',defaultValue=false);
		variables.broadcastCachePurges=variables.configBean.getValue("broadcastCachePurges") && variables.broadcastClusterCommands;
		variables.broadcastAppreloads=variables.configBean.getValue("broadcastAppreloads") && variables.broadcastClusterCommands;
		variables.clearOldBroadcastCommands=variables.configBean.getValue(property="clearOldBroadcastCommands",defaultValue=true) && variables.broadcastClusterCommands;
		return this;
	}

	public function purgeCache(required siteid="", required name="both") output=false {
		if ( variables.broadcastCachePurges ) {
			if ( listFindNoCase('output,data',arguments.name) ) {
				broadcastCommand("getBean('settingsManager').getSite('#arguments.siteID#').purgeCache(name='#arguments.name#',broadcast=false)");
			} else {
				broadcastCommand("getBean('settingsManager').getSite('#arguments.siteID#').purgeCache(name='output',broadcast=false)");
				broadcastCommand("getBean('settingsManager').getSite('#arguments.siteID#').purgeCache(name='data',broadcast=false)");
			}
		}
	}

	public function purgeUserCache(required userID="") output=false {
		if ( variables.broadcastCachePurges ) {
			broadcastCommand("getBean('userManager').purgeUserCache(userID='#arguments.userID#',broadcast=false)");
		}
	}

	public function purgeFeedCache(required feedID="") output=false {
		if ( variables.broadcastCachePurges ) {
			broadcastCommand("getBean('feedManager').purgeFeedCache(feedID='#arguments.feedID#',broadcast=false)");
		}
	}

	public function purgeCategoryCache(required categoryID="") output=false {
		if ( variables.broadcastCachePurges ) {
			broadcastCommand("getBean('categoryManager').purgeCategoryCache(categoryID='#arguments.categoryID#',broadcast=false)");
		}
	}

	public function purgeCategoryDescendentsCache(required categoryID="") output=false {
		if ( variables.broadcastCachePurges ) {
			broadcastCommand("getBean('categoryManager').purgeCategoryDescendentsCache(categoryID='#arguments.categoryID#',broadcast=false)");
		}
	}

	public function purgeContentCache(required contentID="", required siteID="") output=false {
		if ( variables.broadcastCachePurges ) {
			broadcastCommand("getBean('contentManager').purgeContentCache(contentID='#arguments.contentID#',siteID='#arguments.siteID#',broadcast=false)");
		}
	}

	public function purgeCacheKey(required cacheName="data", required cacheKey="", required siteid="") output=false {
		if ( variables.broadcastCachePurges ) {
			broadcastCommand("getBean('settingsManager').getSite('#arguments.siteid#').getCacheFactory(name='#arguments.cacheName#').purge(key='#arguments.cacheKey#')");
		}
	}

	public function purgeContentDescendentsCache(required contentID="", required siteID="") output=false {
		if ( variables.broadcastCachePurges ) {
			broadcastCommand("getBean('contentManager').purgeContentDescendentsCache(contentID='#arguments.contentID#',siteID='#arguments.siteID#',broadcast=false)");
		}
	}

	public function runCommands() output=false {
		var rsCommands="";
		var tableModifier="";

		if(variables.configBean.getDbType()=='MSSQL'){
			tableModifier="with (nolock)";
		}
		if ( variables.broadcastClusterCommands ) {
			rsCommands=queryExecute(
				"select * from tclustercommands #tableModifier# where instanceID= :instanceid",
				{instanceid={cfsqltype="cf_sql_varchar", value=application.instanceID}},
				variables.configBean.getReadOnlyQRYAttrs()
			);

			if(rsCommands.recordcount){
				for(var i=1;i<=rsCommands.recordcount;i++){
					try{
						evaluate("#rsCommands.command[i]#");
					} catch(any e){
						if ( isDefined('cfcatch') ) {
							cflog( text="Cluster Communication Error -- Command: #rsCommands.command[i]#: #serializeJSON(cfcatch)#", log="exception", type="error" );
						} else {
							cflog( text="Cluster Communication Error -- Command: #rsCommands.command[i]#", log="exception", type="error" );
						}					
					}
					queryExecute(
						"delete from tclustercommands where commandID= :commandid",
						{commandid={cfsqltype="cf_sql_varchar", value="#rsCommands.commandID[i]#"}}
					);
				}
			}

			touchInstance();
		}
	}

	public function broadcastCommand(required command="", required interval="0") output=false {
		if ( variables.broadcastClusterCommands ) {
			var rsPeers=getPeers();
			var broadcastTime=now();
			if ( rsPeers.recordcount ) {
				for(var i=1;i <=rsPeers.recordcount;i++){
					broadcasttime=DateAdd("s", arguments.interval, broadcastTime);
					queryExecute(
						"insert into tclustercommands (commandID,instanceID,command,created)
						values(
							'#createUUID()#',
							:instanceid,
							:command,
							:created
						)",
						{
							instanceid={cfsqltype="cf_sql_varchar", value="#rsPeers.instanceID[i]#"},
							command={cfsqltype="cf_sql_varchar", value="#arguments.command#"},
							created={cfsqltype="cf_sql_timestamp", value="#broadcastTime#"}
						}
					);
				}
			}
		}
	}

	public function reload(broadcast="true") output=false {
		var newInstance=touchInstance();
		if ( !newInstance && arguments.broadcast && variables.broadcastAppreloads ) {
			broadcastCommand(command="getBean('settingsManager').remoteReload()",interval=variables.configBean.getValue(property="broadcastAppreloadInterval",defaultValue=0));
			queryExecute(
				"delete from tclustercommands where instanceid not in (select instanceid from tclusterpeers) and created < :created",
				{created={cfsqltype="cf_sql_timestamp", value=dateAdd('d',-1,now())}}
			);
			queryExecute(
				"delete from tclusterpeers where instanceid <> :instanceid",
				{instanceid={cfsqltype="cf_sql_varchar", value=application.instanceID}}
			);
		}
	}

	public function touchInstance() output=false {
		if ( !hasInstance() && variables.broadcastClusterCommands ) {
			queryExecute(
				"insert into tclusterpeers (instanceID) values( :instanceid )",
				{instanceid={cfsqltype="cf_sql_varchar", value=application.instanceID}}
			);
			return true;
		} else {
			return false;
		}
	}

	public function purgeInstance() output=false {
		if ( variables.broadcastClusterCommands ) {
			queryExecute(
				"delete from tclusterpeers where instanceid= :instanceid ",
				{insanceid={cfsqltype="cf_sql_varchar", value=application.instanceID}}
			);
			queryExecute(
				"delete from tclustercommands where instanceid= :instanceid ",
				{insanceid={cfsqltype="cf_sql_varchar", value=application.instanceID}}
			);
		}
	}

	public function hasInstance() output=false {
		return queryExecute(
			"select instanceID from tclusterpeers where instanceID= :instanceid",
			{instanceid={cfsqltype="cf_sql_varchar", value=application.instanceID }},
			variables.configBean.getReadOnlyQRYAttrs()
		).recordcount;
	}

	public function getPeers() output=false {
		return queryExecute(
			"select instanceID from tclusterpeers where instanceID <> :instanceid",
			{instanceid={cfsqltype="cf_sql_varchar", value=application.instanceID }},
			variables.configBean.getReadOnlyQRYAttrs()
		);
	}

	public function clearOldCommands() output=false {
		if ( variables.clearOldBroadcastCommands ) {
			queryExecute(
				"delete from tclusterpeers
					where instanceid in (
						select instanceid from
						tclustercommands where created < :created
					)",
				{created={cfsqltype="cf_sql_timestamp", value=dateAdd('d',-1,now())}}
			);
			queryExecute(
				"delete from tclustercommands where created < :created",
				{created={cfsqltype="cf_sql_timestamp", value=dateAdd('d',-1,now())}}
			);
		}
	}

}

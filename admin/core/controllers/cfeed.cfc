/* license goes here */
component extends="controller" output="false" {

	public function setFeedManager(feedManager) output=false {
		variables.feedManager=arguments.feedManager;
	}

	public function setContentUtility(ContentUtility) output=false {
		variables.contentUtility=arguments.contentUtility;
	}

	public function before(rc) output=false {
		if ( !variables.settingsManager.getSite(arguments.rc.siteid).getHasfeedManager() || (not listFind(session.mura.memberships,'Admin;#variables.settingsManager.getSite(arguments.rc.siteid).getPrivateUserPoolID()#;0') && !listFind(session.mura.memberships,'S2')) && !( variables.permUtility.getModulePerm('00000000000000000000000000000000011',arguments.rc.siteid) && variables.permUtility.getModulePerm('00000000000000000000000000000000000',arguments.rc.siteid)) ) {
			secure(arguments.rc);
		}
		param default=1 name="arguments.rc.startrow";
		param default="" name="arguments.rc.keywords";
		param default="" name="arguments.rc.categoryID";
		param default="" name="arguments.rc.contentID";
		param default=0 name="arguments.rc.restricted";
		param default="" name="arguments.rc.closeCompactDisplay";
		param default="" name="arguments.rc.compactDisplay";
		param default="" name="arguments.rc.homeID";
		param default="" name="arguments.rc.action";
		param default="" name="arguments.rc.assignmentID";
		param default=0 name="arguments.rc.regionID";
		param default=0 name="arguments.rc.orderno";
		param default="" name="arguments.rc.instanceParams";
		param default="" name="arguments.rc.instanceid";
	}

	public function list(rc) output=false {
		arguments.rc.rsLocal=variables.feedManager.getFeeds(arguments.rc.siteID,'Local');
		arguments.rc.rsRemote=variables.feedManager.getFeeds(arguments.rc.siteID,'Remote');
	}

	public function edit(rc) output=false {
		arguments.rc.rsRestrictGroups=variables.contentUtility.getRestrictGroups(arguments.rc.siteid);
		arguments.rc.feedBean=variables.feedManager.read(feedid=arguments.rc.feedID,siteid=arguments.rc.siteid);
		arguments.rc.rslist=variables.feedManager.getcontentItems(arguments.rc.feedBean);
	}

	public function update(rc) output=false {
		if ( rc.$.validateCSRFTokens(context=arguments.rc.feedid) ) {
			if ( arguments.rc.action == 'update' ) {
				if ( len(arguments.rc.assignmentID) && isJSON(arguments.rc.instanceParams) ) {
					getBean("contentManager").updateContentObjectParams(arguments.rc.assignmentID,arguments.rc.regionID,arguments.rc.orderno,arguments.rc.instanceParams);
					arguments.rc.feedBean=variables.feedManager.read(feedid=arguments.rc.feedID,siteid=arguments.rc.siteid);
				} else {
					arguments.rc.feedBean=variables.feedManager.update(arguments.rc);
				}
			}
			if ( arguments.rc.action == 'delete' ) {
				variables.feedManager.delete(arguments.rc.feedID,arguments.rc.siteid);
			}
			if ( arguments.rc.action == 'add' ) {
				arguments.rc.feedBean=variables.feedManager.create(arguments.rc);
				if ( structIsEmpty(arguments.rc.feedBean.getErrors()) ) {
					arguments.rc.feedID=rc.feedBean.getFeedID();
				}
			}
			if ( arguments.rc.closeCompactDisplay != 'true' && !(arguments.rc.action !=  'delete' && !structIsEmpty(arguments.rc.feedBean.getErrors())) ) {
				variables.fw.redirect(action="cFeed.list",append="siteid",path="./");
			}
			if ( arguments.rc.action !=  'delete' && !structIsEmpty(arguments.rc.feedBean.getErrors()) ) {
				arguments.rc.rsRestrictGroups=variables.contentUtility.getRestrictGroups(arguments.rc.siteid);
				arguments.rc.rslist=variables.feedManager.getcontentItems(arguments.rc.feedBean);
			}
		} else {
			variables.fw.redirect(action="cFeed.list",append="siteid",path="./");
		}
	}

	public function import2(rc) output=false {
		arguments.rc.theImport=variables.feedManager.doImport(arguments.rc);
	}

}

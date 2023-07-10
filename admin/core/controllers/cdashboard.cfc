/* license goes here */
component extends="controller" output="false" {

	public function setDashboardManager(dashboardManager) output=false {
		variables.dashboardManager=arguments.dashboardManager;
	}

	public function setUserManager(userManager) output=false {
		variables.userManager=arguments.userManager;
	}

	public function before(rc) output=false {
		param default=1 name="arguments.rc.startrow";
		param default="" name="arguments.rc.keywords";
		param default=10 name="arguments.rc.limit";
		param default=1 name="arguments.rc.threshold";
		param default="" name="arguments.rc.siteID";
		param default=now() name="session.startDate";
		param default=now() name="session.stopDate";
		param default=false name="arguments.rc.membersOnly";
		param default="All" name="arguments.rc.visitorStatus";
		param default="" name="arguments.rc.contentID";
		param default="" name="arguments.rc.direction";
		param default="" name="arguments.rc.orderby";
		param default=1 name="arguments.rc.page";
		param default=session.dashboardSpan name="arguments.rc.span";
		param default="d" name="arguments.rc.spanType";
		param default=dateAdd('#rc.spanType#',-rc.span,now()) name="arguments.rc.startDate";
		param default=now() name="arguments.rc.stopDate";
		param default=false name="arguments.rc.newSearch";
		param default=false name="arguments.rc.startSearch";
		param default="" name="arguments.rc.returnurl";
		param default="" name="arguments.rc.layout";
		param default="" name="arguments.rc.ajax";
		if ( (not listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(arguments.rc.siteid).getPrivateUserPoolID()#;0') && !listFind(session.mura.memberships,'S2')) && !application.permUtility.getModulePerm('00000000000000000000000000000000000',arguments.rc.siteid) ) {
			secure(arguments.rc);
		}
		if ( !LSisDate(arguments.rc.startDate) && !LSisDate(session.startDate) ) {
			session.startdate=now();
		}
		if ( !LSisDate(arguments.rc.stopDate) && !LSisDate(session.stopDate) ) {
			session.stopdate=now();
		}
		if ( arguments.rc.startSearch && LSisDate(arguments.rc.startDate) ) {
			session.startDate=rc.startDate;
		}
		if ( arguments.rc.startSearch && LSisDate(arguments.rc.stopDate) ) {
			session.stopDate=rc.stopDate;
		}
		if ( arguments.rc.newSearch ) {
			session.stopDate=now();
			session.startDate=now();
		}
	}

	public function listSessions(rc) output=false {
		arguments.rc.rslist=variables.dashboardManager.getSiteSessions(arguments.rc.siteid,arguments.rc.contentid,arguments.rc.membersOnly,arguments.rc.visitorStatus,arguments.rc.span,arguments.rc.spanType);
	}

	public function sessionSearch(rc) output=false {
		arguments.rc.rsGroups=variables.userManager.getPublicGroups(arguments.rc.siteid,1);
	}

	public function viewsession(rc) output=false {
		arguments.rc.rslist=application.dashboardManager.getSessionHistory(arguments.rc.urlToken,arguments.rc.siteID);
	}

	public function dismissAlert(rc) output=false {
		var alerts=session.mura.alerts['#rc.siteid#'];
		if ( listFindNoCase('defaultpasswordnotice,cachenotice',rc.alertid) ) {
			alerts[rc.alertid]=false;
		} else {
			structDelete(alerts, rc.alertid);
		}
		abort;
	}

}

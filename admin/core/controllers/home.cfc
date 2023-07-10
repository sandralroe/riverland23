/* license goes here */
component extends="controller" output="false" {

	public function setContentServer(ContentServer) output=false {
		variables.contentServer=arguments.contentServer;
	}

	public function redirect(rc) output=false {
		var siteID="";
		var rsList="";
		var qs="";
		var rsDefault=structNew();
		arguments.rc.siteid="";
		if ( !getCurrentUser().isLoggedIn() ) {
			variables.fw.redirect(action="clogin.main",path="./");
		}
		rsList=application.settingsManager.getUserSites(session.siteArray,listFind(session.mura.memberships,'S2'));
		siteID=application.contentServer.bindToDomain(isAdmin=true);
		if ( siteID != "--none--" ) {
			qs=new Query();
			qs.addParam(name="siteid",cfsqltype="cf_sql_varchar",value=siteID);
			qs.setDbType('query');
			qs.setAttributes(rsList=rsList);
			rsDefault=qs.execute(sql="SELECT siteid FROM rsList WHERE siteid = :siteid").getResult();

		} else {
			rsDefault.recordcount=0;
		}
		if ( rsDefault.recordcount ) {
			arguments.rc.siteid=rsDefault.siteid;
		} else if ( rsList.recordcount ) {
			qs=new Query();
			qs.setDbType('query');
			qs.setAttributes(rsList=rsList);
			rsDefault=qs.execute(sql="SELECT siteid FROM rsList order by orderno").getResult();
			arguments.rc.siteid=rsDefault.siteid;
		}
		if ( len(arguments.rc.siteid)) {
			if ( rc.$.siteConfig().getValue(property='showDashboard',defaultValue=0) && listFind(session.mura.memberships,'S2IsPrivate') ) {
				variables.fw.redirect(action="cDashboard.main",append="siteid",path="./");
			} else {
				arguments.rc.moduleid="00000000000000000000000000000000000";
				arguments.rc.topid="00000000000000000000000000000000001";
				variables.fw.redirect(action="cArch.list",append="siteid,moduleid,topid",path="./");
			}
		}
		if(listFind(session.mura.memberships,'S2IsPrivate')){
			variables.fw.redirect(action="cMessage.noAccess",path="./");
		} else {
			variables.fw.redirect(action="clogin.main",path="./");
		}
	}

}

/* license goes here */
component extends="controller" output="false" {

	public function before(rc) output=false {
		if ( 
			not getCurrentUser().isAdminUser()
		 ) {
			secure(arguments.rc);
		}
		param default="" name="arguments.rc.parentid";
		param default="" name="arguments.rc.topid";
		param default="" name="arguments.rc.contentid";
		param default="" name="arguments.rc.body";
		param default="" name="arguments.rc.Contentid";
		param default="" name="arguments.rc.groupid";
		param default="" name="arguments.rc.url";
		param default="" name="arguments.rc.type";
		param default=1 name="arguments.rc.startrow";
		param default="" name="arguments.rc.siteid";
		param default="" name="arguments.rc.approvalExempt";
		param default="" name="arguments.rc.chainID";
		param default="" name="arguments.rc.exemptID";
		param default=00000000000000000000000000000000001, name="arguments.rc.topid";
	}

	public function update(rc) output=false {
		if ( rc.$.validateCSRFTokens(context=rc.contentid) ) {
			variables.permUtility.update(arguments.rc);
			getBean('approvalChainAssignment')
				.loadBy(siteID=arguments.rc.siteid, contentID=arguments.rc.contentID)
				.setChainID(arguments.rc.chainID)
				.setExemptID(arguments.rc.exemptID)
				.save();
		}
		variables.fw.redirect(action="cArch.list",append="siteid,moduleid,startrow,topid",path="./");
	}

	public function main(rc) output=false {
		arguments.rc.rscontent=variables.permUtility.getcontent(arguments.rc);
	}

	public function module(rc) output=false {
		arguments.rc.groups=variables.permUtility.getGrouplist(arguments.rc);
		arguments.rc.rsContent=variables.permUtility.getModule(arguments.rc);
	}

	public function leveledmodule(rc) output=false {
		arguments.rc.groups=variables.permUtility.getGrouplist(arguments.rc);
		arguments.rc.rsContent=variables.permUtility.getModule(arguments.rc);
	}

	public function updateleveledmodule(rc) output=false {
		if ( rc.$.validateCSRFTokens(context=rc.moduleid) ) {
			variables.permUtility.update(arguments.rc);
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000008' ) {
			variables.fw.redirect(action="cUsers.listusers",append="siteid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000019' ) {
			variables.fw.redirect(action="cChain.list",append="siteid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000020' ) {
			variables.fw.redirect(action="cProxy.list",append="siteid",path="./");
		}
		variables.fw.redirect(action="cPlugins.list",append="siteid",path="./");
	}

	public function updatemodule(rc) output=false {
		if ( rc.$.validateCSRFTokens(context=rc.moduleid) ) {
			variables.permUtility.updateModule(arguments.rc);
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000004' ) {
			variables.fw.redirect(action="cUsers.list",append="siteid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000005' ) {
			variables.fw.redirect(action="cEmail.list",append="siteid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000007' ) {
			variables.fw.redirect(action="cForm.list",append="siteid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000009' ) {
			variables.fw.redirect(action="cMailingList.list",append="siteid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000000' 
			||  arguments.rc.moduleid == '00000000000000000000000000000000017') {
			arguments.rc.moduleid="00000000000000000000000000000000000";
			arguments.rc.topid="00000000000000000000000000000000001";
			variables.fw.redirect(action="cArch.list",append="siteid,topid,moduleid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000006' ) {
			variables.fw.redirect(action="cAdvertising.listAdvertisers",append="siteid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000010' ) {
			variables.fw.redirect(action="cCategory.list",append="siteid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000011' ) {
			variables.fw.redirect(action="cFeed.list",append="siteid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000014' ) {
			variables.fw.redirect(action="cChangesets.list",append="siteid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000015' ) {
			variables.fw.redirect(action="cComments.default",append="siteid",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000016' ) {
			rc.activeTab=2;
			variables.fw.redirect(action="cArch.list",append="siteid,activeTab",path="./");
		}
		if ( arguments.rc.moduleid == '00000000000000000000000000000000018' ) {
			rc.activeTab=2;
			variables.fw.redirect(action="cFilemanager.default",append="siteid",path="./");
		}
		variables.fw.redirect(action="cPlugins.list",append="siteid",path="./");
	}

}

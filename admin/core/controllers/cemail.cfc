/* license goes here */
component extends="controller" output="false" {

	public function setEmailManager(emailManager) output=false {
		variables.emailManager=arguments.emailManager;
	}

	public function before(rc) output=false {
		if ( (not listFind(session.mura.memberships,'Admin;#variables.settingsManager.getSite(arguments.rc.siteid).getPrivateUserPoolID()#;0') && !listFind(session.mura.memberships,'S2')) && !( variables.permUtility.getModulePerm('00000000000000000000000000000000005',arguments.rc.siteid) && variables.permUtility.getModulePerm('00000000000000000000000000000000000',arguments.rc.siteid)) ) {
			secure(arguments.rc);
		}
		session.moduleID="00000000000000000000000000000000005";
		param default="list" name="arguments.rc.muraAction";
		param default="" name="arguments.rc.subject";
		param default="" name="arguments.rc.bodytext";
		param default="" name="arguments.rc.bodyhtml";
		param default="" name="arguments.rc.createddate";
		param default="" name="arguments.rc.deliverydate";
		param default="" name="arguments.rc.grouplist";
		param default="" name="arguments.rc.groupid";
		param default="" name="arguments.rc.emailid";
		param default=2 name="arguments.rc.status";
		param default="" name="arguments.rc.lastupdatebyid";
		param default="" name="arguments.rc.lastupdateby";
		param default=2 name="session.emaillist.status";
		param default="" name="session.emaillist.groupid";
		param default="" name="session.emaillist.subject";
		param default=1 name="session.emaillist.dontshow";
	}

	public function list(rc) output=false {
		arguments.rc.rsList=variables.emailManager.getList(arguments.rc);
		arguments.rc.rsPrivateGroups=variables.emailManager.getPrivateGroups(arguments.rc.siteid);
		arguments.rc.rsPublicGroups=variables.emailManager.getPublicGroups(arguments.rc.siteid);
		arguments.rc.rsMailingLists=variables.emailManager.getMailingLists(arguments.rc.siteid);
	}

	public function edit(rc) output=false {
		arguments.rc.emailBean=variables.emailManager.read(arguments.rc.emailid);
		arguments.rc.rsPrivateGroups=variables.emailManager.getPrivateGroups(arguments.rc.siteid);
		arguments.rc.rsPublicGroups=variables.emailManager.getPublicGroups(arguments.rc.siteid);
		arguments.rc.rsMailingLists=variables.emailManager.getMailingLists(arguments.rc.siteid);
		arguments.rc.rsTemplates=variables.emailManager.getTemplates(arguments.rc.siteid);
	}

	public function update(rc) output=false {
		variables.emailManager.update(arguments.rc);
		variables.fw.redirect(action="cEmail.list",append="siteid",path="./");
	}

	public function showAllBounces(rc) output=false {
		arguments.rc.rsBounces=variables.emailManager.getAllBounces(arguments.rc);
	}

	public function showBounces(rc) output=false {
		arguments.rc.rsBounces=variables.emailManager.getBounces(arguments.rc.emailid);
	}

	public function showReturns(rc) output=false {
		arguments.rc.rsReturns=variables.emailManager.getReturns(arguments.rc.emailid);
		arguments.rc.rsReturnsByUser=variables.emailManager.getReturnsByUser(arguments.rc.emailid);
	}

	public function deleteBounces(rc) output=false {
		variables.emailManager.deleteBounces(arguments.rc);
		location(url="./?muraAction=cEmail.showAllBounces&siteid=#arguments.rc.siteid#",addToken=false );
	}

}

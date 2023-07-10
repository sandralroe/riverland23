/* license goes here */
component extends="controller" output="false" {

	public function setMailingListManager(mailingListManager) output=false {
		variables.mailingListManager=arguments.mailingListManager;
	}

	public function before(rc) output=false {
		if ( (not listFind(session.mura.memberships,'Admin;#variables.settingsManager.getSite(arguments.rc.siteid).getPrivateUserPoolID()#;0') && !listFind(session.mura.memberships,'S2')) && !( variables.permUtility.getModulePerm('00000000000000000000000000000000009','#rc.siteid#') && variables.permUtility.getModulePerm('00000000000000000000000000000000000','#rc.siteid#')) ) {
			secure(arguments.rc);
		}
		param default=1 name="arguments.rc.startrow";
	}

	public function list(rc) output=false {
		arguments.rc.rslist=variables.mailinglistManager.getList(arguments.rc.siteid);
	}

	public function edit(rc) output=false {
		arguments.rc.listBean=variables.mailinglistManager.read(arguments.rc.mlid,arguments.rc.siteid);
	}

	public function listmembers(rc) output=false {
		arguments.rc.listBean=variables.mailinglistManager.read(arguments.rc.mlid,arguments.rc.siteid);
		arguments.rc.rslist=variables.mailinglistManager.getListMembers(arguments.rc.mlid,arguments.rc.siteid);
		arguments.rc.nextn=variables.utility.getNextN(arguments.rc.rslist,30,arguments.rc.startrow);
	}

	public function update(rc) output=false {
		if ( arguments.rc.action == 'add' ) {
			arguments.rc.listBean=variables.mailinglistManager.create(arguments.rc);
			arguments.rc.mlid= rc.listBean.getMLID();
		}
		if ( arguments.rc.action == 'update' ) {
			variables.mailinglistManager.update(arguments.rc);
		}
		if ( arguments.rc.action == 'delete' ) {
			variables.mailinglistManager.delete(arguments.rc.mlid,arguments.rc.siteid);
		}
		if ( arguments.rc.action == 'delete' ) {
			variables.fw.redirect(action="cMailingList.list",append="siteid",path="./");
		} else {
			variables.fw.redirect(action="cMailingList.listmembers",append="siteid,mlid",path="./");
		}
	}

	public function updatemember(rc) output=false {
		if ( arguments.rc.action == 'add' ) {
			variables.mailinglistManager.createMember(arguments.rc);
		}
		if ( arguments.rc.action == 'delete' ) {
			variables.mailinglistManager.deleteMember(arguments.rc);
		}
		variables.fw.redirect(action="cMailingList.listmembers",append="siteid,mlid",path="./");
	}

	public function download(rc) output=false {
		arguments.rc.listBean=variables.mailinglistManager.read(arguments.rc.mlid,arguments.rc.siteid);
		arguments.rc.rslist=variables.mailinglistManager.getListMembers(arguments.rc.mlid,arguments.rc.siteid);
	}

}

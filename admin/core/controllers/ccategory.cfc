/* license goes here */
component extends="controller" output="false" {

	public function setCategoryManager(CategoryManager) output=false {
		variables.categoryManager=arguments.categoryManager;
	}

	public function setContentUtility(contentUtility) output=false {
		variables.contentUtility=arguments.contentUtility;
	}

	public function before(rc) output=false {
		if ( (not listFind(session.mura.memberships,'Admin;#variables.settingsManager.getSite(arguments.rc.siteid).getPrivateUserPoolID()#;0') && !listFind(session.mura.memberships,'S2')) && !( variables.permUtility.getModulePerm('00000000000000000000000000000000010',arguments.rc.siteid) && variables.permUtility.getModulePerm('00000000000000000000000000000000000',arguments.rc.siteid)) ) {
			secure(arguments.rc);
		}
		param default=1 name="arguments.rc.startrow";
		param default="" name="arguments.rc.keywords";
	}

	public function edit(rc) output=false {
		arguments.rc.rsRestrictGroups=variables.contentUtility.getRestrictGroups(arguments.rc.siteid);
		arguments.rc.categoryBean=variables.categoryManager.read(arguments.rc.categoryID);
	}

	public function update(rc) output=false {
		if ( rc.$.validateCSRFTokens(context=rc.categoryid) ) {
			switch ( rc.action ) {
				case  "update":
					arguments.rc.categoryBean=variables.categoryManager.update(arguments.rc);
					break;
				case  "delete":
					variables.categoryManager.delete(arguments.rc.categoryid);
					break;
				case  "add":
					arguments.rc.categoryBean=variables.categoryManager.create(arguments.rc);
					if ( structIsEmpty(arguments.rc.categoryBean.getErrors()) ) {
						arguments.rc.categoryID=rc.categoryBean.getCategoryID();
					}
					break;
			}
		}
		if ( !(arguments.rc.action != 'delete' && !structIsEmpty(arguments.rc.categoryBean.getErrors())) ) {
			variables.fw.redirect(action="cCategory.list",append="siteid",path="./");
		} else {
			arguments.rc.rsRestrictGroups=variables.contentUtility.getRestrictGroups(arguments.rc.siteid);
		}
	}

}

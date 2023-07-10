/* license goes here */
component extends="mura.cfobject" accessors="true" output="false" {
	property name="fw";

	public function init(fw) output=false {
		if(isdefined('arguments.fw')){
			variables.fw = arguments.fw;
		}
	}

	public function secure(rc) output=false {
		request.context.returnURL=request.context.currentURL;
		var currentUser=getCurrentUser();

		if ( !currentUser.isLoggedIn() || !currentUser.isSystemUser() && (!isDefined('session.siteArray') || !arrayLen(session.siteArray))) {
			variables.fw.redirect(action="cLogin.main",append="returnURL,compactDisplay",path="./");
		} else {
			variables.utility.backUp();
		}
	}

	public function setConfigBean(configBean) output=false {
		variables.configBean=arguments.configBean;
	}

	public function setSettingsManager(settingsManager) output=false {
		variables.settingsManager=arguments.settingsManager;
	}

	public function setPermUtility(permUtility) output=false {
		variables.permUtility=arguments.permUtility;
	}

	public function setUtility(utility) output=false {
		variables.utility=arguments.utility;
	}
	//  This is here for backward plugin compatibility

	public function appendRequestScope(rc) output=false {
		var temp=structNew();
		if ( !structKeyExists(request,"requestappended") ) {
			if ( structKeyExists(request, 'layout') ) {
				temp.layout=request.layout;
			}
			structAppend(request,arguments.rc,false);
			if ( structKeyExists(temp, 'layout') ) {
				request.layout=temp.layout;
			} else {
				structDelete(request,"layout");
			}
			request.requestappended=true;
		}
	}

}

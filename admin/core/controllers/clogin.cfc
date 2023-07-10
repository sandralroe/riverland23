/* license goes here */
component extends="controller" output="false" {

	public function setLoginManager(loginManager) output=false {
		variables.loginManager=arguments.loginManager;
	}

	public function before(rc) output=false {
		param default="" name="arguments.rc.returnurl";
		param default="" name="arguments.rc.status";
		param default="" name="arguments.rc.contentid";
		param default="" name="arguments.rc.contenthistid";
		param default="" name="arguments.rc.topid";
		param default="" name="arguments.rc.type";
		param default="" name="arguments.rc.moduleid";
		param default="" name="arguments.rc.redirect";
		param default="" name="arguments.rc.parentid";
		param default="" name="arguments.rc.siteid";
	}

	public function main(rc) output=false {
		if ( listFind(session.mura.memberships,'S2IsPrivate') ) {
			variables.fw.redirect(action="home.redirect",path="./");
		}
	}

	public function login(rc) output=false {
		if ( rc.$.validateCSRFTokens(context='login') ) {
			var loginManager=rc.$.getBean('loginManager');
			if ( isBoolean(rc.$.event('attemptChallenge')) && rc.$.event('attemptChallenge') ) {
				rc.$.event('failedchallenge', !loginManager.handleChallengeAttempt(rc.$));
				loginManager.completedChallenge(rc.$);
			} else if ( isDefined('form.username') && isDefined('form.password') ) {
				loginManager.login(arguments.rc);
			}
		} else {
			variables.fw.redirect(action="clogin.main",path="./");
		}
	}

	public function logout(rc) output=false {
		variables.loginManager.logout();
		variables.fw.redirect(action="home.redirect",path="./");
	}

}

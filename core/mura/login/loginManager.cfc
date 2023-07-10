/* license goes here */
/**
 * This provides primary login service functionality
 */
component extends="mura.baseobject" output="false" hint="This provides primary login service functionality" {

	public function init(required any userUtility, required any userDAO, required any utility, required any permUtility, required any settingsManager) output=false {
		variables.userUtility=arguments.userUtility;
		variables.userDAO=arguments.userDAO;
		variables.globalUtility=arguments.utility;
		variables.permUtility=arguments.permUtility;
		variables.settingsManager=arguments.settingsManager;
		return this;
	}

	public boolean function rememberMe(required string userid="", required string userHash="") output=false {
		if(getBean('configBean').getValue(property='rememberme',defaultValue=true)){
			var rsUser=variables.userDAO.readUserHash(arguments.userid);
			var isLoggedin=0;
			var sessionData=getSession();
			if ( !getBean('configBean').getValue(property='MFA',defaultValue=false) 
			&& len(arguments.userid) && len(arguments.userHash) && arguments.userHash == rsUser.userHash
			) {
				isloggedin=variables.userUtility.loginByUserID(rsUser.userID,rsUser.siteID);
			}
			if ( isloggedin ) {
				sessionData.rememberMe=1;
				return true;
			} else {
				variables.globalUtility.deleteCookie(name="userHash");
				variables.globalUtility.deleteCookie(name="userid");
				variables.globalUtility.deleteCookie(name="MURA_UPC");

				sessionData.rememberMe=0;
				return false;
			}
		} else {
			variables.globalUtility.deleteCookie(name="userHash");
			variables.globalUtility.deleteCookie(name="userid");
			variables.globalUtility.deleteCookie(name="MURA_UPC");
		}
	}

	public function handleSuccess(returnUrl="", rememberMe="0", contentid="", linkServID="", isAdminLogin="false", compactDisplay="false", deviceid="", publicDevice="false") output=false {
		var isloggedin =false;
		var site="";
		var returnDomain="";
		var returnProtocol="";
		var indexFile="./";
		var loginURL="";
		var sessionData=getSession();
		if ( isDefined('sessionData.mfa') ) {
			structDelete(sessionData,'mfa');
		}
		if ( arguments.isAdminLogin ) {
			indexFile="./";
		}
		sessionData.rememberMe=arguments.rememberMe;
		if ( listFind(sessionData.mura.memberships,'S2IsPrivate') ) {
			sessionData.siteArray=arrayNew(1);
			for ( site in variables.settingsManager.getList() ) {
				if ( variables.permUtility.getModulePerm(
					"00000000000000000000000000000000000",
					site.siteid,
					site.publicUserPoolID,
					site.privateUserPoolID
					) 
				) {
					arrayAppend(sessionData.siteArray,site.siteid);
				}
			}
			if ( arguments.returnUrl == '' ) {
				if ( len(arguments.linkServID) ) {
					arguments.returnURL="#indexFile#?LinkServID=#arguments.linkServID#";
				} else {
					arguments.returnURL="#indexFile#";
				}
			} else {
				arguments.returnURL = getBean('utility').sanitizeHREF(replace(arguments.returnUrl, 'doaction=logout', '', 'ALL'));
			}
		} else if ( arguments.returnUrl != '' ) {
			arguments.returnURL = getBean('utility').sanitizeHREF(replace(arguments.returnUrl, 'doaction=logout', '', 'ALL'));
		} else {
			if ( len(arguments.linkServID) ) {
				arguments.returnURL="#indexFile#?LinkServID=#arguments.linkServID#";
			} else {
				arguments.returnURL="#indexFile#";
			}
		}
		structDelete(sessionData,'mfa');
		if ( request.muraAPIRequest) {
			if(!isDefined('request.muraJSONRedirectURL') || !len(request.muraJSONRedirectURL)){
				request.muraJSONRedirectURL=arguments.returnURL;
				request.muraJSONRedirectStatusCode=302;
			}
		} else {
			location( arguments.returnURL, false );
		}
	}

	public function sendAuthCode() output=false {
		sendAuthCodeByEmail();
	}

	public function sendAuthCodeByEmail() output=false {
		var sessionData=getSession();
		var site=getBean('settingsManager').getSite(sessionData.mfa.siteid);
		var contactEmail=site.getContact();
		var contactName=site.getSite();
		var mailText=site.getSendAuthCodeScript();
		var user=getBean('user').loadBy(userid=sessionData.mfa.userid,siteid=sessionData.mfa.siteid);
		var firstName=user.getFname();
		var lastName=user.getLname();
		var email=user.getEmail();
		var username=user.getUsername();
		var authcode=sessionData.mfa.authcode;
		var mailer=getBean('mailer');
		if ( getBean('configBean').getValue(property='MFAPerDevice',defaultValue=false) ) {
			var emailtitle=application.rbFactory.getKeyValue(sessionData.rb,'login.deviceauthorizationcode');
		} else {
			var emailtitle=application.rbFactory.getKeyValue(sessionData.rb,'login.authorizationcode');
		}
		if ( !len(mailText) ) {
			savecontent variable="mailText" {

					writeOutput("#firstName#,

Here is the authorization code you requested for username: #username#. It expires in 3 hours.

Authorization Code: #authcode#

If you did not request a new authorization, contact #contactEmail#.");

			}
		} else {
			var finder=refind('##.+?##',mailText,1,"true");
			while ( finder.len[1] ) {
				try {
					mailText=replace(mailText,mid(mailText, finder.pos[1], finder.len[1]),'#trim(evaluate(mid(mailText, finder.pos[1], finder.len[1])))#');
				} catch (any cfcatch) {
					mailText=replace(mailText,mid(mailText, finder.pos[1], finder.len[1]),'');
				}
				finder=refind('##.+?##',mailText,1,"true");
			}
		}

		
		mailer.sendText(trim(mailText),
	email,
	contactName,
	emailtitle,
	user.getSiteID()
	);
	}

	public function handleChallenge(rememberMe="0", contentid="", linkServID="", isAdminLogin="false", compactDisplay="false", deviceid="", publicDevice="false", failedchallenge="false") output=false {
		var sessionData=getSession();

		sessionData.mfa.authcode=variables.userUtility.getRandomPassword();
		if ( !arguments.failedchallenge && getBean('configBean').getValue(property='MFASendAuthCode',defaultValue=true) ) {
			sendAuthCode();
		}

		if(!isDefined('request.siteid')){
			var sessionData=getSession();
			if(isDefined('sessionData.siteid')){
				request.siteid=sessionData.siteid;
			} else {
				request.siteid="default";
			}
		}
		
		request.siteid=listFirst(request.siteid);
		arguments.compactDisplay=listfirst(arguments.compactDisplay);
		arguments.isAdminLogin=listfirst(arguments.isAdminLogin);

		arguments.compactDisplay=isBoolean(arguments.compactDisplay) ? arguments.compactDisplay : false;
		arguments.isAdminLogin=isBoolean(arguments.isAdminLogin) ? arguments.isAdminLogin : false;
		

		if ( arguments.isAdminLogin ) {
			location( "./?muraAction=cLogin.main&display=login&status=challenge&failedchallenge=#arguments.failedchallenge#&rememberMe=#arguments.rememberMe#&contentid=#arguments.contentid#&LinkServID=#arguments.linkServID#&returnURL=#urlEncodedFormat(arguments.returnUrl)#&compactDisplay=#urlEncodedFormat(arguments.compactDisplay)#", false);
		} else {
			var loginURL = getLoginURL(request.siteid);
			if ( find('?', loginURL) ) {
				loginURL &= "&status=challenge&failedchallenge=#arguments.failedchallenge#&rememberMe=#arguments.rememberMe#&contentid=#arguments.contentid#&LinkServID=#arguments.linkServID#&returnURL=#urlEncodedFormat(arguments.returnUrl)#";
			} else {
				loginURL &= "?status=challenge&failedchallenge=#arguments.failedchallenge#&rememberMe=#arguments.rememberMe#&contentid=#arguments.contentid#&LinkServID=#arguments.linkServID#&returnURL=#urlEncodedFormat(arguments.returnUrl)#";
			}

			if ( request.muraAPIRequest ) {
				//request.muraJSONRedirectURL=loginURL;
			} else {
				location( loginURL, false );
			}
		}
	}

	public function handleFailure(rememberMe="0", contentid="", linkServID="", isAdminLogin="false", compactDisplay="false", deviceid="", publicDevice="false") output=false {
		var sessionData=getSession();
		structDelete(sessionData,'mfa');
		
		if(!isDefined('request.siteid')){
			var sessionData=getSession();
			if(isDefined('sessionData.siteid')){
				request.siteid=sessionData.siteid;
			} else {
				request.siteid="default";
			}
		}

		request.siteid=listFirst(request.siteid);
		arguments.compactDisplay=listfirst(arguments.compactDisplay);
		arguments.isAdminLogin=listfirst(arguments.isAdminLogin);

		arguments.compactDisplay=isBoolean(arguments.compactDisplay) ? arguments.compactDisplay : false;
		arguments.isAdminLogin=isBoolean(arguments.isAdminLogin) ? arguments.isAdminLogin : false;

		if ( isBoolean(arguments.isAdminLogin) && arguments.isAdminLogin) {
			location( "./?muraAction=cLogin.main&display=login&status=failed&rememberMe=#arguments.rememberMe#&contentid=#arguments.contentid#&LinkServID=#arguments.linkServID#&returnURL=#urlEncodedFormat(arguments.returnUrl)#&compactDisplay=#urlEncodedFormat(arguments.compactDisplay)#", false );
		} else {
			var loginURL = application.settingsManager.getSite(request.siteid).getLoginURL();
			if ( find('?', loginURL) ) {
				loginURL &= "&status=failed&rememberMe=#arguments.rememberMe#&contentid=#arguments.contentid#&LinkServID=#arguments.linkServID#&returnURL=#urlEncodedFormat(arguments.returnUrl)#";
			} else {
				loginURL &= "?status=failed&rememberMe=#arguments.rememberMe#&contentid=#arguments.contentid#&LinkServID=#arguments.linkServID#&returnURL=#urlEncodedFormat(arguments.returnUrl)#";
			}
			if ( request.muraAPIRequest ) {
				//request.muraJSONRedirectURL=loginURL;
			} else {
				location( loginURL, false );
			}
		}
	}

	public function attemptChallenge($) output=false {
		var sessionData=getSession();
		var eventResponse = arguments.$.renderEvent('onMFAAttemptChallenge');
		var isCodeValid = IsBoolean(eventResponse)
						? eventResponse
						: Len(arguments.$.event('authcode')) && IsDefined('sessionData.mfa.authcode') && arguments.$.event('authcode') == sessionData.mfa.authcode;
		return isCodeValid;
	}

	public function handleChallengeAttempt($) output=false {
		if ( isBoolean(arguments.$.event('attemptChallenge')) && arguments.$.event('attemptChallenge') ) {
			var sessionData=getSession();
			var strikes = new mura.user.userstrikes(sessionData.mfa.username,getBean('configBean'));
			param name="sessionData.blockLoginUntil" default=strikes.blockedUntil();
			if ( attemptChallenge($=arguments.$) ) {
				strikes.clear();
				return true;
			} else {
				strikes.addStrike();
			}
		}
		return false;
	}

	public function completedChallenge($) output=false {
		var sessionData=getSession();
		var failedchallenge = IsBoolean(arguments.$.event('failedchallenge')) ? arguments.$.event('failedchallenge') : false;

		if ( !IsBoolean(arguments.$.event('isadminlogin')) ) {
			arguments.$.event('isadminlogin', false);
		}

		if ( isDefined('sessionData.mfa') ) {

			if ( failedchallenge ) {
				var data = {
					failedchallenge = true
					, returnurl = listFirst(arguments.$.event('returnurl'))
					, rememberme = listFirst(arguments.$.event('rememberme'))
					, contentid = listFirst(arguments.$.event('contentid'))
					, linkservid = listFirst(arguments.$.event('linkservid'))
					, isadminlogin = listFirst(arguments.$.event('isadminlogin'))
					, compactdisplay = listFirst(arguments.$.event('compactdisplay'))
					, deviceid = listFirst(arguments.$.event('deviceid'))
					, publicdevice = listFirst(arguments.$.event('publicdevice'))
					, siteid = listFirst(arguments.$.event('siteid'))
					, m = arguments.$
					, $ = arguments.$
				};

				handleChallenge(argumentCollection=data);
			} else {
				if ( getBean('configBean').getValue(property='MFA',defaultValue=false) && isBoolean(arguments.$.event('rememberdevice')) && arguments.$.event('rememberdevice') ) {
					var userDevice=getBean('userDevice')
							.loadBy(
								userid=sessionData.mfa.userid,
								deviceid=sessionData.mfa.deviceid,
								siteid=sessionData.mfa.siteid
							)
							.setLastLogin(now())
							.save();
				}
				variables.userUtility.loginByUserID(argumentCollection=sessionData.mfa);
				handleSuccess(argumentCollection=sessionData.mfa);
			}
		}

	}

	public function login(struct data, required any loginObject="") output=false {
		var isloggedin =false;
		var returnUrl ="";
		var site="";
		var returnDomain="";
		var returnProtocol="";
		var indexFile="./";
		var loginURL="";
		structDelete(session,'mfa');

		param name="arguments.data.returnUrl" default="";
		param name="arguments.data.rememberMe" default=0;
		param name="arguments.data.contentid" default="";
		param name="arguments.data.linkServID" default="";
		param name="arguments.data.isAdminLogin" default=false;
		param name="arguments.data.compactDisplay" default=false;
		param name="arguments.data.failedchallenge" default=false;

		arguments.data.siteid=listFirst(arguments.data.siteid);
		arguments.data.returnUrl=listfirst(arguments.data.returnUrl);
		arguments.data.rememberMe=listfirst(arguments.data.rememberMe);
		arguments.data.contentid=listfirst(arguments.data.contentid);
		arguments.data.linkServID=listfirst(arguments.data.linkServID);
		arguments.data.compactDisplay=listfirst(arguments.data.compactDisplay);
		arguments.data.isAdminLogin=listfirst(arguments.data.isAdminLogin);
		arguments.data.compactDisplay=isBoolean(arguments.data.compactDisplay) ? arguments.data.compactDisplay : false;
		arguments.data.isAdminLogin=isBoolean(arguments.data.isAdminLogin) ? arguments.data.isAdminLogin : false;
				
		var sessionData=getSession();

		getBean('utility').excludeFromClientCache();

		if ( !isdefined('arguments.data.username') ) {
			if ( request.muraAPIRequest ) {
				request.muraJSONRedirectURL="#indexFile#?muraAction=clogin.main&linkServID=#arguments.data.linkServID#";
				return false;
			} else {
				location( "#indexFile#?muraAction=clogin.main&linkServID=#arguments.data.linkServID#", false );
			}
		} else {
			if ( getBean('configBean').getValue(property='MFA',defaultValue=false) ) {
				var rsUser=variables.userUtility.lookupByCredentials(arguments.data.username,left(arguments.data.password,255),arguments.data.siteid);
				if ( rsUser.recordcount ) {
					var $=getBean('$').init(arguments.data.siteid);
					sessionData.mfa={
						userid=rsuser.userid,
						siteid=rsuser.siteid,
						username=rsuser.username,
						returnUrl=arguments.data.returnURL,
						rememberMe=arguments.data.rememberMe,
						contentid=arguments.data.contentid,
						linkServID=arguments.data.linkServID,
						isAdminLogin=arguments.data.isAdminLogin,
						compactDisplay=arguments.data.compactDisplay,
						deviceid=cookie.mxp_trackingid,
						failedchallenge=arguments.data.failedchallenge
					};
					//  if the deviceid is supplied then check to see if the user has validated the device
					if ( getBean('configBean').getValue(property='MFAPerDevice',defaultValue=false) ) {
						var userDevice=$.getBean('userDevice').loadBy(userid=sessionData.mfa.userid,deviceid=sessionData.mfa.deviceid,siteid=sessionData.mfa.siteid);
						if ( userDevice.exists() ) {
							userDevice.setLastLogin(now()).save();
							variables.userUtility.loginByUserId(siteid=rsuser.siteid,userid=rsuser.userid);
							handleSuccess(argumentCollection=sessionData.mfa);
							return true;
						}
					}
					handleChallenge(argumentCollection=arguments.data);
					return false;
				} else {
					handleFailure(argumentCollection=arguments.data);
					return false;
				}
			} else {
				if ( !isObject(arguments.loginObject) ) {
					isloggedin=variables.userUtility.login(arguments.data.username,arguments.data.password,arguments.data.siteid);
				} else {
					isloggedin=arguments.loginObject.login(arguments.data.username,arguments.data.password,arguments.data.siteid);
				}
				if ( isloggedin ) {
					handleSuccess(argumentCollection=arguments.data);
					return true;
				} else {
					handleFailure(argumentCollection=arguments.data);
					return false;
				}
			}
		}
	}

	public function remoteLogin(struct data, required any loginObject="") output=false {
		var isloggedin =false;
		var returnUrl ="";
		var site="";
		if ( !isdefined('arguments.data.username')
		or !isdefined('arguments.data.password')
		or !isdefined('arguments.data.siteid')
		or !(isDefined('form.username') && isDefined('form.password')) ) {
			return false;
		} else {
			return login(data=arguments.data);
		}
	}

	public function loginByUserID(struct data) output=true {
		var isloggedin =false;
		var returnURL="";
		var site="";
		var returnDomain="";
		var sessionData=getSession();

		param name="arguments.data.redirect" default="";
		param name="arguments.data.returnUrl" default="";
		param name="arguments.data.rememberMe" default=0;
		param name="arguments.data.contentid"default="";
		param name="arguments.data.linkServID" default="";
		param name="arguments.data.compactDisplay" default=false;
		param name="arguments.data.isAdminLogin" default=false;

		arguments.data.siteid=listFirst(arguments.data.siteid);
		arguments.data.returnUrl=listfirst(arguments.data.returnUrl);
		arguments.data.rememberMe=listfirst(arguments.data.rememberMe);
		arguments.data.contentid=listfirst(arguments.data.contentid);
		arguments.data.linkServID=listfirst(arguments.data.linkServID);
		arguments.data.compactDisplay=listfirst(arguments.data.compactDisplay);
		arguments.data.isAdminLogin=listfirst(arguments.data.isAdminLogin);
		arguments.data.compactDisplay=isBoolean(arguments.data.compactDisplay) ? arguments.data.compactDisplay : false;
		arguments.data.isAdminLogin=isBoolean(arguments.data.isAdminLogin) ? arguments.data.isAdminLogin : false;
				
		sessionData.rememberMe=arguments.data.rememberMe;

		if ( !isdefined('arguments.data.userid') ) {
			location( "./?muraAction=clogin.main&linkServID=#arguments.data.linkServID#", false );
		} else {
			if ( getBean('configBean').getValue(property='MFA',defaultValue=false) ) {
				var $=getBean('$').init(arguments.data.siteid);
				var user=$.getBean('user').loadBy(userid=arguments.data.userid,siteid=arguments.data.siteid);
				if ( user.exists() ) {
					sessionData.mfa={
					userid=user.getUserID(),
					siteid=user.getSiteID(),
					username=user.getUsername(),
					returnUrl=arguments.data.returnURL,
					redirect=arguments.data.redirect,
					rememberMe=arguments.data.rememberMe,
					contentid=arguments.data.contentid,
					linkServID=arguments.data.linkServID,
					isAdminLogin=arguments.data.isAdminLogin,
					compactDisplay=arguments.data.compactDisplay,
					deviceid=sessionData.trackingID};
					//  if the deviceid is supplied then check to see if the user has validated the device
					if ( getBean('configBean').getValue(property='MFAPerDevice',defaultValue=false) ) {
						var userDevice=$.getBean('userDevice').loadBy(userid=arguments.data.userid,deviceid=sessionData.mfa.deviceid);
						if ( userDevice.exists() ) {
							userDevice.setLastLogin(now()).save();
							variables.userUtility.loginByUserId(siteid=rsuser.siteid,userid=rsuser.userid);
							handleSuccess(argumentCollection=sessionData.mfa);
							return true;
						}
					}
					handleChallenge(argumentCollection=arguments.data);
					return false;
				} else {
					handleFailure(argumentCollection=arguments.data);
					return false;
				}
			} else {
				isloggedin=variables.userUtility.loginByUserID(arguments.data.userID,arguments.data.siteid);
				if ( isloggedin ) {
					handleSuccess(argumentCollection=arguments.data);
					return true;
				} else {
					handleFailure(argumentCollection=arguments.data);
					return false;
				}
			}
		}
	}

	public function logout() output=false {
		var pluginEvent="";
		if ( structKeyExists(request,"servletEvent") ) {
			pluginEvent=request.servletEvent;
		} else if ( structKeyExists(request,"event") ) {
			pluginEvent=request.event;
		} else {
			pluginEvent = new mura.event();
		}
		if ( len(pluginEvent.getValue("siteID")) ) {
			getPluginManager().announceEvent('onSiteLogout',pluginEvent);
			getPluginManager().announceEvent('onBeforeSiteLogout',pluginEvent);
		} else {
			getPluginManager().announceEvent('onGlobalLogout',pluginEvent);
			getPluginManager().announceEvent('onBeforeGlobalLogout',pluginEvent);
		}
		if ( yesNoFormat(getBean('configBean').getValue("useLegacySessions")) ) {

			getBean('utility').legacyLogout();

		}
		for ( local.i in session ) {
			if ( !listFindNoCase('cfid,cftoken,sessionid,urltoken,jsessionid',local.i) ) {
				structDelete(session,local.i);
			}
		}
		if ( getBean('configBean').getValue(property='rotateSessions',defaultValue='false') ) {
			sessionInvalidate();
		}

		getBean('utility').excludeFromClientCache();
	
		variables.globalUtility.deleteCookie(name="userHash");
		variables.globalUtility.deleteCookie(name="userid");
		variables.globalUtility.deleteCookie(name="MURA_UPC");

		getSession();
		getBean('changesetManager').removeSessionPreviewData();
		if ( len(pluginEvent.getValue("siteID")) ) {
			getPluginManager().announceEvent('onAfterSiteLogout',pluginEvent);
		} else {
			getPluginManager().announceEvent('onAfterGlobalLogout',pluginEvent);
		}
	}

	function getLoginURL(siteid){
		var site = application.settingsManager.getSite(arguments.siteid);
		var loginURL = site.getLoginURL();

		if(!len(loginURL)){
			if(site.get('isremote')){
				loginURL = site.getAdminPath(complete=1) & "/?muraAction=cLogin.main";
			} else {
				loginURL = "/?display=login" 
			}
		}
		
		return loginURL;
	}

}

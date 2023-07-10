component extends="baseLoginProvider" accessors=true output=false {

	variables.providerName='Microsoft';

	public function generateAuthUrl() {

		setReturnURL();

		var siteid = getBean('contentServer').bindToDomain();
		var providerBean = getBean('oauthprovider').loadBy(siteid=siteid,name=variables.providerName);

		var authUrl = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?";
			authUrl &= "client_id=#providerBean.getClientId()#&";
			authUrl &= "response_type=code&";
			authUrl &= "redirect_uri=#urlEncodedFormat(getCallbackURL())#&";
			authUrl &= "response_mode=query&";
			authUrl &= "scope=openid%20profile%20email&";
			authUrl &= "state=#urlEncodedFormat(session.urltoken & '&provider=' & variables.providerName)#";

		return authUrl;
	}

	public struct function validateResult(code, error, remoteState, clientState) {
		var result = {};

		//If error is anything, we have an error
		if(error != "") {
			result.status = false;
			result.message = error;
			return result;
		}

		//Then, ensure states are equal
		if(remoteState != clientState) {
			result.status = false;
			result.message = "State values did not match.";
			return result;
		}

		var token = getAuthToken(code);
		//If error is defined we have an error getting token
		if(isDefined("token.error")) {
			logText(serializeJSON(token));
			
			result.status = false;
			result.message = "#token.error#: #token.error_description#";
			return result;
		}

		var profile = getProfile(token.access_token);
		//If error is defined we have an error getting profile
		if(isDefined("profile.error")) {
			result.status = false;
			result.message = "#profile.error.code#: #profile.error.message#";
			return result;
		}

		// Handle for difference between facebook and Google returned oAuth objects
	
		profile.given_name = profile.givenName;
		profile.family_name = profile.surname;
		profile.username = profile.userPrincipalName;
		profile.email = profile.userPrincipalName;
		
		getBean('oauthLoginUtility').updateOrCreateUserAccount(profile);

		result.status = true;
		result.token = token;
		result.profile = profile;

		return result;
	}

	public function getProfile(accesstoken) {
		var h = new http();
		h.setURL("https://graph.microsoft.com/v1.0/me");
		h.setMethod("get");
		h.addParam(type="header",name="Authorization",value="Bearer #accesstoken#");
		h.setResolveURL(true);
		var result = h.send().getPrefix();
		return deserializeJSON(result.filecontent.toString());
	}

	private function getAuthToken(code) {
		var siteid = getBean('contentServer').bindToDomain();
		var providerBean=getBean('oauthprovider').loadBy(siteid=siteid,name=variables.providerName);

		var postBody = "code=#UrlEncodedFormat(arguments.code)#&";
			 postBody &= "client_id=#UrlEncodedFormat(providerBean.getClientId())#&";
			 postBody &= "client_secret=#UrlEncodedFormat(providerBean.getClientSecret())#&";
			 postBody &= "redirect_uri=#UrlEncodedFormat(getCallbackURL())#&";
			 postBody &= "grant_type=authorization_code&";
			 //postBody &= "code_verifier=#urlEncodedFormat(hash(int(now().getTime()/1000)))#&";

			var h = new http();
			h.setURL("https://login.microsoftonline.com/common/oauth2/v2.0/token");
			h.setMethod("post");
			h.addParam(type="header",name="Content-Type",value="application/x-www-form-urlencoded");
			h.addParam(type="body",value="#postBody#");
			h.setResolveURL(true);
			var result = h.send().getPrefix();
			return deserializeJSON(result.filecontent.toString());
	}
}
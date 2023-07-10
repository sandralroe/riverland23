component extends="mura.baseobject" {

  public boolean function onSessionStart() {
  	session.loggedin = false;

  	return true;
  }

  public function onGlobalRequestStart($) {
    if(hasCallbackValues()) {
  		handleCallback();
  	}

    if (structKeyExists($.event().getAllValues(), 'showuser')) {
      writeDump($.getBean('event').getCurrentUser().getAllValues());abort;
    }

    if (structKeyExists($.event().getAllValues(), 'logout')) {
      var loginManager = $.getBean('loginManager');
      loginManager.logout();
    }

  }

  function hasCallbackValues(){
    if(findNoCase("MicrosoftLoginProvider", cgi.request_url)) {
      url.loginProvider = "Microsoft";
    }

    structAppend(local,url);
    
    param name="local.code" default="";
    param name="local.loginProvider" default="";
    param name="local.state" default="";
    param name="local.error" default="";
    
    var returnState=listToArray(local.state,'&');
  
    for(var state in returnState){
      if(listFirst(state,'=') == 'provider'){
        url.loginProvider=listLast(state,'=');
        local.loginProvider= url.loginProvider;
      }
    }

    return len(local.loginProvider) && (len(local.code) || len(local.error) || len(local.state));
  }

  function handleCallback(){
    //Attempt authentication
   
    if(getServiceFactory().containsBean(url.loginProvider & 'loginProvider')){
			param name='url.error' default='';
			param name='url.state' default='';
      var result = getBean(url.loginProvider & 'loginProvider').validateResult(url.code, url.error, url.state, session.urltoken & '&provider=' & url.loginProvider);
	    //If authentication successful, redirect user to intended target, or home if no target exists
	 
      if( result.status ){
	      if(isDefined('session.mura.returnURL') && len(session.mura.returnURL)){
					if(request.returnFormat eq 'JSON'){
						request.muraJSONRedirectURL=session.mura.returnURL;
					} else {
						location(url="#session.mura.returnURL#", addToken="no");
					}
	      } else {
					if(request.returnFormat eq 'JSON'){
						request.muraJSONRedirectURL=getBean('configBean').getContext();
					} else {
						if(len(getBean('configBean').getContext())){
							location(url=getBean('configBean').getContext(), addToken="no");
						} else {
							location(url="./", addToken="no");
						}
					}
	      }
	    }
		}
  }

  // onLoginPromptRender

  // onSiteRequestStart
}

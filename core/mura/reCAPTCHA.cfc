/* license goes here */
component accessors=true output=false hint="This provides the ability to interact with Google's reCaptcha functionality"{

  property name='secret' default='';

  this._signupUrl='https://www.google.com/recaptcha/admin';
  this._siteVerifyUrl='https://www.recaptcha.net/recaptcha/api/siteverify?';

  public any function init(required string secret) {
    setSecret(arguments.secret);
  }

  public boolean function verifyResponse(required string response, string remoteip=cgi.remote_addr) {
    var recaptchaResponse = {
      'success' = false
      , 'errorCodes' = ''
    };

    var httpAttributes = {
      'method'='post'
      , 'charset'='utf-8'
      , 'url'=this._siteVerifyUrl
    };

    if ( Len(application.configBean.getProxyServer()) ) {
      StructAppend(httpAttributes, {
        'proxyUser'=application.configBean.getProxyUser()
        , 'proxyPassword'=application.configBean.getProxyPassword()
        , 'proxyServer'=application.configBean.getProxyServer()
        , 'proxyPort'=application.configBean.getProxyPort()
      });
    }

    var httpSvc = new http(argumentCollection=httpAttributes);

    httpSvc.addParam(type='formfield', name='secret', value=getSecret());
    httpSvc.addParam(type='formfield', name='remoteip', value=arguments.remoteip);
    httpSvc.addParam(type='formfield', name='response', value=arguments.response);

    recaptchaResponse.result = httpSvc.send().getPrefix();

    var answers = StructKeyExists(recaptchaResponse.result, 'Filecontent') && IsJson(recaptchaResponse.result.Filecontent)
      ? DeserializeJson(recaptchaResponse.result.FileContent)
      : recaptchaResponse;

    if ( IsBoolean(Trim(answers.success)) && Trim(answers.success) ) {
      recaptchaResponse.success = true;
    } else if ( StructKeyExists(answers, 'error-codes') ) {
      recaptchaResponse.errorCodes = answers['error-codes'];
    } else {
      recaptchaResponse.errorCodes = ['check-siteVerifyUrl'];
    }

    return recaptchaResponse.success;
  }

}

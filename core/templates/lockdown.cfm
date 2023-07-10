<!--- license goes here --->
<cfset providersAdded=$.getFeed('oauthProvider').setSiteID($.siteConfig().getSiteId()).getIterator()>
<cfset providersAddedList = ""/>
<cfloop condition="providersAdded.hasNext()">
    <cfset providerAdded=providersAdded.next()>
    <cfset providersAddedList = listAppend(providersAddedList, providerAdded.getName())/>
</cfloop>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />

<cfoutput>
<title>#REReplace(application.settingsManager.getSite(request.siteID).getEnableLockdown(), "([a-z]{1})", "\U\1", "ONE" )# Mode</title>
<link rel="stylesheet" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/fonts/font-awesome/css/font-awesome.css">
</cfoutput>

<style type="text/css">

body {
	background: #fff;
	color: #646464;
	font-family: "Helvetica", "Arial", sans-serif;
	margin: 0; padding: 0;
}

#wrapper {
	background: #FFF;
	border: 2px solid #ECEEEF;
  border-radius: 1px;
	margin: 100px auto;
	width: 360px;
}

#inner {
	margin: 30px 40px;
}

.alert {
	font-weight: bold;
    text-align: center;
}

form label {
	display: block;
	width: 100%;
	font-size: 13px;
}

form input, 
form input.text, 
form select{
  background-color: #fff;
  background-image: none;
	border: 1px solid #e6e6e6 !important;
  border-radius: 3px !important;
  color: #646464;
  display: block;
	font-size: 13px;
  line-height: 1.6;
	margin: 5px 0 25px;
  padding: 6px 15px;
  position: relative;
	transition: all .15s ease-out;
}

form input.text {
	margin: 5px auto 25px;
	width: 89%;

}

form input.text:focus {
	outline: 0;
}

form select {
	outline: 0;
}

form input.submit {
		cursor: pointer;
		padding: 2px 12px;
    font-weight: 400;
    font-size: 13px;
    display: block;
    width: 100%;
    border: none;
    background-color: #e34a36;
    color: #fff!important;
    height: 35px;
    margin-left: 0;
    margin-right: 0;
}

form p#submitWrap {
	text-align: center;
	margin: 0; padding: 0;
}

form p#error {
		background-color: #fff;
		background-image: none;
		border: 1px solid #e65e4c !important;
    border-radius: 2px!important;
    box-shadow: none!important;
    color: #e65e4c;
    display: flex;
    flex-direction: column;
    justify-content: center;
    font-size: 14px;
    line-height: 1.4em;
    margin-bottom: 8px;
    min-height: 32px;
    padding-top: 12px;
    padding-bottom: 12px;
    position: relative;
    text-align: center;
}

.text-divider {
    display: flex;
    justify-content:center;
    align-items: center;
    margin-top: 20px;
    position: relative;
    text-align: center;
}

.text-divider::before,
.text-divider::after {
    content: '';
    background: #ccc;
    height: 1px;
    display: block;
    width: 100%;
}

.text-divider span {
		color: #646464;
    font-size: 16px;
    font-weight: bold;
    padding: 10px 20px;
    text-align: center;
}

.center{
	text-align: center;
}
/* login and setup */
.mura-login-auth-btn{
  display: inline-block;
  margin: 0 0 6px;
  height: 40px;
  text-align: left;
 	text-decoration: none;
  width: 100%;
}

.mura-login-auth-btn.ggl{
  background-color: #dc4e41;
}

.mura-login-auth-btn.fb{
  background-color: #4267b2;
}

.mura-login-auth-btn.gh {
  background-color: #3c4146;
}

.mura-login-auth-btn.ms {
  border: 1px solid #7a818f;
}

.mura-login-auth-btn span{
  color: #fff;
  font-size: 16px;
  text-align: left;
  padding: 11px 0 0 12px;
  display: inline-block;
}

.mura-login-auth-btn.ms span{
  color: #7a818f;
}

.mura-login-auth-btn i{
  border-right: 1px solid #fff;
  color: #fff;
  height: 40px;
  font-size: 28px;
  float: left;
  padding: 6px;
  text-align: center;
  width: 40px;
 	font-family: 'FontAwesome';
}

.mura-login-auth-btn.ms i {
  border-right: 1px solid #7a818f;
}

h3.mura-login-auth-heading{
  margin: 22px;
}

</style>

</head>
<cfoutput>
<body>
	<div id="wrapper">
		<div id="inner">
			<cfif application.settingsManager.getSite(request.siteID).getEnableLockdown() eq "maintenance">
				<div class="alert">#application.settingsManager.getSite(request.siteID).getSite()# is currently undergoing maintenance.</div>

			<cfelseif application.settingsManager.getSite(request.siteID).getEnableLockdown() eq "development" or application.settingsManager.getSite(request.siteID).getEnableLockdown() eq "archived">
				<form method="post" action="<cfif application.configBean.getLockdownHTTPS() eq true>#replacenocase(arguments.$.getContentRenderer().createHREF(siteid = request.siteid, filename = arguments.event.getScope().currentfilename, complete = true), "http:", "https:")#</cfif>">

						  <cfif listFindNoCase(providersAddedList, 'google') or
						   		listFindNoCase(providersAddedList, 'facebook') or
						   		listFindNoCase(providersAddedList, 'github')>
							<!--- Use Google oAuth Button --->
							<cfif listFindNoCase(providersAddedList, 'google')>
								<div style="padding-bottom: 5px" class="center">
									<a href="#$.getBean('googleLoginProvider').generateAuthUrl(session.urltoken)#" title="#$.rbKey('login.loginwithgoogle')#" class="mura-login-auth-btn ggl">
					        	<i class="icon icon-lg icon-google-plus mi-google"></i>
					        	<span>#$.rbKey('login.loginwithgoogle')#</span>
									</a>
								</div>
							</cfif>
							<!--- Use Facebook oAuth Button --->
							<cfif listFindNoCase(providersAddedList, 'facebook')>
								<div style="padding-bottom: 5px" class="center">
									<a href="#$.getBean('facebookLoginProvider').generateAuthUrl(session.urltoken)#" title="#$.rbKey('login.loginwithfacebook')#" class="mura-login-auth-btn fb">
						      	<i class="icon icon-lg icon-facebook mi-facebook"></i>
						      	<span>#$.rbKey('login.loginwithfacebook')#</span>
									</a>
								</div>
							</cfif>
					        <!--- Use GitHub oAuth Button --->
					        <cfif listFindNoCase(providersAddedList, 'github')>
					            <a href="#$.getBean('githubLoginProvider').generateAuthUrl(session.urltoken)#" title="#$.rbKey('login.loginwithgithub')#" class="mura-login-auth-btn gh">
					              	<i class="mi-github"></i>
					              	<span>#$.rbKey('login.loginwithgithub')#</span>
					            </a>
					        </cfif>
							<!--- Use Microsoft oAuth Button --->
							<cfif listFindNoCase(providersAddedList, 'microsoft')>
							  <a href="#$.getBean('microsoftLoginProvider').generateAuthUrl(session.urltoken)#" title="#$.rbKey('login.loginwithmicrosoft')#" class="mura-login-auth-btn ms">
							  	<i class="mi-ms"></i>
							  	<span>#$.rbKey('login.loginwithmicrosoft')#</span>
							  </a>
							</cfif>
		          			<div class="text-divider"><span>#$.rbKey('login.or')#</span></div>
							<h3 class="center mura-login-auth-heading">#$.rbKey('login.loginwithcredentials')#</h3>
						</cfif>

					<label for="locku">Username</label>
					<input type="text" name="locku" id="locku" class="text" />

					<label for="lockp">Password</label>
					<input type="password" name="lockp" id="lockp" class="text" />
					<cfif not $.globalConfig().getValue(property="sessionBasedLockdown",defaultValue=true)>
					<label for="expires">Log me in for:</label>
						<select name="expires">
							<option value="session">Session</option>
							<option value="1">One Day</option>
							<option value="7">One Week</option>
							<option value="30">One Month</option>
							<option value="10950">Forever</option>
						</select>
					</cfif>

					<input type="hidden" name="locks" value="true" />
					<cfif len(event.getValue('locks'))>
						<p id="error">Login failed!</p>
					</cfif>
					<p id="submitWrap"><input type="submit" name="submit" value="#$.rbKey('login.login')#" class="submit" /></p>
				</form>
			</cfif>
		</div>
	</div>
</body>
</cfoutput>
</html>
<cfabort>

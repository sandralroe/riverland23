<!--- license goes here --->
<cfset providersAdded=$.getFeed('oauthProvider').setSiteID($.siteConfig().getSiteId()).getIterator()>
<cfset providersAddedList = ""/>
<cfloop condition="providersAdded.hasNext()">
    <cfset providerAdded=providersAdded.next()>
    <cfset providersAddedList = listAppend(providersAddedList, providerAdded.getName())/>
</cfloop>

<cfset isBlocked=false/>
<cfparam name="msg" default="">

<cfoutput>
<cfsavecontent variable="focusblockheader">
  <div class="focus-block-header">
		<img src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/images/mura-logo-login.svg" class="mura-logo">
  </div><!-- /focus-block-header -->
</cfsavecontent>

<div id="mura-login">
<!---
		<cfif rc.$.event('status') eq 'challenge' and isdefined('session.mfa')>
			<cfif rc.compactDisplay eq 'true'>
				<h1 class="page-heading">#rc.$.rbKey('login.authorizationcode')#</h1>
			<cfelse>
				<h1 class="page-heading">#rc.$.rbKey('login.authorizationcode')#</h1>
			</cfif>
		<cfelse>
			<cfif rc.compactDisplay eq 'true'>
				<h1 class="page-heading">#rc.$.rbKey('login.pleaselogin')#</h1>
			<cfelse>
				<h1 class="page-heading">#rc.$.rbKey('login.pleaselogin')#</h1>
			</cfif>
		</cfif>
--->
	<div class="block mura-focus-block animated" <cfif rc.status eq 'sendLogin'>style="display:none;"</cfif> id="mura-login-panel">

		#focusblockheader#

	    <div class="block-content">

				<cfset errorMessage = '' />
				<cfset isBlocked = StructKeyExists(session, "blockLoginUntil") and isDate(session.blockLoginUntil) and session.blockLoginUntil gt now() />

				<cfif isBlocked>
					<cfset errorMessage = rc.$.rbKey('login.blocked') />
				<cfelseif rc.status eq 'denied'>
					<cfset errorMessage = rc.$.rbKey('login.denied') />
				<cfelseif rc.status eq 'failed'>
					<cfset errorMessage = rc.$.rbKey('login.failed') />
				<cfelseif rc.$.event('failedchallenge') eq 'true'>
					<cfset errorMessage = rc.$.rbKey('login.incorrectauthorizationcode') />
				</cfif>

				<cfif Len(errorMessage)>
					<div class="alert alert-error">
						<span>#errorMessage#</span>
					</div>
				</cfif>

				<!--- Do not change the html comment below --->
				<!-- mura-primary-login-token -->

				<cfif not isBlocked>
					<cfif rc.$.event('status') eq 'challenge' and isdefined('session.mfa')>
						<cfset output=rc.$.renderEvent('onAdminMFAChallengeRender')>
						<cfif len(output)>
							#output#
						<cfelse>
							<cfif rc.$.getBean('configBean').getValue(property='MFAPerDevice',defaultValue=false) and not len(rc.$.event('authcode'))>
								<div class="alert alert-error"><span>#rc.$.rbKey('login.newdevice')#</span></div>
							</cfif>

							<cfif len(rc.$.event('authcode'))>
								<div class="alert alert-error"><span>#rc.$.rbKey('login.authcodeerror')#</span></div>
							</cfif>

							<form novalidate="novalidate" id="loginForm" name="frmLogin" method="post" action="index.cfm" onsubmit="return submitForm(this);">

							<div class="mura-control-group">
				      			<label>#rc.$.rbKey('login.enteremailedauthcode')#</label>
								<div class="input-prepend">
								  	<span class="add-on"><i class="mi-envelope"></i></span><input autocomplete="off" id="authcode" name="authcode" type="text" placeholder="#esapiEncode('html_attr',rc.$.rbKey('login.authorizationcode'))#" />
								</div>
								<cfif rc.$.getBean('configBean').getValue(property='MFAPerDevice',defaultValue=false) and rc.$.getBean('configBean').getValue(property='rememberme',defaultValue=true)>
									<input type="hidden" name="rememberdevice" value="1"/>
									<!---
									<div id="remember-device">
							      	<input type="checkbox" id="rememberdevice" name="rememberdevice" value="1" />
							     	<label for="rememberdevice">#rc.$.rbKey('login.rememberdevice')#
							      	</label>
									</div>
									--->
								</cfif>
							</div>
							<div class="mura-focus-actions">
								<input type="submit" class="btn" value="#rc.$.rbKey('login.submit')#" />
							</div>
							<input type="hidden" name="muraAction" value="cLogin.login">
							<input type="hidden" name="status" value="challenge">
							<input type="hidden" name="attemptChallenge" value="true">
							<input type="hidden" name="isadminlogin" value="true">
							#rc.$.renderCSRFTokens(format='form',context='login')#
							</form>
						</cfif>
					<cfelse>
						<form novalidate="novalidate" id="loginForm" name="frmLogin" method="post" action="index.cfm" onsubmit="return submitForm(this);">
						  <cfif listFindNoCase(providersAddedList, 'google') or
						   		listFindNoCase(providersAddedList, 'facebook') or
						   		listFindNoCase(providersAddedList, 'github') or
						   		listFindNoCase(providersAddedList, 'microsoft')>
								<div class="mura-login-auth-wrapper">
									<!--- Use Google oAuth Button --->
									<cfif listFindNoCase(providersAddedList, 'google')>
									    <a href="#$.getBean('googleLoginProvider').generateAuthUrl(session.urltoken)#" title="#rc.$.rbKey('login.loginwithgoogle')#" class="mura-login-auth-btn ggl">
									    	<i class="mi-google"></i>
									    	<span>#rc.$.rbKey('login.loginwithgoogle')#</span>
									    </a>
									</cfif>
									<!--- Use Facebook oAuth Button --->
									<cfif listFindNoCase(providersAddedList, 'facebook')>
									  <a href="#$.getBean('facebookLoginProvider').generateAuthUrl(session.urltoken)#" title="#rc.$.rbKey('login.loginwithfacebook')#" class="mura-login-auth-btn fb">
									  	<i class="mi-facebook"></i>
									  	<span>#rc.$.rbKey('login.loginwithfacebook')#</span>
									  </a>
									</cfif>
									<!--- Use GitHub oAuth Button --->
									<cfif listFindNoCase(providersAddedList, 'github')>
									  <a href="#$.getBean('githubLoginProvider').generateAuthUrl(session.urltoken)#" title="#rc.$.rbKey('login.loginwithgithub')#" class="mura-login-auth-btn gh">
									  	<i class="mi-github"></i>
									  	<span>#rc.$.rbKey('login.loginwithgithub')#</span>
									  </a>
									</cfif>
									<!--- Use Microsoft oAuth Button --->
									<cfif listFindNoCase(providersAddedList, 'microsoft')>
									  <a href="#$.getBean('microsoftLoginProvider').generateAuthUrl(session.urltoken)#" title="#rc.$.rbKey('login.loginwithmicrosoft')#" class="mura-login-auth-btn ms">
									  	<i class="mi-ms"></i>
									  	<span>#rc.$.rbKey('login.loginwithmicrosoft')#</span>
									  </a>
									</cfif>
									<div class="text-divider"><span>#rc.$.rbKey('login.or')#</span></div>
									<h3 class="center mura-login-auth-heading">#rc.$.rbKey('login.loginwithcredentials')#</h3>
		       					</div>
			        	</cfif>

					<div class="mura-control-group">
						<label>
							#rc.$.rbKey('login.username')#
						</label>
						<input id="username" name="username" type="text" autofocus="autofocus">
					</div>

					<div class="mura-control-group">
						<label>#rc.$.rbKey('login.password')#</label>
						<input id="password" type="password" name="password" required="true" maxlength="255" autocomplete="off">
					</div>

					<cfif rc.$.getBean('configBean').getValue(property='MFA',defaultValue=false)>
						<div class="mura-control-group half">
							<!--- <label>Language</label> --->
							<label></label>
							<select name="rb">
								<option value="en_US">English</option>
								<!---<option value="zh_CN"<cfif cookie.rb eq "zh_CN"> selected</cfif>>Chinese</option>--->
								<option value="da"<cfif cookie.rb eq "da"> selected</cfif>>Danish</option>
								<option value="de"<cfif cookie.rb eq "de"> selected</cfif>>Deutsch</option>
								<option value="nl"<cfif cookie.rb eq "nl"> selected</cfif>>Dutch</option>
								<option value="fil"<cfif cookie.rb eq "fil"> selected</cfif>>Filipino</option>
								<option value="fr"<cfif cookie.rb eq "fr"> selected</cfif>>Fran&ccedil;ais</option>
								<option value="hu"<cfif cookie.rb eq "hu"> selected</cfif>>Hungarian</option>
								<option value="id"<cfif cookie.rb eq "id"> selected</cfif>>Indonesian</option>
								<option value="it"<cfif cookie.rb eq "it"> selected</cfif>>Italian</option>
								<option value="pt"<cfif cookie.rb eq "pt"> selected</cfif>>Portuguese</option>
									<option value="ru"<cfif cookie.rb eq "ru"> selected</cfif>>Русский</option>
								<option value="es"<cfif cookie.rb eq "es"> selected</cfif>>Spanish</option>
							</select>
						</div>
					<cfelse>
						<div class="mura-control-group half" id="remember-me">
							<label class="css-input switch switch-sm switch-primary">
								<input type="checkbox" id="rememberMe" name="rememberMe" value="1" ><span></span> #rc.$.rbKey('login.rememberme')#
							</label>
						</div>
						<div class="mura-control-group half">
							<!--- <label>Language</label> --->
							<label></label>
							<select name="rb">
								<option value="en_US">English</option>
								<!---<option value="zh_CN"<cfif cookie.rb eq "zh_CN"> selected</cfif>>Chinese</option>--->
								<option value="da"<cfif cookie.rb eq "da"> selected</cfif>>Danish</option>
								<option value="de"<cfif cookie.rb eq "de"> selected</cfif>>Deutsch</option>
								<option value="nl"<cfif cookie.rb eq "nl"> selected</cfif>>Dutch</option>
								<option value="fil"<cfif cookie.rb eq "fil"> selected</cfif>>Filipino</option>
								<option value="fr"<cfif cookie.rb eq "fr"> selected</cfif>>Fran&ccedil;ais</option>
								<option value="hu"<cfif cookie.rb eq "hu"> selected</cfif>>Hungarian</option>
								<option value="id"<cfif cookie.rb eq "id"> selected</cfif>>Indonesian</option>
								<option value="it"<cfif cookie.rb eq "it"> selected</cfif>>Italian</option>
								<option value="pt"<cfif cookie.rb eq "pt"> selected</cfif>>Portuguese</option>
								<option value="ru"<cfif cookie.rb eq "ru"> selected</cfif>>Русский</option>
								<option value="es"<cfif cookie.rb eq "es"> selected</cfif>>Spanish</option>
							</select>
						</div>

					</cfif>

					<div class="mura-focus-actions">
						<button type="submit"> #rc.$.rbKey('login.login')#</button>
					</div>

					<input name="returnUrl" type="hidden" value="#esapiEncode('html_attr',rc.returnURL)#">
					<input type="hidden" name="muraAction" value="cLogin.login">
					<input type="hidden" name="isAdminLogin" value="true">
					<input type="hidden" name="compactDisplay" value="#esapiEncode('html_attr',rc.compactDisplay)#">
					#rc.$.renderCSRFTokens(format='form',context='login')#
				</form>

				<cfif not isBoolean(application.configBean.getValue('showadminloginhelp')) or application.configBean.getValue('showadminloginhelp')>
					<div id="pw-link">
						<label><a href="##" onclick="return false;">#application.rbFactory.getKeyValue(session.rb,'login.forgetpassword')#</a></label>
					</div>
				</cfif>

				</div><!-- /block-content -->
			</div><!-- /mura-focus-block -->

		<div class="block mura-focus-block animated" id="mura-password-panel" <cfif not rc.status eq 'sendLogin'>style="display:none;"</cfif>>

			#focusblockheader#

	  	  	<div class="block-content">

				<cfif not isBoolean(application.configBean.getValue('showadminloginhelp')) or application.configBean.getValue('showadminloginhelp')>
					<form novalidate="novalidate" id="sendLogin" name="sendLogin" method="post" action="./?muraAction=cLogin.main" onsubmit="return submitForm(this);">

						<div class="mura-control-group">
							<h2>#rc.$.rbKey('login.forgetpassword')#</h2>
							<cfset alertclass = ''>
							<cfsavecontent variable="pwresponse">
							<cfif rc.status eq 'sendLogin'>
								<cfset msg=application.userManager.sendLoginByEmail('#rc.email#','','#esapiEncode("url","#listFirst(cgi.http_host,":")##cgi.SCRIPT_NAME#")#')>
									<cfif left(msg,2) eq "No">
									#esapiEncode('html',application.rbFactory.getResourceBundle(session.rb).messageFormat(rc.$.rbKey("login.noaccountexists"),rc.email))#
									<cfset alertclass = "alert alert-error">
									<cfelseif left(msg,4) eq "Your">
									#esapiEncode('html',application.rbFactory.getResourceBundle(session.rb).messageFormat(rc.$.rbKey("login.messagesent"),rc.email))#
									<cfset alertclass = "alert">
									<cfelse>	#esapiEncode('html',application.rbFactory.getResourceBundle(session.rb).messageFormat(rc.$.rbKey("login.invalidemail"),rc.email))#
									<cfset alertclass = "alert alert-error">
									</cfif>
								<cfelse>
								#rc.$.rbKey('login.enteremail')#
								</cfif>
							</cfsavecontent>
								<div id="pw-response" class="#alertclass# clear-both">#pwresponse#</div>
								<div class="mura-control-group">
									<label>#rc.$.rbKey('login.emailaddress')#</label>
									<input id="email" name="email" type="text" autofocus="autofocus">
								</div>
						</div>
						<div class="mura-focus-actions">
							<input type="submit" class="btn" value="#rc.$.rbKey('login.submit')#" />
							</div>
						<input type="hidden" name="status" value="sendlogin" />
						<input name="returnURL" type="hidden" value="#esapiEncode('html_attr',rc.returnURL)#">
						<input type="hidden" name="isAdminLogin" value="true">
						<input type="hidden" name="compactDisplay" value="#esapiEncode('html_attr',rc.compactDisplay)#">
					</form>

					<div id="login-link">
							<label><a href="##" onclick="return false;">Return to login</a></label>
					</div>

					</cfif>
				</cfif>
			</cfif>

		</div><!-- /block-content -->
	</div><!-- /mura-focus-block -->

</div><!-- /mura-login -->
</cfoutput>

<script type="text/javascript">
jQuery(document).ready(function(){
<cfif rc.compactDisplay eq "true">
	if (top.location != self.location) {
		if(jQuery("#ProxyIFrame").length){
			jQuery("#ProxyIFrame").load(
				function(){
					frontEndProxy.post({cmd:'setWidth',width:400});
				}
			);
		} else {
			frontEndProxy.post({cmd:'setWidth',width:400});
		}
	}
</cfif>

	jQuery('#pw-link a').click(function(){
		jQuery('#mura-login-panel').removeClass('flipInY').addClass('flipOutY').hide();
		jQuery('#mura-password-panel').removeClass('flipOutY').show().addClass('flipInY');
		document.getElementById('email').focus();
	});
	jQuery('#login-link a').click(function(){
		jQuery('#mura-password-panel').removeClass('flipInY').addClass('flipOutY').hide();
		jQuery('#pw-response').removeClass('alert').removeClass('alert-error').html('<cfoutput>#esapiEncode('html_attr',rc.$.rbKey('login.enteremail'))#</cfoutput>');
		jQuery('#mura-login-panel').removeClass('flipOutY').show().addClass('flipInY');
		document.getElementById('username').focus();
	});

});
</script>
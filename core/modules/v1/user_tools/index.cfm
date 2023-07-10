<!--- license goes here --->
<cfsilent>
	<cfset variables.$.loadShadowBoxJS() />
	<cfset request.cacheitem=false>
</cfsilent>
<cfoutput>
	<cfif variables.$.event('display') neq 'login'>
		<cfif not len(getPersonalizationID())>
			<div id="login" class="mura-user-tools-login #this.userToolsLoginWrapperClass#">
				<form role="form" class="#this.userToolsLoginFormClass#" action="<cfoutput>?nocache=1</cfoutput>" name="loginForm" method="post">
					<legend>#variables.$.rbKey('user.signin')#</legend>

					<!--- Username --->
					<div class="req #this.userToolsFormGroupWrapperClass#">
						<label class="#this.userToolsLoginFormLabelClass#" for="txtUserName">
							#variables.$.rbKey('user.username')#
							<ins>(#HTMLEditFormat(variables.$.rbKey('user.required'))#)</ins>
						</label>
						<div class="#this.userToolsLoginFormInputWrapperClass#">
							<input type="text" id="txtUserName" name="username" class="#this.userToolsLoginFormInputClass#" placeholder="#variables.$.rbKey('user.username')#">
						</div>
					</div>

					<!--- Password --->
					<div class="req #this.userToolsFormGroupWrapperClass#">
						<label class="#this.userToolsLoginFormLabelClass#" for="txtPassword">
							#variables.$.rbKey('user.password')#
							<ins>(#HTMLEditFormat(variables.$.rbKey('user.required'))#)</ins>
						</label>
						<div class="#this.userToolsLoginFormInputWrapperClass#">
							<input type="password" id="txtPassword" name="password" class="#this.userToolsLoginFormInputClass#" placeholder="#variables.$.rbKey('user.password')#"  autocomplete="off">
						</div>
					</div>

					<!--- Remember Me --->
					<div class="#this.userToolsFormGroupWrapperClass#">
						<div class="#this.userToolsLoginFormFieldInnerClass#">
							<label class="#this.userToolsLoginFormCheckboxClass#" for="cbRemember">
								<input type="checkbox" id="cbRemember" name="rememberMe" value="1"> #variables.$.rbKey('user.rememberme')#
							</label>
						</div>
					</div>

					<div class="#this.userToolsFormGroupWrapperClass#">
						<div class="#this.userToolsLoginFormFieldInnerClass#">
							<input type="hidden" name="doaction" value="login">
							#variables.$.renderCSRFTokens(format='form',context='login')#
							<button type="submit" class="#this.userToolsLoginFormSubmitClass#">#variables.$.rbKey('user.signin')#</button>
						</div>
					</div>
				</form>
			</div>
			<!--- Not Registered? --->
			<cfif application.settingsManager.getSite(variables.$.event('siteID')).getExtranetPublicReg()>
					<#variables.$.getHeaderTag('subHead2')#>#variables.$.rbKey('user.notregistered')# <a class="#this.userToolsNotRegisteredLinkClass#" href="#variables.$.siteConfig().getEditProfileURL()#&amp;returnURL=#esapiEncode('url',variables.$.getCurrentURL())#">#variables.$.rbKey('user.signup')#</a></#variables.$.getHeaderTag('subHead2')#>
			</cfif>
		<cfelse>
			<cfif session.mura.isLoggedIn>
				<div id="svSessionTools" class="mura-user-tools-session #this.userToolsWrapperClass#">
					<p id="welcome">#variables.$.rbKey('user.welcome')#, #HTMLEditFormat("#session.mura.fname# #session.mura.lname#")#</p>
				 	<ul id="navSession">
						<li id="navEditProfile"><a class="#this.userToolsEditProfileLinkClass#" href="#variables.$.siteConfig().getEditProfileURL()#&amp;nocache=1&amp;returnURL=#esapiEncode('url',variables.$.getCurrentURL())#">#variables.$.rbKey('user.editprofile')#</a></li>
						<li id="navLogout"><a class="#this.userToolsLogoutLinkClass#" href="./?doaction=logout">#variables.$.rbKey('user.logout')#</a></li>
					</ul>
				</div>
			</cfif>
			#dspObject('favorites')#
		</cfif>
	</cfif>
</cfoutput>

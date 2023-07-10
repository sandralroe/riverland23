<!--- license goes here --->
<cfoutput>
<cfset variables.bean=$.event('formBean')>
<cfset variables.rsform=variables.bean.getAllValues()>
<cfif StructKeyExists(request, 'polllist') and  variables.rsform.responseChart and not(refind("Mac",cgi.HTTP_USER_AGENT) and refind("MSIE 5",cgi.HTTP_USER_AGENT))>

	<cfset variables.customResponse=application.pluginManager.renderEvent("onFormSubmitPollRender",variables.event)>
	<cfif len(variables.customResponse)>
		#variables.customResponse#
	<cfelse>
		#$.dspObject_Include(thefile='datacollection/dsp_poll.cfm')#
	</cfif>
</cfif>
<cfset formDataBean=variables.event.getValue('formDataBean')>
<cfif not formDataBean.getValue('acceptdata')>
	<cfset variables.customresponse = application.pluginManager.renderEvent("onFormSubmitErrorRender",variables.event) />
	<cfif Len(variables.customresponse)>
		#variables.customresponse#
	<cfelseif formDataBean.getValue('acceptError') eq "Browser">
		<p class="#this.alertDangerClass#">We're sorry the polling feature is not supported for IE 5 on the Mac</p>
	<cfelseif formDataBean.getValue('acceptError') eq "Duplicate">
		<p class="#this.alertDangerClass#">#$.rbKey("poll.onlyonevote")#</p>
	<cfelseif formDataBean.getValue('acceptError') eq "Captcha">
		<p class="#this.alertDangerClass#">#$.rbKey("captcha.error")# <a href="javascript:history.back();">#$.rbKey("captcha.tryagain")#</a></p>
	<cfelseif formDataBean.getValue('acceptError') eq "Spam">
		<p class="#this.alertDangerClass#">#$.rbKey("captcha.spam")# <a href="javascript:history.back();">#$.rbKey("captcha.tryagain")#</a></p>
  <cfelseif formDataBean.getValue('acceptError') eq 'reCAPTCHA'>
    <p class="#this.alertDangerClass#">#$.rbKey('recaptcha.error')# <a href="javascript:history.back();">#$.rbKey('recaptcha.tryagain')#</a></p>
	<cfelse>
		<div class="#this.alertDangerClass#">#application.utility.displayErrors(formDataBean.getErrors())#</div>
	</cfif>
<cfelse>
		<div id="frm#replace(variables.rsform.contentID,'-','','ALL')#">
		<cfset variables.customResponse=application.pluginManager.renderEvent("onFormSubmitResponseRender",event)>
		<cfif len(customResponse)>
		#variables.customResponse#
		<cfelse>
		#variables.$.setDynamicContent('<p class="success">' & variables.rsform.responseMessage & '</p>')#
		</cfif>

		<cfif isdefined("request.redirect_url")>
			<cfset request.redirect_url=variables.$.getBean('utility').sanitizeHref(request.redirect_url)>
			<cfset variables.customResponse=application.pluginManager.renderEvent("onBeforeFormSubmitRedirect",variables.event)>
			<cfif len(variables.customResponse)>
				#variables.customResponse#
			<cfelse>
				<cfif isdefined("request.redirect_label")>
					<p class="#this.alertSuccessClass#"><a href="#request.redirect_url#">#request.redirect_label#</a></p>
				<cfelse>
					<cfif request.muraFrontEndRequest>
						<cflocation addtoken="false" url="#request.redirect_url#">
					<cfelse>
						<cfset request.muraJSONRedirectURL=request.redirect_url>
					</cfif>

				</cfif>
			</cfif>
		</cfif>
		</div>
</cfif>
</cfoutput>

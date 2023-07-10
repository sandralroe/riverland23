<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="deprecated">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="settingsManager" type="any" required="yes"/>
		<cfargument name="contentRenderer" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfset variables.settingsManager=arguments.settingsManager />
		<cfset variables.contentRenderer=arguments.contentRenderer />
		<cfreturn this />
	</cffunction>

	<cffunction name="send" output="false">
		<cfargument name="args" type="struct" default="#structNew()#">
		<cfargument name="sendto" type="string" default="">
		<cfargument name="from" type="string" default="">
		<cfargument name="subject" type="string" default="">
		<cfargument name="siteid" type="string" default="">
		<cfargument name="replyto" type="string" default="">
		<cfargument name="bcc" type="string" required="true" default="">

		<cfset var mailserverUsername=""/>
		<cfset var mailserverIP=""/>
		<cfset var mailserverPassword=""/>
		<cfset var mailserverUsernameEmail=""/>
		<cfset var mailserverPort=80/>
		<cfset var tmt_mail_body=""/>
		<cfset var tmt_cr=""/>
		<cfset var tmt_mail_head=""/>
		<cfset var form_element= "" />
		<cfset var attachments=arrayNew(1) />
		<cfset var a =1  />
		<cfset var redirectID=""/>
		<cfset var reviewLink=""/>
		<cfset var fields=""/>
		<cfset var fn=""/>
		<cfset var useDefaultSMTPServer=0/>

			<cfif arguments.siteid neq ''>
				<cfset useDefaultSMTPServer=variables.settingsManager.getSite(arguments.siteid).getUseDefaultSMTPServer()>
				<cfset mailServerUsername=variables.settingsManager.getSite(arguments.siteid).getMailserverUsername(true)/>
				<cfset mailServerUsernameEmail=variables.settingsManager.getSite(arguments.siteid).getMailserverUsernameEmail()/>
				<cfset mailServerIP=variables.settingsManager.getSite(arguments.siteid).getMailserverIP()/>
				<cfset mailServerPassword=variables.settingsManager.getSite(arguments.siteid).getMailserverPassword()/>
				<cfset mailServerPort=variables.settingsManager.getSite(arguments.siteid).getMailserverSMTPPort()/>
			<cfelse>
				<cfset useDefaultSMTPServer=variables.configBean.getUseDefaultSMTPServer()>
				<cfset mailServerUsername=variables.configBean.getMailserverUsername(true)/>
				<cfset mailServerUsernameEmail=variables.configBean.getMailserverUsernameEmail()/>
				<cfset mailServerIP=variables.configBean.getMailserverIP()/>
				<cfset mailServerPassword=variables.configBean.getMailserverPassword()/>
				<cfset mailServerPort=variables.configBean.getMailserverSMTPPort()/>
			</cfif>

		<cfif isStruct(arguments.args) and REFindNoCase("^[^@%*<>' ]+@[^@%*<>' ]{1,255}\.[^@%*<>' ]{2,5}", trim(arguments.sendto)) neq 0>

			<cfset fields=arguments.args>

			<cfif not structKeyExists(fields,"fieldnames")>
			<cfset fields.fieldnames=""/>
			<cfloop collection="#fields#" item="fn">
				<cfset fields.fieldnames=listAppend(fields.fieldnames,fn) />
			</cfloop>
			</cfif>


			<cfset tmt_mail_body = "">
			<cfset tmt_cr = Chr(13) & Chr(10)>
			<cfset tmt_mail_head = "This form was sent at: #LSDateFormat(Now())# #LSTimeFormat(Now(),'short')#">
			<cfloop index="form_element" list="#fields.fieldnames#">

				<cfif form_element neq 'siteid'
						and right(form_element,2) neq ".X"
						and right(form_element,2) neq ".Y"
						and form_element neq 'doaction'
						and form_element neq 'userid'
						and  form_element neq 'password2'
						and form_element neq 'submit'
						and form_element neq 'sendto'
						and form_element neq 'HKEY'
						and form_element neq 'UKEY'>

					<cfif findNoCase('attachment',form_element) and isValid("UUID",fields['#form_element#'])>

						<cfset redirectID=createUUID() />
						<cfset reviewLink='#application.settingsManager.getSite(arguments.siteID).getScheme()#://#application.settingsManager.getSite(arguments.siteID).getDomain()##variables.configBean.getServerPort()##application.configBean.getContext()##application.configBean.getIndexPath()#/_api/render/file/?fileID=#fields["#form_element#"]#&method=attachment' />

						<cfquery datasource="#variables.configBean.getDatasource()#"  username="#variables.configBean.getDBUsername()#" password="#variables.configBean.getDBPassword()#">
						insert into tredirects (redirectID,URL,created) values(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#redirectID#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#reviewLink#" >,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
						)
						</cfquery>

						<cfset tmt_mail_body = tmt_mail_body & form_element & ": " & "#application.settingsManager.getSite(arguments.siteID).getScheme()#://#application.settingsManager.getSite(arguments.siteID).getDomain()##variables.configBean.getServerPort()##application.configBean.getContext()##variables.contentRenderer.getURLStem(arguments.siteID,redirectID)#" & tmt_cr>

					<cfelse>
						<cfset tmt_mail_body = tmt_mail_body & form_element & ": " & fields['#form_element#'] & tmt_cr>
					</cfif>

				</cfif>

			</cfloop>
		<cftry>
		<cfif useDefaultSMTPServer>
		<cfmail to="#arguments.sendto#"
				from='"#arguments.from#" <#MailServerUsernameEmail#>'
				subject="#arguments.subject#"
				replyto="#arguments.replyto#"
				bcc="#arguments.bcc#">#tmt_mail_head#
#trim(tmt_mail_body)#
		</cfmail>
		<cfelse>
		<cfmail to="#arguments.sendto#"
				from='"#arguments.from#" <#MailServerUsernameEmail#>'
				subject="#arguments.subject#"
				server="#MailServerIp#"
				username="#MailServerUsername#"
				password="#MailServerPassword#"
				port="#mailserverPort#"
				replyto="#arguments.replyto#"
				bcc="#arguments.bcc#">#tmt_mail_head#
#trim(tmt_mail_body)#
		</cfmail>
		</cfif>
		<cfcatch>
		<cfif len(arguments.siteid)>
		<cfthrow type="Invalid Mail Settings"
					message="The current mail server settings for the site '#arguments.siteID#'are not valid.">

		<cfelse>
		<cfthrow type="Invalid Mail Settings"
					message="The current mail server settings in the settings.ini are not valid.">
		</cfif>
		</cfcatch>
		</cftry>

		</cfif>
	</cffunction>

	<cffunction name="sendText" output="false">
		<cfargument name="text" type="string" default="">
		<cfargument name="sendto" type="string" default="">
		<cfargument name="from" type="string" default="">
		<cfargument name="subject" type="string" default="">
		<cfargument name="siteid" type="string" default="">
		<cfargument name="replyTo" type="string" default="">
		<cfargument name="mailerID" type="string" default="">
		<cfargument name="bcc" type="string" required="true" default="">

		<cfset var mailserverUsername=""/>
		<cfset var mailserverIP=""/>
		<cfset var mailserverPassword=""/>
		<cfset var mailserverUsernameEmail=""/>
		<cfset var useDefaultSMTPServer=0/>
		<cfset var mailserverPort=80/>

		<cfif REFindNoCase("^[^@%*<>' ]+@[^@%*<>' ]{1,255}\.[^@%*<>' ]{2,5}", trim(arguments.sendto)) neq 0>
			<cfif arguments.siteid neq ''>
				<cfset useDefaultSMTPServer=variables.settingsManager.getSite(arguments.siteid).getUseDefaultSMTPServer()>
				<cfset mailServerUsername=variables.settingsManager.getSite(arguments.siteid).getMailserverUsername(true)/>
				<cfset mailServerUsernameEmail=variables.settingsManager.getSite(arguments.siteid).getMailserverUsernameEmail()/>
				<cfset mailServerIP=variables.settingsManager.getSite(arguments.siteid).getMailserverIP()/>
				<cfset mailServerPassword=variables.settingsManager.getSite(arguments.siteid).getMailserverPassword()/>
				<cfset mailServerPort=variables.settingsManager.getSite(arguments.siteid).getMailserverSMTPPort()/>
			<cfelse>
				<cfset useDefaultSMTPServer=variables.configBean.getUseDefaultSMTPServer()>
				<cfset mailServerUsername=variables.configBean.getMailserverUsername(true)/>
				<cfset mailServerUsernameEmail=variables.configBean.getMailserverUsernameEmail()/>
				<cfset mailServerIP=variables.configBean.getMailserverIP()/>
				<cfset mailServerPassword=variables.configBean.getMailserverPassword()/>
				<cfset mailServerPort=variables.configBean.getMailserverSMTPPort()/>
			</cfif>

			<cftry>
			<cfif useDefaultSMTPServer>
				<cfmail to="#arguments.sendto#"
						from='"#arguments.from#" <#MailServerUsernameEmail#>'
						subject="#arguments.subject#"
						replyto="#arguments.replyto#"
						failto="#mailServerUsernameEmail#"
						type="text"
						mailerid="#arguments.mailerID#"
						bcc="#arguments.bcc#">#trim(arguments.text)#</cfmail>
			<cfelse>
				<cfmail to="#arguments.sendto#"
						from='"#arguments.from#" <#MailServerUsernameEmail#>'
						subject="#arguments.subject#"
						server="#MailServerIp#"
						username="#MailServerUsername#"
						password="#MailServerPassword#"
						port="#mailserverPort#"
						replyto="#arguments.replyto#"
						failto="#mailServerUsernameEmail#"
						type="text"
						mailerid="#arguments.mailerID#"
						bcc="#arguments.bcc#">#trim(arguments.text)#</cfmail>
			</cfif>
			<cfcatch>
				<cfif len(arguments.siteid)>
					<cfthrow type="Invalid Mail Settings"
						message="The current mail server settings for the site '#arguments.siteID#'are not valid.">

				<cfelse>
					<cfthrow type="Invalid Mail Settings"
						message="The current mail server settings in the settings.ini are not valid.">
				</cfif>
			</cfcatch>
			</cftry>

		</cfif>
	</cffunction>

	<cffunction name="sendHTML" output="false">
		<cfargument name="html" type="string" default="">
		<cfargument name="sendto" type="string" default="">
		<cfargument name="from" type="string" default="">
		<cfargument name="subject" type="string" default="">
		<cfargument name="siteid" type="string" default="">
		<cfargument name="replyTo" type="string" default="">
		<cfargument name="mailerID" type="string" default="">
		<cfargument name="bcc" type="string" required="true" default="">

		<cfset var mailserverUsername=""/>
		<cfset var mailserverIP=""/>
		<cfset var mailserverPassword=""/>
		<cfset var mailserverUsernameEmail=""/>
		<cfset var useDefaultSMTPServer=0/>
		<cfset var mailserverPort=80/>

		<cfif REFindNoCase("^[^@%*<>' ]+@[^@%*<>' ]{1,255}\.[^@%*<>' ]{2,5}", trim(arguments.sendto)) neq 0>
			<cfif arguments.siteid neq ''>
				<cfset useDefaultSMTPServer=variables.settingsManager.getSite(arguments.siteid).getUseDefaultSMTPServer()>
				<cfset mailServerUsername=variables.settingsManager.getSite(arguments.siteid).getMailserverUsername(true)/>
				<cfset mailServerUsernameEmail=variables.settingsManager.getSite(arguments.siteid).getMailserverUsernameEmail()/>
				<cfset mailServerIP=variables.settingsManager.getSite(arguments.siteid).getMailserverIP()/>
				<cfset mailServerPassword=variables.settingsManager.getSite(arguments.siteid).getMailserverPassword()/>
				<cfset mailServerPort=variables.settingsManager.getSite(arguments.siteid).getMailserverSMTPPort()/>
			<cfelse>
				<cfset useDefaultSMTPServer=variables.configBean.getUseDefaultSMTPServer()>
				<cfset mailServerUsername=variables.configBean.getMailserverUsername(true)/>
				<cfset mailServerUsernameEmail=variables.configBean.getMailserverUsernameEmail()/>
				<cfset mailServerIP=variables.configBean.getMailserverIP()/>
				<cfset mailServerPassword=variables.configBean.getMailserverPassword()/>
				<cfset mailServerPort=variables.configBean.getMailserverSMTPPort()/>
			</cfif>

			<cftry>
			<cfif useDefaultSMTPServer>
				<cfmail to="#arguments.sendto#"
						from='"#arguments.from#" <#MailServerUsernameEmail#>'
						subject="#arguments.subject#"
						replyto="#arguments.replyto#"
						failto="#mailServerUsernameEmail#"
						type="html"
						mailerid="#arguments.mailerID#"
						bcc="#arguments.bcc#">#trim(arguments.html)#</cfmail>
			<cfelse>
				<cfmail to="#arguments.sendto#"
						from='"#arguments.from#" <#MailServerUsernameEmail#>'
						subject="#arguments.subject#"
						server="#MailServerIp#"
						username="#MailServerUsername#"
						password="#MailServerPassword#"
						port="#mailserverPort#"
						replyto="#arguments.replyto#"
						failto="#mailServerUsernameEmail#"
						type="html"
						mailerid="#arguments.mailerID#"
						bcc="#arguments.bcc#">#trim(arguments.html)#</cfmail>
			</cfif>
			<cfcatch>
				<cfif len(arguments.siteid)>
					<cfthrow type="Invalid Mail Settings"
						message="The current mail server settings for the site '#arguments.siteID#'are not valid.">

				<cfelse>
					<cfthrow type="Invalid Mail Settings"
						message="The current mail server settings in the settings.ini are not valid.">
				</cfif>
			</cfcatch>
			</cftry>

		</cfif>
	</cffunction>

	<cffunction name="sendTextAndHTML" output="false">
		<cfargument name="text" type="string" default="">
		<cfargument name="html" type="string" default="">
		<cfargument name="sendto" type="string" default="">
		<cfargument name="from" type="string" default="">
		<cfargument name="subject" type="string" default="">
		<cfargument name="siteid" type="string" default="">
		<cfargument name="replyTo" type="string" default="">
		<cfargument name="mailerID" type="string" default="">
		<cfargument name="bcc" type="string" required="true" default="">

		<cfset var mailserverUsername=""/>
		<cfset var mailserverIP=""/>
		<cfset var mailserverPassword=""/>
		<cfset var mailserverUsernameEmail=""/>
		<cfset var useDefaultSMTPServer=0/>
		<cfset var mailserverPort=80/>

		<cfif REFindNoCase("^[^@%*<>' ]+@[^@%*<>' ]{1,255}\.[^@%*<>' ]{2,5}", trim(arguments.sendto)) neq 0>
			<cfif arguments.siteid neq ''>
				<cfset useDefaultSMTPServer=variables.settingsManager.getSite(arguments.siteid).getUseDefaultSMTPServer()>
				<cfset mailServerUsername=variables.settingsManager.getSite(arguments.siteid).getMailserverUsername(true)/>
				<cfset mailServerUsernameEmail=variables.settingsManager.getSite(arguments.siteid).getMailserverUsernameEmail()/>
				<cfset mailServerIP=variables.settingsManager.getSite(arguments.siteid).getMailserverIP()/>
				<cfset mailServerPassword=variables.settingsManager.getSite(arguments.siteid).getMailserverPassword()/>
				<cfset mailServerPort=variables.settingsManager.getSite(arguments.siteid).getMailserverSMTPPort()/>
			<cfelse>
				<cfset useDefaultSMTPServer=variables.configBean.getUseDefaultSMTPServer()>
				<cfset mailServerUsername=variables.configBean.getMailserverUsername(true)/>
				<cfset mailServerUsernameEmail=variables.configBean.getMailserverUsernameEmail()/>
				<cfset mailServerIP=variables.configBean.getMailserverIP()/>
				<cfset mailServerPassword=variables.configBean.getMailserverPassword()/>
				<cfset mailServerPort=variables.configBean.getMailserverSMTPPort()/>
			</cfif>

			<cftry>
			<cfif useDefaultSMTPServer>
				<cfmail to="#arguments.sendto#"
						from='"#arguments.from#" <#MailServerUsernameEmail#>'
						subject="#arguments.subject#"
						replyto="#arguments.replyto#"
						failto="#mailServerUsernameEmail#"
						type="html"
						mailerid="#arguments.mailerID#"
						bcc="#arguments.bcc#">
							<cfmailpart type="text/plain">#trim(arguments.text)#</cfmailpart>
							<cfmailpart type="text/html">#trim(arguments.html)#</cfmailpart>
						</cfmail>
			<cfelse>
				<cfmail to="#arguments.sendto#"
						from='"#arguments.from#" <#MailServerUsernameEmail#>'
						subject="#arguments.subject#"
						server="#MailServerIp#"
						username="#MailServerUsername#"
						password="#MailServerPassword#"
						port="#mailserverPort#"
						replyto="#arguments.replyto#"
						failto="#mailServerUsernameEmail#"
						type="html"
						mailerid="#arguments.mailerID#"
						bcc="#arguments.bcc#">
							<cfmailpart type="text/plain">#trim(arguments.text)#</cfmailpart>
							<cfmailpart type="text/html">#trim(arguments.html)#</cfmailpart>
						</cfmail>
			</cfif>
			<cfcatch>
				<cfif len(arguments.siteid)>
					<cfthrow type="Invalid Mail Settings"
						message="The current mail server settings for the site '#arguments.siteID#'are not valid.">

				<cfelse>
					<cfthrow type="Invalid Mail Settings"
						message="The current mail server settings in the settings.ini are not valid.">
				</cfif>
			</cfcatch>
			</cftry>

		</cfif>
	</cffunction>

	<cffunction name="isValidEmailFormat" output="false">
		<cfargument name="email">
		<cfreturn REFindNoCase("^[^@%*<>' ]+@[^@%*<>' ]{1,255}\.[^@%*<>' ]{2,5}", trim(arguments.email)) neq 0>
	</cffunction>

</cfcomponent>

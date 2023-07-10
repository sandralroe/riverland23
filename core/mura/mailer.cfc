<!--- license goes here --->
<cfcomponent extends="mura.baseobject" output="false" hint="This provides a utility to send emails with site of global config settings">

	<cffunction name="init" output="false">
		<cfargument name="configBean" type="any" required="yes"/>
		<cfargument name="settingsManager" type="any" required="yes"/>
		<cfargument name="contentRenderer" type="any" required="yes"/>
		<cfset variables.configBean=arguments.configBean />
		<cfset variables.settingsManager=arguments.settingsManager />
		<cfset variables.contentRenderer=arguments.contentRenderer />
		<cfset variables.sendFromMailServerUserName=variables.configBean.getSendFromMailServerUserName()>
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
		<cfargument name="mailParamArray" type="array" required="false" hint='You can pass the attributes for the cfMailParam tag as an array of structured keys.'>

		<cfset var mailserverUsername="" />
		<cfset var mailserverIP="" />
		<cfset var mailserverPassword="" />
		<cfset var mailserverPort=80 />
		<cfset var mailServerTLS=false />
		<cfset var mailServerSSL=false />
		<cfset var tmt_mail_body="" />
		<cfset var tmt_cr="" />
		<cfset var tmt_mail_head="" />
		<cfset var form_element= "" />
		<cfset var attachments=arrayNew(1) />
		<cfset var a =1  />
		<cfset var redirectID="" />
		<cfset var reviewLink="" />
		<cfset var fields="" />
		<cfset var fn="" />
		<cfset var useDefaultSMTPServer=0 />
		<cfset var fromEmail="" />
		<cfset var filteredSendto=filterEmails(arguments.sendto) />
		<cfset var mailServerFailto="" />
		<cfset var site="">

		<cfif len(arguments.siteid) and not len(arguments.from)>
			<cfset arguments.from=getFromEmail(arguments.siteid)>
		</cfif>

		<cfscript>
			useDefaultSMTPServer = getUseDefaultSMTPServer(arguments.siteid);
			mailServerUsername = getMailserverUsername(arguments.siteid);
			mailServerIP = getMailserverIP(arguments.siteid);
			mailServerPassword = getMailserverPassword(arguments.siteid);
			mailServerPort = getMailServerPort(arguments.siteid);
			mailServerTLS = getMailserverTLS(arguments.siteid);
			mailServerSSL = getMailserverSSL(arguments.siteid);
			fromEmail = getFromEmail(arguments.siteid);
			mailServerFailto = IsValidEmailFormat(fromEmail) ? fromEmail : '';
		</cfscript>

		<cfif isStruct(arguments.args) and len(filteredSendto)>
			<cfset fields=arguments.args>
			<cfif not structKeyExists(fields,"fieldnames")>
				<cfset fields.fieldnames=""/>
				<cfloop collection="#fields#" item="fn">
					<cfset fields.fieldnames=listAppend(fields.fieldnames,fn) />
				</cfloop>
			</cfif>

			<cfset tmt_mail_body = "">
			<cfset tmt_cr = Chr(13) & Chr(10)>
			<cfset tmt_mail_head = "Submitted: #LSDateFormat(Now())# #LSTimeFormat(Now(),'short')# #tmt_cr#">
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
						and form_element neq 'UKEY'
						and structkeyexists(fields, form_element)>

					<cfif findNoCase('attachment',form_element) and isValid("UUID",fields['#form_element#'])>

						<cfset redirectID=createUUID() />
						<cfset site=variables.settingsManager.getSite(arguments.siteid)>
						<cfset reviewLink='#site.getResourcePath(complete=1)##application.configBean.getIndexPath()#/_api/render/file/?fileID=#fields["#form_element#"]#&method=attachment' />

						<cfquery>
						insert into tredirects (redirectID,URL,created) values(
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#redirectID#" >,
						<cfqueryparam cfsqltype="cf_sql_varchar" value="#reviewLink#" >,
						<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
						)
						</cfquery>

						<cfset tmt_mail_body = tmt_mail_body & form_element & ": " & "#site.getWebPath(complete=1)##site.getContentRenderer().getURLStem(arguments.siteID,redirectID)#" & tmt_cr>

					<cfelse>
						<cfset tmt_mail_body = tmt_mail_body & form_element & ": " & fields['#form_element#'] & tmt_cr>
					</cfif>

				</cfif>
			</cfloop>

			<cftry>
				<cfif useDefaultSMTPServer>
					<cfmail to="#filteredSendTo#"
							from="#arguments.from# <#fromEmail#>"
							subject="#arguments.subject#"
							replyto="#arguments.replyto#"
							failto="#mailServerFailto#"
							bcc="#arguments.bcc#">#tmt_mail_head##Chr(13)##Chr(10)##trim(tmt_mail_body)#
							<cfif isDefined('arguments.mailParamArray') and isArray(arguments.mailParamArray)>
								<cfloop array="#arguments.mailParamArray#" index="local.mailParamIndex">
									<cfmailparam attributeCollection='#local.mailParamIndex#'/>
								</cfloop>
							</cfif>
					</cfmail>
				<cfelse>
					<cfmail to="#filteredSendTo#"
							from="#arguments.from# <#fromEmail#>"
							subject="#arguments.subject#"
							server="#MailServerIp#"
							username="#MailServerUsername#"
							password="#MailServerPassword#"
							port="#mailserverPort#"
							useTLS="#mailserverTLS#"
							useSSL="#mailserverSSL#"
							replyto="#arguments.replyto#"
							failto="#mailServerFailto#"
							bcc="#arguments.bcc#">#tmt_mail_head##Chr(13)##Chr(10)##trim(tmt_mail_body)#
							<cfif isDefined('arguments.mailParamArray') and isArray(arguments.mailParamArray)>
								<cfloop array="#arguments.mailParamArray#" index="local.mailParamIndex">
									<cfmailparam attributeCollection='#local.mailParamIndex#'/>
								</cfloop>
							</cfif>
					</cfmail>

				</cfif>
				<cfcatch>
					<cfif len(arguments.siteid)>
						<cflog type="Error" log="exception" text="The current mail server settings for the site '#arguments.siteID#' are not valid.">
					<cfelse>
						<cflog type="Error" log="exception" text="The current mail server settings in the settings.ini are not valid.">
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
		<cfargument name="mailParamArray" type="array" required="false" hint='You can pass the attributes for the cfMailParam tag as an array of structured keys.'>

		<cfset var mailserverUsername=""/>
		<cfset var mailserverIP=""/>
		<cfset var mailserverPassword=""/>
		<cfset var useDefaultSMTPServer=0/>
		<cfset var mailserverPort=80/>
		<cfset var mailServerTLS=false />
		<cfset var mailServerSSL=false />
		<cfset var mailServerFailto="" />
		<cfset var fromEmail="" />
		<cfset var filteredSendto=filterEmails(arguments.sendto)>

		<cfif len(arguments.siteid) and not len(arguments.from)>
			<cfset arguments.from=getFromEmail(arguments.siteid)>
		</cfif>

		<cfif len(filteredSendto)>

			<cfscript>
				useDefaultSMTPServer = getUseDefaultSMTPServer(arguments.siteid);
				mailServerUsername = getMailserverUsername(arguments.siteid);
				mailServerIP = getMailserverIP(arguments.siteid);
				mailServerPassword = getMailserverPassword(arguments.siteid);
				mailServerPort = getMailServerPort(arguments.siteid);
				mailServerTLS = getMailserverTLS(arguments.siteid);
				mailServerSSL = getMailserverSSL(arguments.siteid);
				fromEmail = getFromEmail(arguments.siteid);
				mailServerFailto = IsValidEmailFormat(fromEmail) ? fromEmail : '';
			</cfscript>

			<cftry>
				<cfif useDefaultSMTPServer>
					<cfmail to="#filteredSendTo#"
							from='"#arguments.from#" <#fromEmail#>'
							subject="#arguments.subject#"
							replyto="#arguments.replyto#"
							failto="#mailServerFailto#"
							type="text"
							mailerid="#arguments.mailerID#"
							bcc="#arguments.bcc#">#trim(arguments.text)#
							<cfif isDefined('arguments.mailParamArray') and isArray(arguments.mailParamArray)>
								<cfloop array="#arguments.mailParamArray#" index="local.mailParamIndex">
									<cfmailparam attributeCollection='#local.mailParamIndex#'/>
								</cfloop>
							</cfif>
					</cfmail>
				<cfelse>
					<cfmail to="#filteredSendTo#"
							from='"#arguments.from#" <#fromEmail#>'
							subject="#arguments.subject#"
							server="#MailServerIp#"
							username="#MailServerUsername#"
							password="#MailServerPassword#"
							port="#mailserverPort#"
							useTLS="#mailserverTLS#"
							useSSL="#mailserverSSL#"
							replyto="#arguments.replyto#"
							failto="#mailServerFailto#"
							type="text"
							mailerid="#arguments.mailerID#"
							bcc="#arguments.bcc#">#trim(arguments.text)#
							<cfif isDefined('arguments.mailParamArray') and isArray(arguments.mailParamArray)>
								<cfloop array="#arguments.mailParamArray#" index="local.mailParamIndex">
									<cfmailparam attributeCollection='#local.mailParamIndex#'/>
								</cfloop>
							</cfif>
					</cfmail>
				</cfif>
			<cfcatch>
				<cfif len(arguments.siteid)>
					<cflog type="Error" log="exception" text="The current mail server settings for the site '#arguments.siteID#' are not valid: #serializeJSON(cfcatch)#">
				<cfelse>
					<cflog type="Error" log="exception" text="The current mail server settings in the settings.ini are not valid: #serializeJSON(cfcatch)#">
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
		<cfargument name="mailParamArray" type="array" required="false" hint='You can pass the attributes for the cfMailParam tag as an array of structured keys.'>

		<cfset var mailserverUsername=""/>
		<cfset var mailserverIP=""/>
		<cfset var mailserverPassword=""/>
		<cfset var useDefaultSMTPServer=0/>
		<cfset var mailserverPort=80/>
		<cfset var mailServerTLS=false />
		<cfset var mailServerSSL=false />
		<cfset var mailServerFailto="" />
		<cfset var fromEmail="" />
		<cfset var filteredSendto=filterEmails(arguments.sendto)>

		<cfif len(arguments.siteid) and not len(arguments.from)>
			<cfset arguments.from=getFromEmail(arguments.siteid)>
		</cfif>

		<cfif len(filteredSendto)>
			<cfscript>
				useDefaultSMTPServer = getUseDefaultSMTPServer(arguments.siteid);
				mailServerUsername = getMailserverUsername(arguments.siteid);
				mailServerIP = getMailserverIP(arguments.siteid);
				mailServerPassword = getMailserverPassword(arguments.siteid);
				mailServerPort = getMailServerPort(arguments.siteid);
				mailServerTLS = getMailserverTLS(arguments.siteid);
				mailServerSSL = getMailserverSSL(arguments.siteid);
				fromEmail = getFromEmail(arguments.siteid);
				mailServerFailto = IsValidEmailFormat(fromEmail) ? fromEmail : '';
			</cfscript>

			<cftry>
				<cfif useDefaultSMTPServer>
					<cfmail to="#filteredSendTo#"
							from='"#arguments.from#" <#fromEmail#>'
							subject="#arguments.subject#"
							replyto="#arguments.replyto#"
							failto="#mailServerFailto#"
							type="html"
							mailerid="#arguments.mailerID#"
							bcc="#arguments.bcc#">#trim(arguments.html)#
							<cfif isDefined('arguments.mailParamArray') and isArray(arguments.mailParamArray)>
								<cfloop array="#arguments.mailParamArray#" index="local.mailParamIndex">
									<cfmailparam attributeCollection='#local.mailParamIndex#'/>
								</cfloop>
							</cfif>
					</cfmail>
				<cfelse>
					<cfmail to="#filteredSendTo#"
							from='"#arguments.from#" <#fromEmail#>'
							subject="#arguments.subject#"
							server="#MailServerIp#"
							username="#MailServerUsername#"
							password="#MailServerPassword#"
							port="#mailserverPort#"
							useTLS="#mailserverTLS#"
							useSSL="#mailserverSSL#"
							replyto="#arguments.replyto#"
							failto="#mailServerFailto#"
							type="html"
							mailerid="#arguments.mailerID#"
							bcc="#arguments.bcc#">#trim(arguments.html)#
							<cfif isDefined('arguments.mailParamArray') and isArray(arguments.mailParamArray)>
								<cfloop array="#arguments.mailParamArray#" index="local.mailParamIndex">
									<cfmailparam attributeCollection='#local.mailParamIndex#'/>
								</cfloop>
							</cfif>
					</cfmail>
				</cfif>
			<cfcatch>
				<cfif len(arguments.siteid)>
					<cflog type="Error" log="exception" text="The current mail server settings for the site '#arguments.siteID#' are not valid: #serializeJSON(cfcatch)#">
				<cfelse>
					<cflog type="Error" log="exception" text="The current mail server settings in the settings.ini are not valid: #serializeJSON(cfcatch)#">
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
		<cfargument name="mailParamArray" type="array" required="false" hint='You can pass the attributes for the cfMailParam tag as an array of structured keys.'>

		<cfset var mailserverUsername=""/>
		<cfset var mailserverIP=""/>
		<cfset var mailserverPassword=""/>
		<cfset var useDefaultSMTPServer=0/>
		<cfset var mailserverPort=80/>
		<cfset var mailServerTLS=false />
		<cfset var mailServerSSL=false />
		<cfset var mailServerFailto="" />
		<cfset var fromEmail="" />
		<cfset var filteredSendto=filterEmails(arguments.sendto)>

		<cfif len(arguments.siteid) and not len(arguments.from)>
			<cfset arguments.from=getFromEmail(arguments.siteid)>
		</cfif>

		<cfif len(filteredSendto)>

			<cfscript>
				useDefaultSMTPServer = getUseDefaultSMTPServer(arguments.siteid);
				mailServerUsername = getMailserverUsername(arguments.siteid);
				mailServerIP = getMailserverIP(arguments.siteid);
				mailServerPassword = getMailserverPassword(arguments.siteid);
				mailServerPort = getMailServerPort(arguments.siteid);
				mailServerTLS = getMailserverTLS(arguments.siteid);
				mailServerSSL = getMailserverSSL(arguments.siteid);
				fromEmail = getFromEmail(arguments.siteid);
				mailServerFailto = IsValidEmailFormat(fromEmail) ? fromEmail : '';
			</cfscript>

			<cftry>
			<cfif useDefaultSMTPServer>
				<cfmail to="#filteredSendTo#"
						from='"#arguments.from#" <#fromEmail#>'
						subject="#arguments.subject#"
						replyto="#arguments.replyto#"
						failto="#mailServerFailto#"
						type="html"
						mailerid="#arguments.mailerID#"
						bcc="#arguments.bcc#">
					<cfmailpart type="text/plain">#trim(arguments.text)#</cfmailpart>
					<cfmailpart type="text/html">#trim(arguments.html)#</cfmailpart>
					<cfif isDefined('arguments.mailParamArray') and isArray(arguments.mailParamArray)>
						<cfloop array="#arguments.mailParamArray#" index="local.mailParamIndex">
							<cfmailparam attributeCollection='#local.mailParamIndex#'/>
						</cfloop>
					</cfif>
				</cfmail>
			<cfelse>
				<cfmail to="#filteredSendTo#"
						from='"#arguments.from#" <#fromEmail#>'
						subject="#arguments.subject#"
						server="#MailServerIp#"
						username="#MailServerUsername#"
						password="#MailServerPassword#"
						port="#mailserverPort#"
						useTLS="#mailserverTLS#"
						useSSL="#mailserverSSL#"
						replyto="#arguments.replyto#"
						failto="#mailServerFailto#"
						type="html"
						mailerid="#arguments.mailerID#"
						bcc="#arguments.bcc#">
					<cfmailpart type="text/plain">#trim(arguments.text)#</cfmailpart>
					<cfmailpart type="text/html">#trim(arguments.html)#</cfmailpart>
					<cfif isDefined('arguments.mailParamArray') and isArray(arguments.mailParamArray)>
						<cfloop array="#arguments.mailParamArray#" index="local.mailParamIndex">
							<cfmailparam attributeCollection='#local.mailParamIndex#'/>
						</cfloop>
					</cfif>
				</cfmail>
			</cfif>
			<cfcatch>
				<cfif len(arguments.siteid)>
					<cflog type="Error" log="exception" text="The current mail server settings for the site '#arguments.siteID#' are not valid: #serializeJSON(cfcatch)#">
				<cfelse>
					<cflog type="Error" log="exception" text="The current mail server settings in the settings.ini are not valid: #serializeJSON(cfcatch)#">
				</cfif>
			</cfcatch>
			</cftry>
		</cfif>
	</cffunction>

	<cffunction name="isValidEmailFormat" output="false">
		<cfargument name="email">
		<cfreturn REFindNoCase("^[^@%*<>' ]+@[^@%*<>' ]{1,255}\.[^@%*<>' ]{2,5}", trim(arguments.email)) neq 0>
	</cffunction>

	<cffunction name="filterEmails" output="false">
		<cfargument name="emails">
		<cfset var returnList="">
		<cfset var i="">
		<cfif len(arguments.emails)>
			<cfloop list="#arguments.emails#" index="i">
				<cfif isValidEmailFormat(i)>
					<cfset returnList=listAppend(returnList,i)>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn returnList>
	</cffunction>

	<cfscript>
		public any function getFromEmail(string siteid='default') {
			var defaultFrom = 'no-reply@' & variables.settingsManager.getSite(arguments.siteid).getDomain();
			return variables.sendFromMailServerUserName && Len(getMailServerUsername(arguments.siteid)) && IsValid('email', getMailServerUsername(arguments.siteid))
				? getMailServerUsername(arguments.siteid)
				: Len(variables.settingsManager.getSite(arguments.siteid).getContact()) && IsValid('email', variables.settingsManager.getSite(arguments.siteid).getContact())
					? variables.settingsManager.getSite(arguments.siteid).getContact()
					: Len(variables.configBean.getAdminEmail()) && IsValid('email', variables.configBean.getAdminEmail())
						? variables.configBean.getAdminEmail()
						: defaultFrom;
		}

		public string function getUseDefaultSMTPServer(string siteid='') {
			return Len(arguments.siteid)
				? variables.settingsManager.getSite(arguments.siteid).getUseDefaultSMTPServer()
				: variables.configBean.getUseDefaultSMTPServer();
		}

		public string function getMailServerUsername(string siteid='') {
			return Len(arguments.siteid)
				? variables.settingsManager.getSite(arguments.siteid).getMailServerUsername(true)
				: variables.configBean.getMailServerUsername(true);
		}

		public string function getMailServerIP(string siteid='') {
			return Len(arguments.siteid)
				? variables.settingsManager.getSite(arguments.siteid).getMailServerIP()
				: variables.configBean.getMailServerIP();
		}

		public string function getMailServerPassword(string siteid='') {
			return Len(arguments.siteid)
				? variables.settingsManager.getSite(arguments.siteid).getMailServerPassword()
				: variables.configBean.getMailServerPassword();
		}

		public string function getMailServerPort(string siteid='') {
			return Len(arguments.siteid)
				? variables.settingsManager.getSite(arguments.siteid).getMailServerSMTPPort()
				: variables.configBean.getMailServerSMTPPort();
		}

		public string function getMailServerTLS(string siteid='') {
			return Len(arguments.siteid)
				? variables.settingsManager.getSite(arguments.siteid).getMailServerTLS()
				: variables.configBean.getMailServerTLS();
		}

		public string function getMailServerSSL(string siteid='') {
			return Len(arguments.siteid)
				? variables.settingsManager.getSite(arguments.siteid).getMailServerSSL()
				: variables.configBean.getMailServerSSL();
		}
	</cfscript>

</cfcomponent>

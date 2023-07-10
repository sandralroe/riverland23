<!--- license goes here --->
<cfsilent>
	<cfquery datasource="#application.configBean.getDatasource(mode='readOnly')#" username="#application.configBean.getDBUsername(mode='readOnly')#" password="#application.configBean.getDBPassword(mode='readOnly')#" name="variables.rslist">
		SELECT mlid, name, ispurge, description
		FROM tmailinglist
		WHERE siteid=<cfqueryparam cfsqltype="cf_sql_varchar" value="#variables.$.event('siteID')#">
			AND
				<cfif isValid('UUID',arguments.objectID)>
					mlid
				<cfelse>
					name
				</cfif>
				=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#">
	</cfquery>
</cfsilent>
<cfoutput>
	<div class="svMailingList mura-mailing-list #this.mailingListWrapperClass#" id="#createCSSID(variables.rslist.name)#">

		<cfif variables.$.event('doaction') eq 'unsubscribe'>
				<p class="#this.alertSuccessClass#">
					#variables.$.rbKey('mailinglist.youhaveunsubscribed')#
				</p>
		<cfelseif variables.$.event('doaction') eq 'subscribe' and variables.rslist.isPurge neq 1>
			<cfif variables.$.event("passedProtect")>
				<p class="#this.alertSuccessClass#">
					#variables.$.rbKey('mailinglist.youhavesubscribed')#
				</p>
			<cfelse>
				<p class="#this.alertDangerClass#">
					#variables.$.rbKey('captcha.spam')#
				</p>
			</cfif>
		<cfelseif variables.$.event('doaction') eq 'subscribe' and variables.rslist.isPurge eq 1>
			<cfif variables.$.event("passedProtect")>
				<p class="#this.alertSuccessClass#">
					#variables.$.rbKey('mailinglist.emailremoved')#
				</p>
			<cfelse>
				<p class="#this.alertDangerClass#">
					#variables.$.rbKey('captcha.spam')#
				</p>
			</cfif>
		<cfelse>

			<!--- THE FORM --->
			<form role="form" class="#this.mailingListFormClass#" name="frmMailingList" action="?nocache=1" method="post" onsubmit="return Mura.validateForm(this);" novalidate="novalidate" >
				<fieldset>
					<legend>#HTMLEditFormat(variables.rslist.name)#</legend>

					<!--- Form Description --->
					<cfif #variables.rslist.description# neq ''>
						<div class="description">#HTMLEditFormat(variables.rslist.description)#</div>
					</cfif>

					<cfif variables.rslist.isPurge neq 1>

						<!--- First Name --->
						<div class="req #this.mailingListFormGroupWrapperClass#">
							<label for="txtNameFirst" class="#this.mailingListFormLabelClass#">
								#variables.$.rbKey('mailinglist.fname')#
								<ins>(#variables.$.rbKey('mailinglist.required')#)</ins>
							</label>
							<div class="#this.mailingListFormFieldWrapperClass#">
								<input type="text" id="txtNameFirst" class="#this.mailingListFormInputClass#" name="fname" maxlength="50" data-required="true" data-message="#HTMLEditFormat(variables.$.rbKey('mailinglist.fnamerequired'))#"/>
							</div>
						</div>

						<!--- Last Name --->
						<div class="req #this.mailingListFormGroupWrapperClass#">
							<label for="txtNameLast" class="#this.mailingListFormLabelClass#">
								#variables.$.rbKey('mailinglist.lname')#
								<ins>(#variables.$.rbKey('mailinglist.required')#)</ins>
							</label>
							<div class="#this.mailingListFormFieldWrapperClass#">
								<input type="text" id="txtNameLast" class="#this.mailingListFormInputClass#" name="lname" maxlength="50" data-required="true" data-message="#HTMLEditFormat(variables.$.rbKey('mailinglist.lnamerequired'))#"/>
							</div>
						</div>

						<!--- Company --->
						<div class="#this.mailingListFormGroupWrapperClass#">
							<label for="txtCompany" class="#this.mailingListFormLabelClass#">
								#variables.$.rbKey('mailinglist.company')#
							</label>
							<div class="#this.mailingListFormFieldWrapperClass#">
								<input type="text" id="txtCompany" class="#this.mailingListFormInputClass#" name="company" maxlength="50" />
							</div>
						</div>
					</cfif>

					<!--- Email --->
					<div class="req #this.mailingListFormGroupWrapperClass#">
						<label for="txtEmail" class="#this.mailingListFormLabelClass#">
							#variables.$.rbKey('mailinglist.email')#
							<ins>(#variables.$.rbKey('mailinglist.required')#)</ins>
						</label>
						<div class="#this.mailingListFormFieldWrapperClass#">
							<input type="text" id="txtEmail" class="#this.mailingListFormInputClass#" name="email" maxlength="100" data-required="true" data-validate="email" data-message="#HTMLEditFormat(variables.$.rbKey('mailinglist.emailvalidate'))#"/>
						</div>
					</div>
				</fieldset>

				<div class="buttons">
					<input type="hidden" name="linkServID" value="#variables.$.content('contentID')#" />
					<input type="hidden" name="mlid" value="#variables.rslist.mlid#">
					<input type="hidden" name="siteid" value="#variables.$.event('siteID')#" />

					<cfif variables.rslist.isPurge eq 0>
						<input type="hidden" name="doaction" value="subscribe" checked="checked" />
						<input type="hidden" name="isVerified" value="1" />
						<!--- Subscribe --->
						<div class="#this.mailingListFormGroupWrapperClass#">
							<div class="#this.mailingListSubmitWrapperClass#">
								<input type="submit" class="#this.mailingListSubmitClass#" value="#HTMLEditFormat(variables.$.rbKey('mailinglist.subscribe'))#" />
							</div>
						</div>
					<cfelse>
						<input type="hidden" name="doaction" value="subscribe"  />
						<input type="hidden" name="isVerified" value="1"  />
						<!--- Unsubscribe --->
						<div class="#this.mailingListFormGroupWrapperClass#">
							<div class="#this.mailingListSubmitWrapperClass#">
								<input type="submit" class="#this.mailingListSubmitClass#" value="#HTMLEditFormat(variables.$.rbKey('mailinglist.unsubscribe'))#" />
							</div>
						</div>
					</cfif>

					#variables.$.dspObject_Include(thefile='datacollection/dsp_form_protect.cfm')#
				</div>
			</form>
		</cfif>
	</div>
</cfoutput>

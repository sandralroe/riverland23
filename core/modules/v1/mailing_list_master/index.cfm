<!--- license goes here --->
<cfsilent>
	<cfquery datasource="#application.configBean.getDatasource(mode='readOnly')#" username="#application.configBean.getDBUsername(mode='readOnly')#" password="#application.configBean.getDBPassword(mode='readOnly')#" name="variables.rslist">
		SELECT mlid, name, description
		FROM tmailinglist
		WHERE siteid=<cfqueryparam value="#variables.$.event('siteID')#" cfsqltype="varchar">
			AND isPublic=1
		ORDER BY isPurge, name
	</cfquery>
</cfsilent>
<cfoutput>
	<div id="svMasterEmail" class="mura-master-email #this.mailingListWrapperClass#">
		<cfif variables.$.event('doaction') eq 'unsubscribe'>
			<p class="#this.alertSuccessClass#">
				#variables.$.rbKey('mailinglist.youhaveunsubscribed')#
			</p>
		<cfelseif variables.$.event('doaction') eq 'masterSubscribe'>
			<cfif variables.$.event("passedProtect")>
				<p class="#this.alertSuccessClass#">
					#variables.$.rbKey('mailinglist.selectionssaved')#
				</p>
			<cfelse>
				<p class="#this.alertDangerClass#">
					#variables.$.rbKey('captcha.spam')#
				</p>
			</cfif>
		<cfelseif variables.$.event('doaction') eq 'validateMember'>
			<cfset application.mailinglistManager.validateMember(variables.$.event().getAllValues())/>
			<p class="#this.alertSuccessClass#">
				#variables.$.rbKey('mailinglist.hasbeenvalidated')#
			</p>
		<cfelse>

			<!--- THE FORM --->
			<form role="form" class="#this.mailingListFormClass#" id="frmEmailMaster" name="frmEmailMaster" action="?nocache=1" method="post" onsubmit="return Mura.validateForm(this);" novalidate="novalidate" >
				<fieldset>
					<legend>#variables.$.rbKey('mailinglist.mydetails')#</legend>

					<!--- First Name --->
					<div class="#this.mailingListFormGroupWrapperClass# req">
						<label for="txtNameFirst" class="#this.mailingListFormLabelClass#">
							#variables.$.rbKey('mailinglist.fname')#
							<ins>(#variables.$.rbKey('mailinglist.required')#)</ins>
						</label>
						<div class="#this.mailingListFormFieldWrapperClass#">
							<input id="txtNameFirst" class="#this.mailingListFormInputClass#" type="text" name="fname" maxlength="50" data-required="true" data-message="#HTMLEditFormat(variables.$.rbKey('mailinglist.fnamerequired'))#" />
						</div>
					</div>

					<!--- Last Name --->
					<div class="#this.mailingListFormGroupWrapperClass# req">
						<label for="txtNameLast" class="#this.mailingListFormLabelClass#">
							#variables.$.rbKey('mailinglist.lname')#
							<ins>(#variables.$.rbKey('mailinglist.required')#)</ins>
						</label>
						<div class="#this.mailingListFormFieldWrapperClass#">
							<input id="txtNameLast" class="#this.mailingListFormInputClass#" type="text" name="lname" maxlength="50" data-required="true" data-message="#HTMLEditFormat(variables.$.rbKey('mailinglist.lnamerequired'))#" />
						</div>
					</div>

					<!--- Company --->
					<div class="#this.mailingListFormGroupWrapperClass#">
							<label for="txtCompany" class="#this.mailingListFormLabelClass#">#variables.$.rbKey('mailinglist.company')#</label>
							<div class="#this.mailingListFormFieldWrapperClass#">
								<input id="txtCompany" class="#this.mailingListFormInputClass#" type="text" maxlength="50" name="company" />
							</div>
					</div>

					<!--- Email --->
					<div class="#this.mailingListFormGroupWrapperClass# req">
						<label for="txtEmail" class="#this.mailingListFormLabelClass#">#variables.$.rbKey('mailinglist.email')#<ins> (#variables.$.rbKey('mailinglist.required')#)</ins></label>
						<div class="#this.mailingListFormFieldWrapperClass#">
							<input id="txtEmail" class="#this.mailingListFormInputClass#" type="text" name="email" maxlength="100" data-required="true" data-validate="email" data-message="#HTMLEditFormat(variables.$.rbKey('mailinglist.emailvalidate'))#" />
						</div>
					</div>
				</fieldset>

			  <!--- Subscriptions --->
				<fieldset>
					<legend>Subscription Settings</legend>
					<div id="subSettings" class="stack"><cfset variables.loopcount = 1>
						<cfloop query="variables.rslist">
							<div class="#this.mailingListFormGroupWrapperClass#">
								<div class="#this.mailingListCheckboxWrapperClass#">
									<div class="#this.mailingListCheckboxClass#">
										<label for="mlid#variables.loopcount#">
											<input id="mlid#variables.loopcount#" class="#this.mailingListCheckboxClass#" type="checkbox" name="mlid" value="#variables.rslist.mlid#" <cfif listfind(variables.$.event('mlid'),variables.rslist.mlid)>checked="checked"</cfif> />
											#variables.rslist.name#
										</label>
										<cfif #variables.rslist.description# neq ''><p class="inputNote">#variables.rslist.description#</p></cfif>
									</div>
								</div>
							</div>
							<cfset variables.loopcount = variables.loopcount + 1>
						</cfloop>
					</div>
				</fieldset>
				<div class="buttons">
					<input type="hidden" name="siteid" value="#variables.$.event('siteID')#" />
					<input type="hidden" name="doaction" value="masterSubscribe" />
					<input type="hidden" name="linkServID" value="#variables.$.content('contentID')#" />
					<div class="#this.mailingListFormGroupWrapperClass#">
						<div class="#this.mailingListSubmitWrapperClass#">
							<input type="submit" class="#this.mailingListSubmitClass#" value="#HTMLEditFormat(variables.$.rbKey('mailinglist.submit'))#" />
						</div>
					</div>
				</div>
				#variables.$.dspObject_Include(thefile='datacollection/dsp_form_protect.cfm')#
			</form>
		</cfif>
	</div>
</cfoutput>

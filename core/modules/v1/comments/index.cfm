<!--- License goes here --->
<!---
	NOTE: The comment form does not appear on Folders or Galleries
--->

<cfif variables.$.siteConfig().getHasComments() and not listFindNoCase("Folder,Gallery",variables.$.content('type'))>
<cfoutput>
	<cfsilent>
		<cfparam name="request.subscribe" default="0">
		<cfparam name="request.remember" default="0">

		<cfif not isDefined('cookie.remember')>
			<cfcookie name="remember" value="0" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
		</cfif>
		<cfif not isDefined('cookie.subscribe')>
			<cfcookie name="subscribe" value="0" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
		</cfif>
		<cfif not isDefined('cookie.name')>
			<cfcookie name="name" value="" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
		</cfif>
		<cfif not isDefined('cookie.url')>
			<cfcookie name="url" value="" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
		</cfif>
		<cfif not isDefined('cookie.email')>
			<cfcookie name="email" value="" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
		</cfif>


		<cfset errorJSTxt = "">

		<cfif not structKeyExists(request,"name")>
			<cfif structKeyExists(cookie,"name")>
				<cfset request.name=cookie.name>
			<cfelseif variables.$.currentUser().isLoggedIn()>
				<cfset request.name=variables.$.currentUser().getUserName()>
			</cfif>
		</cfif>

		<cfif not structKeyExists(request,"url")>
			<cfset request.url=cookie.url>
		</cfif>

		<cfif not structKeyExists(request,"email")>
			<cfif structKeyExists(cookie,"email")>
				<cfset request.email=cookie.email>
			<cfelseif variables.$.currentUser().isLoggedIn()>
				<cfset request.email=variables.$.currentUser().getEmail()>
			</cfif>
		</cfif>

		<cfif not structKeyExists(request,"subscribe")>
			<cfset request.subscribe=cookie.subscribe>
		</cfif>

		<cfif not structKeyExists(request,"remember")>
			<cfset request.remember=cookie.remember>
		</cfif>


		<cfset variables.theContentID=variables.$.content('contentID')>
		<cfset request.isEditor=application.permUtility.getModulePerm("00000000000000000000000000000000015",session.siteid) or application.permUtility.getnodePerm(request.crumbdata) neq 'none'>
		<cfparam name="request.commentid" default="">
		<cfparam name="request.comments" default="">
		<cfparam name="request.commenteditmode" default="add">
		<cfparam name="request.securityCode" default="">
		<cfparam name="session.securityCode" default="">
		<cfparam name="request.deletecommentid" default="">
		<cfparam name="request.spamcommentid" default="">
		<cfparam name="request.approvedcommentid" default="">
		<cfparam name="request.isApproved" default="1">
		<cfparam name="request.hkey" default="">
		<cfparam name="request.ukey" default="">

		<cfset errors=structNew()/>

		<cfif structKeyExists(request,"commentUnsubscribe")>
			<cfset application.contentManager.commentUnsubscribe(variables.$.content('contentID'),request.commentUnsubscribe,variables.$.event('siteID'))>
			<cfset errors["unsubscribe"]=variables.$.rbKey('comments.youhaveunsubscribed')>
		</cfif>

		<cfif request.commentid neq '' and request.comments neq '' and request.name neq ''>
			<cfscript>
				variables.myRequest = structNew();
				StructAppend(variables.myRequest, url, "no");
				StructAppend(variables.myRequest, form, "no");
				// form protection
				variables.passedProtect = variables.$.getBean('utility').isHuman(variables.$.event());
			</cfscript>

			<cfif variables.passedProtect>

				<cfset variables.submittedData=variables.$.getBean('utility').filterArgs(request,application.badwords)/>
				<cfset variables.submittedData.contentID=variables.theContentID />
				<cfif variables.$.currentUser().isLoggedIn()>
					<cfset request.userID=variables.$.currentUser().getUserID()>
				</cfif>

				<cfset variables.submittedData.isApproved=application.settingsManager.getSite(variables.$.event('siteID')).getCommentApprovalDefault() />

				<cfif request.commenteditmode eq "add">
					<cfset commentBean=application.contentManager.saveComment(submittedData,event.getContentRenderer()) />
				<cfelseif request.commenteditmode eq "edit" and request.isEditor>

					<cfset variables.commentBean=application.contentManager.getCommentBean().setCommentID(request.commentID).load()>
					<cfset variables.commentBean.setName(submittedData.name)>
					<cfset variables.commentBean.setComments(submittedData.comments)>
					<cfset variables.commentBean.setURL(submittedData.url)>
					<cfset variables.commentBean.setEmail(submittedData.email)>
					<cfset variables.commentBean.save()>
				</cfif>

				<cfset request.comments=""/>
				<cfif not (request.remember)>
					<cfset request.name=""/>
					<cfset request.email=""/>
					<cfset request.url=""/>
					<cfset request.subscribe=0/>
					<cfset request.remember=0/>
				</cfif>
				<cfif not application.settingsManager.getSite(variables.$.event('siteID')).getCommentApprovalDefault() eq 1>
					<cfset commentBean.sendNotification() />
				</cfif>
				<cfif isBoolean(request.remember) and request.remember>
					<cfcookie name="remember" value="1" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
					<cfcookie name="subscribe" value="#request.subscribe#" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
					<cfcookie name="name" value="#request.name#" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
					<cfcookie name="url" value="#request.url#" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
					<cfcookie name="email" value="#request.email#" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
				<cfelse>
					<cfcookie name="remember" value="0" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
					<cfcookie name="subscribe" value="" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
					<cfcookie name="name" value="" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
					<cfcookie name="url" value="" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
					<cfcookie name="email" value="" httponly="true" secure="#variables.$.globalConfig('SecureCookies')#">
				</cfif>
			<cfelse>
				<cfsavecontent variable="errorJSTxt">
					<script type="text/javascript">
						Mura(function(){
							window.location.hash="errors";
						});
					</script>
				</cfsavecontent>
				<cfset variables.errors["Spam"] = variables.$.rbKey("captcha.spam")>
			</cfif>
		</cfif>

		<cfif request.isEditor and request.deletecommentid neq "" >
			<cfset application.contentManager.deleteComment(request.deletecommentid) />
		</cfif>

		<cfif request.isEditor and request.spamcommentid neq "" >
			<cfset application.contentManager.markCommentAsSpam(request.spamcommentid) />
		</cfif>

		<cfif request.approvedcommentid neq "" >
			<cfset application.contentManager.approveComment(request.approvedcommentid,variables.$.getContentRenderer()) />
		</cfif>
		<cfset variables.level=0>
		<!---
		<cfset rsComments=application.contentManager.readComments(variables.thecontentID,variables.$.event('siteID'),request.isEditor,"asc","",false ) />--->
		<cfset variables.rsSubComments=StructNew() />
	</cfsilent>

	<!--- <cfset TotalRecords=rsComments.RecordCount>
	<cfset RecordsPerPage=10>
	<cfset NumberOfPages=Ceiling(TotalRecords/RecordsPerPage)>
	<cfset CurrentPageNumber=Ceiling(request.StartRow/RecordsPerPage)> --->

	<!--- COMMENTS --->
	<script>
		Mura(function(){
			$.fn.changeElementType = function(newType) {
				var attrs = {};

				$.each(this[0].attributes, function(idx, attr) {
					attrs[attr.nodeName] = attr.value;
				});

				var newelement = $("<" + newType + "/>", attrs).append($(this).contents());
				this.replaceWith(newelement);
				return newelement;
			};

			Mura.loader().loadjs(
				"#variables.$.siteConfig('corePath')#/modules/v1/comments/js/comments.js",
				function(){
					initMuraComments({proxyPath:"#variables.$.globalConfig('corePath')#/modules/v1/comments/ajax/commentsProxy.cfc"});
				}
			);
		});
	</script>

	<div id="svComments" class="mura-comments #this.commentsWrapperClass#">
		<a name="mura-comments"></a>

		<#variables.$.getHeaderTag('subHead1')#>#variables.$.rbKey('comments.comments')#</#variables.$.getHeaderTag('subHead1')#>

		<div id="mura-comments-sort" class="mura-comment-sort-container #this.commentSortContainerClass#" style="display:none">
			<div class="mura-comment-sort-wrapper #this.commentSortWrapperClass#">
				<select id="mura-sort-direction-selector" class="#this.commentSortSelectClass#" name="sortDirection">
					<option value="desc"<cfif variables.$.event('sortDirection') eq "desc"> selected</cfif>>#variables.$.rbKey('comments.sortdescending')#</option>
					<option value="asc"<cfif variables.$.event('sortDirection') eq "asc"> selected</cfif>>#variables.$.rbKey('comments.sortascending')#</option>
				</select>
			</div>
		</div>

		<div id="mura-comments-page" data-contentid="#variables.$.content('contentID')#" data-siteid="#variables.$.content('siteid')#">

		</div>

		<cfif not structIsEmpty(variables.errors) >

				#errorJSTxt#
				<a name="errors"></a>
				<div class="#this.alertDangerClass#">
					#variables.$.getBean('utility').displayErrors(variables.errors)#
				</div>

		<cfelseif request.commentid neq '' and application.settingsManager.getSite(variables.$.event('siteID')).getCommentApprovalDefault() neq 1>
			<div class="#this.alertInfoClass#">
				#variables.$.rbKey('comments.postedsoon')#
			</div>
		</cfif>

		<!--- COMMENT FORM --->
		<div id="mura-comment-post-comment-form" class="#this.commentFormWrapperClass#">

			<cfif $.getContentRenderer().allowPublicComments OR $.currentUser().isLoggedIn()>
				<a id="mura-comment-post-comment-comment" style="display: none" class="#this.commentNewClass#" href="##mura-comment-post-comment">#variables.$.rbKey('comments.newcomment')#</a>
				<!--- THE FORM --->
				<form role="form" id="mura-comment-post-comment" class="#this.commentFormClass#" method="post" name="addComment" novalidate="novalidate"">
					<fieldset>

						<legend id="mura-comment-post-a-comment">#variables.$.rbKey('comments.postacomment')#</legend>
						<div id="mura-comment-edit-comment" style="display:none">#variables.$.rbKey('comments.editcomment')#</div>
						<div id="mura-comment-reply-to-comment" style="display:none">#variables.$.rbKey('comments.replytocomment')#</div>

						<!--- Name --->
							<div class="req #this.commentFieldWrapperClass#">
								<label class="#this.commentFieldLabelClass#" for="txtName">#variables.$.rbKey('comments.name')#<ins> (#variables.$.rbKey('comments.required')#)</ins></label>
								<div class="#this.commentInputWrapperClass#">
									<input id="txtName" name="name" type="text" class="#this.commentInputClass#" maxlength="50" data-required="true" data-message="#htmlEditFormat(variables.$.rbKey('comments.namerequired'))#" value="#HTMLEditFormat(request.name)#">
								</div>
							</div>

						<!--- Email --->
							<div class="req #this.commentFieldWrapperClass#">
								<label class="#this.commentFieldLabelClass#" for="txtEmail">#variables.$.rbKey('comments.email')#<ins> (#variables.$.rbKey('comments.required')#)</ins></label>
								<div class="#this.commentInputWrapperClass#">
									<input id="txtEmail" name="email" type="text" class="#this.commentInputClass#" maxlength="100" data-required="true" data-message="#htmlEditFormat(variables.$.rbKey('comments.emailvalidate'))#" value="#HTMLEditFormat(request.email)#">
								</div>
							</div>

							<!--- URL --->
							<div class="#this.commentFieldWrapperClass#">
								<label for="txtUrl" class="#this.commentFieldLabelClass#">#variables.$.rbKey('comments.url')#</label>
								<div class="#this.commentInputWrapperClass#">
									<input id="txtUrl" name="url" type="text" class="#this.commentInputClass#" maxlength="100" value="#HTMLEditFormat(request.url)#">
								</div>
							</div>

							<!--- Comment --->
							<div class="req #this.commentFieldWrapperClass#">
								<label for="txtComment" class="#this.commentFieldLabelClass#">#variables.$.rbKey('comments.comment')#<ins> (#variables.$.rbKey('comments.required')#)</ins></label>
								<div class="#this.commentInputWrapperClass#">
									<textarea rows="5" id="txtComment" class="#this.commentInputClass#" name="comments" data-message="#htmlEditFormat(variables.$.rbKey('comments.commentrequired'))#" data-required="true">#HTMLEditFormat(request.comments)#</textarea>
								</div>
							</div>

							<!--- Remember --->
							<div class="#this.commentFieldWrapperClass#">
								<div class="#this.commentPrefsInputWrapperClass#">
									<div class="#this.commentCheckboxClass#">
										<label for="txtRemember">
											<input type="checkbox" id="txtRemember" name="remember" value="1"<cfif isBoolean(cookie.remember) and cookie.remember> checked="checked"</cfif>> #variables.$.rbKey('comments.rememberinfo')#
										</label>
									</div>
								</div>
							</div>

							<!--- Subscribe --->
							<div class="#this.commentFieldWrapperClass#">
								<div class="#this.commentPrefsInputWrapperClass#">
									<div class="#this.commentCheckboxClass#">
										<label for="txtSubscribe">
											<input type="checkbox" id="txtSubscribe" name="subscribe" value="1"<cfif isBoolean(cookie.subscribe) and cookie.subscribe> checked="checked"</cfif>> #variables.$.rbKey('comments.subscribe')#
										</label>
									</div>
								</div>
							</div>

					</fieldset>

					<div class="#this.commentRequiredWrapperClass#">
						<p class="required">#variables.$.rbKey('comments.requiredfield')#</p>
					</div>

					<!--- Form Protect --->
					<div class="#this.commentFieldWrapperClass#">
						#variables.$.dspObject_Include(thefile='datacollection/dsp_form_protect.cfm')#
					</div>

					<!--- SUBMIT BUTTON --->
					<div class="#this.commentFieldWrapperClass#">
						<div class="#this.commentSubmitButtonWrapperClass#">
							<input type="hidden" name="returnURL" value="#esapiEncode('html_attr',variables.$.getCurrentURL())#">
							<input type="hidden" name="commentid" value="#createuuid()#">
							<input type="hidden" name="parentid" value="">
							<input type="hidden" name="commenteditmode" value="add">
							<input type="hidden" name="linkServID" value="#variables.$.content('contentID')#">
							<button type="submit" class="#this.commentSubmitButtonClass#">#htmlEditFormat(variables.$.rbKey('comments.submit'))#</button>
						</div>
					</div>
				</form>
			<cfelse>
				<p class="loginMessage">#variables.$.siteConfig('RBFactory').getResourceBundle().messageFormat(variables.$.rbKey('comments.pleaselogin'),'#variables.$.siteConfig('LoginURL')#&returnURL=#esapiEncode('url',getCurrentURL())#')#</p>
			</cfif>
		</div>
	</div>
</cfoutput>
</cfif>

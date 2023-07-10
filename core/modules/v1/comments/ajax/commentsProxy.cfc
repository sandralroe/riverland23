<!--- license goes here --->
<cfcomponent extends="mura.baseobject">

	<cffunction name="get" access="remote" returnformat="plain">
		<cfargument name="commentID">
		<cfargument name="siteid" default="#application.contentServer.bindToDomain()#" />
		<cfset var $ = getBean("MuraScope").init(arguments.siteid)>
		<cfset var comment = $.getBean("contentManager").getCommentBean()>
		<cfset var data = comment.setCommentID(arguments.commentID).load().getAllValues()>
		<cfset var jsonUtil=new mura.json()>
		<cfreturn jsonUtil.encode(data)>
	</cffunction>

	<cffunction name="flag" access="remote" returnformat="plain">
		<cfargument name="commentID">
		<cfargument name="siteid" default="#application.contentServer.bindToDomain()#" />
		<cfset var $ = getBean("MuraScope").init(arguments.siteid)>
		<cfset var comment = $.getBean("contentManager").getCommentBean()>
		<cfset comment.setCommentID(arguments.commentID).load().flag()>
	</cffunction>

	<cffunction name="getContentStats" access="remote" returnformat="plain">
		<cfargument name="contentID">
		<cfargument name="siteid" default="#application.contentServer.bindToDomain()#" />
		<cfset var $ = getBean("MuraScope").init(arguments.siteid)>
		<cfset var contentStats = $.getBean('content').loadBy(contentID=arguments.contentID).getStats()>
		<cfset var jsonUtil=new mura.json()>
		<cfreturn jsonUtil.encode(contentStats.getAllValues())>
	</cffunction>

	<cffunction name="renderCommentsPage" access="remote" returnformat="plain">
		<cfargument name="contentID">
		<cfargument name="pageNo" data-required="true" default="1">
		<cfargument name="nextN" data-required="true" default="3">
		<cfargument name="sortDirection" data-required="true" default="desc">
		<cfargument name="commentID" data-required="true" default="">
		<cfargument name="siteid" default="#application.contentServer.bindToDomain()#" />
		<cfset var $ = getBean("MuraScope").init(arguments.siteid)>
		<cfset var renderer = $.getContentRenderer()>
		<cfset var content = $.getBean('content').loadBy(contentID=arguments.contentID)>
		<cfset var crumbArray = content.getCrumbArray()>
		<cfset var isEditor=isDefined('session.mura.memberships') and (listFind(session.mura.memberships,'S2IsPrivate;#application.settingsManager.getSite($.event('siteID')).getPrivateUserPoolID()#')
				and application.permUtility.getnodePerm(crumbArray) neq 'none')
				or listFind(session.mura.memberships,'S2')
				or application.permUtility.getModulePerm("00000000000000000000000000000000015", $.event('siteID'))>
		<cfset var sort = listFindNoCase('asc,desc', arguments.sortDirection) ? arguments.sortDirection : 'asc'>
		<cfset var commentArgs={contentID=content.getContentID(),
						siteID=$.event('siteID'),
						isspam=0,
						isdeleted=0,
						sortDirection=sort}>
		<cfif not isEditor>
			<cfset commentArgs.isApproved=1>
		</cfif>
		<cfset var it = $.getBean('contentCommentManager').getCommentsIterator(argumentCollection=commentArgs)>
		<cfset var q = it.getQuery()>
		<cfset var comment = "">
		<cfset var local = structNew()>
		<cfset var i = "">
		<cfset var commenter = "">
		<cfset var remoteID = "">
		<cfset var user = "">
		<cfset var avatar = "">
		<cfset var returnStruct = structNew()>
		<cfset returnStruct.count = q.recordcount>

		<cfscript>
			// Pagination Setup
			local.nextn = Val(arguments.nextn);
			local.pageno = Val(arguments.pageno);
			local.commentPos = 0;
			local.continue = true;
			local.x = 1;

			// set defaults
			if ( local.nextn < 1 ) {
				local.nextn = 20;
			}
			it.setNextN(local.nextn);

			if ( local.pageno < 1 || local.pageno > it.pageCount() ) {
				local.pageno = 1;
			}
			it.setPage(local.pageno);

			local.startPage = local.pageNo;
			local.endPage = local.pageNo;

			if ( len(arguments.commentID) ) {
				for(local.x = 1; x <= q.recordcount && local.continue; local.x++){
					if (q['commentID'][local.x] == arguments.commentID) {
						local.commentPos = local.x;
						local.continue = false;
					}
				}

				local.endPage = Ceiling(local.commentPos / local.nextN);
			}
		</cfscript>

		<cfsavecontent variable="returnStruct.htmloutput">
			<cfoutput>
				<cfloop from="#local.startPage#" to="#local.endPage#" index="i">
					<cfset it.setPage(local.pageNo)>
					<cfloop condition="#it.hasNext()#">
						<cfset comment = it.next()>
						<cfset commenter = comment.getCommenter()>
						<!--- set avatar from Mura's user bean --->
						<cfset avatar = "">
						<cfif isValid("UUID", commenter.getRemoteID())>
							<cfset user = $.getBean('user').loadBy(userID=commenter.getRemoteID())>
							<cfif not user.getIsNew() and len(user.getPhotoFileID())>
								<cfset avatar = $.createHREFForImage(user.getSiteID(), user.getPhotoFileID(), 'jpg', 'medium')>
							</cfif>
						</cfif>
						<dl id="mura-comment-#comment.getCommentID()#" <cfif comment.getIsApproved() neq 1>class="#renderer.alertDangerClass#"</cfif>>
							<dt>
								<cfset local.commenterName=comment.getName()>

								<cfif not len(local.commenterName) and len(commenter.getName())>
									<cfset local.commenterName=commenter.getName()>
								</cfif>

								<cfset local.commenterURL=comment.getURL()>

								<cfif not len(local.commenterURL) and len(commenter.getURL())>
									<cfset local.commenterURL=commenter.getURL()>
								</cfif>

								<cfset local.commenterEmail=comment.getEmail()>

								<cfif  not len(local.commenterEmail) and len(commenter.getEmail())>
									<cfset local.commenterEmail=commenter.getEmail()>
								</cfif>

								<cfif len(local.commenterURL)>
									<a href="#local.commenterURL#" target="_blank">#htmleditformat(local.commenterName)#</a>
								<cfelse>
									#htmleditformat(local.commenterName)#
								</cfif>
								<cfif len(comment.getParentID())>
									<em>(#$.rbKey('comments.inreplyto')#: <a href="##" class="mura-in-reply-to" data-parentid="#comment.getParentID()#">#comment.getParent().getName()#</a>)</em>
								</cfif>
								<cfif isEditor>
								<div class="mura-comment-admin-button-wrapper #renderer.commentAdminButtonWrapperClass#">
									<cfif isEditor and len(local.commenterEmail)>
										<a class="mura-comment-user-email #renderer.commentUserEmailClass#" href="javascript:Mura.noSpam('#listFirst(htmlEditFormat(local.commenterEmail),'@')#','#listlast(HTMLEditFormat(local.commenterEmail),'@')#')" onfocus="this.blur();">#$.rbKey('comments.email')#</a>
									</cfif>
									<cfif isEditor>
										<cfif yesnoformat(application.configBean.getValue("editablecomments"))>
											 <a class="mura-comment-edit-comment #renderer.commentEditButtonClass#" data-id="#comment.getCommentID()#" data-siteid="#comment.getsiteID()#">#$.rbKey('comments.edit')#</a>
										</cfif>
										<cfif comment.getIsApproved() neq 1>
											 <a class="mura-comment-approve-button #renderer.commentApproveButtonClass#" href="./?approvedcommentid=#comment.getCommentID()#&amp;nocache=1&amp;linkServID=#content.getContentID()###mura-comment-#comment.getCommentID()#" onClick="return confirm('Approve Comment?');">#$.rbKey('comments.approve')#</a>
										</cfif>
										 <a class="mura-comment-delete-button #renderer.commentDeleteButtonClass#" href="./?deletecommentid=#comment.getCommentID()#&amp;nocache=1&amp;linkServID=#content.getContentID()###mura-comments-page" onClick="return confirm('Delete Comment?');">#$.rbKey('comments.delete')#</a>
										<!--- <a class="btn btn-default" href="./?spamcommentid=#comment.getCommentID()#&amp;nocache=1&amp;linkServID=#content.getContentID()#" onClick="return confirm('Mark Comment As Spam?');">Spam</a>	--->
									</cfif>
								</div>
								</cfif>
							</dt>
							<cfif len(avatar)>
								<dd class="mura-comment-thumb #renderer.commentThumbClass#"><img src="#avatar#"></dd>
							<cfelse>
								<cfset gravatarURL = $.getBean('utility').isHTTPS() ? 'https://secure.gravatar.com' : 'http://www.gravatar.com' />
								<dd class="mura-comment-thumb #renderer.commentThumbClass#"><img src="#gravatarURL#/avatar/#lcase(Hash(lcase(local.commenterEmail)))#" /></dd>
							</cfif>
							<dd class="mura-comment #renderer.commentClass#">
								#$.setParagraphs(htmleditformat(comment.getComments()))#
							</dd>
							<dd class="mura-comment-date-time #renderer.commentDateTimeClass#">
								#LSDateFormat(comment.getEntered(),"long")#, #LSTimeFormat(comment.getEntered(),"short")#
							</dd>
							<cfif $.getContentRenderer().allowPublicComments OR $.currentUser().isLoggedIn()>
								<dd class="mura-comment-reply #renderer.commentReplyClass#"><a data-id="#comment.getCommentID()#" data-siteid="#comment.getsiteID()#" href="##mura-comment-post-comment">#$.rbKey('comments.reply')#</a></dd>
								<dd class="mura-comment-spam #renderer.commentSpamClass#"><a data-id="#comment.getCommentID()#" data-siteid="#comment.getsiteID()#" class="mura-comment-flag-as-spam #renderer.commentSpamLinkClass#" href="##">Flag as Spam</a></dd>
							</cfif>
						</dl>
						<div id="mura-comment-post-comment-#comment.getCommentID()#" class="mura-comment-reply-wrapper #renderer.commentFormWrapperClass#" style="display: none;"></div>
					</cfloop>
					<cfset local.pageNo++>
				</cfloop>

				<!--- MOAR --->
				<cfif it.getPageIndex() lt it.pageCount()>
					<div class="mura-comment-more-comments-container #renderer.commentMoreCommentsContainer#"><a id="mura-more-comments" class="#renderer.commentMoreCommentsDownClass#" href="##" data-pageno="#it.getPageIndex()+1#" data-siteid="#HTMLEditFormat($.event('siteID'))#">#$.rbKey('comments.morecomments')#</a></div>
				</cfif>

			</cfoutput>
		</cfsavecontent>

		<cfreturn serializeJSON(returnStruct)>

	</cffunction>

</cfcomponent>

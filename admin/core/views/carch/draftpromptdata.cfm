 <!--- license goes here --->
<cfparam name="rc.targetversion" default="false">
<cfif not isBoolean(rc.targetversion)>
	<cfset rc.targetversion=false>
</cfif>
<cfif not len(rc.contentid) and isdefined('rc.homeid') and len(rc.homeid)>
	<cfset draftprompdata=application.contentManager.getDraftPromptData(rc.homeid,rc.siteid)>
<cfelse>
	<cfset draftprompdata=application.contentManager.getDraftPromptData(rc.contentid,rc.siteid)>
</cfif>

<cfset poweruser=$.currentUser().isSuperUser() or $.currentUser().isAdminUser()>
<cfif draftprompdata.showdialog >
	<cfset draftprompdata.showdialog='true'>
	<cfsavecontent variable="draftprompdata.message">
	<cfoutput>
	<div id="draft-prompt">
		<cfif $.siteConfig('hasLockableNodes') and draftprompdata.islocked>
			<cfset lockedBy=$.getBean('user').loadBy(userid=draftprompdata.lockid)>
			<div class="help-block">
				<p>#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"sitemanager.nodeLockedby"),"#esapiEncode('html_attr',lockedBy.getFName())# #esapiEncode('html',lockedBy.getLName())#")#.</p>
				<p><a tabindex="-1" href="mailto:#esapiEncode('html',lockedBy.getEmail())#?subject=#esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.nodeunlockrequest'))#"><i class="mi-envelope"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.requestnoderelease')#</a></p>
			</div>
		</cfif>

		<cfif not $.siteConfig('hasLockableNodes') or draftprompdata.lockavailable or poweruser or $.currentUser().getUserID() eq  draftprompdata.lockid>

			<cfif draftprompdata.hasmultiple and not rc.targetversion>
				<div class="help-block">#application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.dialog')#</div>
			</cfif>

			<cfif listFindNoCase("author,editor",draftprompdata.verdict)>

			<cfif $.siteConfig('hasLockableNodes') and (draftprompdata.lockavailable) and  draftprompdata.lockid neq session.mura.userid>
				<div class="help-block"><input id="locknodetoggle" type="checkbox"/> #application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.locknode')#</div>
			</cfif>

			<cfif rc.targetversion>
				<cfset publishedVersion=$.getBean('content').loadBy(contenthistid=rc.contenthistid)>
			<cfelse>
				<cfset publishedVersion=$.getBean('content').loadBy(contenthistid=draftprompdata.publishedHistoryID)>
			</cfif>
		
			<cfif publishedVersion.getApproved() or not draftprompdata.hasdraft or rc.targetversion>
				<table class="mura-table-grid">
					<thead>
						<tr>
							<th colspan="4">
								<cfif not rc.targetversion>
									<cfif publishedVersion.getApproved()>
										<i class="mi-check"></i> #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.published'))#
									<cfelse>
										<i class="mi-edit"></i> #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.latest'))#
									</cfif>
								<cfelse>
									<i class="mi-edit"></i> #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.editversion'))#
								</cfif>
							</th>
						</tr>
					</thead>
					<tbody>
						<td><a href="##" tabindex="-1" class="draft-prompt-option" data-contenthistid="#draftprompdata.publishedHistoryID#"><i class="mi-pencil"></i></a></td>
						<td class="var-width"><a href="##" tabindex="-1" class="draft-prompt-option var-width" data-contenthistid="#draftprompdata.publishedHistoryID#">#esapiEncode('html',publishedVersion.getMenuTitle())#</a></td>
						<td>#LSDateFormat(publishedVersion.getlastupdate(),session.dateKeyFormat)# #LSTimeFormat(publishedVersion.getLastUpdate(),"medium")#</td>
						<td>#esapiEncode('html',publishedVersion.getLastUpdateBy())#</td>
					</tbody>
				</table>
			</cfif>

			<cfif draftprompdata.hasdraft and not rc.targetversion>

				<cfset draftVersion=$.getBean('content').loadBy(contenthistid=draftprompdata.historyid)>
				<table class="mura-table-grid">
					<thead>
						<tr>
							<th colspan="4"><i class="mi-edit"></i> #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.latest'))#</th>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><a href="##" tabindex="-1" class="draft-prompt-option" data-contenthistid="#draftprompdata.historyid#"><i class="mi-pencil"></i></a></td>
							<td class="var-width"><a href="##" tabindex="-1" class="draft-prompt-option" data-contenthistid="#draftprompdata.historyid#">#esapiEncode('html',draftVersion.getMenuTitle())#</a></td>
							<td>#LSDateFormat(draftVersion.getlastupdate(),session.dateKeyFormat)# #LSTimeFormat(draftVersion.getLastUpdate(),"medium")#</td>
							<td>#esapiEncode('html',draftVersion.getLastUpdateBy())#</td>
						</tr>
					</tbody>
				</table>
			</cfif>

			<cfif draftprompdata.pendingchangesets.recordcount and not rc.targetversion>
				<table class="mura-table-grid">
					<thead>
						<tr>
							<th colspan="4"><i class="mi-clone"></i> #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.changesets'))#</th>
						</tr>
					</thead>
					<tbody>
						<cfloop query="draftprompdata.pendingchangesets">
						<tr>
							<td><a href="##" tabindex="-1" class="draft-prompt-option" data-contenthistid="#draftprompdata.pendingchangesets.contenthistid#"><i class="mi-pencil"></i></a></td>
							<td class="var-width"><a href="##" tabindex="-1" class="draft-prompt-option" data-contenthistid="#draftprompdata.pendingchangesets.contenthistid#">#esapiEncode('html',draftprompdata.pendingchangesets.changesetName)#</a></td>
							<td>#LSDateFormat(draftprompdata.pendingchangesets.lastupdate,session.dateKeyFormat)# #LSTimeFormat(draftprompdata.pendingchangesets.lastupdate,"medium")#</td>
							<td>#esapiEncode('html',draftprompdata.pendingchangesets.lastupdateby)#</td>
						</tr>
						</cfloop>
					</tbody>
				</table>
			</cfif>
			</cfif>
			<cfif draftprompdata.yourapprovals.recordcount and not rc.targetversion>
				<cfset content=$.getBean('content').loadBy(contentid=rc.contentid)>
				<table class="mura-table-grid">
					<thead>
						<tr>
							<th colspan="4"><i class="mi-clock-o"></i> #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.draftprompt.awaitingapproval'))#</th>
						</tr>
					</thead>
					<tbody>
						<cfloop query="draftprompdata.yourapprovals">
							<tr>
								<cfif listFindNoCase("author,editor",draftprompdata.verdict)>
									<td><a href="##" data-contenthistid="#draftprompdata.yourapprovals.contenthistid#" tabindex="-1" class="draft-prompt-option"><i class="mi-pencil"></i></a></td>
									<td class="var-width"><a href="##" data-contenthistid="#draftprompdata.yourapprovals.contenthistid#"  tabindex="-1" class="draft-prompt-option">#esapiEncode('html',draftprompdata.yourapprovals.menutitle)#</a></td>
									<td>#LSDateFormat(draftprompdata.yourapprovals.lastupdate,session.dateKeyFormat)# #LSTimeFormat(draftprompdata.yourapprovals.lastupdate,"medium")#</td>
									<td>#esapiEncode('html',draftprompdata.yourapprovals.lastupdateby)#</td>
								<cfelse>
									<td><a href="#content.getURL(complete=true,querystring="previewid=#draftprompdata.yourapprovals.contenthistid#",useEditRoute=true)#" tabindex="-1" class="draft-prompt-approval"><i class="mi-pencil"></i></a></td>
									<td class="var-width"><a href="#content.getURL(complete=true,querystring="previewid=#draftprompdata.yourapprovals.contenthistid#",useEditRoute=true)#" tabindex="-1" class="draft-prompt-approval">#esapiEncode('html',draftprompdata.yourapprovals.menutitle)#</a></td>
									<td>#LSDateFormat(draftprompdata.yourapprovals.lastupdate,session.dateKeyFormat)# #LSTimeFormat(draftprompdata.yourapprovals.lastupdate,"medium")#</td>
									<td>#esapiEncode('html',draftprompdata.yourapprovals.lastupdateby)#</td>

								</cfif>
							</tr>
						</cfloop>
					</tbody>
				</table>
			</cfif>

		</cfif>

		</div>
	</cfoutput>
	</cfsavecontent>
<cfelse>
	<cfset draftprompdata.showdialog='false'>
	<cfset draftprompdata.message="">
</cfif>
<cfset structDelete(draftprompdata,'yourapprovals')>
<cfset structDelete(draftprompdata,'pendingchangesets')>
<cfcontent type="application/json; charset=utf-8" reset="true">
<cfoutput>#createObject("component","mura.json").encode(draftprompdata)#</cfoutput>
<cfabort>

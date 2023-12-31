 <!--- license goes here --->
<cfsilent>
	<cfset content=$.getBean('content').loadBy(contenthistid=rc.contenthistid)>
	<cfset $.event('contentBean',content)>
	<cfset requiresApproval=content.requiresApproval()>
	<cfset showApprovalStatus=content.requiresApproval(applyExemptions=false)>
	<cfset user=content.getUser()>
	<cfset islocked=false>
	<cfif requiresApproval or showApprovalStatus>
		<cfset approvalRequest=content.getApprovalRequest()>
		<cfset group=approvalRequest.getGroup()>
		<cfset actions=approvalRequest.getActionsIterator()>
		<cfif user.getIsNew()>
			<cfset user=approvalRequest.getUser()>
		</cfif>
	</cfif>
	<cfparam name="rc.mode" default="">
</cfsilent>
<cfoutput>
<cfif rc.mode eq 'frontend'>
	<div class="mura-header">
		<h1>#application.rbFactory.getKeyValue(session.rb,'layout.status')#</h1>
	</div>
	<cfif $.siteConfig('hasLockableNodes')>
		<cfset stats=content.getStats()>
		<cfif stats.getLockType() eq 'node'>
		<cfset islocked=true>
		<cfset lockedBy=$.getBean('user').loadBy(userid=stats.getLockID())>
		<div class="alert alert-error">
			<span>
			#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"sitemanager.nodeLockedby"),"#esapiEncode('html_attr',lockedBy.getFName())# #esapiEncode('html',lockedBy.getLName())#")#.
			<br><a tabindex="-1" href="mailto:#esapiEncode('html',lockedBy.getEmail())#?subject=#esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.nodeunlockrequest'))#"><i class="mi-envelope"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.requestnoderelease')#</a>
			</span>
		</div>
		</cfif>
	</cfif>
<div>
</cfif>
<div id="status-modal" class="mura-list-grid">
	<dl>
		<dt>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.createdby')#</dt> 
		<dd>
			<i class="mi-user"></i>
			<p><cfif not user.getIsNew()>#esapiEncode('html',user.getFullName())# <cfelse> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.na")# </cfif></p>
		</dd>
	</dl>
	
	<dl class="created-on">
		<dt>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.createdon')#</dt>
		<dd>
			<i class="mi-calendar"></i>
			<p>#LSDateFormat(parseDateTime(content.getLastUpdate()),session.dateKeyFormat)#<br />
			#LSTimeFormat(parseDateTime(content.getLastUpdate()),"short")#</p>
		</dd>
	</dl>
	
	<dl>
		<dt>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.status')#</dt>
		<dd<cfif islocked> class="status-locked"</cfif>>	
			<cfif content.getactive() gt 0 and content.getapproved() gt 0>
				<i class="mi-check-circle"></i>
				<p>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.published")#</p>
			<cfelseif len(content.getApprovalStatus()) and (requiresApproval or showApprovalStatus)>
				<i class="mi-clock-o"></i>
				<p>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.#content.getApprovalStatus()#")#</p>
			<cfelseif content.getapproved() lt 1>
				<cfif len(content.getChangesetID())>
					<i class="mi-check-circle"></i>
					<p>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.queued")#</p
				<cfelse>
					<i class="mi-edit"></i>
					<p>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.draft")#</p>
				</cfif>
			<cfelse>
				<i class="mi-history"></i>
				<p>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.archived")#</p>
			</cfif>
		</dd>
	</dl>
		
	
		<cfif $.siteConfig('hasChangesets')>
		<cfset changeset=$.getBean('changeset').loadBy(changesetID=content.getChangesetID())>
		<dl class="change-set">
			<dt>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.changeset')#</dt>
			<dd>
				<i class="mi-list-alt"></i>
				<p><cfif changeset.getIsNew()>Unassigned<cfelse>#esapiEncode('html',changeset.getName())#</cfif></p>
			</dd>
		</dl>
		</cfif>
					
	
		<cfif requiresApproval or showApprovalStatus>
			<cfif not content.getApproved() and approvalRequest.getStatus() eq 'Pending'>
			<dl class="approval-status">
				<dt>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.approvalstatus')#</dt>
				<dd>
					<i class="mi-clock-o"></i>
					 <cfif group.getType() eq 1>
						<em>#application.rbFactory.getKeyValue(session.rb,"approvalchains.waitingforgroup")#:</em>
						<p>#esapiEncode('html',group.getGroupName())#</p>
					<cfelse>
						<em>#application.rbFactory.getKeyValue(session.rb,"approvalchains.waitingforuser")#:</em>
						<p>#esapiEncode('html',group.getFullName())#</p>
					</cfif>
				</dd>
			</dl>
			</cfif>	
		
			<cfif actions.hasNext()>
			<dl class="approval-chain-comments">
				<dt>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.actions')#</dt>
				<cfloop condition="actions.hasNext()">
				<cfset action=actions.next()>
			
				<dd>
					<strong class="<cfif action.getActionType() eq 'rejection'>rejected<cfelseif action.getActionType() eq 'cancelation'>canceled<cfelse>approved</cfif>">
					<cfif action.getActionType() eq 'rejection'><i class="mi-warning"></i> #application.rbFactory.getKeyValue(session.rb,"approvalchains.rejected")#<cfelseif action.getActionType() eq 'cancelation'><i class="mi-ban"></i> #application.rbFactory.getKeyValue(session.rb,"approvalchains.canceled")#<cfelse><i class="mi-check-circle"></i> #application.rbFactory.getKeyValue(session.rb,"approvalchains.approved")#</cfif></strong> 
					<cfif len(action.getComments())><p><!--- <i class="mi-comment"></i>  --->#esapiEncode('html',action.getComments())#</p></cfif>
					<em>#application.rbFactory.getKeyValue(session.rb,"approvalchains.by")# #esapiEncode('html',action.getUser().getFullName())# #application.rbFactory.getKeyValue(session.rb,"approvalchains.on")# #LSDateFormat(parseDateTime(action.getCreated()),session.dateKeyFormat)# #application.rbFactory.getKeyValue(session.rb,"approvalchains.at")# #LSTimeFormat(parseDateTime(action.getCreated()),"short")#</em>		
				</dd>
			
			</cfloop>
			</dl>
			</cfif>
		
			<cfset isApprover=(listfindNoCase(session.mura.membershipids,approvalRequest.getGroupID()) or $.currentUser().isAdminUser() or $.currentUser().isSuperUser())>
			<cfset isRequester=approvalRequest.getUserID() eq session.mura.userid>

			<cfif not content.getApproved() and approvalRequest.getStatus() eq 'Pending' and (isApprover or isRequester)>
				<dl class="approval-action-form">
				<dt>#application.rbFactory.getKeyValue(session.rb,"approvalchains.action")#</dt>
				<dd>
					<div class="mura-control-group">
						<cfif isApprover>
						<label class="radio inline">
							<input class="approval-action" id="approval-approve" name="approval-action"type="radio" value="Approve" checked/> #application.rbFactory.getKeyValue(session.rb,"approvalchains.approve")# 
						</label>
						<label class="radio inline">
							<input class="approval-action" id="approval-reject" name="approval-action" type="radio" value="Reject" checked/> #application.rbFactory.getKeyValue(session.rb,"approvalchains.reject")#
						</label>
						</cfif>
						<cfif isRequester>
						<label class="radio inline">
							<input class="approval-action" id="approval-cancel" name="approval-action"type="radio" value="Cancel" checked/> #application.rbFactory.getKeyValue(session.rb,"approvalchains.cancel")# 
						</label>
						</cfif>
					</div>					
				<p>#application.rbFactory.getKeyValue(session.rb,"approvalchains.comments")#</p>
				<textarea id="approval-comments" rows="4"></textarea>
					<div class="form-actions">					
					<input id="mura-approval-apply" type="button" class="btn mura-primary" value="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.apply'))#" onclick="applyApprovalAction('#approvalRequest.getRequestID()#',$('input:radio[name=approval-action]:checked').val(),$('##approval-comments').val(),'#esapiEncode('javascript',approvalRequest.getSiteID())#');"/>
					</div>
				</dd>
				</dl>
			</cfif>
		</cfif>
</div>

<cfif rc.mode eq 'frontend'>
</div>
	<cfif not content.getApproved() and (requiresApproval or showApprovalStatus)>
		<script>
		function applyApprovalAction(requestid,action,comment,siteid){
			
			if(action == 'Reject' && comment == ''){
				alertDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"approvalchains.rejectioncommentrequired"))#');
			} else {
				$('##mura-approval-apply').attr('disabled','disabled').css('opacity', '.30');
		
				var pars={
							muraAction:'carch.approvalaction',
							siteid: siteid,
							requestid: requestid,
							comment: comment,
							action:action
						};

				actionModal(
					function(){
						$.post('#$.siteConfig().getResourcePath(complete=1)##application.configBean.getIndexPath()#/_api/json/v1/generatecsrftokens/?context=approvalaction&siteid=' + pars.siteid).then(
							function(data){
								pars['csrf_token']=data['csrf_token'];
								pars['csrf_token_expires']=data['csrf_token_expires'];

								$.post('./index.cfm',
									pars,
									function(data) {
										//$('html').html(data);
										//alert(data.previewurl)
										top.location.replace(data.previewurl);
									}
								);
							}
						);
					}
				);
			}
		}

		$(document).ready(function(){
			if (top.location != self.location) {
				if(jQuery("##ProxyIFrame").length){
					jQuery("##ProxyIFrame").load(
						function(){
							frontEndProxy.post({cmd:'setWidth',width:'configurator'});
						}
					);	
				} else {
					frontEndProxy.post({cmd:'setWidth',width:'configurator'});
				}
			}
		});
		</script>
	</cfif>
<cfelse>
	<cfset request.layout=false>
</cfif>
</cfoutput>

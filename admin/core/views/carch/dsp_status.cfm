 <!--- license goes here --->
<cfoutput>
<cfif $.siteConfig('hasLockableNodes')>
	<cfset nodeLockedByYou= stats.getLockType() eq 'node' and stats.getLockID() eq session.mura.userID>
	<cfset nodeLockedBySomeElse=len(stats.getLockID()) and stats.getLockType() eq 'node' and  stats.getLockID() neq session.mura.userID>

	<cfif nodeLockedByYou or nodeLockedBySomeElse>

		<cfif not nodeLockedBySomeElse>
			<p id="msg-node-locked" class="alert alert-error"<cfif not nodeLockedByYou> style="display:none;"</cfif>>
				<span>
#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.youvelockednode')# <a class="mura-node-unlock" href="##"<cfif not nodeLockedByYou> style="display:none;"</cfif>><i class="mi-unlock"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.unlocknode')#</a>
				</span>
			</p>
		<cfelse>
			<!--- Locked by someone else --->
			<cfset lockedBy=$.getBean("user").loadBy(stats.getLockID())>
			<p id="msg-node-locked-else" class="alert alert-error">
				<span>
					#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"sitemanager.nodeLockedby"),"#esapiEncode('html_attr',lockedBy.getFName())# #esapiEncode('html',lockedBy.getLName())#")#.<br>
				<a href="mailto:#esapiEncode('html',lockedBy.getEmail())#?subject=#esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.nodeunlockrequest'))#"><i class="mi-envelope"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.requestnoderelease')#</a>
					<cfif $.currentUser().isSuperUser() or $.currentUser().isAdminUser()> &nbsp; &nbsp;<a class="mura-node-unlock" href="##"><i class="mi-unlock"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.unlocknode')#</a>
					</cfif>
				</span>
			</p>

		</cfif>
		<script>
			$(function(){
				jQuery(".mura-node-unlock").click(
					function(event){
						event.preventDefault();
						confirmDialog(
							"#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.unlocknodeconfirm'))#",
							function(){
								jQuery("##msg-node-locked").fadeOut();
								jQuery(".mura-node-unlock").hide();
								if(lockedbysomeonelse){
									jQuery("##msg-node-locked-else").fadeOut();
									lockedbysomeonelse=false;
									siteManager.doConditionalExit=true;
								}
								siteManager.hasNodeLock=false;
								$('.form-actions').fadeIn();
								<cfset csrf=rc.$.generateCSRFTokens(context=rc.contentBean.getContentID() & 'unlocknode')>
								jQuery.post("./",{
									muraAction:"carch.unlockNode",
									contentid:"#rc.contentBean.getContentID()#",
									siteid:"#rc.contentBean.getSiteID()#",
									csrf_token:'#csrf.token#',
									csrf_token_expires: '#csrf.expires#'
								})
							}
						);
					}
				);

				<cfif nodeLockedBySomeElse>
				$('.form-actions').hide();
				lockedbysomeonelse=true;
				siteManager.doConditionalExit=false;
				</cfif>
			});
			</script>
	</cfif>
</cfif>
<cfif isdefined('showApprovalStatus')>

<div style="display:none;" title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"layout.status"))#" id="approvalModalContainer"></div>

<cfif showApprovalStatus and listFindNoCase('Pending,Rejected',rc.contentBean.getApprovalStatus())  >
	<div class="alert alert-error">
		<span>
		<cfif rc.contentBean.getApprovalStatus() eq 'Rejected'>
			#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.rejectedmessage")#:
		<cfelseif rc.contentBean.getApprovalStatus() eq 'Cancelled'>
			#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.canceledmessage")#:
		<cfelse>
			#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.pendingmessage")#:
		</cfif>
		<strong><a href="##" onclick="return viewStatusInfo('#esapiEncode('javascript',rc.contentBean.getContentHistID())#','#esapiEncode('javascript',rc.contentBean.getSiteID())#');">#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.viewdetails")#</a></strong>
		</span>
	</div>
</cfif>

<cfif rc.parentBean.getType() eq 'Calendar'>
	<cfset conflicts=rc.contentBean.getDisplayConflicts()>

	<cfif rc.contentBean.getDisplay() eq 2>
		<div class="alert alert-info" >
			<span>
				<strong>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.display')#:</strong> #rc.contentBean.getDisplayIntervalDesc(showTitle=false)#
			</span>
		</div>
	</cfif>

	<cfif conflicts.hasNext()>
		<cfset calendar=rc.contentBean.getParent()>
		<div class="alert alert-error">
			<span>
			<h3>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.displayinterval.schedulingconflicts")#:</h3>
				<cfloop condition="conflicts.hasNext()">
					<cfset conflict=conflicts.next()>
					<p><strong><a href="#conflict.getEditURL()#">#esapiEncode('html',conflict.getTitle())#:</strong></a>
						<cfset conflictDetails=conflict.getConfictDetailIterator()>
						<cfloop condition="conflictDetails.hasNext()">
							<cfset conflictdetail=conflictDetails.next()>
							<a href="#rc.$.createHREF(filename='#calendar.getFilename()#/_/date/#year(conflictdetail.getDisplayStart())#/#month(conflictdetail.getDisplayStart())#/#day(conflictdetail.getDisplayStart())#',complete=true)#" <cfif rc.compactdisplay eq 'true'>target="_top"<cfelse>target="_blank"</cfif>>#LSDateFormat(conflictdetail.getDisplayStart(),session.dateKeyFormat)#</a>
							<cfif conflictDetails.hasNext()>, </cfif>
						</cfloop>
					</p>
				</cfloop>
			</span>
		</div>
	</cfif>
</cfif>
<script>
function viewStatusInfo(contenthistid,siteid){

	var url = 'index.cfm';
	var pars = 'muraAction=cArch.statusmodal&compactDisplay=true&siteid=' + siteid  + '&contenthistid=' + contenthistid +'&cacheid=' + Math.random();
	var d = jQuery('##approvalModalContainer');
	d.html('<div class="load-inline"></div>');
	//$('##approvalModalContainer .load-inline').spin(spinnerArgs2);
	$.get(url + "?" + pars,
		function(data) {
			if(data.indexOf('mura-primary-login-token') != -1) {
				location.href = './';
			}
			$('##approvalModalContainer .load-inline').spin(false);
			jQuery('##approvalModalContainer').html(data);
			stripe('stripe');
		});

		$("##approvalModalContainer").dialog({
			resizable: false,
			modal: true,
			width: 600,
			position: { my: "center", at: "top+180", of: window, collision: "fit" }
		});


	return false;
}

function applyApprovalAction(requestid,action,comment,siteid){

	if(action == 'Reject' && comment == ''){
		//This was downgraded to alert from alertDialog because of stacked modal z-index issue
		alert('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"approvalchains.rejectioncommentrequired"))#');
	} else {
		$('##mura-approval-apply').attr('disabled','disabled').css('opacity', '.30');

		<cfset csrf=rc.$.generateCSRFTokens(context='approvalaction')>
		var pars={
					muraAction:'carch.approvalaction',
					siteid: siteid,
					requestid: requestid,
					comment: comment,
					action:action,
					csrf_token:'#csrf.token#',
					csrf_token_expires: '#csrf.expires#'
				};

		actionModal(
			function(){
				$.post('index.cfm',
					pars,
					function(data) {
						if(typeof(data) == 'string'){
							$('html').html(data);
						} else {
							var href = window.location.href.replace('#rc.contentBean.getContentHistID()#',data.contenthistid);
							//alert(href)
							window.location = href;
						}
					}
				).fail(function(data){
					$('html').html(data);
				});
			}
		);
	}
}
</script>
</cfif>
</cfoutput>

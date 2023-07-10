<!--- License goes here --->
<cfoutput>
<cfinclude template="inc/dsp_users_header.cfm" />
<cfset isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('00000000000000000000000000000000008',rc.siteid))>
<div class="block block-constrain">

	<!--- Tab Nav (only tabbed for Admin + Super Users) --->
		<cfif ListFind(rc.$.currentUser().getMemberships(), 'Admin;#rc.$.siteConfig('privateUserPoolID')#;0') OR ListFind(rc.$.currentUser().getMemberships(), 'S2')>

				<ul id="viewTabs" class="mura-tab-links nav-tabs">

					<!--- Member/Public Groups --->
						<li<cfif rc.ispublic eq 1> class="active"</cfif>>
							<a href="#buildURL(action='cusers.list', querystring='ispublic=1')#" onclick="actionModal();">
								#rbKey('user.membergroups')#  <span id="membergroups-count"></span>
								
							</a>
						</li>

					<!--- System/Private Groups --->
						<li<cfif rc.ispublic eq 0> class="active"</cfif>>
							<a href="#buildURL(action='cusers.list', querystring='ispublic=0')#" onclick="actionModal();">
								#rbKey('user.adminusergroups')# <span id="adminusergroups-count"></span>
							</a>
						</li>

				</ul>

		<cfelse>
			<h3>#rbKey('user.membergroups')#</h3>
		</cfif>
	<!--- /Tab Nav --->

	<div class="block-content tab-content">

		<!-- start tab -->
		<div class="tab-pane active">

			<div class="block block-bordered">
				<!-- block header -->
				<div class="block-header">
					<h3 class="block-title">
						<cfif ListFind(rc.$.currentUser().getMemberships(), 'Admin;#rc.$.siteConfig('privateUserPoolID')#;0') OR ListFind(rc.$.currentUser().getMemberships(), 'S2')>
							#rbKey('user.groups')#
						<cfelse>
							#rbKey('user.membergroups')#
						</cfif>
					</h3>
				</div> <!-- /.block header -->
				<div class="block-content">

	<!--- Group Listing --->
		<cfif rc.it.hasNext()>
			<table id="temp" class="table table-striped table-condensed table-bordered mura-table-grid">

				<thead>
					<tr>
						<th class="actions"></th>
						<th class="var-width">
							#rbKey('user.grouptotalmembers')# 
						</th>
						<th>
							#rbKey('user.groupemail')#
						</th>
						<th>
							#rbKey('user.datelastupdate')#
						</th>
						<th>
							#rbKey('user.timelastupdate')#
						</th>
						<th>
							#rbKey('user.lastupdatedby')#
						</th>
					</tr>
				</thead>

				<tbody>
					<cfloop condition="rc.it.hasNext()">
						<cfsilent>
							<cfscript>
								local.item = rc.it.next();
								local.membercount = Len(local.item.getValue('counter'))
									? local.item.getValue('counter')
									: 0;
							</cfscript>
						</cfsilent>
						<tr>
							<!--- Actions --->
								<td class="actions">
									<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
									<div class="actions-menu hide">
										<ul class="actions-list">

											<!--- Edit --->
												<li class="edit">
													<a href="#buildURL(action='cusers.editgroup', querystring='userid=#local.item.getValue('userid')#&siteid=#esapiEncode('url',rc.siteid)#')#" rel="tooltip" onclick="actionModal(); window.location=this.href;">
														<i class="mi-pencil"></i>#rbKey('user.edit')#
													</a>
												</li>

											<!--- View Members --->
												<li class="members">
													<a href="#buildURL(action='cusers.editgroupmembers', querystring='userid=#local.item.getValue('userid')#&siteid=#esapiEncode('url',rc.siteid)#')#" rel="tooltip" onclick="actionModal(); window.location=this.href;">
														<i class="mi-users"></i>#rbKey('user.members')#
													</a>
												</li>

											<!--- Delete --->
												<cfif local.item.getValue('perm') eq 0 and isEditor>

													<cfset msgDelete = rc.$.getBean('resourceBundle').messageFormat(
															rbKey('user.deleteusergroupconfim')
															, [local.item.getValue('groupname')]
													) />

													<li class="delete">
														<a href="#buildURL(action='cusers.update', querystring='action=delete&isPublic=#local.item.getValue('isPublic')#&userid=#local.item.getValue('userid')#&siteid=#esapiEncode('url',rc.siteid)#&type=1#rc.$.renderCSRFTokens(context=local.item.getValue('userid'),format='url')#')#" onclick="return confirmDialog('#esapiEncode('javascript', msgDelete)#',this.href)" rel="tooltip">
															<i class="mi-trash"></i>#rbKey('user.delete')#
														</a>
													</li>
<!--- 												<cfelse>
													<li class="disabled">
																	<i class="mi-trash"></i>
													</li> --->
												</cfif>

										</ul>
									</div>
								</td>
							<!--- /Actions --->

							<!--- Group Name --->
								<td class="var-width">
									<a href="#buildURL(action='cusers.editgroup', querystring='userid=#local.item.getValue('userid')#&siteid=#esapiEncode('url',rc.siteid)#')#" onclick="actionModal();">
										#esapiEncode('html',local.item.getValue('groupname'))#</a>
									(#Val(local.membercount)#)
								</td>

							<!--- Group Email --->
								<td>
									<cfif Len(local.item.getValue('email'))>
										<a href="mailto:#URLEncodedFormat(local.item.getValue('email'))#">
											#esapiEncode('html',local.item.getValue('email'))#
										</a>
									<cfelse>
										&nbsp;
									</cfif>
								</td>

							<!--- Date Last Update --->
								<td>
									#LSDateFormat(local.item.getValue('lastupdate'), session.dateKeyFormat)#
								</td>

							<!--- Time Last Update --->
								<td>
									#LSTimeFormat(local.item.getValue('lastupdate'), 'short')#
								</td>

							<!--- Last Update By --->
								<td>
									#esapiEncode('html',local.item.getValue('lastupdateby'))#
								</td>


						</tr>
					</cfloop>
				</tbody>

			</table>
			
			<cfinclude template="inc/dsp_nextn.cfm" />
			
		<cfelse>
			<!--- No groups message --->
			<div class="help-block-empty">#rbKey('user.nogroups')#</div>

		</cfif>

					</div> <!-- /.block-content -->
				</div> <!-- /.block-bordered -->
			</div> <!-- /.tab-pane -->

	</div> <!-- /.block-content.tab-content -->
</div> <!-- /.block-constrain -->


<script>
	var searchInput=document.getElementById('search');
	var search =(searchInput)? searchInput.value : '';
	var systemUsers = 0;
	var siteMembers = 0;
	$.get('..#application.configBean.getAdminDir()#/?muraAction=cUsers.remoteList&ispublic=0&search='+search+'&siteid=#esapiEncode("javascript", session.siteid)#', function(data) {
		systemUsers = parseInt(data.trim());
		$.get('..#application.configBean.getAdminDir()#/?muraAction=cUsers.remoteList&ispublic=1&search='+search+'&siteid=#esapiEncode("javascript", session.siteid)#', function(data) {
			siteMembers = parseInt(data.trim());
			processTabs(systemUsers,siteMembers);
		});
	});
	function processTabs(systemUsers,siteMembers) {
		$('##adminusergroups-count').text('(' + systemUsers + ')');
		$('##membergroups-count').text('(' + siteMembers + ')');
	}
</script> 

</cfoutput>

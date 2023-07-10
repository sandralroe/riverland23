<!--- License goes here --->
<cfoutput>
	<cfscript>
		isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('00000000000000000000000000000000008',rc.siteid));
		if (!isDefined("rc.isGroupSearch"))
			rc.isGroupSearch = 0; 
	</cfscript>
	<cfif IsDefined('rc.it')>

		<cfif rc.it.hasNext()>

			<table id="tbl-users" class="table table-striped table-condensed table-bordered mura-table-grid">

				<thead>
					<tr>
						<th class="actions"></th>
						<cfif not rc.isGroupSearch>
							<th class="actions"></th>
						</cfif>
						<th class="var-width">
							<cfif rc.isGroupSearch>
								#rbkey('user.group')#
							<cfelse>
								#rbKey('user.user')#
							</cfif>
						</th>
						<th>
							#rbKey('user.email')#
						</th>
						<th class="hidden-xs">
							#rbKey('user.datelastupdate')#
						</th>
						<th class="hidden-xs hidden-sm">
							#rbKey('user.timelastupdate')#
						</th>
						<th class="hidden-xs">
							#rbKey('user.lastupdatedby')#
						</th>
					</tr>
				</thead>

				<tbody>		

					<!--- Users Iterator --->
						<cfloop condition="rc.it.hasNext()">
							<cfscript>
								local.item = rc.it.next();
								local.canEdit = rc.$.currentUser().isInGroup('Admin') || rc.$.currentUser().isSuperUser() || local.item.getValue('isPublic') == 1;
							</cfscript>
							<tr>

								<!--- Actions --->
									<td class="actions">
										<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
										<div class="actions-menu hide">
											<ul class="actions-list">

												<!--- Edit --->
													<cfif local.canEdit>
														<li>
															<a href="#buildURL(action='cusers.#rc.isGroupSearch ? 'editgroup' : 'edituser'#', querystring='userid=#local.item.getValue('userid')#&siteid=#esapiEncode('url',rc.siteid)#')#" rel="tooltip" onclick="actionModal(); window.location=this.href;">
																<i class="mi-pencil"></i>#rbKey('user.edit')#
															</a>
														</li>
														<!--- <cfelse>
														<li class="disabled">
															<i class="mi-pencil"></i>
														</li> --->
													</cfif>

												<!--- Remove From Group --->
													<cfif ListLast(rc.muraAction, '.') eq 'editgroupmembers'>
														<li class="remove">
															<a href="#buildURL(action='cusers.removefromgroup', querystring='userid=#local.item.getValue('userid')#&routeid=#rc.userid#&groupid=#rc.userid#&siteid=#esapiEncode('url',rc.siteid)#')#" onclick="return confirmDialog('#jsStringFormat(rbKey('user.removeconfirm'))#',this.href)" rel="tooltip">
																<i class="mi-minus-circle"></i>#rbKey('user.removeconfirm')#
															</a>
														</li>
													</cfif>

												<!--- Delete --->
													<cfif local.canEdit and isEditor>
														<li class="delete">
															<a <cfif not rc.isGroupSearch and local.item.getValue('userid') eq rc.$.currentUser().get('userid')>class="disabled"</cfif> href="#buildURL(action='cusers.update', querystring='action=delete&ispublic=#local.item.getValue('ispublic')#&userid=#local.item.getValue('userid')#&siteid=#esapiEncode('url',rc.siteid)#&type=1#rc.$.renderCSRFTokens(context=local.item.getValue('userid'),format='url')#')#" onclick="return confirmDialog('#jsStringFormat(application.rbFactory.getKeyValue(session.rb, rc.isGroupSearch ? 'user.deletegroupconfirm' : 'user.deleteuserconfirm'))#',this.href)" rel="tooltip">
																<i class="mi-trash"></i>#rbKey('user.delete')#
															</a>
														</li>
														<!--- <cfelse>
														<li class="disabled">
															<i class="mi-trash"></i>
														</li> --->
													</cfif>

										</ul>
										</div>
									</td>
								<!--- /Actions --->

								<!--- Icons --->
								<cfif not rc.isGroupSearch>
									<td class="actions">
										<ul>
											<cfif IsDefined('rc.listUnassignedUsers') and ListFindNoCase(rc.listUnassignedUsers, local.item.getValue('userid'))>
												<li>
													<a rel="tooltip" title="Unassigned">
														<i class="mi-exclamation"></i>
													</a>
												</li>
											</cfif>
											<cfif local.item.getValue('s2') EQ 1>
												<li>
													<a rel="tooltip" title="#rbKey('user.superuser')#">
														<i class="mi-star"></i>
													</a>
												</li>
											<cfelseif local.item.getValue('isPublic') EQ 0>
												<li>
													<a rel="tooltip" title="#rbKey('user.adminuser')#">
														<i class="mi-user"></i>
													</a>
												</li>
											<cfelse>
												<li>
													<a rel="tooltip" title="#rbKey('user.sitemember')#">
														<i class="mi-user"></i>
													</a>
												</li>
											</cfif>
										</ul>
									</td>
								</cfif>
								<!--- /Icons --->

								<!--- Last Name, First Name, Group Name --->
									<cfif rc.isGroupSearch>
										<td class="var-width">
											<cfif local.canEdit>
												<a href="#buildURL(action='cusers.editgroup', querystring='userid=#local.item.getValue('userid')#&siteid=#esapiEncode('url',rc.siteid)#')#" onclick="actionModal();">
													#esapiEncode('html', local.item.getValue('groupname'))#
												</a>
											<cfelse>
												#esapiEncode('html', local.item.getValue('groupname'))#
											</cfif>
										</td>
									<cfelse>
										<td class="var-width">
											<cfif local.canEdit>
												<a href="#buildURL(action='cusers.edituser', querystring='userid=#local.item.getValue('userid')#&siteid=#esapiEncode('url',rc.siteid)#')#" onclick="actionModal();">
													#esapiEncode('html', local.item.getValue('lname'))#, #esapiEncode('html', local.item.getValue('fname'))#
												</a>
											<cfelse>
												#esapiEncode('html', local.item.getValue('lname'))#, #esapiEncode('html', local.item.getValue('fname'))#
											</cfif>
										</td>
									</cfif>

								<!--- Email --->
									<td>
										<cfif Len(local.item.getValue('email'))>
											<a href="mailto:#esapiEncode('url',local.item.getValue('email'))#">
												#esapiEncode('html', local.item.getValue('email'))#
											</a>
										<cfelse>
											&nbsp;
										</cfif>
									</td>

								<!--- Date Lastupdate --->
									<td class="hidden-xs">
										#LSDateFormat(local.item.getValue('lastupdate'), session.dateKeyFormat)#
									</td>

								<!--- Time Lastupdate --->
									<td class="hidden-xs hidden-sm">
										#LSTimeFormat(local.item.getValue('lastupdate'), 'short')#
									</td>

								<!--- Last Update By --->
									<td class="hidden-xs">
										#esapiEncode('html', local.item.getValue('lastupdateby'))#
									</td>

							</tr>
						</cfloop>

				</tbody>
			</table>

			<cfinclude template="dsp_nextn.cfm" />

		<cfelse>

			<!--- No Users Message --->
			<div class="help-block-empty">
				<cfif IsDefined('rc.noUsersMessage')>
					#esapiEncode('html', rc.noUsersMessage)#
				<cfelse>
					#rbKey('user.nousers')#
				</cfif>
			</div>

		</cfif>

	</cfif>

<script>
	var searchInput=document.getElementById('search');
	var search =(searchInput)? searchInput.value : '';
	var systemUsers = 0;
	var siteMembers = 0;
	$.get('..#application.configBean.getAdminDir()#/?muraAction=cUsers.remoteSearch&ispublic=0&search='+search+'&isGroupSearch=#rc.isGroupSearch#&siteid=#esapiEncode("javascript", session.siteid)#', function(data) {
		systemUsers = parseInt(data.trim());
		$.get('..#application.configBean.getAdminDir()#/?muraAction=cUsers.remoteSearch&ispublic=1&search='+search+'&isGroupSearch=#rc.isGroupSearch#&siteid=#esapiEncode("javascript", session.siteid)#', function(data) {
			siteMembers = parseInt(data.trim());
			processTabs(systemUsers,siteMembers);
		});
	});
	function processTabs(systemUsers,siteMembers) {
		var tabs = document.getElementsByClassName('mura-tab-links')[0].children;
		var systemUsersTab = tabs[1];
		var aUsers = systemUsersTab.children[0];
		aUsers.innerText = aUsers.innerText.trim() + ' (' + systemUsers + ')';

		var siteMembersTab = tabs[0];
		var aMembers = siteMembersTab.children[0];
		aMembers.innerText = aMembers.innerText.trim() + ' (' + siteMembers + ')';

	}
</script>
</cfoutput>

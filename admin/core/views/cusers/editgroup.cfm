<!--- License goes here --->

<cfhtmlhead text="#session.dateKey#" />

<cfsilent>
	<cfscript>
		isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('00000000000000000000000000000000008',rc.siteid));
		event = request.event;
		userPoolID = rc.ispublic == 0 && rc.isAdmin
			? rc.$.siteConfig('privateUserPoolID')
			: rc.$.siteConfig('publicUserPoolID');

		rsSubTypes = application.classExtensionManager.getSubTypesByType(type=1, siteid=userPoolID, activeOnly=true);

		q = new Query();
		q.setDbType('query');
		q.setAttributes(rs=rsSubTypes);
		q.addParam(name='subType', value='Default', cfsqltype='cf_sql_varchar');
		q.setSQL('SELECT * FROM rs WHERE subtype <> :subType');
		rsNonDefault = q.execute().getResult();

		variables.pluginEvent = CreateObject("component","mura.event").init(event.getAllValues());
		pluginEventMappings = Duplicate(rc.$.getBean('pluginManager').getEventMappings(eventName='onGroupEdit', siteid=rc.siteid));

		if ( ArrayLen(pluginEventMappings) ) {
			for ( i=1; i <= ArrayLen(pluginEventMappings); i++) {
				pluginEventMappings[i].eventName = 'onGroupEdit';
			}
		}

		tabLabelList='#rbKey('user.basic')#';
		tablist="tabBasic";
		if ( rsSubTypes.recordcount ) {
			tabLabelList=listAppend(tabLabelList,rbKey('user.extendedattributes'));
			tabList=listAppend(tabList,"tabExtendedattributes");
		}
	</cfscript>
</cfsilent>

<cfif rc.isAdmin>
	<script>
		jQuery(document).ready(function($){

			$('input[name="isPublic"]').click(function(e){
				e.preventDefault();
				actionModal();
				$('form#frmTemp input[name="setispublic"]').val($(this).val());
				$('form#frmTemp').submit();
			});

		});
	</script>
	<form id="frmTemp" action="" method="post">
		<input type="hidden" name="setispublic" value="1">
	</form>
</cfif>

<!--- Header --->
<cfoutput>
	<div class="mura-header">
		<h1>#rbKey('user.groupform')#</h1>
		<div class="nav-module-specific btn-group">
			<a class="btn" href="##" title="#esapiEncode('html',rbKey('sitemanager.back'))#" onclick="actionModal();window.history.back(); return false;">
					<i class="mi-arrow-circle-left"></i>
				#rbKey('sitemanager.back')#
			</a>
			<a class="btn" href="#buildURL(action='cusers.list')#" onclick="actionModal();">
					<i class="mi-users"></i>
				#rbKey('user.viewallgroups')#
			</a>
			<cfif !rc.userBean.getIsNew()>
				<a class="btn" href="#buildURL(action='cusers.editgroupmembers', querystring='userid=#rc.userid#&siteid=#esapiEncode('url',rc.siteid)#')#" onclick="actionModal();">
						<i class="mi-group"></i>
					#rbKey('user.viewgroupsusers')#
				</a>
			</cfif>
		</div>
	</div> <!-- /.mura-header -->

	<!--- Edit Form --->
	<cfif not structIsEmpty(rc.userBean.getErrors())>
		<div class="alert alert-error"><span>#application.utility.displayErrors(rc.userBean.getErrors())#</span></div>
	</cfif>

	<form novalidate="novalidate" action="#buildURL(action='cUsers.update', querystring='userid=#rc.userBean.getUserID()#')#" enctype="multipart/form-data" method="post" name="form1" onsubmit="return userManager.submitForm(this);">

		<div class="block block-constrain">

			<cfif rsSubTypes.recordcount or arrayLen(pluginEventMappings)>
				<ul class="mura-tabs nav-tabs" data-toggle="tabs">
					<!--- Basic --->
					<li class="active">
						<a href="##tabBasic" onclick="return false;"><span>#esapiEncode('html',rbKey('user.basic'))#</span></a>
					</li>

					<!--- Extended Attributes --->
					<cfif rsSubTypes.recordcount>
						<li id="tabExtendedattributesLI" class="hide">
							<a href="##tabExtendedattributes" onclick="return false;">
								<span>#esapiEncode('html',rbKey('user.extendedattributes'))#</span>
							</a>
						</li>
					</cfif>

					<cfif arrayLen(pluginEventMappings)>
						<cfloop from="1" to="#arrayLen(pluginEventMappings)#" index="i">
							<cfset tabID="tab" & $.createCSSID(pluginEventMappings[i].pluginName)>
							<li id="###tabID#LI">
								<a href="###tabID#" onclick="return false;">
									<span>#esapiEncode('html',pluginEventMappings[i].pluginName)#</span>
								</a>
							</li>
						</cfloop>
					</cfif>
				</ul>

				<div class="tab-content block-content">
					<div id="tabBasic" class="tab-pane active">
			</cfif>

			<div class="block block-bordered">
				<cfif rsSubTypes.recordcount or arrayLen(pluginEventMappings)>
					<!-- block header -->
					<div class="block-header">
						<h3 class="block-title">Basic Settings</h3>
					</div> <!-- /.block header -->
				</cfif>
			
				<div class="block-content">
					<!---
						Group Type
						** Only allow 'Admin' or Super Users to modify Group Types
					--->
					<cfif rc.isAdmin and not rc.userbean.getPerm()>
						<div class="mura-control-group">
							<label>
								#rbKey('user.grouptype')#
							</label>
							<label class="radio inline">
								<input name="isPublic" type="radio" class="radio inline" value="1" <cfif rc.tempIsPublic>Checked</cfif>>
								#rbKey('user.membergroup')#
							</label>
							<label class="radio inline">
								<input name="isPublic" type="radio" class="radio inline" value="0" <cfif not rc.tempIsPublic>Checked</cfif>>
									#rbKey('user.systemgroup')#
							</label>
						</div>
					<cfelse>
						<input type="hidden" name="isPublic" value="#rc.tempIsPublic#">
					</cfif>

					<cfif rsNonDefault.recordcount>
						<div class="mura-control-group">
							<label>
								#rbKey('user.type')#
							</label>
							<select name="subtype" onchange="userManager.resetExtendedAttributes('#rc.userBean.getUserID()#','1',this.value,'#userPoolID#','#application.configBean.getContext()#','#application.settingsManager.getSite(rc.siteID).getThemeAssetPath()#');">
								<option value="Default" <cfif  rc.userBean.getSubType() eq "Default">selected</cfif>>
									#rbKey('user.default')#
								</option>
								<cfloop query="rsNonDefault">
									<option value="#rsNonDefault.subtype#" <cfif rc.userBean.getSubType() eq rsNonDefault.subtype>selected</cfif>>
										#rsNonDefault.subtype#
									</option>
								</cfloop>
							</select>
						</div>
					</cfif>

					<div class="mura-control-group">
						<label>
							#rbKey('user.groupname')#
						</label>
						<input type="text" name="groupname" maxlength="255" value="#esapiEncode('html',rc.userBean.getgroupname())#" required="required" message="#rbKey('user.groupnamerequired')#" <cfif rc.userbean.getPerm()>readonly="readonly"</cfif>>
					</div>

					<div class="mura-control-group">
						<label>
							<span data-toggle="popover" title="" data-placement="right"
							  	data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"user.groupemailmessage"))#"
							  	data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"user.groupemail"))#">
									#rbKey('user.groupemail')#
								<i class="mi-question-circle"></i>
							</span>
						</label>
						<input type="text" name="email" maxlength="255" value="#esapiEncode('html',rc.userBean.getemail())#">
					</div>

					<cfif not rc.userbean.getperm()>
						<div class="mura-control-group">
							<label>
								#rbKey('user.tablist')#
							</label>
							<select name="tablist" size="#listLen(application.contentManager.getTabList()) + 1#" multiple="multiple">
								<option value=""<cfif not len(rc.userBean.getTablist())> selected</cfif>>All</option>
								<cfloop list="#application.contentManager.getTabList()#" index="t">
									<option value="#t#"<cfif listFindNoCase(rc.userBean.getTablist(),t)> selected</cfif>>
										#rbKey("sitemanager.content.tabs.#REreplace(t, "[^\\\w]", "", "all")#")#
									</option>
								</cfloop>
							</select>
						</div>
					</cfif>
					<span id="extendSetsBasic"></span>
				</div> <!-- /.block-content -->

		<cfif rsSubTypes.recordcount or arrayLen(pluginEventMappings)>
				</div> <!-- / tabBasic -->		
			</div> <!-- /.tab-content block-content -->

				<cfif rsSubTypes.recordcount>
					<div id="tabExtendedattributes" class='tab-pane'>
						<div class="block block-bordered">
							<!-- block header -->
							<div class="block-header">
								<h3 class="block-title">Extended Attributes</h3>
							</div> <!-- /.block header -->
							<div class="block-content">
								<span id="extendSetsDefault"></span>
							</div> <!-- /.block-content -->
						</div> <!-- /.block-bordered -->
					</div> <!-- /.tab-pane -->
				</cfif>

				<cfif arrayLen(pluginEventMappings)>
					<cfloop from="1" to="#arrayLen(pluginEventMappings)#" index="i">
						<cfset tabLabelList=listAppend(tabLabelList,pluginEventMappings[i].pluginName)/>
						<cfset tabID="tab" & $.createCSSID(pluginEventMappings[i].pluginName)>
						<cfset tabList=listAppend(tabList,tabID)>
						<cfset pluginEvent.setValue("tabList",tabLabelList)>
						<div id="#tabID#" class="tab-pane">
							<div class="block block-bordered">
								<!-- block header -->
								<div class="block-header">
									<h3 class="block-title">Plugin Events</h3>
								</div> <!-- /.block header -->
								<div class="block-content">
									#$.getBean('pluginManager').renderEvent(eventToRender=pluginEventMappings[i].eventName,currentEventObject=$,index=i)#
								</div> <!-- /.block-content -->
							</div> <!-- /.block-bordered -->
						</div> <!-- /.tab-pane -->
					</cfloop>
				</cfif>

			</div> <!-- /.block-content.tab-content -->
			
			<cfif isEditor>
				<div class="mura-actions">
					<div class="form-actions">
						<cfif rc.userid eq ''>
							<button type="button" class="btn mura-primary" onclick="submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i>#rbKey('user.add')#</button>
						<cfelse>
							<button type="button" class="btn" onclick="submitForm(document.forms.form1,'delete','#jsStringFormat(rbKey('user.deletegroupconfirm'))#');"><i class="mi-trash"></i>#rbKey('user.delete')#</button>
							<button type="button" class="btn mura-primary" onclick="submitForm(document.forms.form1,'update');"><i class="mi-check-circle"></i>#rbKey('user.update')#</button>
						</cfif>

						<cfset tempAction = !Len(rc.userid) ? 'Add' : 'Update' />
						<input type="hidden" name="action" value="#tempAction#">
						<input type="hidden" name="type" value="1">
						<input type="hidden" name="contact" value="0">
						<input type="hidden" name="siteid" value="#esapiEncode('html',rc.siteid)#">
						<input type="hidden" name="returnurl" value="#buildURL(action='cUsers.list', querystring='ispublic=#rc.tempIsPublic#')#">
						<cfif not rsNonDefault.recordcount>
							<input type="hidden" name="subtype" value="Default"/>
						</cfif>
						#rc.$.renderCSRFTokens(context=rc.userBean.getUserID(),format="form")#
					</div>
				</div>
			</cfif>
			<cfif rsSubTypes.recordcount>
				<script type="text/javascript">
					userManager.loadExtendedAttributes('#rc.userbean.getUserID()#','1','#rc.userbean.getSubType()#','#userPoolID#','#application.configBean.getContext()#','#application.settingsManager.getSite(rc.siteid).getThemeAssetPath()#');
				</script>
			</cfif>
		<cfelse>
			<!--- </div> ---> <!-- /.block-content -->
			<div class="mura-actions">
				<div class="form-actions">
					<cfif rc.userid eq ''>
						<button type="button" class="btn mura-primary" onclick="userManager.submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i>#rbKey('user.add')#</button>
					<cfelse>
						<button type="button" class="btn" onclick="submitForm(document.forms.form1,'delete','#jsStringFormat(rbKey('user.deletegroupconfirm'))#');"><i class="mi-trash"></i>#rbKey('user.delete')#</button>
						<button type="button" class="btn mura-primary" onclick="userManager.submitForm(document.forms.form1,'update');"><i class="mi-check-circle"></i>#rbKey('user.update')#</button>
					</cfif>
					<cfset tempAction = !Len(rc.userid) ? 'Add' : 'Update' />
					<input type="hidden" name="action" value="#tempAction#">
					<input type="hidden" name="type" value="1"><!--- 1=group, 2=user --->
					<input type="hidden" name="contact" value="0">
					<input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.siteid)#">
					<input type="hidden" name="returnurl" value="#buildURL(action='cUsers.list', querystring='ispublic=#rc.tempIsPublic#')#">
					<cfif not rsNonDefault.recordcount>
						<input type="hidden" name="subtype" value="Default"/>
					</cfif>
					#rc.$.renderCSRFTokens(context=rc.userBean.getUserID(),format="form")#
				</div>
			</div>
		</cfif>

		<!--- </div> ---> <!-- /.block-bordered -->
		</div> <!-- /.block-constrain -->
	</form>
	<!--- /Edit Form --->
</cfoutput>

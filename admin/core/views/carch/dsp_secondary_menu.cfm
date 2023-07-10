<!--- license goes here --->
<cfoutput>
<cfif isdefined('rc.contentBean')>
	<cfparam name="stats" default="#rc.contentBean.getStats()#">
	<cfset isLocked=$.siteConfig('hasLockableNodes') and len(stats.getLockID()) and stats.getLockType() eq 'node'>
	<cfset isLockedBySomeoneElse=isLocked and stats.getLockID() neq session.mura.userid>
</cfif>

<cfset rc.originalfuseaction=listLast(request.action,".")>
<cfset rc.originalcircuit=listFirst(listLast(request.action,":"),".")>
<div class="nav-module-specific btn-group">
	<cfif rc.compactDisplay eq 'true' and not rc.$.useLayoutManager()>
		<a class="btn" onclick="history.go(-1);"><i class="mi-arrow-circle-left"></i>  #application.rbFactory.getKeyValue(session.rb,'collections.back')#</a>
	</cfif>

	<cfswitch expression="#rc.moduleid#">
		<!--- 0003 = components, 0004 = forms, 0099 = remote variations --->
		<cfcase value="00000000000000000000000000000000003,00000000000000000000000000000000004,00000000000000000000000000000000099">
			<cfswitch expression="#rc.originalfuseaction#">
				<!--- list view --->
				<cfcase value="list">
					<cfif rc.perm neq 'none'>
						<!--- components --->
						<cfif rc.moduleid eq "00000000000000000000000000000000003">
							<!--- add component --->
							<a class="btn" href="./?muraAction=cArch.edit&type=Component&contentid=&topid=#esapiEncode('url',rc.topid)#&parentid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#esapiEncode('url',rc.moduleid)#"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.addcomponent')#</a>
						<!--- forms (!= remote vars) --->	
						<cfelseif rc.moduleid neq "00000000000000000000000000000000099">
							<!--- new form builder --->
							<a class="btn" href="./?muraAction=cArch.edit&type=Form&contentid=&topid=#esapiEncode('url',rc.topid)#&parentid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#esapiEncode('url',rc.moduleid)#&formType=builder"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.addformwithbuilder')#</a>
							<!--- add simple form --->
							<cfif application.configBean.getValue('allowSimpleHTMLForms')>
								<a class="btn" href="./?muraAction=cArch.edit&type=Form&contentid=&topid=#esapiEncode('url',rc.topid)#&parentid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#esapiEncode('url',rc.moduleid)#&formType=editor"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.addformwitheditor')#</a>
							</cfif>
						</cfif>
						<!--- permissions --->
						<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
							<a class="btn <cfif rc.originalfuseaction eq "main"> active</cfif>" href="./?muraAction=cPerm.main&contentid=#esapiEncode('url',rc.moduleid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#esapiEncode('url',rc.moduleid)#&startrow=#esapiEncode('url',rc.startrow)#"><i class="mi-group"></i> Permissions</a>
						</cfif>
					</cfif>
				</cfcase>
				<!--- form data view --->
				<cfcase value="datamanager">

					<!--- back to forms --->
					<a class="btn" href="./?muraAction=cArch.list&siteid=#esapiEncode('url',rc.siteid)#&topid=#esapiEncode('url',rc.moduleid)#&parentid=#esapiEncode('url',rc.moduleid)#&moduleid=#esapiEncode('url',rc.moduleid)#"><i class="mi-arrow-circle-left"></i>
							#application.rbFactory.getKeyValue(session.rb,'sitemanager.backtoforms')#
					</a>

					<!--- version history --->
					<a class="btn" href="./?muraAction=cArch.hist&contentid=#esapiEncode('url',rc.contentid)#&type=Form&parentid=00000000000000000000000000000000004&topid=00000000000000000000000000000000004&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=00000000000000000000000000000000004"><i class="mi-history"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.versionhistory')#</a>

					<!--- manage data --->
					<cfif rc.action neq ''>
						<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.managedate')#" href="./?muraAction=cArch.datamanager&contentid=#esapiEncode('url',rc.contentid)#&type=Form&topid=00000000000000000000000000000000004&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000004&parentid=00000000000000000000000000000000004"><i class="mi-wrench"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.managedata')#</a>
					</cfif>

					<cfif rc.perm eq 'editor' and not isLockedBySomeoneElse>
					
						<!--- edit display --->
						<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.editdisplay')#" href="./?muraAction=cArch.datamanager&contentid=#esapiEncode('url',rc.contentid)#&type=Form&action=display&topid=00000000000000000000000000000000004&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000004&parentid=00000000000000000000000000000000004"><i class="mi-pencil"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.editdisplay')#</a>
						
						<!--- delete form --->
						<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.delete')#" href="./?muraAction=cArch.update&contentid=#esapiEncode('url',rc.contentid)#&type=Form&action=deleteall&topid=00000000000000000000000000000000004&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000004&parentid=00000000000000000000000000000000004#rc.$.renderCSRFTokens(context=rc.contentid & 'deleteall',format='url')#" onClick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.deleteformconfirm'))#',this.href)"><i class="mi-trash"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.deleteform')#</a>
						
					</cfif>

					<!--- permissions --->
					<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>	
						<a class="btn" href="./?muraAction=cPerm.main&contentid=#esapiEncode('url',rc.contentid)#&type=Form&parentid=00000000000000000000000000000000004&topid=00000000000000000000000000000000004&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000004&startrow=#esapiEncode('url',rc.startrow)#"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.permissions')#</a>
					</cfif>
				</cfcase>
				<!--- edit view --->
				<cfcase value="edit,update">
					<cfset started=false>
					<cfif rc.compactDisplay neq 'true'>
						<cfset started=true>

						<!--- back to list --->
						<a class="btn" href="./?muraAction=cArch.list&siteid=#esapiEncode('url',rc.siteid)#&topid=#esapiEncode('url',rc.moduleid)#&parentid=#esapiEncode('url',rc.moduleid)#&moduleid=#esapiEncode('url',rc.moduleid)#"><i class="mi-arrow-circle-left"></i>
							<cfif rc.moduleid eq "00000000000000000000000000000000003">
								#application.rbFactory.getKeyValue(session.rb,'sitemanager.backtocomponents')#
							<cfelseif rc.moduleid eq "00000000000000000000000000000000099">
								#application.rbFactory.getKeyValue(session.rb,'sitemanager.backtovariations')#
							<cfelse>
								#application.rbFactory.getKeyValue(session.rb,'sitemanager.backtoforms')#
							</cfif>
						</a>

					</cfif>

					<cfif rc.contentBean.exists()>
						<cfif listFind(session.mura.memberships,'S2IsPrivate')>
							<cfset started=true>

							<!--- manage data --->
							<a class="btn" href="./?muraAction=cArch.datamanager&contentid=#esapiEncode('url',rc.contentid)#&siteid=#esapiEncode('url',rc.siteid)#&topid=#esapiEncode('url',rc.topid)#&moduleid=#esapiEncode('url',rc.moduleid)#&type=Form&parentid=#esapiEncode('url',rc.moduleid)#"><i class="mi-wrench"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.managedata")#</a></li>

						</cfif>
						
						<!--- start actions nav --->
						<cfif started>
							<div class="btn-group">
						</cfif>
					  <a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
					    <i class="mi-cogs"></i> Actions
					    <span class="caret"></span>
					  </a>
					 	 <ul class="dropdown-menu">

							<!--- view this version --->	
							<cfif rc.type eq 'Variation'>
							 	<li><a href="#esapiEncode('html_attr','#rc.contentBean.getRemoteURL()#?previewid=#rc.contentBean.getContentHistID()#')#"><i class="mi-globe"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.viewversion")#</a></li>
							</cfif>

							<!--- version history --->
							<li><a href="./?muraAction=cArch.hist&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)#&compactDisplay=#esapiEncode('url',rc.compactdisplay)#"><i class="mi-history"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.versionhistory")#</a></li>
	
							<!--- audit trail --->
							<li><a href="./?muraAction=cArch.audit&contentid=#esapiEncode('url',rc.contentid)#&contenthistid=#rc.contentBean.getContentHistID()#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)#&compactDisplay=#esapiEncode('url',rc.compactdisplay)#"><i class="mi-tasks"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.audittrail")#</a></li>

							<!--- permissions --->
							<cfif (listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2'))>
								<li><a href="./?muraAction=cPerm.main&contentid=#esapiEncode('url',rc.contentid)#&type=#rc.contentBean.gettype()#&parentid=#rc.contentBean.getparentID()#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#esapiEncode('url',rc.moduleid)#&startrow=#esapiEncode('url',rc.startrow)#"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.permissions")#</a></li>
							</cfif>

							<!--- export/import --->
							<cfif !rc.contentBean.get('isNew')>
								<cfif rc.contentBean.get('type') eq 'Form'>
									<li class="mura-nav-divider"><a href="./?muraAction=cForm.export&contentid=#esapiEncode('url',rc.contentid)#"><i class="mi-save"></i>  #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.exportnode"))#</a></li>
									<li><a href="./?muraAction=cForm.importform"><i class="mi-upload"></i>  #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.importnode"))#</a></li>
								<cfelseif rc.contentBean.get('type') eq 'Component'>
									<li class="mura-nav-divider"><a href="./?muraAction=cArch.exportcomponent&contentid=#esapiEncode('url',rc.contentid)#"><i class="mi-save"></i>  #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.exportnode"))#</a></li>
									<li><a href="./?muraAction=cArch.importcomponent"><i class="mi-upload"></i>  #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.importnode"))#</a></li>
								</cfif>
							</cfif>
						

							<!--- delete version --->
							<cfif rc.compactDisplay neq 'true' and rc.contentBean.getactive()lt 1 and (rc.perm neq 'none' and application.configBean.getPurgeDrafts() or $.currentUser().isSuperUser() or $.currentUser().isAdminUser()) and not isLockedBySomeoneElse>
								<li class="mura-nav-divider"><a href="./?muraAction=cArch.update&contenthistid=#esapiEncode('url',rc.contenthistid)#&action=delete&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)#&return=#esapiEncode('url',rc.return)##rc.$.renderCSRFTokens(context=rc.contenthistid & 'delete',format='url')#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.deleteversionconfirm"))#',this.href)"><i class="mi-trash"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.deleteversion")#</a></li>
							</cfif>
							
							<!--- delete --->
							<cfif rc.deletable and not isLockedBySomeoneElse>
								<li class="mura-nav-divider"><a href="./?muraAction=cArch.update&action=deleteall&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)##rc.$.renderCSRFTokens(context=rc.contentid & 'deleteall',format='url')#"
								<cfif listFindNoCase(nodeLevelList,rc.contentBean.getType())>onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,'sitemanager.content.deletecontentrecursiveconfirm'),rc.contentBean.getMenutitle()))#',this.href)"<cfelse>onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.deletecontentconfirm"))#',this.href)"</cfif>><i class="mi-trash"></i>  #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.deletecontent")#</a></li>
							</cfif>



						</ul>
						<cfif started>
							</div>
						</cfif>
					</cfif>
				</cfcase>

				<cfcase value="hist,audit">

					<!--- back to list --->
					<a class="btn" href="./?muraAction=cArch.list&siteid=#esapiEncode('url',rc.siteid)#&topid=#esapiEncode('url',rc.moduleid)#&parentid=#esapiEncode('url',rc.moduleid)#&moduleid=#esapiEncode('url',rc.moduleid)#"><i class="mi-arrow-circle-left"></i>
						<cfif rc.moduleid eq "00000000000000000000000000000000003">
							#application.rbFactory.getKeyValue(session.rb,'sitemanager.backtocomponents')#
						<cfelseif rc.moduleid eq "00000000000000000000000000000000099">
							#application.rbFactory.getKeyValue(session.rb,'sitemanager.backtovariations')#
						<cfelse>
							#application.rbFactory.getKeyValue(session.rb,'sitemanager.backtoforms')#
						</cfif>
					</a>

					<!--- start actions nav --->
					<cfif rc.contentBean.exists()>
						<div class="btn-group">
						  <a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
								<i class="mi-cogs"></i> Actions
								<span class="caret"></span>
						  </a>
						  <ul class="dropdown-menu drop-right">

								<!--- manage data --->
								<cfif rc.type eq "Form" and listFind(session.mura.memberships,'S2IsPrivate')>
									<li><a href="./?muraAction=cArch.datamanager&contentid=#esapiEncode('url',rc.contentid)#&siteid=#esapiEncode('url',rc.siteid)#&topid=#esapiEncode('url',rc.topid)#&moduleid=#esapiEncode('url',rc.moduleid)#&type=Form&parentid=#esapiEncode('url',rc.moduleid)#"><i class="mi-wrench"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.managedata")#</a></li>
								</cfif>

								<!--- clear version history --->
								<cfif rc.originalfuseaction eq 'hist'>
									<cfif (rc.perm neq 'none' and application.configBean.getPurgeDrafts() or (listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2'))) and not isLockedBySomeoneElse>
										<li><a href="./?muraAction=cArch.update&action=deletehistall&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)#&compactDisplay=#esapiEncode('url',rc.compactdisplay)##rc.$.renderCSRFTokens(context=rc.contentid & 'deletehistall',format='url')#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.clearversionhistoryconfirm'))#',this.href)"><i class="mi-eraser"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.clearversionhistory')#</a></li>
									</cfif>

								<!--- view version history --->
								<cfelse>
									<li><a href="./?muraAction=cArch.hist&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)#&compactDisplay=#esapiEncode('url',rc.compactdisplay)#"><i class="mi-history"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.versionhistory")#</a></li>
								</cfif>

								<!--- delete --->
								<cfif rc.deletable and not isLockedBySomeoneElse>
									<li class="mura-nav-divider"><a href="./?muraAction=cArch.update&action=deleteall&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)##rc.$.renderCSRFTokens(context=rc.contentid & 'deleteall',format='url')#"<cfif listFindNoCase(nodeLevelList,rc.contentBean.getType())>onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,'sitemanager.content.deletecontentrecursiveconfirm'),rc.contentBean.getMenutitle()))#',this.href)"<cfelse>onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.deletecontentconfirm"))#',this.href)"</cfif>><i class="mi-trash"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.deletecontent")#</a></li>
								</cfif>

								<!--- permissions --->
								<cfif (listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2'))>
									<li><a href="./?muraAction=cPerm.main&contentid=#esapiEncode('url',rc.contentid)#&type=#rc.contentBean.gettype()#&parentid=#rc.contentBean.getparentID()#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#esapiEncode('url',rc.moduleid)#&startrow=#esapiEncode('url',rc.startrow)#"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.permissions")#</a></li>
								</cfif>

							</ul>
						</div>
					</cfif>
				</cfcase>
			</cfswitch>
		</cfcase>

		<!--- all other content types (!= form, components, remote var) --->
		<cfdefaultcase>
			<cfswitch expression="#rc.originalfuseaction#">

				<cfcase value="edit,update">

					<cfif rc.contentid neq "">
						<!--- subnavigation for custom entities --->
						<cfsavecontent variable="customEntitiesNav">
							<cfset started=false>
							<cfoutput>
								<div class="btn-group">
									<a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
										<i class="mi-cubes"></i> Custom Entities
										<span class="caret"></span>
									</a>
									<ul class="dropdown-menu drop-right">
										<cfset hasManyArray=rc.contentBean.getHasManyPropArray()>
										<cfloop array="#hasManyArray#" index="i">
											<cfif structKeyExists(i,'scaffold') and i.scaffold>
												<cfset started=true>
												<cfset beanInstance=rc.$.getBean(i.cfc)>
												<li><a href="./?muraAction=cArch.list&activeTab=2&entityid=#esapiEncode('url',rc.contentid)#&entityname=content&siteid=#esapiEncode('url',rc.siteid)#&relatesto=#esapiEncode('url',i.cfc)#"><i class="mi-cube"></i> #esapiEncode('html',beanInstance.pluralizeHasRefName(beanInstance.getEntityDisplayName()))#</a></li>
											</cfif>
										</cfloop>
										<cfset hasOneArray=rc.contentBean.getHasOnePropArray()>
										<cfloop array="#hasOneArray#" index="i">
											<cfif structKeyExists(i,'scaffold') and i.scaffold>
												<cfset started=true>
												<cfset beanInstance=rc.$.getBean(i.cfc)>
												<li><a href="./?muraAction=cArch.list&activeTab=2&entityid=#esapiEncode('url',rc.contentid)#&entityname=content&siteid=#esapiEncode('url',rc.siteid)#&relatesto=#esapiEncode('url',i.cfc)#"><i class="mi-cube"></i> #esapiEncode('html',beanInstance.pluralizeHasRefName(beanInstance.getEntityDisplayName()))# #beanInstance.getEntityDisplayName()#</a></li>
											</cfif>
										</cfloop>
									</ul>
								</div>
							</cfoutput>
						</cfsavecontent>
						<cfif started>#customEntitiesNav#</cfif>

						<!--- start actions nav --->
						<div class="btn-group">
						  <a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
						    <i class="mi-cogs"></i> Actions
						    <span class="caret"></span>
						  </a>
						  <ul class="dropdown-menu drop-right">
						 
						  	<!--- view this version --->
								<cfif (rc.contentBean.getfilename() neq '' or rc.contentid eq '00000000000000000000000000000000001')>
									<cfif listFind("Page,Folder,Calendar,Gallery",rc.type)>
										<li><a href="#rc.contentBean.getURL(secure=rc.$.getBean('utility').isHTTPs(),complete=1,queryString='previewid=#rc.contentBean.getContentHistID()#&editlayout=true',useEditRoute=true)#"><i class="mi-th"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.edit-layout")#</a></li>
									</cfif>
									<!---<cfswitch expression="#rc.type#">
									<cfcase value="Page,Folder,Calendar,Gallery">--->
										<!---<li><a href="#rc.contentBean.getURL(secure=rc.$.getBean('utility').isHTTPs(),complete=1,useEditRoute=true)#"><i class="mi-globe"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.view")#</a></li>--->
										<li<cfif listFind("Page,Folder,Calendar,Gallery",rc.type)> class="mura-nav-divider"</cfif>><a href="#rc.contentBean.getURL(secure=rc.$.getBean('utility').isHTTPs(),complete=1,queryString='previewid=#rc.contentBean.getContentHistID()#',useEditRoute=true)#"><i class="mi-globe"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.viewversion")#</a></li>
									<!---</cfcase>
									<cfcase value="File">
										<!---<li><a href="##" href="##" onclick="return preview('#rc.contentBean.getURL(secure=rc.$.getBean('utility').isHTTPs(),complete=1,useEditRoute=true)#');"><i class="mi-globe"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.view")#</a></li>--->
										<li><a href="##" href="##" onclick="return preview('#application.settingsManager.getSite(rc.siteid).getResourcePath(complete=1)##application.configBean.getIndexPath()#/_api/render/file/?fileID=#rc.contentBean.getFileID()#');"><i class="mi-globe"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.viewversion")#</a></li>
									</cfcase>
									</cfswitch>--->
								</cfif>

								<!--- version history --->
								<li>
									<a href="./?muraAction=cArch.hist&amp;contentid=#esapiEncode('url',rc.contentid)#&amp;type=#esapiEncode('url',rc.type)#&amp;parentid=#esapiEncode('url',rc.parentid)#&amp;topid=#esapiEncode('url',rc.topid)#&amp;siteid=#esapiEncode('url',rc.siteid)#&amp;startrow=#esapiEncode('url',rc.startrow)#&amp;moduleid=#esapiEncode('url',rc.moduleid)#&amp;compactDisplay=#esapiEncode('url',rc.compactdisplay)#">
										<i class="mi-history"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.versionhistory")#
									</a>
								</li>

								<!--- audit trail --->
								<li>
									<a href="./?muraAction=cArch.audit&amp;contentid=#esapiEncode('url',rc.contentid)#&amp;contenthistid=#rc.contentBean.getContentHistID()#&amp;type=#esapiEncode('url',rc.type)#&amp;parentid=#esapiEncode('url',rc.parentid)#&amp;topid=#esapiEncode('url',rc.topid)#&amp;siteid=#esapiEncode('url',rc.siteid)#&amp;startrow=#esapiEncode('url',rc.startrow)#&amp;moduleid=#esapiEncode('url',rc.moduleid)#&amp;compactDisplay=#esapiEncode('url',rc.compactdisplay)#">
										<i class="mi-tasks"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.audittrail")#
									</a>
								</li>

								<!--- permissions --->
								<cfif (listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2'))>
									<li><a href="./?muraAction=cPerm.main&contentid=#esapiEncode('url',rc.contentid)#&type=#rc.contentBean.gettype()#&parentid=#rc.contentBean.getparentID()#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#esapiEncode('url',rc.moduleid)#&startrow=#esapiEncode('url',rc.startrow)#"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.permissions")#</a></li>
								</cfif>

								<!--- export node --->
								<li class="mura-nav-divider">
									<a href="?muraAction=cArch.export&amp;siteid=#esapiEncode('url',rc.siteid)#&amp;contentid=#esapiEncode('url',rc.contentid)#">
										<i class="mi-sign-out"></i> #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.exportnode"))#
									</a>
								</li>

								<!--- import node --->
								<li>
									<a href="?muraAction=cArch.import&amp;contentid=#esapiEncode('url',rc.contentid)#&amp;moduleid=#esapiEncode('url',rc.moduleid)#&amp;siteid=#esapiEncode('url',rc.siteid)#">
										<i class="mi-sign-in"></i> #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.importnode"))#
									</a>
								</li>

								<!--- delete version --->
								<cfif rc.compactDisplay neq 'true' and rc.contentBean.getactive()lt 1 and (rc.perm neq 'none') and not isLockedBySomeoneElse>
									<li><a href="./?muraAction=cArch.update&contenthistid=#esapiEncode('url',rc.contenthistid)#&action=delete&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)#&return=#rc.return##rc.$.renderCSRFTokens(context=rc.contenthistid & 'delete',format='url')#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.deleteversionconfirm"))#',this.href)"><i class="mi-trash"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.deleteversion")#</a></li>
								</cfif>

								<!--- delete --->
								<cfif rc.deletable and not isLockedBySomeoneElse>
									<li class="mura-nav-divider"><a href="./?muraAction=cArch.update&action=deleteall&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)##rc.$.renderCSRFTokens(context=rc.contentid & 'deleteall',format='url')#"
									<cfif listFindNoCase(nodeLevelList,rc.contentBean.getType())>onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,'sitemanager.content.deletecontentrecursiveconfirm'),rc.contentBean.getMenutitle()))#',this.href)"<cfelse>onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.deletecontentconfirm"))#',this.href)"</cfif>><i class="mi-trash"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.deletecontent")#</a></li>
								</cfif>
							</ul>
						</div>
					</cfif>
				</cfcase>

				<cfcase value="hist,audit">
					<!--- start actions nav --->
					<cfif rc.contentBean.exists()>
						<div class="btn-group">
						  <a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
								<i class="mi-cogs"></i> Actions
								<span class="caret"></span>
						  </a>
						  <ul class="dropdown-menu drop-right">
								<!--- clear version history --->
								<cfif rc.originalfuseaction eq 'hist'>	
									<cfif rc.perm neq 'none' and not isLockedBySomeoneElse>
										<li>
											<a href="./?muraAction=cArch.update&action=deletehistall&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)#&compactDisplay=#esapiEncode('url',rc.compactdisplay)##rc.$.renderCSRFTokens(context=rc.contentid & 'deletehistall',format='url')#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.clearversionhistoryconfirm'))#',this.href)">
												<i class="mi-eraser"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.clearversionhistory')#
											</a>
										</li>
									</cfif>
							
								<!--- view version history --->
								<cfelse>
									<li><a href="./?muraAction=cArch.hist&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)#&compactDisplay=#esapiEncode('url',rc.compactdisplay)#"><i class="mi-history"></i> #application.rbFactory.getKeyValue(session.rb,"sitemanager.content.versionhistory")#</a></li>
								</cfif>

								<!--- delete content --->
								<cfif rc.deletable and rc.compactDisplay neq 'true' and not isLockedBySomeoneElse>
									<li class="mura-nav-divider"><a href="./?muraAction=cArch.update&action=deleteall&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&startrow=#esapiEncode('url',rc.startrow)#&moduleid=#esapiEncode('url',rc.moduleid)#&compactDisplay=#esapiEncode('url',rc.compactdisplay)##rc.$.renderCSRFTokens(context=rc.contentid & 'deleteall',format='url')#"
										<cfif listFindNoCase(nodeLevelList,rc.contentBean.getType()) >onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,'sitemanager.content.deletecontentrecursiveconfirm'),rc.contentBean.getMenutitle()))#',this.href)"<cfelse>onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.deletecontentconfirm'))#',this.href)"</cfif> ><i class="mi-trash"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.deletecontent')#</a></li>
								</cfif>

								<!--- permissions --->
								<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
									<li><a href="./?muraAction=cPerm.main&contentid=#esapiEncode('url',rc.contentid)#&type=#esapiEncode('url',rc.type)#&parentid=#esapiEncode('url',rc.parentid)#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#esapiEncode('url',rc.moduleid)#&startrow=#esapiEncode('url',rc.startrow)#"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.permissions')#</a></li>
								</cfif>

							</ul>
						</div>
						<cfif rc.compactDisplay neq 'true'>
							<a class="btn" href="#rc.contentBean.getEditURL(compactDisplay=rc.compactDisplay)#">
								<i class="mi-edit"></i>
							#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.edit-content')#
							</a>
						</cfif>
					</cfif>
				</cfcase>

				<cfcase value="imagedetails,multiFileUpload">
					<cfif isdefined('rc.contentBean')>

						<!--- back to site manager --->
						<cfif rc.compactdisplay neq 'true'>
							<cfif listFindNoCase(session.mura.memberships,'S2IsPrivate;#rc.siteid#') or listFindNoCase(session.mura.memberships,'S2')>
								<a class="btn" href="./?&muraAction=cArch.list&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000000">
									<i class="mi-sitemap"></i>
									#application.rbFactory.getKeyValue(session.rb,'sitemanager.backtositemanager')#
								</a>
							</cfif>

						<!--- view content --->
						<cfelse>
							<cfscript>
								viewContentURL = StructKeyExists(rc, 'homeid') && Len(rc.homeid)
									? application.contentManager.getActiveContent(rc.homeid, rc.siteid).getURL(useEditRoute=true)
									: rc.contentBean.getURL(useEditRoute=true);
							</cfscript>
							<a class="btn" href="##" onclick="frontEndProxy.post({cmd:'setLocation',location:'#esapiEncode('javascript', viewContentURL)#'}); return false;">
								<i class="mi-globe"></i>
								#application.rbFactory.getKeyValue(session.rb,'sitemanager.viewcontent')#
							</a>
						</cfif>

					<cfelseif rc.compactDisplay eq 'false'>
						
						<!--- back --->
						<a class="btn" href="##" title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.back'))#" onclick="window.history.back(); return false;"><i class="mi-arrow-circle-left"></i> #esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.back'))#</a>
					</cfif>
				</cfcase>
			</cfswitch>
		</cfdefaultcase>
	</cfswitch>

	<!--- output additional nav w/ renderer events --->
	<cfif isDefined('rc.contentBean')>
		<cfif not listFindNoCase("Form,Component",rc.contentBean.getType())>
		#$.renderEvent('onContentSecondaryNavRender')#
			#$.renderEvent('onBase#rc.contentBean.getSubType()#SecondaryNavRender')#
		</cfif>
		#$.renderEvent('on#rc.contentBean.getType()#SecondaryNavRender')#
		#$.renderEvent('on#rc.contentBean.getType()##rc.contentBean.getSubType()#SecondaryNavRender')#
	</cfif>

</div>
</cfoutput>

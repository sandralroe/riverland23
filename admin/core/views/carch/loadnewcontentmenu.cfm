 <!--- license goes here --->
<!--- removing galleries
<cfset typeList="Page,Link,File,Folder,Calendar,Gallery">
--->
<cfset $=application.serviceFactory.getBean('$').init(rc.siteID)>
<cfset renderer=$.getContentRenderer()>
<cfif isDefined('renderer.primaryContentTypes') and len(renderer.primaryContentTypes)>
	<cfset typeList=renderer.primaryContentTypes>
<cfelse>
	<cfset typeList="Page,Link,File,Folder,Calendar">
</cfif>
<cfset parentBean=$.getBean('content').loadBy(contentID=rc.contentID)>
<cfset $availableSubTypes=application.classExtensionManager.getSubTypeByName(parentBean.getType(),parentBean.getSubType(),parentBean.getSiteID()).getAvailableSubTypes()>

<cfset $availableTemplates=$.getFeed('content').where().prop('isTemplate').isEq(1).showExcludeSearch(1).showNavOnly(0)>
<cfset rsTemplates = $availableTemplates.getQuery()>

<cfset rsSubTypes=application.classExtensionManager.getSubTypes(siteID=rc.siteID,activeOnly=true) />
<cfif not isDefined('rc.frontEndProxyLoc')>
	<cfset request.layout=false>
</cfif>
<cfset $=request.event.getValue("MuraScope")>
<script>
	$(document).ready(function(){
		setToolTips('.add-content-ui');
		$('#mura-content-options li.template-parent').each(function(){
			$(this).clone().insertAfter($(this)).removeClass('template-parent').addClass('template-link').find('span').text('No Template');
			}).addClass('closed').on('click',function(){
				var nextOptions = $(this).nextUntil('li:not(.template-link)');
				if ($(this).hasClass('closed')){
					$(this).siblings('li.template-parent.open').trigger('click');
				}
				$(this).toggleClass('open').toggleClass('closed');
				$(nextOptions).toggle();
				return false;
			});
	});
</script>
<cfoutput>
<div class="mura">
	<cfif isDefined('rc.frontEndProxyLoc')>
		<div class="mura-header">
			<h1>#application.rbFactory.getKeyValue(session.rb,"sitemanager.selectcontenttype")#</h1>
		</div>
	</cfif>

	<div class="block-content">
		<div class="add-content-ui">
			<ul id="mura-content-options">
			<cfif rc.moduleid eq '00000000000000000000000000000000004'>
				<cfloop list="Form,Folder" index="i">
					<cfquery name="rsItemTypes" dbtype="query">
						select * from rsSubTypes where
						lower(type)='#lcase(i)#' and lower(subtype) = 'default'
					</cfquery>
					<cfif not rsItemTypes.recordcount or rsItemTypes.recordcount and (rsItemTypes.adminonly neq 1 or (
						rc.$.currentUser().isAdminUser()
						or rc.$.currentUser().isSuperUser()
						))>
						<cfif not len($availableSubTypes) or listFindNoCase($availableSubTypes,'#i#/Default')>
							<cfif i neq 'Form'>
								<li class="new#i#">
									<cfif len(rsItemTypes.description)>
										<a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a>
									</cfif>
									<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=#esapiEncode('url',rc.moduleid)#&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="new#i#Link"><i class="#$.iconClassByContentType(type=i,subtype='default',siteid=rc.siteid)#"></i> <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.add#lcase(i)#")#</span></a>
								</li>
							<cfelse>
								<li class="new#i#">
									<cfif len(rsItemTypes.description)>
										<a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a>
									</cfif>
									<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=#esapiEncode('url',rc.moduleid)#&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#&formType=builder" target="_top" id="new#i#Link"><i class="#$.iconClassByContentType(type=i,subtype='default',siteid=rc.siteid)#"></i> <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.addform")#</span></a>
								</li>
								<cfif application.configBean.getValue('allowSimpleHTMLForms')>
								<li class="new#i#simple">
									<cfif len(rsItemTypes.description)>
										<a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a>
									</cfif>
									<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=#esapiEncode('url',rc.moduleid)#&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#&formType=editor" target="_top" id="new#i#Link"><i class="#$.iconClassByContentType(type=i,subtype='default',siteid=rc.siteid)#"></i> <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.addformsimple")#</span></a>
								</li>
								</cfif>
							</cfif>
						</cfif>
					</cfif>
					<cfif i eq 'Form'>
						<cfquery name="rsItemTypes" dbtype="query">
						select * from rsSubTypes where lower(type)='#lcase(i)#' and lower(subtype) != 'default'
						<cfif not (
								rc.$.currentUser().isAdminUser()
								or rc.$.currentUser().isSuperUser()
								)>
								and adminonly !=1
							</cfif>
						</cfquery>
						<cfloop query="rsItemTypes">
							<cfif not len($availableSubTypes) or listFindNoCase($availableSubTypes,'#i#/#rsItemTypes.subType#')>
								<cfset output = $.renderEvent('on#i##rsItemTypes.subType#NewContentMenuRender')>
								<cfif len(output)>
									#output#
								<cfelse>
									<li class="new#i#">
										<cfif len(rsItemTypes.description)><a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a></cfif>
										<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&subType=#rsItemTypes.subType#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=#esapiEncode('url',rc.moduleid)#&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="new#i#Link"><i class="#$.iconClassByContentType(type=i,subtype=rsItemTypes.subtype,siteid=rc.siteID)#"></i> <span> <!--- #application.rbFactory.getKeyValue(session.rb,"sitemanager.add#lcase(i)#")#/ --->#rsItemTypes.subType#</span></a>
									</li>
								</cfif>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
			<cfelseif rc.moduleid eq '00000000000000000000000000000000003'>
				<cfloop list="Component,Folder" index="i">
					<cfquery name="rsItemTypes" dbtype="query">
						select * from rsSubTypes where lower(type)='#lcase(i)#' and lower(subtype) = 'default'
					</cfquery>
					<cfif not rsItemTypes.recordcount or rsItemTypes.recordcount and (rsItemTypes.adminonly neq 1 or (
						rc.$.currentUser().isAdminUser()
						or rc.$.currentUser().isSuperUser()
						))>
						<cfif not len($availableSubTypes) or listFindNoCase($availableSubTypes,'#i#/Default')>
							<li class="new#i#">
								<cfif len(rsItemTypes.description)>
									<a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a>
								</cfif>
								<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=#esapiEncode('url',rc.moduleid)#&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="new#i#Link"><i class="#$.iconClassByContentType(type=i,subtype='default',siteid=rc.siteid)#"></i> <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.add#lcase(i)#")#</span></a>
							</li>
						</cfif>
					</cfif>
					<cfif i eq 'Component'>
						<cfquery name="rsItemTypes" dbtype="query">
						select * from rsSubTypes where lower(type)='#lcase(i)#' and lower(subtype) != 'default'
						<cfif not (
								rc.$.currentUser().isAdminUser()
								or rc.$.currentUser().isSuperUser()
								)>
								and adminonly !=1
							</cfif>
						</cfquery>
						<cfloop query="rsItemTypes">
							<cfif not len($availableSubTypes) or listFindNoCase($availableSubTypes,'#i#/#rsItemTypes.subType#')>
								<cfset output = $.renderEvent('on#i##rsItemTypes.subType#NewContentMenuRender')>
								<cfif len(output)>
									#output#
								<cfelse>
									<li class="new#i#">
										<cfif len(rsItemTypes.description)><a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a></cfif>
										<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&subType=#rsItemTypes.subType#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=#esapiEncode('url',rc.moduleid)#&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="new#i#Link"><i class="#$.iconClassByContentType(type=i,subtype=rsItemTypes.subtype,siteid=rc.siteID)#"></i> <span> <!--- #application.rbFactory.getKeyValue(session.rb,"sitemanager.add#lcase(i)#")#/ --->#rsItemTypes.subType#</span></a>
									</li>
								</cfif>
							</cfif>
						</cfloop>
					</cfif>
				</cfloop>
				<cfelseif rc.moduleid eq '00000000000000000000000000000000099'>
					<cfloop list="Folder,File" index="i">
						<cfquery name="rsItemTypes" dbtype="query">
							select * from rsSubTypes 
							where lower(type)='#lcase(i)#' and lower(subtype) = 'default'
						</cfquery>
						<cfif not rsItemTypes.recordcount or rsItemTypes.recordcount and (rsItemTypes.adminonly neq 1 or (
							rc.$.currentUser().isAdminUser()
							or rc.$.currentUser().isSuperUser()
							))>
							<cfif not len($availableSubTypes) or listFindNoCase($availableSubTypes,'#i#/Default')>
								<li class="new#i#">
									<cfif len(rsItemTypes.description)>
										<a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a>
									</cfif>
									<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=#esapiEncode('url',rc.moduleid)#&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="new#i#Link"><i class="#$.iconClassByContentType(type=i,subtype='default',siteid=rc.siteid)#"></i> <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.add#lcase(i)#")#</span></a>
								</li>
							</cfif>
						</cfif>
						<cfif i eq 'Variation'>
							<cfquery name="rsItemTypes" dbtype="query">
							select * from rsSubTypes where lower(type)='#lcase(i)#' and lower(subtype) != 'default'
							<cfif not (
									rc.$.currentUser().isAdminUser()
									or rc.$.currentUser().isSuperUser()
									)>
									and adminonly !=1
								</cfif>
							</cfquery>
							<cfloop query="rsItemTypes">
								<cfif not len($availableSubTypes) or listFindNoCase($availableSubTypes,'#i#/#rsItemTypes.subType#')>
									<cfset output = $.renderEvent('on#i##rsItemTypes.subType#NewContentMenuRender')>
									<cfif len(output)>
										#output#
									<cfelse>
										<li class="new#i#">
											<cfif len(rsItemTypes.description)><a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a></cfif>
											<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&subType=#rsItemTypes.subType#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=#esapiEncode('url',rc.moduleid)#&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="new#i#Link"><i class="#$.iconClassByContentType(type=i,subtype=rsItemTypes.subtype,siteid=rc.siteID)#"></i> <span> <!--- #application.rbFactory.getKeyValue(session.rb,"sitemanager.add#lcase(i)#")#/ --->#rsItemTypes.subType#</span></a>
										</li>
									</cfif>
								</cfif>
							</cfloop>
						</cfif>
					</cfloop>
					<cfif application.configBean.getValue(property='allowmultiupload',defaultValue=true) and not len($availableSubTypes) or listFindNoCase($availableSubTypes,'File/Default')>
						<li class="newGalleryItemMulti">
							<!---<a href="##" rel="tooltip" data-original-title="Description goes here."><i class="mi-question-circle"></i></a>--->
							<a href="./?muraAction=cArch.multiFileUpload&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=File&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=00000000000000000000000000000000000&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="newGalleryItemMultiLink"><i class="#$.iconClassByContentType(type='Quick',subtype='default',siteid=rc.siteid)#"></i> <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.addmultiitems")#</span></a>
						</li>
					</cfif>
			<!--- all other types (standard content) --->
			<cfelseif rc.ptype neq 'Gallery'>
				<cfloop list="#typeList#" index="i">
					<cfquery name="rsItemTypes" dbtype="query">
						select * from rsSubTypes where lower(type)='#lcase(i)#' and lower(subtype) = 'default'
					</cfquery>
					<cfif not rsItemTypes.recordcount or rsItemTypes.recordcount and (rsItemTypes.adminonly neq 1 or (
						rc.$.currentUser().isAdminUser()
						or rc.$.currentUser().isSuperUser()
						))>
						<cfif not len($availableSubTypes) or listFindNoCase($availableSubTypes,'#i#/Default')>
							<cfquery name="rsSubTemplates" dbtype="query">
								select * from rsTemplates where lower(type)='#lcase(i)#' and lower(subtype) = 'default'
							</cfquery>							
							<li class="new#i#<cfif rsSubTemplates.recordcount> template-parent</cfif>">
								<cfif len(rsItemTypes.description)>
									<a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a>
								</cfif>
								<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=00000000000000000000000000000000000&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="new#i#Link"><i class="#$.iconClassByContentType(type=i,subtype='default',siteid=rc.siteid)#"></i> <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.add#lcase(i)#")#</span></a>
							</li>
								<cfloop query="#rsSubTemplates#">
									<li class="new#i# template-link">
										<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=00000000000000000000000000000000000&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#&templateid=#rsSubTemplates.contentID#" target="_top" id="newTemplateLink#rsSubTemplates.filename#"><i class="#$.iconClassByContentType(type=i,subtype='default',siteid=rc.siteid)#"></i> <span>Template: #rsSubTemplates.title#</span></a>
								</li>
								</cfloop>
						</cfif>
					</cfif>
					<cfquery name="rsItemTypes" dbtype="query">
					select * from rsSubTypes where lower(type)='#lcase(i)#' and lower(subtype) != 'default'
					<cfif not (
							rc.$.currentUser().isAdminUser()
							or rc.$.currentUser().isSuperUser()
							)>
							and adminonly !=1
						</cfif>
					</cfquery>
					<cfloop query="rsItemTypes">
						<cfif not len($availableSubTypes) or listFindNoCase($availableSubTypes,'#i#/#rsItemTypes.subType#')>
							<cfset output = $.renderEvent('on#i##rsItemTypes.subType#NewContentMenuRender')>
							<cfif len(output)>
								#output#
							<cfelse>
								<cfquery name="rsSubTemplates" dbtype="query">
									select * from rsTemplates where lower(type)='#lcase(i)#' and lower(subtype) = '#rsItemTypes.subType#'
								</cfquery>
								<li class="new#i#<cfif rsSubTemplates.recordcount> template-parent</cfif>">
									<cfif len(rsItemTypes.description)><a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a></cfif>
									<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&subType=#rsItemTypes.subType#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=00000000000000000000000000000000000&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="new#i#Link"><i class="#$.iconClassByContentType(type=i,subtype=rsItemTypes.subtype,siteid=rc.siteID)#"></i> <span> <!--- #application.rbFactory.getKeyValue(session.rb,"sitemanager.add#lcase(i)#")#/ --->#rsItemTypes.subType#</span></a>
								</li>

								<cfloop query="#rsSubTemplates#">
									<li class="new#i# template-link">
									<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=#i#&subType=#rsItemTypes.subType#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=00000000000000000000000000000000000&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#&templateid=#rsSubTemplates.contentID#" target="_top" id="newTemplateLink#rsSubTemplates.filename#"><i class="#$.iconClassByContentType(type=i,subtype=rsItemTypes.subtype,siteid=rc.siteID)#"></i> <span>Template: #rsSubTemplates.title#</span></a>
								</li>
								</cfloop>
							</cfif>
						</cfif>
					</cfloop>
				</cfloop>
				<cfif application.configBean.getValue(property='allowmultiupload',defaultValue=true) and not len($availableSubTypes) or listFindNoCase($availableSubTypes,'File/Default')>
					<li class="newGalleryItemMulti">
						<!---<a href="##" rel="tooltip" data-original-title="Description goes here."><i class="mi-question-circle"></i></a>--->
						<a href="./?muraAction=cArch.multiFileUpload&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=File&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=00000000000000000000000000000000000&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="newGalleryItemMultiLink"><i class="#$.iconClassByContentType(type='Quick',subtype='default',siteid=rc.siteid)#"></i> <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.addmultiitems")#</span></a>
					</li>
				</cfif>
			<cfelse>
				<cfquery name="rsItemTypes" dbtype="query">
					select * from rsSubTypes where lower(type)='file' and lower(subtype) != 'default'
					<cfif not (
						rc.$.currentUser().isAdminUser()
						or rc.$.currentUser().isSuperUser()
						)>
						and adminonly !=1
					</cfif>
				</cfquery>
				<cfif not len($availableSubTypes) or listFindNoCase($availableSubTypes,'File/Default')>
					<li class="newGalleryItem">
						<cfif len(rsItemTypes.description)><a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a></cfif>
						<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=File&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=00000000000000000000000000000000000&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="newGalleryItemLink"><i class="#$.iconClassByContentType(type='GalleryItem',subtype='default',siteid=rc.siteid)#"></i> <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.addgalleryitem")#</span></a>
					</li>
				</cfif>
				<cfloop query="rsItemTypes">
					<cfif not len($availableSubTypes) or listFindNoCase($availableSubTypes,'File/#rsItemTypes.subType#')>
						<cfset output = $.renderEvent('onFile#rsItemTypes.subType#NewContentMenuRender')>
						<cfif len(output)>
							#output#
						<cfelse>
							<li class="newFile">
								<cfif len(rsItemTypes.description)>
									<a href="##" rel="tooltip" data-original-title="#esapiEncode('html_attr',rsItemTypes.description)#"><i class="mi-question-circle"></i></a>
								</cfif>
								<a href="./?muraAction=cArch.edit&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=File&subType=#rsItemTypes.subType#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=00000000000000000000000000000000000&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="newGalleryItem"><i class="#$.iconClassByContentType(type='GalleryItem',subtype='default',siteid=rc.siteid)#"></i> <span><!--- #application.rbFactory.getKeyValue(session.rb,"sitemanager.addgalleryItem")#/ --->#rsItemTypes.subType#</span></a>
							</li>
						</cfif>
					</cfif>
				</cfloop>
				<cfif application.configBean.getValue(property='allowmultiupload',defaultValue=true) and not len($availableSubTypes) or listFindNoCase($availableSubTypes,'File/Default')>
					<li class="newGalleryItemMulti">
						<!---<a href="##" rel="tooltip" data-original-title="Description goes here."><i class="mi-question-circle"></i></a>--->
						<a href="./?muraAction=cArch.multiFileUpload&contentid=&parentid=#esapiEncode('url',rc.contentid)#&parenthistid=#esapiEncode('url',rc.contenthistid)#&type=File&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteID)#&moduleid=00000000000000000000000000000000000&ptype=#esapiEncode('url',rc.ptype)#&frontend=#esapiEncode('url',rc.compactDisplay)#" target="_top" id="newGalleryItemMultiLink"><i class="#$.iconClassByContentType(type='Quick',subtype='default',siteid=rc.siteid)#"></i> <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.addmultiitems")#</span></a>
					</li>
				</cfif>
			</cfif>
			</ul>
		</div>
	</div>
</div>

#$.renderEvent('onNewContentMenuRender')#

</cfoutput>

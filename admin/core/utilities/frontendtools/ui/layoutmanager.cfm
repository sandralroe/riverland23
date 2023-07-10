<cfsilent>
	<cfset hasModuleTemplateAccess=$.currentUser().isSuperUser() or $.currentUser().isAdminUser() or $.getBean('permUtility').getModulePerm('00000000000000000000000000000000017',session.siteid)>
	<cfset contentRendererUtility=$.getBean('contentRendererUtility')>
	<cfset displayObjects=Mura.siteConfig('displayObjects')>
	<cfset customTemplates=Mura.getFeed('moduleTemplate').getIterator()>
	<cfset objectKeys=listSort(structKeylist(displayObjects),'textNoCase')>
	<!--- add priority object to front of list (inverse order) --->
	<cfset priorityObjects = "collection,cta,form,image,text,container">
	<cfloop list="#priorityObjects#" index="pkey">
		<cfset listPos = listFind(objectKeys,pkey)>
		<cfif listPos gt 0>
			<cfset objectKeys = listDeleteAt(objectKeys,listFind(objectKeys,pkey))>
			<cfset objectKeys = listPrepend(objectKeys,pkey)>
		</cfif>
	</cfloop>
	<cfparam name="session.rb" default="en">
</cfsilent>

<cfoutput>
	<div id="mura-sidebar-container" class="mura" style="display:none">

		<div class="mura__layout-manager__controls">
			<div class="mura__layout-manager__controls__scrollable">
				<div class="mura__layout-manager__controls__objects">
					<div id="mura-sidebar-objects" class="mura-sidebar__objects-list">
					 	<div class="mura-sidebar__objects-list__object-group">
							<div class="mura-sidebar__objects-list__object-group-heading">
								<h1><i class="mi-th"></i>#application.rbFactory.getKeyValue(session.rb,'sitemanager.editlayout')#</h1>
								<i class="mi-close mura-input-icon mura-clear" id="mura-filter-objects-clear" data-clear="mura-filter-objects" style="display: none;"></i>
								<input type="text" id="mura-filter-objects" placeholder="Filter" class="mura-sidebar__filter">
							</div>
							<div class="mura-sidebar__objects-list__object-group-items">					
								<div class="mura-panel-group" id="module-list-panels" role="tablist" aria-multiselectable="true">
									<!--- panel 1 --->
									<div class="mura-panel">
										<div class="mura-panel-heading" role="tab" id="heading-modules-list">
											<h4 class="mura-panel-title">
												<a class="mura-collapse mura-collapsed" role="button" data-toggle="mura-collapse" data-parent="module-list-panels" href="##panel-modules-list" aria-expanded="true" aria-controls="panel-modules-list"><i class="mi-th"></i>Modules</a>
											</h4>
										</div>
									    <div id="panel-modules-list" class="mura-panel-collapse mura-collapse" role="tabpanel" aria-labelledby="heading-modules-list">
											<div class="mura-panel-body">
												<cfloop list="#objectKeys#" index="key">
													<cftry>
														<cfif (displayobjects['#key#'].contenttypes eq '*'
															or listFindNoCase(displayobjects['#key#'].contenttypes,variables.Mura.content('type'))
															or listFindNoCase(displayobjects['#key#'].contenttypes,variables.Mura.content('type') & '/' & variables.Mura.content('subtype'))
															or listFindNoCase(displayobjects['#key#'].contenttypes,variables.Mura.content('subtype'))
														) and not (
															 listFindNoCase(displayobjects['#key#'].omitcontenttypes,variables.Mura.content('type'))
															or listFindNoCase(displayobjects['#key#'].omitcontenttypes,variables.Mura.content('type') & '/' & variables.Mura.content('subtype'))
															or listFindNoCase(displayobjects['#key#'].omitcontenttypes,variables.Mura.content('subtype'))
														)
														and evaluate(displayobjects['#key#'].condition)>
															#contentRendererUtility.renderObjectClassOption(
																object=displayObjects[key].object,
																objectid='',
																objectname=displayObjects[key].name,
																objecticonclass=displayObjects[key].iconclass
															)#
														</cfif>
														<cfcatch>
																<cfset writeLog(type="Error", file="exception", text="Error rendering display object as option in sidebar: #serializeJSON(displayObjects[key])#")>
														</cfcatch>	
													</cftry>
												</cfloop>

											</div>
										</div>
									</div> <!--- /end panel 1 --->

									<!--- panel 2 --->
									<div class="mura-panel">
										<div class="mura-panel-heading" role="tab" id="heading-module-templates">
											<h4 class="mura-panel-title">
												<a class="mura-collapse mura-collapsed" role="button" data-toggle="mura-collapse" data-parent="module-list-panels" href="##panel-module-templates" aria-expanded="false" aria-controls="panel-module-templates"><i class="mi-tasks"></i>Module Templates</a>
											</h4>
										</div>
										<div id="panel-module-templates" class="mura-panel-collapse mura-collapse" role="tabpanel" aria-labelledby="heading-module-templates">
											<div class="mura-panel-body">
												<cfif customTemplates.hasNext()>
													<cfloop condition="customTemplates.hasNext()">
														<cfset moduleTemplate=customTemplates.next()>
														<cftry>
															<cfset params=deserializeJSON(moduleTemplate.get('params'))>				
															#contentRendererUtility.renderObjectCustomOption(
															params=moduleTemplate.get('params'),
															object=params.object,
															objectid=moduleTemplate.get('templateid'),
															objectname=params.objectname,
															objectlabel=moduleTemplate.get('name'),
															objecticonclass="mi-square-o",
															hasModuleTemplateAccess=hasModuleTemplateAccess
															)#
															<cfcatch>
																<cfset Mura.logError(cfcatch)>
															</cfcatch>
														</cftry>

													</cfloop>
												</cfif>		
											</div>
										</div>
									</div> <!--- /end panel 2 --->

									<cfif not variables.Mura.siteConfig('isremote') and (variables.Mura.content('type') neq 'Variation' and
									listLen(request.muraActiveRegions) lt variables.Mura.siteConfig('columnCount') || request.muraAPIRequest)>	
										<!--- panel 3 --->
										<div class="mura-panel">
											<div class="mura-panel-heading no-panel" role="tab" id="heading-addl-regions">
												<h4 class="mura-panel-title">
													<a id="mura-objects-openregions-btn" data-parent="module-list-panels" href="##panel-addl-regions"><i class="mi-columns"></i>#application.rbFactory.getKeyValue(session.rb,'sitemanager.additionaldisplayregions')#</a>
												</h4>
											</div>
										</div> <!--- /end panel 3 --->
									</cfif> 

									<cfif variables.Mura.content('type') neq 'Variation' and
									this.legacyobjects>	
										<!--- panel 4 --->
										<div class="mura-panel">
											<div class="mura-panel-heading no-panel" role="tab" id="heading-legacy-objects">
												<h4 class="mura-panel-title">
													<a id="mura-objects-legacy-btn" data-parent="module-list-panels" href="##panel-legacy-objects"><i class="mi-object-ungroup"></i>#application.rbFactory.getKeyValue(session.rb,'sitemanager.legacyobjects')#</a>
												</h4>
											</div>
										</div> <!--- /end panel 4 --->
									</cfif> 

								</div> <!--- /.mura-panel-group --->												
							</div> <!--- /.mura-sidebar__objects-list__object-group-items --->

						</div> <!--- /.mura-sidebar__objects-list__object-group --->
					</div> <!--- /mura-sidebar-objects --->

					<cfif variables.Mura.content('type') neq 'Variation' and this.legacyobjects>
						<div id="mura-sidebar-objects-legacy" class="mura-sidebar__objects-list" style="display:none">
							<div class="mura-sidebar__objects-list__object-group">
								<div class="mura-sidebar__objects-list__object-group-heading">
									<button class="mura-objects-back-btn btn btn-secondary">
										<i class="mi-arrow-left"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.back')#
									</button>
									<h3>#application.rbFactory.getKeyValue(session.rb,'sitemanager.legacyobjects')#</h3>
								</div>
								<div class="mura-sidebar__objects-list__object-group-items controls">
									<select name="classSelector" onchange="mura.loadObjectClass('#esapiEncode("Javascript",variables.Mura.content('siteid'))#',this.value,'','#variables.Mura.content('contenthistid')#','#variables.Mura.content('parentid')#','#variables.Mura.content('contenthistid')#',0);">
									<option value="">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectobjecttype')#</option>
						            <cfif application.settingsManager.getSite(variables.Mura.event('siteid')).getemailbroadcaster()>
						                <option value="mailingList">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.mailinglists')#</option>
						            </cfif>
					                <cfif application.settingsManager.getSite(variables.Mura.event('siteid')).getAdManager()>
					                  <option value="adzone">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.adregions')#</option>
					                </cfif>
					                <!--- <option value="category">Categories</option> --->
					                <option value="folder">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.folders')#</option>
					                <option value="calendar">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.calendars')#</option>
					                <option value="gallery">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.galleries')#</option>
					                <cfif application.settingsManager.getSite(variables.Mura.event('siteid')).getHasfeedManager()>
					                  <option value="localFeed">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.localindexes')#</option>
					                  <option value="slideshow">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.localindexslideshows')#</option>
					                  <option value="remoteFeed">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remotefeeds')#</option>
					                </cfif>
					              </select>

								</div> <!--- .mura-sidebar__objects-list__object-group --->
							</div>

							<div id="classListContainer" class="mura-sidebar__objects-list__object-group" style="display:none">
								<div class="mura-sidebar__objects-list__object-group-heading">
									#application.rbFactory.getKeyValue(session.rb,'sitemanager.selectobject')#
								</div>
								<div class="mura-sidebar__object-group-items" id="classList"></div>
							</div>

						</div> <!--- /mura-sidebar-objects-legacy --->
					</cfif>

					<div id="mura-sidebar-configurator" style="display:none">
						<iframe src="" data-preloadsrc="#variables.Mura.siteConfig().getAdminPath(complete=completeurls)#?muraAction=carch.frontendconfigurator&siteid=#variables.Mura.content('siteid')#&preloadOnly=true&layoutmanager=true&compactDisplay=true&cacheid=#createUUID()#" id="frontEndToolsSidebariframe" scrolling="false" frameborder="0" style="overflow:hidden;width:100%; min-height:320px;" name="frontEndToolsSidebariframe">
						</iframe>
					</div> <!--- /mura-sidebar-configurator --->

					<div id="mura-sidebar-editor" style="display:none">

						<div class="mura-sidebar__objects-list__object-group">
							<div class="mura-sidebar__objects-list__object-group-heading">
								<div class="clearfix">
									<h3>#application.rbFactory.getKeyValue(session.rb,'sitemanager.editingcontent')#</h3>
								</div>
								<div class="form-actions">
									<button class="mura-objects-back-btn btn mura-primary" id="mura-deactivate-editors"><i class="mi-check"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.done')#</button>
								</div>
							</div>
						</div>

						<div id="classListContainer" class="mura-sidebar__objects-list__object-group" style="display:none">
							<div class="mura-sidebar__objects-list__object-group-heading">
								#application.rbFactory.getKeyValue(session.rb,'sitemanager.selectobject')#
							</div>
							<div class="mura-sidebar__object-group-items" id="classList"></div>
						</div>
					</div> <!--- /mura-sidebar-editor --->
				</div> <!--- /.mura__layout-manager__controls__objects --->
			</div> <!--- /.mura__layout-manager__controls__scrollable --->
		</div> 	<!--- /.mura__layout-manager__controls --->

		<cfif not variables.Mura.siteConfig('isremote') and ( listLen(request.muraActiveRegions) lt variables.Mura.siteConfig('columnCount') || request.muraAPIRequest )>
			<cfset regionNames=variables.Mura.siteConfig('columnNames')>
			<cfset regionCount=variables.Mura.siteConfig('columnCount')>

			<!--- additional regions flyout ui --->
			<div class="mura__layout-manager__display-regions">
				<div class="mura__layout-manager__display-regions__X">
					<p><button id="mura-objects-closeregions-btn" class="btn mura-primary">Done <i class="mi-angle-right"></i></button><p>
					<h3>Additional Display Regions</h3>
					<cfloop from="1" to="#regionCount#" index="r">
						<cfif (not listFind(request.muraActiveRegions,r) || request.muraAPIRequest) and listLen(regionNames,'^') gte r>
							<div class="mura-region__item" data-regionid="#r#">
								<h4>#esapiEncode('html',listGetAt(regionNames,r,'^'))#</h4>
								#$.dspObjects(columnid=r,allowInheritance=false)#
							</div>
						</cfif>
					</cfloop>
				</div>
			</div> <!--- /.mura__layout-manager__display-regions --->
		</cfif>

</div> <!--- /mura-sidebar-container --->

<script>
Mura(function(){

	Mura("##mura-filter-objects").on("keyup",function(ev) {
		setTimeout(function(){

			var filter = Mura("##mura-filter-objects").val(); 
			if(filter.length) {
				Mura("##mura-filter-objects-clear").show();
				Mura("[data-filtername]","##mura-sidebar-objects").hide();
				Mura( "[data-filtername*='"+filter.toLowerCase()+"']" ).each(function( index ) {
					Mura( index ).show();
					Mura( index ).parent().parent().parent().find('a.mura-collapse.mura-collapsed').trigger('click');
				});
			}
			else {
				Mura("##mura-filter-objects-clear").hide();
				Mura("[data-filtername]").show();
			}
			sessionStorage.setItem('mura_modulepanelfilter', filter);

		},'100');

	});

	// set value of filter on load
	var filterStr = sessionStorage.getItem('mura_modulepanelfilter');
	if (filterStr !== null){
		Mura("##mura-filter-objects").val(filterStr).trigger("keyup");
	}

	Mura("##mura-filter-objects-clear").on("click",function(ev){
		var clr = Mura(this).attr('data-clear');
		Mura('##' + clr).val('').trigger('keyup');
		return false;
	})

	Mura(".mura-sidebar__objects-list .mura-customtemplate .module-delete-icon").on("click",function(ev) {
		
		var templateid = Mura(this).parent().data('objectid');
		var templateName = Mura(this).parent().text();
		var conf = confirm( 'Permanently delete template "' + templateName + '"?');

		if (conf) {
      Mura.getEntity('moduleTemplate')
				.set('id',templateid)
				.delete();
			Mura(this).parent().remove();
		}
	});
	
	if(typeof Mura.deInitLayoutManager != 'undefined'
		&& typeof Mura.editing != 'undefined'
		&& Mura.editing){
			Mura.deInitLayoutManager();
	}
	Mura.loader().load('#variables.Mura.siteConfig().getAdminPath(complete=completeurls)#/dist/layoutmanager.bundle.js?coreversion=#application.coreversion#',
		function(){
			<cfif variables.Mura.content('type') eq 'Variation' and isBoolean(variables.Mura.content('notsaved')) and variables.Mura.content('notsaved')>
			if(!Mura('.mxp-editable').length){
				Mura('##adminQuickEdit').remove();
				Mura('##adminFullEdit').remove();
				Mura('##mura-edit-var-initjs').remove();
			}
			</cfif>
			Mura('body').addClass('mura-sidebar-state__hidden--right');
			Mura('body').removeClass('mura-sidebar-state__pushed--right');
			Mura('##mura-sidebar-container').show();
			Mura('##mura-objects-legacy-btn').click(function(e){
				e.preventDefault();
				MuraInlineEditor.sidebarAction('showlegacyobjects');
			});
			Mura('##mura-objects-openregions-btn').click(function(e){
				e.preventDefault();
				var el=Mura('body');
				if(el.hasClass('mura-regions-state__pushed--right')){
					el.removeClass('mura-regions-state__pushed--right');
				} else {
					el.addClass('mura-regions-state__pushed--right');
				}
			});
			Mura('##mura-objects-closeregions-btn').click(function(e){
				e.preventDefault();
				Mura('body').removeClass('mura-regions-state__pushed--right');
			});
			Mura('.mura-objects-back-btn').click(function(e){
				e.preventDefault();
				MuraInlineEditor.sidebarAction('showobjects');
			});
			Mura.rb.saveasdraft='#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.saveasdraft"))#';
			Mura.adminpath='#variables.Mura.siteConfig().getAdminPath(complete=completeurls)#';
			
			<cfif isBoolean(variables.Mura.event('editlayout')) and variables.Mura.event('editlayout')>
				function initInlineEditor(){
					if(typeof window.MuraInlineEditor !== "undefined"){
						window.MuraInlineEditor.init();
					}
					else{
						setTimeout(initInlineEditor, 10);
					}
				}
				
				initInlineEditor();
			</cfif>
		});

	/* mura-panel-group */
	// hide on load
	Mura ('.mura-panel-group .mura-panel-collapse').hide();
	// toggle on click
	Mura('.mura-panel-title a').click(function(e){
		var targetPanel = '.mura-panel-group  ##' + Mura(this).attr('aria-controls');
		if (Mura(this).hasClass('mura-collapsed')){
			Mura(targetPanel).fadeIn().removeClass('mura-collapsed');
			Mura(this).removeClass('mura-collapsed').addClass('in');
		} else {
			Mura(targetPanel).fadeOut().addClass('mura-collapsed');
			Mura(this).addClass('mura-collapsed').removeClass('in');
		}
		setTimeout(function(){
			setModulePanelStates('module-list-panels');
		},500);	

		e.preventDefault();
		return false;
	});

	/* persist panel selections */
	function setModulePanelStates(panelGroupID){
		var panelStates = [];
		var panelStr = '';
		var panelArr = Mura('##' + panelGroupID).find('.mura-panel-heading:not(.no-panel)');
		panelArr.each(function(el){
			var pID  = Mura(el).attr('id');
			var pLink  = Mura(el).find('a.mura-collapse.in'); 
			if (pLink.length){
				panelStates.push(pID);
			}
		});
		
		panelStr = JSON.stringify(panelStates);
		sessionStorage.setItem('mura_modulepanelstate', panelStr);
	}

	/* show from saved state */
	function getModulePanelStates(panelGroupID){
		var data = Mura.readCookie('mura_modulepanelstate');
		var data = sessionStorage.getItem('mura_modulepanelstate');
		var panelStates = [];

		if (data !== null){
			panelStates = JSON.parse(data);
		} else {
			panelStates = ["heading-modules-list"];
		}

		panelStates.forEach(function(str){
			Mura('##' + str).find('a.mura-collapse').trigger("click");
		});
	}

	// run on load
	getModulePanelStates();

});
</script>
</cfoutput>
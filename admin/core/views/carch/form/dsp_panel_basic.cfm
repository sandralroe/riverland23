<!--- license goes here --->
<cfset started=false>
<cfset tabList=listAppend(tabList,"tabBasic")>

<!--- AltURLs --->
<!--- Load up redirect iterator --->
<cfset altURLit = $.content().getalturlIterator() />
<!--- Set up helper to display path --->
<cfset httpProtocol = len(cgi.https) ? 'https://' : 'http://' />
<cfset altURLHelper = httpProtocol & application.Mura.getBean('utility').getRequestHost() & '/' />
<!--- Begin check for ismuracontent --->
<!--- set isMuraContentCheck variable to set radio buttons --->
<cfset isMuraContentCheck = 0 />
<!--- we need to check the redirect iterator for the value of ismuracontent
			there can only be one redirect to Mura Content so we don't need to loop to get the 1 or 0
 --->
<cfif isObject(altURLit)>
	<cfif altURLit.hasNext()>
		<cfset muracheck = altURLit.next()>
		<cfif muracheck.get('ismuracontent') >
			<cfset isMuraContentCheck = 1 />
		</cfif>
	</cfif>
	<!--- reset the iterator for use below. --->
	<cfset altURLit.reset() />
</cfif>
<!--- /end AltURLs --->

<cfoutput>
<script>
	function showPreview(){
		<cfif rc.preview eq 1>
			if(!previewLaunched){
		<cfif listFindNoCase("File",rc.type)>
			preview('#rc.contentBean.getURL(secure=rc.$.getBean("utility").isHTTPs(),complete=1,queryString="previewid=#rc.contentBean.getcontenthistid()#",useEditRoute=true)#');
		<cfelse>
			preview('#rc.contentBean.getURL(secure=rc.$.getBean("utility").isHTTPs(),complete=1,queryString="previewid=#rc.contentBean.getcontenthistid()#",useEditRoute=true)#');
		</cfif>
			previewLaunched=true;
			}
		</cfif>
	}
</script>
<div class="mura-panel" id="tabBasic">
	<div class="mura-panel-heading" role="tab" id="heading-basic">
		<h4 class="mura-panel-title">
			<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##content-panels" href="##panel-basic" aria-expanded="true" aria-controls="panel-basic">#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.basic")#</a>
		</h4>
	</div>
	<div id="panel-basic" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-basic" aria-expanded="false" style="height: 0px;">
		<div class="mura-panel-body">

				<span id="extendset-container-tabbasictop" class="extendset-container"></span>

				<!--- type/subtype --->
				<cfinclude template="dsp_type_selector.cfm">

				<!--- title --->
				<cfswitch expression="#rc.type#">
					<cfcase value="Page,Folder,Calendar,Gallery,File,Link">
						<div class="mura-control-group">
							<label>
						    	<span data-toggle="popover" title="" data-placement="right"
						    	data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"tooltip.pageTitle"))#"
						    	data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.title"))#"
						    	>
						    	#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.title")# <i class="mi-question-circle"></i></span>
						    </label>
							<input type="text" id="title" name="title" value="#esapiEncode('html_attr',rc.contentBean.gettitle())#"  maxlength="255" required="true" message="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.titlerequired')#" <cfif not rc.contentBean.getIsNew()>onkeypress="openDisplay('editAdditionalTitles','#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.close')#');"</cfif>>
							<!--- title --->
							<div id="alertTitleSuccess" class="help-block" style="display:none;">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.seotitlescleared')# </div>

								<div class="help-block" id="editAdditionalTitles" style="display:none;">
									<p>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.AdditionalTitlesnote")#</p><br />
									<button type="button" id="resetTitles" name="resetTitles" class="btn">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.clearseotitles')#</button>
								</div>

						 </div>

							<div class="mura-control-group">
								<div id="mura-seo-titles">
									<label class="help-block-title">Additional Titles (optional)</label>
									<div class="help-block">
										<div class="mura-control-group">
											<label>
										  	<span data-toggle="popover" title="" data-placement="right"
										    	data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"tooltip.navigationTitle"))#"
										    	data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.menutitle"))#"
										    	>
										    				#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.menutitle")#
											 <i class="mi-question-circle"></i>
											</span>
											</label>
											<input type="text" id="menuTitle" name="menuTitle" value="#esapiEncode('html_attr',rc.contentBean.getmenuTitle())#"  maxlength="255">
										</div>

										<div class="mura-control-group">
											<label>
										  	<span data-toggle="popover" title="" data-placement="right"
										    	data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"tooltip.urlTitle"))#"
										    	data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.urltitle"))#"
										    	>
										    				#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.urltitle")#
												 <i class="mi-question-circle"></i>
												</span>
											</label>
											<input type="text"   id="urlTitle" name="urlTitle" value="#esapiEncode('html_attr',rc.contentBean.getURLTitle())#"  maxlength="255">
											<input type="hidden" id="urlTitleHidden" value="#esapiEncode('html_attr',rc.contentBean.getmenuTitle())#">
										</div>

										<div class="mura-control-group">
											<label>
										  	<span data-toggle="popover" title="" data-placement="right"
										    	data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"tooltip.htmlTitle"))#"
										    	data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.htmltitle"))#"
										    	>
										    				#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.htmltitle")#
												 <i class="mi-question-circle"></i>
												</span>
											</label>
											<input type="text" id="htmlTitle" name="htmlTitle" value="#esapiEncode('html_attr',rc.contentBean.getHTMLTitle())#"  maxlength="255">
										</div>
									</div>

								</div><!-- /mura-seo-titles -->
						</div>
					</cfcase>
					<cfdefaultcase>
						<div class="mura-control-group">
				      		<label>
			      				#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.title')#
			      			</label>
				     		<input type="text" id="title" name="title" value="#esapiEncode('html_attr',rc.contentBean.getTitle())#"  maxlength="255" required="true" message="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.titlerequired')#"<cfif rc.contentBean.getIsLocked()> disabled="disabled"</cfif>>
			     		 	<input type="hidden" id="menuTitle" name="menuTitle" value="">
			     		</div>
					</cfdefaultcase>
				</cfswitch>
				<!--- /title --->

				<cfif listFindNoCase("Page,Folder,Calendar,Gallery,File,Link",rc.type)>
				<!--- AltURLs --->
				<div class="mura-control-group">
					<label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.urlredirection'))#</label>
					<div class="mura-control justify">
						
						<div class="bigui__preview">
							<div id="alturls__selected"></div>
						</div>
						<!--- 'big ui' flyout panel --->
						<div class="bigui" id="bigui__alturl" data-label="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.manageredirects'))#">
							<div class="bigui__title">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.alternateurldirection'))#</div>
							<div class="bigui__controls">

								<div class="mura-control-group">
									<label>
										<span data-toggle="popover" title="" data-placement="right" data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.definemultipleurl'))#" data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.alternateurldirection'))#">
									#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.urldirection'))# <i class="mi-question-circle"></i></span>
									</label>
									<div class="radio-group">
										<label for="isMura" class="radio">
											<input type="radio" name="ismuracontent" id="isMura" <cfif isMuraContentCheck eq 1>checked</cfif> value="1">
										#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.redirect'))#
										</label>
										<label for="notMura" class="radio">
											<input type="radio" name="ismuracontent" id="notMura" <cfif isMuraContentCheck eq 0>checked</cfif> value="0">
										#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.allowalternative'))#
										</label>
									</div>
								</div>
								<cfif isObject(altURLit)>
								<div class="mura-control-group">
									<div class="input_fields_wrap">
										<cfif altURLit.hasNext()>
											<cfloop condition="altURLit.hasNext()">
												<cfset item = altURLit.next() />
												<div class="mura-control-group <cfif altURLit.getCurrentIndex() eq 1>first</cfif>">
													<span>#altURLHelper#</span>
													<input type="text" class="alturl-input" name="alturl_#item.get('alturlid')#" value="#item.get('alturl')#" placeholder="url-here">
													<span class="altstatuscode">
														<select class="altstatuscode" name="altstatuscode_#item.get('alturlid')#">
															<option value="301"<cfif item.get('statuscode') eq 301> selected</cfif>>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.permanent'))# (301)</option>
															<option value="302"<cfif item.get('statuscode') eq 302> selected</cfif>>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.temporary'))# (302)</option>
															<option value=""<cfif not listFind('301,302',item.get('statuscode'))> selected</cfif>>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.noredirection'))#</option>
														</select>
														<cfif altURLit.getCurrentIndex() gt 1>
															<button class="btn remove_field" title="Remove Alternate URL">
																<i class="fa fa-trash"></i>
															</button>
														</cfif>
													</span>
												</div>
											</cfloop>
										<cfelse>
											<cfset newid=createUUID()>
											<div class="mura-control-group first">
												<span>#altURLHelper#</span>
												<input type="text" class="alturl-input" name="alturl_#newid#" placeholder="url-here">
												<span class="altstatuscode">
													<select  name="altstatuscode_#newid#">
														<option value="301">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.permanent'))# (301)</option>
														<option value="302">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.temporary'))# (302)</option>
														<option value="">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.noredirection'))#</option>
													</select>
												</span>
											</div>
										</cfif>
									</div> <!--- /.input_fields_wrap --->

									<input type="hidden" name="numberOfAltURLs" class="numberOfAltURLs" value="1"/>
									<input type="hidden" name="alturluiid" value="#$.content().getContentID()#"/>
								</div> <!--- /.mura-control-group --->
								</cfif>
								<div class="mura-control-group" id="add_field_button_wrapper">
									<label class="sr-only">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.alternateurldirection'))#</label>
									<button class="add_field_button btn"><i class="fa fa-plus"></i> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.addalternateurl'))#</button>
								</div>

							</div> <!--- /.bigui__controls --->
						</div> <!--- /.bigui --->
					</div> <!--- /end mura-control .justify --->
				</div> <!--- /end mura-control-group --->
				<!--- /AltURLs --->
				</cfif>
				<!--- content parent --->
				<cfif ((rc.parentid neq '00000000000000000000000000000000001' and application.settingsManager.getSite(rc.siteid).getlocking() neq 'all') or (rc.parentid eq '00000000000000000000000000000000001' and application.settingsManager.getSite(rc.siteid).getlocking() eq 'none')) and rc.contentid neq '00000000000000000000000000000000001'>
					<cfif application.settingsManager.getSite(rc.siteid).getlocking() neq 'all'>
						<div class="mura-control-group">
			      		<label>
				  			#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.contentparent')#
		      			</label>
		      			<div class="mura-control justify">
			  				<cfif arrayLen(rc.crumbData)>
			  					<div class="bigui__preview">
				  					<div id="newparent-label">
					      			"<span><cfif rc.contentBean.getIsNew() or arrayLen(rc.crumbData) eq 1>#rc.crumbData[1].menutitle#<cfelse>#rc.crumbData[2].menutitle#</cfif></span>"
					  				</div>
			  					</div>
			  				</cfif>

								<!--- 'big ui' flyout panel --->
								<div class="bigui" id="bigui__selectparent" data-label="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectnewparent'))#">
									<div class="bigui__title">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectnewparent'))#</div>
									<div class="bigui__controls">
										<!--- new parent UI gets loaded here --->
								    <span id="mover2" style="display:none"><input type="hidden" name="parentid" value="#esapiEncode('html_attr',rc.parentid)#"></span>
									</div>
								</div> <!--- /.bigui --->

								<script>
									jQuery(document).ready(function(){
										siteManager.loadSiteParents(
											'#esapiEncode('javascript',rc.siteid)#'
											,'#esapiEncode('javascript',rc.contentid)#'
											,'#esapiEncode('javascript',rc.parentid)#'
											,''
											,1
										);

										// populate current parent text when changed
										jQuery(document).on('click', '##mover2 input[name="parentid"]',function(){
											var newparent = jQuery(this).parents('tr').find('ul.navZoom li:last-child').text().trim();
											jQuery('##newparent-label > span').html(newparent);
										})
										jQuery(document).on('click', '##mover2 td.var-width',function(){
											var parentradio = jQuery(this).parents('tr').find('td.actions input[name="parentid"]');
											jQuery(parentradio).trigger('click');
										})
									});
								</script>
							</div> <!--- /end mura-control .justify --->
						</div> <!--- /end mura-control-group --->

					<cfelse>
					 	<input type="hidden" name="parentid" value="#esapiEncode('html_attr',rc.parentid)#">
					</cfif> <!--- /end content parent --->

				<cfelse>
					<input type="hidden" name="parentid" value="#esapiEncode('html_attr',rc.parentid)#">
				</cfif> <!--- /end content parent --->

				<!--- body --->
				<cfif listFindNoCase(rc.$.getBean('contentManager').HTMLBodyList,rc.type)>
					<cfset rsPluginEditor=application.pluginManager.getScripts("onHTMLEdit",rc.siteID)>

						<!--- set up body content --->
						<cfsavecontent variable="bodyContent">

					   <span id="extendset-container-tabprimarytop" class="extendset-container"></span>

							<div id="bodyContainer" class="body-container mura-control-group" style="display:none;">
								<label>
					      	#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.content")#
					      </label>
							<cfif rsPluginEditor.recordcount>
								#application.pluginManager.renderScripts("onHTMLEdit",rc.siteid,pluginEvent,rsPluginEditor)#
							<cfelse>
								<cfif application.configBean.getValue("htmlEditorType") eq "none">
									<textarea name="body" id="body">#esapiEncode('html',rc.contentBean.getBody())#</textarea>
								<cfelseif application.configBean.getValue("htmlEditorType") eq "markdown">
									<div id="body-markdown-wrapper">
										<textarea class="mura-markdown" data-height="calc(100vh - 380px)" name="body" id="body">#esapiEncode('html',rc.contentBean.getBody())#</textarea>
									</div>
									<script>
									hideBodyEditor=function(){	
										jQuery(".body-container").hide();
										jQuery(".no-body-container").show();
										jQuery(".mura-content-body-inner").attr('id','mura-content-body-inner');
									}
									showBodyEditor=function(){
										jQuery(".body-container").show();
										jQuery(".no-body-container").hide();
										jQuery(".mura-content-body-inner").attr('id','');
									}

									jQuery(document).ready(function(){
										<cfif not isExtended>
										showBodyEditor();
										</cfif>
										if (!hasSummary && !hasBody){
											setTimeout(function(){
												showPreview();
											}, 2000);
										}
									});
									</script>
								<cfelse>	
									<textarea name="body" id="body"><cfif len(rc.contentBean.getBody())>#esapiEncode('html',rc.contentBean.getBody())#<cfelse><p></p></cfif></textarea>
									<script type="text/javascript">
									var loadEditorCount = 0;
									<cfif rc.preview eq 1>var previewLaunched= false;</cfif>

									hideBodyEditor=function(){
										if(typeof CKEDITOR.instances.body != 'undefined'){
											CKEDITOR.instances.body.updateElement();
											CKEDITOR.instances.body.destroy();
										}
										jQuery(".body-container").hide();
										jQuery(".no-body-container").show();
										jQuery(".mura-content-body-inner").attr('id','mura-content-body-inner');
									}

									showBodyEditor=function(){
										if(typeof CKEDITOR.instances.body == 'undefined'){
											jQuery(".body-container").show();
											jQuery(".no-body-container").hide();
											jQuery(".mura-content-body-inner").attr('id','');
											jQuery('##body').ckeditor(
											{ toolbar:<cfif rc.type eq "Form">'Form'<cfelse>'Default'</cfif>,
											height:'calc(100vh - 380px)',
											customConfig : 'config.js.cfm'
											},
												function(editorInstance){
													htmlEditorOnComplete(editorInstance);
													showPreview();
													// custom global resize function fits to content window
													resizeBodyEditor();
												}
											);
										}
									}

									jQuery(document).ready(function(){
										<cfif not isExtended>
										showBodyEditor();
										</cfif>
										if (!hasSummary && !hasBody){
											setTimeout(function(){
												showPreview();
											}, 2000);
										}
									});
									</script>
								</cfif>
							</cfif>
						</div>
						<div id="noBodyContainer" class="no-body-container mura-control-group" style="display:none;">
							<cfif listFindNoCase('component,form', rc.type)>
								<div class="block">
								<h2>Content powered by Layout Manager</h2>
								<p>This content type has no editable content body.</p>
								</div>
							<cfelse>
								<cfinclude template="dsp_lm_helper.cfm">
							</cfif>
							
						</div>
						<span id="extendset-container-primary" class="extendset-container"></span>
						<span id="extendset-container-tabprimarybottom" class="extendset-container"></span>
					</cfsavecontent>

				<cfelseif rc.type eq 'Link'>
					<cfsavecontent variable="bodyContent">

			   		<span id="extendset-container-tabprimarytop" class="extendset-container"></span>

					<div class="mura-control-group">
					     <h2>
				      		#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.url")#
				      	</h2>
			     	 	<cfif len(application.serviceFactory.getBean('settingsManager').getSite(session.siteid).getRazunaSettings().getHostname())>
			 	 			<input type="text" id="url" name="body" value="#esapiEncode('html_attr',rc.contentBean.getbody())#" class="text" required="true" message="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.urlrequired')#">
			 	 			<div class="mura-control justify">
			 	 				<div class="mura-input-set">
				 	 				<a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
				     	 				 	<i class="mi-folder-open"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.browseassets')#
				 	 				</a>
				 	 				<ul class="dropdown-menu">
				 	 					<li><a href="##" type="button" data-completepath="false" data-target="body" data-resourcepath="User_Assets" class="mura-file-type-selector mura-finder" title="Select a File from Server">
				     	 						<i class="mi-folder-open"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.local')#</a></li>
				 	 					<li><a href="##" type="button" onclick="renderRazunaWindow('body');return false;" class="mura-file-type-selector btn-razuna-icon" value="URL-Razuna" title="Select a File from Razuna"><i></i> Razuna</a></li>
				 	 				</ul>
				 	 			</div>
			 	 			</div>
						<cfelse>
							<div class="mura-control justify">
								<div class="mura-input-set">
									<input type="text" id="url" name="body" value="#esapiEncode('html_attr',rc.contentBean.getbody())#" class="text mura-5" required="true" message="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.urlrequired')#">
				     	 			<button type="button" data-completepath="false" data-target="body" data-resourcepath="User_Assets" class="btn mura-file-type-selector mura-finder" title="Select a File from Server"><i class="mi-folder-open"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.browseassets')#</button>
					     	 	</div>
				     	 	</div>
						</cfif>

				   <span id="extendset-container-primary" class="extendset-container"></span>
				   <span id="extendset-container-tabprimarybottom" class="extendset-container"></span>

			     	</div>
			     </cfsavecontent>
				<cfelseif rc.type eq 'File'>
					<cfsavecontent variable="bodyContent">
						<cfinclude template="dsp_file_selector.cfm">
					</cfsavecontent>
				<cfelseif rc.type eq 'Variation'>
					<cfsavecontent variable="bodyContent">
						<div id="noBodyContainer" class="no-body-container mura-control-group">
						<cfinclude template="dsp_lm_helper.cfm">
						</div>
					</cfsavecontent>
				</cfif>
				<!--- /end body --->

				<!--- component module assignments --->
				<cfif rc.type eq 'Component'>
					<div class="mura-control-group">
					    <label>
				      		#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.componentassign')#
				      	</label>
						<label for="m1" class="checkbox inline">
							<input name="moduleAssign" type="CHECKBOX" id="m1" value="00000000000000000000000000000000000" <cfif listFind(rc.contentBean.getmoduleAssign(),'00000000000000000000000000000000000') or rc.contentBean.getIsNew()>checked </cfif> class="checkbox"> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.content')#
						</label>

						<label for="m2" class="checkbox inline">
							<input name="moduleAssign" type="CHECKBOX" id="m2" value="00000000000000000000000000000000003" <cfif listFind(rc.contentBean.getmoduleAssign(),'00000000000000000000000000000000003')>checked </cfif> class="checkbox"> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.components')#
						</label>

						<cfif application.settingsManager.getSite(rc.siteid).getdatacollection()>
							<label for="m3" class="checkbox inline">
								<input name="moduleAssign" type="CHECKBOX" id="m3" value="00000000000000000000000000000000004" <cfif listFind(rc.contentBean.getmoduleAssign(),'00000000000000000000000000000000004')>checked </cfif> class="checkbox">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.formsmanager')#
							</label>
						</cfif>

						<cfif application.settingsManager.getSite(rc.siteid).getemailbroadcaster()>
							<label for="m4" class="checkbox inline">
								<input name="moduleAssign" type="CHECKBOX" id="m4"  value="00000000000000000000000000000000005" <cfif listFind(rc.contentBean.getmoduleAssign(),'00000000000000000000000000000000005')>checked </cfif> class="checkbox"> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.emailbroadcaster')#
							</label>
						</cfif>
					</div>
				</cfif>

				<!--- form confirmation, sendto --->
				<cfif rc.type eq 'Form'>
					<cfif application.configBean.getValue(property='formpolls',defaultValue=false)>
					<div class="mura-control-group">
						<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.formpresentation')#</label>
						<label for="rc" class="checkbox">
							<input name="responseChart" type="CHECKBOX" value="1" <cfif rc.contentBean.getresponseChart() eq 1>checked </cfif> class="checkbox"> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.ispoll')#
						</label>
						</div>
					</cfif>
					<div class="mura-control-group body-container" style="display:none">
						<label>
						 	#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.confirmationmessage')#
						</label>
						<textarea name="responseMessage" rows="4">#esapiEncode('html',rc.contentBean.getresponseMessage())#</textarea>
					</div>
					<div class="mura-control-group">
						<label>
							#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.responsesendto')#
						</label>
						<input type="text" name="responseSendTo" value="#esapiEncode('html_attr',rc.contentBean.getresponseSendTo())#">
					</div>
				</cfif>

				<span id="extendset-container-basic" class="extendset-container"></span>

				<span id="extendset-container-tabbasicbottom" class="extendset-container"></span>

		</div>
	</div>
</div>

	<script>
		jQuery(document).ready(function(){

			$('##showTitles').click(function(e){
				$(this).parents('div.mura-control').hide();
				$('##alertTitleSuccess').hide();
				$('##mura-seo-titles').fadeIn();
			})

			$('##resetTitles').click(function(e){
				e.preventDefault();
				$('##menuTitle,##urlTitle,##htmlTitle').val('');
				$('##editAdditionalTitles').hide();
				$('##alertTitleSuccess').fadeIn();
				isMenuTitleSynchronized = isUrlTitleSynchronized = isHtmlTitleSynchronized = true;
				//initializeSynchronizedValues();
				return true;
			});

		});

		// altURLs
		<cfif listFindNoCase("Page,Folder,Calendar,Gallery,File,Link",rc.type)>
		 Mura(function (m) {

				var max_fields = 20; //maximum input boxes allowed
				var global_max_fields = max_fields; // used to reset max fields
				var wrapper = $(".input_fields_wrap"); //fields wrapper
				var add_button = $(".add_field_button"); //add button ID
				var button_wrapper = $("##add_field_button_wrapper"); //add wrapper div
				var totalAltURLs = $(".numberOfAltURLs"); //hidden for count
				var ismuracontent = $("input[name='ismuracontent']");
				var urlvals = []; // used to reset existing values
				var statusvals = []; // used to reset existing values
				var redirurlvals = []; // used to reset existing values
				var redirstatusvals = []; // used to reset existing values
				var x = 1; //initlal text box count

				var showSelectedAltUrls = function(){
					var selStr = '';
					var defaultStr = '<div>No alternate URLs defined</div>';
					var pv = $('##alturls__selected');
					var inputs = $('.alturl-input');
					if (inputs.length){
						$(inputs).each(function(){
							if ($(this).val().length){
								selStr = selStr + '<div>' + $(this).val() +  '</div>';
							}
						})						
					} 
					if (selStr == ''){
						selStr = defaultStr;
					}
					$(pv).html(selStr);
					$(".altstatuscode > select").niceSelect();
				}
				
				if ($("input[name='ismuracontent']:checked").val() == 1 ) {
					$(add_button).attr('disabled','disabled');
					$(button_wrapper).hide();
					showSelectedAltUrls();
				}

				$(ismuracontent).on('change',function(e){
					if ($(this).val() == 1) {
						max_fields = 1;
						urlvals = $(wrapper).find('input[name^="alturl_"]').serializeArray();
						statusvals = $(wrapper).find('select[name^="altstatuscode_"]').serializeArray();
						$(add_button).attr('disabled','disabled');
						$(button_wrapper).hide();
						$(wrapper).find('input[name^="alturl_"]').each(function(){
							$(this).val('');
						});
						if(redirurlvals.length){
							for (x in redirurlvals){
								if (redirurlvals[x]['name'].startsWith('alturl_') && redirurlvals[x]['value'].length){
									$(wrapper).find('div.mura-control-group:last-child').find('input[name^="alturl_"]').val(redirurlvals[x]['value']).next('span.altstatuscode').find('select[name^="altstatuscode_"]').val(redirstatusvals[x]['value']).niceSelect('update');
								}
							}
						}
						$(wrapper).find('div.mura-control-group').not('.first').remove();
					} else {
						max_fields = global_max_fields;
						redirurlvals = $(wrapper).find('input[name^="alturl_"]').serializeArray();
						redirstatusvals = $(wrapper).find('select[name^="altstatuscode_"]').serializeArray();
						$(add_button).removeAttr('disabled');
						$(wrapper).find('input[name^="alturl_"]').each(function(){
							$(this).val('');
						});
						if(urlvals.length){
							for (x in urlvals){
								if (urlvals[x]['name'].startsWith('alturl_') && urlvals[x]['value'].length){
									if (x > 0){
										$(add_button).trigger('click');
									}
									$(wrapper).find('div.mura-control-group:last-child').find('input[name^="alturl_"]').val(urlvals[x]['value']).next('span.altstatuscode').find('select[name^="altstatuscode_"]').val(statusvals[x]['value']).niceSelect('update');
								}
							}
						}
						$(button_wrapper).show();
						urlvals = [];
					}
					showSelectedAltUrls();
				})

				$(add_button).click(function(e){ //on add input button click
					var inputs = $('.alturl-input:visible');
					var x = inputs.length;
					e.preventDefault();
					if(x < max_fields){ //max input box allowed
						var newID=m.createUUID();
						newForm = '<div class="mura-control-group">#altURLHelper# <input type="text" class="alturl-input" name="alturl_'+ newID +'" placeholder="url-here"/> <span class="altstatuscode"><select  name="altstatuscode_' + newID +'"><option value="301">Permanent (301)</option><option value="302">Temporary (302)</option><option value="">No redirection</option></select> <button class="btn remove_field" title="Remove Alternate URL"> <i class="fa fa-trash"></i> </button></span></div>';
						$(wrapper).append(newForm); //add input box
						// focus new input and handle 'enter' keypress
						$('input[name="alturl_'+ newID +'"]').focus().on("keypress", function(event){
							if (event.keyCode === 13) {
							    event.preventDefault();
							    
							    $(add_button).trigger('click');
							  }
						});
						x++; //text box increment
						totalAltURLs.val(x);
						$(add_button).removeAttr('disabled');
						if (x == max_fields) {
							$(add_button).attr('disabled','disabled');
						}
					}
					showSelectedAltUrls();
				});

				$(wrapper).on("click",".remove_field", function(e){ 
					e.preventDefault();
					var parent=$(this).closest('div.mura-control-group');
					if($(".input_fields_wrap").children('div:visible').length > 1){
						parent.hide();
						$(add_button).removeAttr('disabled');
					}
					parent.find('input[name^="alturl_"]').val('');
					var inputs = $('.alturl-input:visible');
					var x = inputs.length;
					if(x > 1){
						totalAltURLs.val(x);
					}
					showSelectedAltUrls();
				});

				$(wrapper).on('keyup','.alturl-input',function(){
					showSelectedAltUrls();
				})
					// run on load
					showSelectedAltUrls();

			}); // end Mura function(m)
			</cfif>
	</script>

</cfoutput>
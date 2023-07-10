<!--- license goes here --->
<cfoutput>
	<div class="mura__edit__controls" id="mura-edit-controls-wrapper"<cfif not $.event('compactDisplay')>style="width: 340px;"</cfif>>
		<!--- accordion panels --->
		<div class="mura__edit__controls__scrollable">

			<!--- filter settings --->
			<div id="mura__edit__settings__filter">
	  		<input type="text" class="form-control" id="mura__edit__settings__filter__input" placeholder="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.edit.searchsettings'))#">
			</div>
			<!--- settings --->
			<div class="mura__edit__controls__objects">
				<div id="mura-edit-tabs" class="mura__edit__controls__tabs">

					<div class="mura-panel-group" id="content-panels" role="tablist" aria-multiselectable="true">

						<!--- basic --->
						<cfif rc.type eq "Form">
							<cfif rc.contentBean.getIsNew() and not (isdefined("url.formType") and url.formType eq "editor")>
								<cfset rc.contentBean.setBody( application.serviceFactory.getBean('formBuilderManager').createJSONForm( rc.contentBean.getContentID() ) ) />
							</cfif>
							<cfif isJSON(rc.contentBean.getBody())>
								<cfinclude template="form/dsp_panel_formbuilder.cfm">
							<cfelse>
								<cfinclude template="form/dsp_panel_basic.cfm">
								<cfinclude template="form/dsp_panel_summary.cfm">
								<cfinclude template="form/dsp_panel_assocfile.cfm">
							</cfif>
						<cfelse>
							<cfinclude template="form/dsp_panel_basic.cfm">
							<cfinclude template="form/dsp_panel_summary.cfm">
							<cfinclude template="form/dsp_panel_assocfile.cfm">
						</cfif>
						<!--- /basic --->

						<!--- publishing --->
						<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Publishing')>
								<cfinclude template="form/dsp_panel_publishing.cfm">
						</cfif>
						<!--- /publishing --->

						<!--- scheduling --->
						<cfif (not len(tabAssignments) or listFindNocase(tabAssignments,'Scheduling')) and rc.contentBean.getcontentID() neq '00000000000000000000000000000000001'>
								<cfinclude template="form/dsp_panel_scheduling.cfm">
						</cfif>
						<!--- /scheduling --->

						<!--- layoutobjects,categories,related_content,tags --->
						<cfswitch expression="#rc.type#">
							<cfcase value="Page,Folder,Calendar,Gallery">
								<cfif rc.moduleid eq '00000000000000000000000000000000000' and (not len(tabAssignments) or listFindNocase(tabAssignments,'Layout & Objects') or listFindNocase(tabAssignments,'Layout'))>
									<cfinclude template="form/dsp_panel_layoutobjects.cfm">	
								</cfif>
								<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Categorization')>
									<cfif application.categoryManager.getCategoryCount(rc.siteID)>
										<cfinclude template="form/dsp_panel_categories.cfm">
									</cfif>
								</cfif>
								<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Tags')>
									<cfinclude template="form/dsp_panel_tags.cfm">
								</cfif>
								<cfif rc.moduleid eq '00000000000000000000000000000000000' and (not len(tabAssignments) or listFindNocase(tabAssignments,'Related Content'))>
									<cfinclude template="form/dsp_panel_related_content.cfm">
								<cfelse>
									<input type="hidden" name="ommitRelatedContentTab" value="true">
								</cfif>
							</cfcase>
							<cfcase value="Link,File">
								<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Categorization')>
									<cfif application.categoryManager.getCategoryCount(rc.siteid)>
										<cfinclude template="form/dsp_panel_categories.cfm">
									</cfif>
								</cfif>
								<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Tags')>
									<cfinclude template="form/dsp_panel_tags.cfm">
								</cfif>
								<cfif rc.moduleid eq '00000000000000000000000000000000000' and (not len(tabAssignments) or listFindNocase(tabAssignments,'Related Content'))>
									<cfinclude template="form/dsp_panel_related_content.cfm">
								<cfelse>
									<input type="hidden" name="ommitRelatedContentTab" value="true">
								</cfif>
							</cfcase>
							<cfcase value="Variation">
								<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Categorization')>
									<cfif application.categoryManager.getCategoryCount(rc.siteID)>
										<cfinclude template="form/dsp_panel_categories.cfm">
									</cfif>
								</cfif>
								<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Tags')>
									<cfinclude template="form/dsp_panel_tags.cfm">
								</cfif>
							</cfcase>
							<cfcase value="Component">
								<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Categorization')>
									<cfif application.categoryManager.getCategoryCount(rc.siteID)>
										<cfinclude template="form/dsp_panel_categories.cfm">
									</cfif>
								</cfif>
								<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Tags')>
									<cfinclude template="form/dsp_panel_tags.cfm">
								</cfif>
							</cfcase>
							<cfcase value="Form">
								<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Categorization')>
									<cfif application.categoryManager.getCategoryCount(rc.siteID)>
										<cfinclude template="form/dsp_panel_categories.cfm">
									</cfif>
								</cfif>
								<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Tags')>
									<cfinclude template="form/dsp_panel_tags.cfm">
								</cfif>
							</cfcase>
						</cfswitch>
						<!--- /layoutobjects,categories,related_content,tags  --->

						<!--- extended attributes --->
						<cfif listFindNoCase(rc.$.getBean('contentManager').ExtendableList,rc.type)>
							<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Extended Attributes')>
									<cfinclude template="form/dsp_panel_extended_attributes.cfm">
							</cfif>
						</cfif>
						<!--- /extended attributes --->

						<!--- Remote --->
						<cfif (rc.type neq 'Component' and rc.type neq 'Form') and rc.contentBean.getcontentID() neq '00000000000000000000000000000000001'>
							<cfif not len(tabAssignments) or listFindNocase(tabAssignments,'Remote')>
								<cfif listFind(session.mura.memberships,'S2IsPrivate')>
									<cfinclude template="form/dsp_panel_Remote.cfm">
								<cfelse>
									<input type="hidden" name="ommitRemoteTab" value="true">
								</cfif>
							</cfif>
						</cfif>
						<!--- /Remote --->

						<!--- plugin rendering --->
						<cfif arrayLen(pluginEventMappings)>
							<cfoutput>
								<cfset renderedEvents = '' />
								<cfset eventIdx = 0 />
								<cfloop from="1" to="#arrayLen(pluginEventMappings)#" index="i">
									<cfset eventToRender = pluginEventMappings[i].eventName />

									<cfif ListFindNoCase(renderedEvents, eventToRender)>
										<cfset eventIdx++ />
									<cfelse>
										<cfset renderedEvents = ListAppend(renderedEvents, eventToRender) />
										<cfset eventIdx=1 />
									</cfif>

									<cfset renderedEvent=$.getBean('pluginManager').renderEvent(eventToRender=eventToRender,currentEventObject=$,index=eventIdx)>
									<cfif len(trim(renderedEvent))>
										<cfset tabLabel = Len($.event('tabLabel')) && !ListFindNoCase(tabLabelList, $.event('tabLabel')) ? $.event('tabLabel') : pluginEventMappings[i].pluginName />
										<cfset tabLabelList=listAppend(tabLabelList, tabLabel)/>
										<cfset tabID="tab" & $.createCSSID(tabLabel)>
										<cfif ListFind(tabList,tabID)>
											<cfset tabID = tabID & i />
										</cfif>
										<cfset pluginEvent.setValue("tabList",tabLabelList)>
										<div class="mura-panel">
											<div class="mura-panel-heading" role="tab" id="heading-#tabID#">
												<h4 class="mura-panel-title">
													<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##content-panels" href="##panel-#tabID#" aria-expanded="false" aria-controls="panel-#tabID#">#tablabel#</a>
												</h4>
											</div>
											<div id="panel-#tabID#" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-#tabID#" aria-expanded="false" style="height: 0px;">
												<div class="mura-panel-body">
													#renderedEvent#
												</div>
											</div>
										</div>
									</cfif>
								</cfloop>
							</cfoutput>
						</cfif>
						<!--- /plugin rendering --->
					</div>	<!--- /.mura__edit__controls__scrollable --->

				</div>
			</div>
		</div>
	</div>

</cfoutput>

<script type="text/javascript">
$(document).ready(function(){

	var typeSelector = $('.mura-type-selector select[name="typeSelector"]');
	
	if(typeSelector.length){
		$(document).on('change',typeSelector, function(){
			var typeArray=typeSelector.val().split('^');
			var type=typeArray[0];
			var subtype=typeArray[1];
			var typeStr = type + '/' + subtype;
			Mura('#no-body-message-type').text(typeStr);
		});
	}
	// custom case-insensitive :contains method
    $.expr[":"].contains = $.expr.createPseudo(function (arg) {
        return function (elem) {
            return $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;
        };
    });

	// open tab via url hash
	if(window.location.hash.substring(1,7) == 'panel-'){
		$('#content-panels .mura-panel-heading a[href$="' + window.location.hash + '"]').trigger('click');
		window.location.hash = "";
	}

	// open basic tab for no-body content types
	<cfif not subType.getHasBody() or rc.contentBean.getType() eq 'Variation'>
		$('#content-panels .mura-panel-heading a[href$="panel-basic"]').trigger('click');
		window.location.hash = "";
	</cfif>

	// filter settings in side panels
	filterSettings=function(fstr){

		// minimum string length for action
		if(fstr.length > 2){

			// if matching a panel name
			$("#content-panels a.collapse:contains('" + fstr + "')").each(function(){
				if ($(this).parents('.mura-panel').has('.panel-collapse.collapse.in').length == 0){
					$(this).parents('.mura-panel').siblings('.mura-panel').has('.panel-collapse.collapse.in').find('a.collapse').trigger('click');
					$(this).trigger('click');
				}
			});

			// also match contents
			$("#content-panels .mura-panel label:contains('" + fstr + "')").addClass('control-matched').parents('.mura-control-group').addClass('control-matched');
				if ($('#content-panels .panel-collapse.collapse.in').length == 0){
					$('.mura-control-group.control-matched').parents('.mura-panel').find('a.collapse').trigger('click');
				}

		// reset on short length
		} else {
			$("#content-panels .panel-collapse.collapse").collapse("hide","fast");
			$('#content-panels .mura-panel .control-matched').removeClass('control-matched');
		}
	}

	// apply filter by typing, with delay
	$("#mura__edit__settings__filter__input").keyup(function(){
		var timeout = null;
		clearTimeout(timeout);
	    timeout = setTimeout(function () {
			var filterStr = $("#mura__edit__settings__filter__input").val();
				//	console.log(filterStr);
					filterSettings(filterStr)	;
	    }, 500);
	});

	// focus on input filter on page load
	<cfif not $.content().getIsNew()>
	setTimeout(function () {
		$("#mura__edit__settings__filter__input").focus();
	 }, 500);
	</cfif>

	// set sidebar width
	if (localStorage.getItem("admincontrolwidth") === null) {
		localStorage.setItem("admincontrolwidth", 340);
	}
	<cfif not $.event('compactDisplay')>
		$('#mura-edit-controls-wrapper').css('width',localStorage.getItem("admincontrolwidth"));
	</cfif>
	resizeTabPane();

	$('#content-panels').on('shown.bs.collapse', function (e) {
	    selector= "#content-panels .panel-collapse.collapse.in textarea.mura-markdown, #content-panels .panel-collapse.collapse.in textarea.markdownEditor";
	    Mura(selector).forEach(function(){
	    	var input=Mura(this);
	        if(input.hasClass("markdown-lazy-init")) {
	            input.hide();
	            var id='mura-markdown-' + input.attr('name');
	            if(typeof markdownInstances[input.attr('name')] == 'undefined'){
	                input.after('<div class="mura-markdown-editor" id="'+ id + '" data-target="' + input.attr('name') + '"></div>');
	                var height= input.data('height') || '300px';
	                var previewStyle= input.data('previewstyle') ||  'tabs';
	                var initialEditType= input.data('initialedittype') ||  'wysiwyg';
	                markdownInstances[input.attr('name')]=getMarkdownEditor({
	                    el: document.getElementById(id),
	                    initialEditType: initialEditType,
	                    previewStyle: previewStyle,
	                    height: height,
	                    initialValue: input.val()
	                });
	            }
	            input.removeClass("markdown-lazy-init");
	        }
	    });
	});
});
</script>

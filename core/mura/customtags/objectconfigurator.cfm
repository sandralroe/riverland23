<cfif thisTag.ExecutionMode eq 'start'>
	<cfscript>
		if(server.coldfusion.productname != 'ColdFusion Server'){
			backportdir='';
			include "/mura/backport/backport.cfm";
		} else {
			backportdir='/mura/backport/';
			include "#backportdir#backport.cfm";
		}
	
		$=application.serviceFactory.getBean("muraScope").init(session.siteid);
		
		if ( !isdefined('attributes.params') ) {
			if ( isDefined("form.params") && isJSON(form.params) ) {
				attributes.params=deserializeJSON(form.params);
			} else {
				attributes.params={};
			}
		}
		param default=true name="attributes.configurable";
		param default=true name="attributes.basictab";
		param default="mura-twelve" name="attributes.params.class";
		param default="" name="attributes.params.cssclass";
		param default="" name="attributes.params.metacssclass";
		param default="" name="attributes.params.metacssid";
		param default="" name="attributes.params.contentcssclass";
		param default="" name="attributes.params.contentcssid";
		param default="" name="attributes.params.cssid";
		param default=false name="attributes.params.hasTargetAttr";
		param default="" name="attributes.params.label";
		param default="h2" name="attributes.params.labeltag";
		param default="" name="attributes.params.object";
		param default="" name="attributes.params.objectspacing";
		param default="" name="attributes.params.contentspacing";
		param default="" name="attributes.params.metaspacing";
		param default="" name="attributes.params.objectthemeclasses";
		param default=$.siteConfig().getContentRenderer().queueObjects name="attributes.params.queue";
		if ( attributes.params.queue == 'undefined' ) {
		attributes.params.queue=true;
		}
		param default=false name="request.hasbasicoptions";
		param default=true name="request.hasstyleoptions";
		param default=false name="request.hasmetaoptions";
		param default=false name="request.haspositionoptions";
		param default=true name="request.objectconfiguratortag";

		if(len(attributes.params.object) 
			&& $.siteConfig().hasModule(attributes.params.object)){
				moduleConfig=$.siteConfig().hasModule(attributes.params.object);
				if(moduleConfig){
					moduleConfig=$.siteConfig().getModule(attributes.params.object);
				}
				if(isDefined('moduleConfig.metaoptions') && !moduleConfig.metaoptions){
					request.hasmetaoptions=false;
				}
				if(isDefined('moduleConfig.styleoptions')){
					request.hasstyleoptions=moduleConfig.styleoptions;
				}
		}

		if(attributes.params.object == 'plugin'){
			request.hasmetaoptions=false;
			request.hasstyleoptions=false;
		}

		request.hasFixedWidth=$.globalConfig().getValue(property="fixedModuleWidths", defaultValue=true);
	
		// basic unit of measure options		
		request.uomdefault = "%,px,rem,em";
		// unit of measure options for min-height (incl. vw, vh)
		request.uomextdefault = "%,px,rem,em,vw,vh";
		// default selected unit
		request.preferreduom = "px";
		param name="request.objectlayoutuom" default=$.globalConfig().getValue(property='objectlayoutuom',defaultValue=request.uomdefault);
		param name="request.objectlayoutuomext" default=$.globalConfig().getValue(property='objectlayoutuomext',defaultValue=request.uomextdefault);
		param name="request.preferreduom" default=$.globalConfig().getValue(property='preferreduom',defaultValue=request.preferreduom);

		u = request.objectlayoutuom.listToArray(',');
		v = request.uomdefault.listToArray(',');
		u.retainAll(v);
		if (arrayLen(v)){
			request.objectlayoutuom = u.toList(',');
		} else {
			request.objectlayoutuom = request.uomdefault;
		}

		u = request.objectlayoutuomext.listToArray(',');
		v = request.uomextdefault.listToArray(',');
		u.retainAll(v);
		if (arrayLen(v)){
			request.objectlayoutuomext = u.toList(',');
		} else {
			request.objectlayoutuomext = request.uomextdefault;
		}

		if(!isStruct(attributes.params)){
			attributes.params={};
		}
		param name="attributes.params.stylesupport" default={};
		if(!isStruct(attributes.params.stylesupport)){
			attributes.params.stylesupport={};
		}
		param name="attributes.params.stylesupport.css" default="";
		param name="attributes.params.stylesupport.objectbackgroundimageurl" default="";
		param name="attributes.params.stylesupport.objectbackgroundcolorsel" default="";
		param name="attributes.params.stylesupport.contentbackgroundimageurl" default="";
		param name="attributes.params.stylesupport.contentbackgroundimageurl" default="";
		param name="attributes.params.stylesupport.contentbackgroundcolorsel" default="";
		param name="attributes.params.stylesupport.metabackgroundimageurl" default="";
		param name="attributes.params.stylesupport.metabackgroundimageurl" default="";
		param name="attributes.params.stylesupport.metabackgroundcolorsel" default="";
		param name="attributes.params.stylesupport.metabackgroundcolorsel" default="";

		param name="attributes.params.stylesupport.metamarginuom" default="";
		param name="attributes.params.stylesupport.meta_lg_marginuom" default="";
		param name="attributes.params.stylesupport.meta_md_marginuom" default="";
		param name="attributes.params.stylesupport.meta_sm_marginuom" default="";
		param name="attributes.params.stylesupport.meta_xs_marginuom" default="";
	
		param name="attributes.params.stylesupport.metapaddinguom" default="";
		param name="attributes.params.stylesupport.meta_lg_paddinguom" default="";
		param name="attributes.params.stylesupport.meta_md_paddinguom" default="";
		param name="attributes.params.stylesupport.meta_sm_paddinguom" default="";
		param name="attributes.params.stylesupport.meta_xs_paddinguom" default="";
		
		param name="attributes.params.stylesupport.objectmarginuom" default="";
		param name="attributes.params.stylesupport.object_lg_marginuom" default="";
		param name="attributes.params.stylesupport.object_md_marginuom" default="";
		param name="attributes.params.stylesupport.object_sm_marginuom" default="";
		param name="attributes.params.stylesupport.object_xs_marginuom" default="";

		param name="attributes.params.stylesupport.objectpaddinguom" default="";
		param name="attributes.params.stylesupport.object_lg_paddinguom" default="";
		param name="attributes.params.stylesupport.object_md_paddinguom" default="";
		param name="attributes.params.stylesupport.object_sm_paddinguom" default="";
		param name="attributes.params.stylesupport.object_xs_paddinguom" default="";

		param name="attributes.params.stylesupport.objectminheightuom" default="";
		param name="attributes.params.stylesupport.object_lg_minheightuom" default="";
		param name="attributes.params.stylesupport.object_md_minheightuom" default="";
		param name="attributes.params.stylesupport.object_sm_minheightuom" default="";
		param name="attributes.params.stylesupport.object_xs_minheightuom" default="";

		param name="attributes.params.stylesupport.metaminheightuom" default="";
		param name="attributes.params.stylesupport.meta_lg_minheightuom" default="";
		param name="attributes.params.stylesupport.meta_md_minheightuom" default="";
		param name="attributes.params.stylesupport.meta_sm_minheightuom" default="";
		param name="attributes.params.stylesupport.meta_xs_minheightuom" default="";

		param name="attributes.params.stylesupport.contentminheightuom" default="";
		param name="attributes.params.stylesupport.content_lg_minheightuom" default="";
		param name="attributes.params.stylesupport.content_md_minheightuom" default="";
		param name="attributes.params.stylesupport.content_sm_minheightuom" default="";
		param name="attributes.params.stylesupport.content_xs_minheightuom" default="";

		param name="attributes.params.stylesupport.contentmarginuom" default="";
		param name="attributes.params.stylesupport.content_lg_marginuom" default="";
		param name="attributes.params.stylesupport.content_md_marginuom" default="";
		param name="attributes.params.stylesupport.content_sm_marginuom" default="";
		param name="attributes.params.stylesupport.content_xs_marginuom" default="";

		param name="attributes.params.stylesupport.contentpaddinguom" default="";
		param name="attributes.params.stylesupport.content_lg_paddinguom" default="";
		param name="attributes.params.stylesupport.content_md_paddinguom" default="";
		param name="attributes.params.stylesupport.content_sm_paddinguom" default="";
		param name="attributes.params.stylesupport.content_xs_paddinguom" default="";

		param name="attributes.params.stylesupport.contentwidth" default="";
		param name="attributes.params.stylesupport.contentwidthuom" default="";


		param name="attributes.params.stylesupport.objectbackgroundpositionx" default="";
		param name="attributes.params.stylesupport.objectbackgroundpositiony" default="";
		param name="attributes.params.stylesupport.contentbackgroundpositionx" default="";
		param name="attributes.params.stylesupport.contentbackgroundpositiony" default="";
		param name="attributes.params.stylesupport.metabackgroundpositionx" default="";
		param name="attributes.params.stylesupport.metabackgroundpositiony" default="";
		
		$=request.$;

		request.associatedImageURL=$.content().getImageURL(complete=$.siteConfig('isRemote'));

		attributes.globalparams = [
			'backgroundcolor'
			,'backgroundimage'
			,'backgroundoverlay'
			,'backgroundattachment'
			,'backgroundposition'
			,'backgroundpositionx'
			,'backgroundpositiony'
			,'backgroundrepeat'
			,'backgroundsize'
			,'backgroundvideo'
			,'color'
			,'float'
			,'gridcolumnstart'
            ,'gridcolumnend'
            ,'gridrowstart'
            ,'gridrowend'
            ,'gridcolumn'
            ,'gridrow'
			,'gridarea'
			,'gridtemplatecolumns'
			,'gridtemplaterows'
			,'gridtemplateareas'
			,'gridtemplate'
			,'gridcolumngap'
			,'gridrowgap'
			,'gridgap'
			,'justifyitems'
			,'placeitems'
			,'justifycontent'
			,'placecontent'
			,'gridautocolumns'
			,'gridautorows'
			,'gridautoflow'
			,'grid'
            ,'justifyself'
            ,'alignself'
			,'placeself'
			,'margin'
			,'margintop'
			,'marginright'
			,'marginbottom'
			,'marginleft'
			,'marginall'
			,'marginuom'
			,'opacity'
			,'padding'
			,'paddingtop'
			,'paddingright'
			,'paddingbottom'
			,'paddingleft'
			,'paddingall'
			,'paddinguom'
			,'textalign'
			,'minheight'
			,'width'
			,'justifyContent'
			,'alignItems'
			,'alignContent'
			,'alignSelf'
			,'justifySelf'
			,'order'
			,'flexGrow'
			,'flexShrink'
			,'flex'
			,'zindex'
			,'display'];

		for (p in attributes.globalparams){
			param name="attributes.params.stylesupport.objectstyles.#p#" default="";
			param name="attributes.params.stylesupport.object_lg_styles.#p#" default="";
			param name="attributes.params.stylesupport.object_md_styles.#p#" default="";
			param name="attributes.params.stylesupport.object_sm_styles.#p#" default="";
			param name="attributes.params.stylesupport.object_xs_styles.#p#" default="";
			if(p == 'textalign'){
				param name="attributes.params.stylesupport.metastyles.#p#" default="center";
				param name="attributes.params.stylesupport.meta_lg_styles.#p#" default="center";
				param name="attributes.params.stylesupport.meta_md_styles.#p#" default="center";
				param name="attributes.params.stylesupport.meta_sm_styles.#p#" default="center";
				param name="attributes.params.stylesupport.meta_xs_styles.#p#" default="center";
			} else {
				param name="attributes.params.stylesupport.metastyles.#p#" default="";
				param name="attributes.params.stylesupport.meta_lg_styles.#p#" default="";
				param name="attributes.params.stylesupport.meta_md_styles.#p#" default="";
				param name="attributes.params.stylesupport.meta_sm_styles.#p#" default="";
				param name="attributes.params.stylesupport.meta_xs_styles.#p#" default="";
			}
			param name="attributes.params.stylesupport.contentstyles.#p#" default="";
			param name="attributes.params.stylesupport.content_lg_styles.#p#" default="";
			param name="attributes.params.stylesupport.content_md_styles.#p#" default="";
			param name="attributes.params.stylesupport.content_sm_styles.#p#" default="";
			param name="attributes.params.stylesupport.content_xs_styles.#p#" default="";

		}
	
		request.colorOptions = $.getContentRenderer().getColorOptions();
		request.modulethemeoptions = $.getContentRenderer().getModuleThemeOptions();
		request.spacingoptions = $.getContentRenderer().getSpacingOptions();
		request.layoutoptions = $.getContentRenderer().getLayoutOptions();

		request.cssdisplay=request.$.event('cssdisplay');
		
		contentcontainerclass=esapiEncode("javascript",$.getContentRenderer().expandedContentContainerClass);
		if ( !(isDefined("attributes.params.stylesupport.objectstyles") && isStruct(attributes.params.stylesupport.objectstyles)) ) {
			if ( isDefined("attributes.params.stylesupport.objectstyles") && isJSON(attributes.params.stylesupport.objectstyles) ) {
				attributes.params.stylesupport.objectstyles=deserializeJSON(attributes.params.stylesupport.objectstyles);
			} else {
				attributes.params.stylesupport.objectstyles={};
			}
		}
		if ( !(isDefined("attributes.params.stylesupport.metastyles") && isStruct(attributes.params.stylesupport.metastyles)) ) {
			if ( isDefined("attributes.params.stylesupport.metastyles") && isJSON(attributes.params.stylesupport.metastyles) ) {
				attributes.params.stylesupport.metastyles=deserializeJSON(attributes.params.stylesupport.metastyles);
			} else {
				attributes.params.stylesupport.metastyles={};
			}
		}
		if ( !(isDefined("attributes.params.stylesupport.contentstyles") && isStruct(attributes.params.stylesupport.contentstyles)) ) {
			if ( isDefined("objectParams.contentcssstyles") && isJSON(attributes.params.stylesupport.contentstyles) ) {
				attributes.params.stylesupport.contentstyles=deserializeJSON(attributes.params.stylesupport.contentstyles);
			} else {
				attributes.params.stylesupport.contentstyles={};
			}
		}
		if ( !request.hasbasicoptions ) {
			request.hasbasicoptions=attributes.basictab;
		}
		if ( !listFindNoCase('folder,gallery,calendar',attributes.params.object) && !(isBoolean(attributes.params.hasTargetAttr) && attributes.params.hasTargetAttr) ) {
			request.haspositionoptions = true;
		}

		attributes.positionoptions = [
				{value='mura-one', label='1/12',percent='8.33%', cols='1'}
				,{value='mura-two', label='1/6',percent='16.66%', cols='2'}
				,{value='mura-three', label='1/4',percent='25%', cols='3'}
				,{value='mura-four', label='1/3',percent='33.33%', cols='4'}
				,{value='mura-five', label='5/12',percent='41.66%', cols='5'}
				,{value='mura-six', label='1/2',percent='50%', cols='6'}
				,{value='mura-seven', label='7/12',percent='58.33%', cols='7'}
				,{value='mura-eight', label='2/3',percent='66.66%', cols='8'}
				,{value='mura-nine', label='3/4',percent='75%', cols='9'}
				,{value='mura-ten', label='5/6',percent='41.66%', cols='10'}
				,{value='mura-eleven', label='11/12',percent='91.66%', cols='11'}
				,{value='mura-twelve', label='100%',percent='100%', cols='12'}
				,{value='mura-expanded', label='Expanded',percent='100%'}
			];
	</cfscript>

	<cfif $.getContentRenderer().useLayoutManager()>
		<cfoutput>
		<cfset request.muraconfiguratortag=true>
		<div id="availableObjectContainer"<cfif not attributes.configurable> style="display:none"</cfif>>
			<div class="mura-panel-group" id="configurator-panels" role="tablist" aria-multiselectable="true">
			<!--- Basic panel --->
			<cfif request.hasbasicoptions>
			<div class="mura-panel">
				<div class="mura-panel-heading" role="tab" id="heading-basic">
					<h4 class="mura-panel-title">
						<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##configurator-panels" href="##panel-basic" aria-expanded="true" aria-controls="panel-basic">
							<i class="mi-sliders"></i>Settings <!--- #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.basic')# --->
						</a>
					</h4>
				</div>
				<div id="panel-basic" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-basic">
					<div class="mura-panel-body">
			</cfif>
		</cfoutput>
	</cfif>
<!--- /end start mode --->
<cfelseif thisTag.ExecutionMode eq 'end'>
	<cfset $=application.serviceFactory.getBean("muraScope").init(session.siteid)>
	
	<cfif attributes.params.object eq 'plugin'>
		<cfset hasModuleTemplateAccess=false>
	<cfelse>
		<cfset hasModuleTemplateAccess=$.currentUser().isSuperUser() or $.currentUser().isAdminUser() or $.getBean('permUtility').getModulePerm('00000000000000000000000000000000017',session.siteid)>
	</cfif>
	
	<cfif $.getContentRenderer().useLayoutManager()>

	<cfoutput>

		<!--- close the basic or style panel --->
		<cfif request.hasbasicoptions or request.hasmetaoptions and not (IsBoolean(attributes.params.hasTargetAttr) and attributes.params.hasTargetAttr)>
				</div> <!--- /end  mura-panel-collapse --->
			</div> <!--- /end  mura-panel-body --->
		</div> <!--- /end panel --->
		</cfif>
	
		<style>
			.btn-group, .btn-group button, .btn-group ul {
				background-color:##333;
				color:##f3f3f3;
			}

			.btn-group button {
				border-radius: 2px;
				background-image: none;
				text-shadow: none;
				color: ##f3f3f3;
				background-color: ##333;
				border-color: transparent;
				border-radius: 2px;
				font-size: 13px;
    			padding: 3px 12px 3px;
				font-family: "Inter UI","Helvetica Neue",Helvetica,Arial,sans-serif;
    			font-weight: 400;
			}

			.btn-group li, .btn-group li:hover {
				border-radius: 2px !important;
				background-image: none !important;
				text-shadow: none !important;
				background-color: ##333 !important;
				font-size: 13px !important;
    			padding: 3px 12px 3px!important;
				font-family: "Inter UI","Helvetica Neue",Helvetica,Arial,sans-serif;
    			
			}

			.btn-group a, .btn-group a:active{
				background-color: ##333 !important;
				font-weight: 400 !important;
				font-size: 13px !important;
    			padding: 0px 0px !important;
    			padding-left: 0px !important;
			}

			.btn-group a:active, .btn-group a:hover { 
				color: ##f3f3f3 !important;
			}

			a.mura-external-link {
				cursor:pointer !important;
			}

			a.mura-external-link i {
				cursor:pointer !important;
			}

			a.mura-external-link:link {
				color:white;
			}

			a.mura-external-link:hover {
				color:white;
			}

			a.mura-external-link:active {
				color:white !important;
			}

			a.mura-external-link:visited {
				color:white;
			}
			

		</style>
		<!--- style --->
		<cfif request.hasstyleoptions>
			<div class="mura-panel">
				<div class="mura-panel-heading" role="tab" id="heading-style">
					<h4 class="mura-panel-title">
						<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##configurator-panels" href="##panel-style" aria-expanded="false" aria-controls="panel-style">
							<i class="mi-tint"></i>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.style')#
						</a>
					</h4>
				</div>
				<div id="panel-style" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-style">
					<div class="mura-panel-body">
						<div class="container">
							<!--- nested panels --->
						<cfoutput>
							<div class="panel-gds-box active" id="panel-gds-object" data-gdsel="panel-style-object"><span>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.module')#</span> <!--.mura-object-->
								<cfif request.hasmetaoptions>
									<div class="panel-gds-box" id="panel-gds-meta" data-gdsel="panel-style-label"<cfif not len(attributes.params.label)> style="display:none"</cfif>><span>Heading</span><!---  .mura-object-meta---></div>
								</cfif>
								<div class="panel-gds-box" id="panel-gds-content" data-gdsel="panel-style-content"><span>Content</span><!--- .mura-object-content---></div>
							</div>
						</cfoutput>

						<div class="mura-panel-group" id="style-panels" role="tablist" aria-multiselectable="true">

							<!--- object/module style panel--->
							<div class="mura-panel">
								<div class="mura-panel-heading" role="tab" id="heading-style-object">
									<h4 class="mura-panel-title">
										<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##configurator-panels" href="##panel-style-object" aria-expanded="false" aria-controls="panel-style-object">
											Module
										</a>
									</h4>
								</div>
								<div id="panel-style-object" class="panel-collapse collapse" role="tabpanel" aria-labeledby="heading-style-object">
									<div class="mura-panel-body">
										<div class="container">
											<cfinclude template="objectconfigpanels/objectconfigpanelstylemodule.cfm">
										</div> <!--- /end container --->
									</div> <!--- /end mura-panel-body --->
								</div> <!--- /end panel-collapse --->
							</div> <!--- /end object panel --->

						<!--- meta/label style panel --->
						<cfif request.hasmetaoptions and not (IsBoolean(attributes.params.hasTargetAttr) and attributes.params.hasTargetAttr)>
							<!--- label --->
							<div class="mura-panel">
								<div class="mura-panel-heading" role="tab" id="heading-style-label">
									<h4 class="mura-panel-title">
										<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##configurator-panels" href="##panel-style-label" aria-expanded="false" aria-controls="panel-style-label">
											Label
										</a>
									</h4>
								</div>
								<div id="panel-style-label" class="panel-collapse collapse" role="tabpanel" aria-labeledby="heading-style-label">
									<div class="mura-panel-body">
										<div class="container" id="labelContainer">
											<cfinclude template="objectconfigpanels/objectconfigpanelstyleheading.cfm">
										</div> <!--- /end container --->
									</div> <!--- /end mura-panel-body --->
								</div> <!--- /end panel-collapse --->
							</div> <!--- /end label panel --->
						</cfif>

						<!--- content style panel --->
							<div class="mura-panel">
								<div class="mura-panel-heading" role="tab" id="heading-style-content">
									<h4 class="mura-panel-title">
										<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##configurator-panels" href="##panel-style-content" aria-expanded="false" aria-controls="panel-style-content">
											Content
										</a>
									</h4>
								</div>
								<div id="panel-style-content" class="panel-collapse collapse" role="tabpanel" aria-labeledby="heading-style-content">
									<div class="mura-panel-body">
										<div class="container">
											<cfinclude template="objectconfigpanels/objectconfigpanelstylecontent.cfm">
										</div> <!--- /end container --->
									</div> <!--- /end mura-panel-body --->
								</div> <!--- /end panel-collapse --->
							</div> <!--- /end content panel --->

							<cfoutput>
							<div>
								<input name="class" type="hidden" class="objectParam" value="#esapiEncode('html_attr',attributes.params.class)#"/>
								<input class="styleSupport" name="css" id="csscustom" type="hidden" value="#esapiEncode('html_attr',attributes.params.stylesupport.css)#"/>
							</div>
							</cfoutput>

							</div> <!--- /end panel group --->
						</div> <!--- /end container --->
					</div> <!--- /end  mura-panel-body --->
				</div> <!--- /end  mura-panel-collapse --->
			</div> <!--- /end style panel --->
		</cfif>
		<!--- save module panel --->
		<cfif hasModuleTemplateAccess>
			<div class="mura-panel">
				<div class="mura-panel-heading" role="tab" id="save-module">
					<h4 class="mura-panel-title">
						<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##configurator-panels" href="##panel-save" aria-expanded="false" aria-controls="panel-save">
							<i class="mi-tasks"></i>Template
						</a>
					</h4>
				</div>
				<div id="panel-save" class="panel-collapse collapse" role="tabpanel" aria-labelledby="save-module">
					<div class="mura-panel-body">
						<div class="container">
							<cfinclude template="objectconfigpanels/objectconfigpaneltemplate.cfm">
						</div>
					</div> <!--- end panel body --->
				</div> <!--- end panel collapse --->
			</div> <!--- end save module panel --->
		</cfif>
	</div><!--- /end panels --->
	</cfoutput>
</div> <!--- /end availableObjectContainer --->

	<script>
		$(function(){

			currentPanel="";
			re="[^0-9\\-\\.]";
			numRE = new RegExp(re,"g")
			window.configuratorInited=false;

			// select dispenser
			function dispense(targetID){
				var targetEl = $('#' + targetID); 
				var param =	targetEl.data('param'); 
				var delim = targetEl.data('delim'); 
				var dispenseVal = $(targetEl).val();

				if(dispenseVal != null && dispenseVal.length){
					var targetOption = $(targetEl).find('option[value="' + dispenseVal + '"]');
					var targetLabel = targetOption.text();
					var dispenseTo = $('div.dispense-to[data-select="' + targetID + '"]');
					var dispenseEl = '<div class="dispense-option" data-value="' + dispenseVal + '"><span class="drag-handle"><i class="mi-navicon"></i></span><span class="dispense-label">' + targetLabel + '</span><a class="dispense-option-close"><i class="mi-minus-circle"></i></a></div>';

					if(!$(dispenseTo).length){
						var dispenseTo = $('<div class="dispense-to" data-select="' + targetID + '"  data-param="' + param + '"  data-delim="' + delim + '"></div>');
						$(dispenseTo).appendTo($(targetEl).parents('div.mura-control-group'));
					}
					$(dispenseTo).sortable({
						update: function(event){
							event.stopPropagation();
							updateDispenserSelections(targetID);
							}
					});
					if(!$(dispenseTo).find('.dispense-option[data-value="' + dispenseVal + '"]').length){
						$(dispenseEl).prependTo(dispenseTo);
						$(targetOption).attr('disabled','disabled');
						$(targetEl).niceSelect('update');
						updateDispenserSelections(targetID);
					}
				}				
			};

			$('.dispenser-select').on('change',function(){
				dispense($(this).attr('id'));
			})

			// create sortable existimg themes on load
			$('.dispense-to').each(function(){
				var targetID = $(this).attr('data-select');
				var dispenseTo = $('div.dispense-to[data-select="' + targetID + '"]');
				if ($(dispenseTo).length){
					$(dispenseTo).sortable({
						update: function(event){
							event.stopPropagation();
							updateDispenserSelections(targetID);
						}
					});		
				}
			})

			$(document).on('click', '.dispense-to .dispense-option-close', function(){
				 var dispenseOption = $(this).parents('.dispense-option');
				 var dispenseVal = $(dispenseOption).attr('data-value');
				 var targetID = $(dispenseOption).parents('.dispense-to').attr('data-select');
				 var targetEl = $('#' + targetID);
				 $(dispenseOption).remove();
				 $(targetEl).find('option[value="' + dispenseVal + '"]').removeAttr('disabled');
				 $(targetEl).niceSelect('update');
				 updateDispenserSelections(targetID);
			})
 
			function updateDispenserSelections(targetID){			
				var dispenseTo = $('.dispense-to[data-select="' + targetID + '"]');
				var delimiter =  dispenseTo.data('delim');
				var param =  dispenseTo.data('param');
				var vals = '';
				$(dispenseTo).find('.dispense-option').each(function(){
					var val = $(this).attr('data-value');
					if (val.length){
						if (vals.length){
							vals = vals + delimiter;
						}
						vals = vals + val;
					}
				});
				$('#' + param + 'dispenserval').val(vals).trigger('change');
			}

			$('#panel-gds-object,.mura-panel-heading').click(function(){
				if(!$(this).is('.panel-content, .panel-meta')){
					currentPanel="";
					frontEndProxy.post(
					{
						cmd:'setCurrentPanel',
						instanceid:instanceid,
						currentPanel:currentPanel
					});
				}
			});

			$('#panel-gds-content, .panel-content').click(function(){
				currentPanel="content";
				frontEndProxy.post(
				{
					cmd:'setCurrentPanel',
					instanceid:instanceid,
					currentPanel:currentPanel
				});
			});

			$('#panel-gds-meta,.panel-meta').click(function(){
				currentPanel="meta";
				frontEndProxy.post(
				{
					cmd:'setCurrentPanel',
					instanceid:instanceid,
					currentPanel:currentPanel
				});
			});

			
			$('.mura-panel-heading, .panel-gds-box').on('click',function(){
				setConfigPanelStates();
			})

			$('.panel-gds-box').on('click',function(){
				var gdspanel = $(this).attr('data-gdsel');
				var gdstarget = $('#' + gdspanel);
				$('.panel-gds-box').removeClass('active');
				$(this).addClass('active');
				$('#style-panels > .mura-panel > .panel-collapse.in').removeClass('in');
				$(gdstarget).addClass('in');
				return false;
			})

			<cfif request.hasFixedWidth>
			$('#object-widthsel-ui .object-widthsel-option').hover(
				function(){
					previewGridWidth($(this));
				}, 
				function(){
					resetGridWidth();
				}
			)
			
			$('#object-widthsel-ui .object-widthsel-option').on('click',function(){
				setGridWidth($(this));
				setGridIndicators($(this));
				$(this).addClass('selected').siblings().removeClass('selected');
				selectGridWidth($(this));
			})

			function unsetGridWidth(){
				$('#object-widthsel-ui .object-widthsel-option').removeClass('set');
			}	
			function resetGridWidth(){
				$('#object-widthsel-ui .object-widthsel-option').removeClass('active');
			}

			function selectGridWidth(activeOption){
				var optionValue = $(activeOption).attr('data-value');
				if (optionValue == 'mura-twelve' && $('#expandedwidthtoggle').is(':checked')){
					optionValue = 'mura-expanded';
				} else if (optionValue == 'mura-expanded' && !($('#expandedwidthtoggle').is(':checked'))){
					optionValue = 'mura-twelve';
				}

				$('#objectwidthsel').val(optionValue).trigger('change').niceSelect('update');
			}

			function setGridWidth(activeOption){
				$(activeOption).siblings('.object-widthsel-option').removeClass('set');
				$(activeOption).addClass('set').prevAll('.object-widthsel-option').addClass('set');
			}

			function previewGridWidth(activeOption){
				$(activeOption).siblings('.object-widthsel-option').removeClass('active');
				$(activeOption).addClass('active').prevAll('.object-widthsel-option').addClass('active');
			}

			function setGridIndicators(activeOption){
				var optionValue = $(activeOption).attr('data-value');
				var markers = '';

				if (optionValue == 'mura-two' || optionValue == 'mura-ten'){
					markers = ['2','4','6','8','10'];
				} else if (optionValue == 'mura-three' || optionValue == 'mura-six' || optionValue == 'mura-nine'){
					markers = ['3','6','9'];
				} else if (optionValue == 'mura-four' || optionValue == 'mura-eight'){
					markers = ['4','8'];
				} else {
					markers = ['1','2','3','4','5','6','7','8','9','10','11'];
				} 

				$('#object-widthsel-wrapper .indicator').removeClass('indicator');

				for (m in markers){
					$('#object-widthsel-wrapper > .object-widthsel-option:nth-child(' + markers[m] + ')').addClass('indicator');
				}
			}
			</cfif>

			function setActiveGDSpanel(){
				var visiblekids = $('#style-panels > .mura-panel > .panel-collapse.in');
				if (!visiblekids.length){
					$('#panel-gds-object').trigger('click');
				} else {
					$('.panel-gds-box[data-gdsel="' + visiblekids[0].id + '"]').trigger('click');
				}
			}
		
			// set panel state cookie
			function setConfigPanelStates(){
				var savedStates = JSON.parse(getConfigPanelStates());
				var newStates = [];

				for (i in savedStates){
					if (newStates.length <= 10){
						var item = savedStates[i];
						if (item[0] != instanceid){
							newStates.push(item);
						}
					}
				}

				setTimeout(function(){
				 	var openPanels = $('#configurator-panels').find('.panel-collapse.in').map(function(){
				 			return this.id;
				 	}).get();
				 	var thisArr = [instanceid,openPanels];
				 	newStates.unshift(thisArr);
				 	var str = JSON.stringify(newStates);
				 	window.sessionStorage.setItem('mura_configpanelstate',str);

					 try{
						if(siteManager.availableObject.params.object!=='collection'){
							window.configuratorInited=true;
						}
					} catch(e){
						window.configuratorInited=true;
					}
				},500);
			}
		
			// get panel state cookie
			function getConfigPanelStates(){
					var cps = window.sessionStorage.getItem('mura_configpanelstate');
					if (cps == ''){
						return JSON.stringify([]);
					} else {
						return cps;
					}
			}

			// apply open panels
			function applyConfigPanelStates(){
					var cps = JSON.parse(getConfigPanelStates());
					var found=false;
					for (i in cps){
						var savedinstanceid = cps[i][0];
						var panelarr = cps[i][1];
						if (panelarr.length && savedinstanceid == instanceid){
							found=true;
							$('#configurator-panels').find('.panel-collapse.in').removeClass('in');
							$('#configurator-panels').find('.mura-panel-title a.collapse').addClass('collapsed');
							for (i in panelarr){
								$('#'+ panelarr[i]).addClass('in').siblings('.mura-panel-heading').find('a.collapse').removeClass('collapsed');
							}
						} 
					}

					if(!found){
						$('#configurator-panels').find('.panel-collapse.in').removeClass('in');
						$('#configurator-panels').find('.mura-panel-title a.collapse').addClass('collapsed');
						$('#panel-basic').addClass('in').siblings('.mura-panel-heading').find('a.collapse').removeClass('collapsed');
					}
				
					setTimeout(function(){
						try{
								if(siteManager.availableObject.params.object!=='collection'){
									window.configuratorInited=true;
								}
							} catch(e){
								window.configuratorInited=true;
							}
						},500);
				}

			// run on load
			$('#style-panels').addClass('no-header');
			$('#panel-style-object').addClass('in');
			
			applyConfigPanelStates();
			setActiveGDSpanel();

			$('#labelText').change(function(item){
				if(Mura.trim(Mura(this).val())){
					Mura('#panel-gds-meta').show();
				} else {
					Mura('#panel-gds-meta').hide();
					$('#panel-style-label').removeClass('in');
					$('#panel-style-object').addClass('in');
					$('#panel-gds-object').addClass('active');
				}
			});
		
			<cfif len(contentcontainerclass) 
				and listFind(attributes.params.contentcssclass,contentcontainerclass,' ')
				and listFind(attributes.params.class,'mura-expanded',' ')>
				var hasExpandedContainerClass=true;
			<cfelse>
				var hasExpandedContainerClass=false;
			</cfif>

			function updateDynamicClasses(){
				var classInput=$('input[name="class"]');
				classInput.val('');

				$('.classtoggle,.classToggle').each(function(){
					var input=$(this);
					if(classInput.val()){
						classInput.val($.trim(($.trim(classInput.val()) + ' ' + $.trim(input.val()))));
					} else {
						classInput.val($.trim(input.val()));
					}
				})

				classInput.val($.trim(classInput.val()));
			
				var contentcssclass=$('input[name="contentcssclass"]');
				var expandedContentContainerClass='<cfoutput>#contentcontainerclass#</cfoutput>';
				var contentcssclassArray=[];
				if(typeof contentcssclass.val() =='string'){
					contentcssclassArray=contentcssclass.val().split(' ');
				}
				var constraincontent=$('select[name="constraincontent"]');
				var currentwidth = $('select[name="width"].classtoggle').val();

				if(expandedContentContainerClass && constraincontent.length){

					// if selecting expanded class
					if(currentwidth == 'mura-expanded' || currentwidth == 'mura-twelve'){
						$('.constraincontentcontainer').show();

						// if constraining content
						if(constraincontent.val()=='constrain'){
							// if expanded class not present yet
							if(contentcssclassArray.indexOf(expandedContentContainerClass)==-1){
								// apply container class
								if(contentcssclassArray.length){
									contentcssclass.val($.trim(contentcssclass.val() + ' ') + expandedContentContainerClass);
								} else {
									contentcssclass.val(expandedContentContainerClass);
								}
							}
							hasExpandedContainerClass=true;
						
						// if not constraining
						} else {
							if(contentcssclassArray.indexOf(expandedContentContainerClass) > -1){
								for( var i = 0; i < contentcssclassArray.length; i++){
									if ( contentcssclassArray[i] === expandedContentContainerClass) {
										contentcssclassArray.splice(i, 1);
									}
								}
							}
							contentcssclass.val(contentcssclassArray.join(' '));
							hasExpandedContainerClass=false;
						} // end if constraining

					} else if (hasExpandedContainerClass){
						$('.constraincontentcontainer').hide();
						if(contentcssclassArray.indexOf(expandedContentContainerClass) > -1){
							for( var i = 0; i < contentcssclassArray.length; i++){
								if ( contentcssclassArray[i] === expandedContentContainerClass) {
									contentcssclassArray.splice(i, 1);
								}
							}
						}
						contentcssclass.val(contentcssclassArray.join(' '));
						hasExpandedContainerClass=false;
					} else {
						$('.constraincontentcontainer').hide();
					}

					contentcssclass.val($.trim(contentcssclass.val()));
				}
				if(typeof updateDraft == 'function'){
					updateDraft();
				}
			}

			updateDynamicClasses();
			
			$('#globalSettingsBtn').click(function(){
				$('#availableObjectContainer').hide();
				$('#objectSettingsBtn').show();
				$('#globalObjectParams').fadeIn();
				$('#globalSettingsBtn').hide();
			});

			$('#objectSettingsBtn').click(function(){
				$('#availableObjectContainer').fadeIn();
				$('#objectSettingsBtn').hide();
				$('#globalObjectParams').hide();
				$('#globalSettingsBtn').show();
			});

			$('.mura-ui-link').on('click',function(){
				var targetEl = $(this).attr('data-reveal');
				if (typeof targetEl != 'undefined' && targetEl.length > 0){
					$('#' + targetEl).toggle();
				}
				return false;
			})

			$('.classtoggle,.classToggle').on('change', function() {
				updateDynamicClasses();
			});

			$('a.input-auto').on('click',function(){
				var ai = '#' + $(this).attr('data-auto-input');
				$(ai).val('auto').trigger('keyup');
				return false;
			})
			
			// background position x/y
			function updatePositionSelection(sel){
				var v = $(sel).val();
				var el = $(sel).attr('data-numfield');
				if (v == 'px' || v == '%' || v == 'vh' || v == 'vw'){
					$('#' + el).show();
				} else {
					$('#' + el).hide();
				}
			}

			/*
			$('#contentminheightnum,#contentminheightuom').on('change',function(){
				var el = $('#contentminheightuomval');
				var str = $('#contentminheightuom').val();
				var num = $('#contentminheightnum').val();
				if (Mura.isNumeric(num)){
					str = num + str;
				} else {
					str='';
				}
				$(el).val(str).trigger('change');
			});
			*/


			// update width UI controls 
			<cfif request.hasFixedWidth>
			function updateObjectWidthSelection(){
				var curVal = $('#objectwidthsel').val() || 'mura-twelve';
				var	curOption = $('#object-widthsel-ui .object-widthsel-option[data-value="' + curVal + '"]');
				var defaultOption = $('#object-widthsel-ui .object-widthsel-option[data-value="mura-twelve"]');
				var bpSel =	$('#objectbreakpointsel');
				var bpbhSel =	$('#objectbreakpointbhsel');
				var bpDiv = $('div.objectbreakpointcontainer');
				var floatSel=$('select[name="float"]');
				var alignSelfSel=$('select[name="alignSelf"]');
				
				if (curVal == ''){
					$(bpSel).val('').niceSelect('update');
					$(bpbhSel).val('').niceSelect('update');
					//$(bpDiv).hide();
					resetGridWidth();
					unsetGridWidth();
					if(floatSel.length){
						
						$('.float-container-object,.flex-container-object').hide();
						floatSel.val('').niceSelect('update');
					}
				} else {
					if (curVal == 'mura-twelve' || curVal == 'mura-expanded'){
						//$(bpDiv).hide();
						if(floatSel.length){
							$('.float-container-object').hide();
							floatSel.val('').niceSelect('update');
						} 
						if(alignSelfSel.length){
							$('.flex-container-object').hide();
							alignSelfSel.val('').niceSelect('update');
						}
					} else {
						//$(bpDiv).show();
						if(floatSel.length){
							$('.float-container-object').show();;
						}	
						if(alignSelfSel.length){
							$('.flex-container-object').show();
						}				
					}
				}
				if (curOption.length){
					setGridWidth(curOption);
					setGridIndicators(curOption);					
				} else {
					setGridWidth(defaultOption);
					setGridIndicators(defaultOption);					
				}
			}
			// run on change of hidden dropdown
			$('#objectwidthsel').on('change', function(){
					updateObjectWidthSelection();
			});
			// run on load
			$('#objectwidthsel').trigger('change');
			</cfif>
			// object spacing
		
			<cfif not $.globalConfig().getValue(property='spacingdispenser',defaultValue=true) and arrayLen(request.spacingoptions)>
				$('select[name="objectspacingselect"]').on(
					'change',
					function(){
						var item=$(this);
						
						if($(this).val()=='custom'){
							$('.customobjectspacing').show();
						} else {
							$('.customobjectspacing').hide();
							$('#objectpaddingall').val('').trigger('keyup');
							$('#objectmarginall').val('').trigger('keyup');
							$('#object_lg_paddingall').val('').trigger('keyup');
							$('#object_lg_marginall').val('').trigger('keyup');
							$('#object_md_paddingall').val('').trigger('keyup');
							$('#object_md_marginall').val('').trigger('keyup');
							$('#object_sm_paddingall').val('').trigger('keyup');
							$('#object_sm_marginall').val('').trigger('keyup');
							$('#object_xs_paddingall').val('').trigger('keyup');
							$('#object_xs_marginall').val('').trigger('keyup');
						}
						
						$('input[name="objectspacing"]').val(item.val()).trigger('change');
					}	
				)
				$('select[name="metaspacingselect"]').on(
					'change',
					function(){
						var item=$(this);
					
						if($(this).val()=='custom'){
							$('.custommetaspacing').show();
						} else {
						
							$('.custommetaspacing').hide();
							$('#metapaddingall').val('').trigger('keyup');
							$('#metamarginall').val('').trigger('keyup');
							$('#meta_lg_paddingall').val('').trigger('keyup');
							$('#meta_lg_marginall').val('').trigger('keyup');
							$('#meta_md_paddingall').val('').trigger('keyup');
							$('#meta_md_marginall').val('').trigger('keyup');
							$('#meta_sm_paddingall').val('').trigger('keyup');
							$('#meta_sm_marginall').val('').trigger('keyup');
							$('#meta_xs_paddingall').val('').trigger('keyup');
							$('#meta_xs_marginall').val('').trigger('keyup');
							
						}
						
						$('input[name="metaspacing"]').val(item.val()).trigger('change');
					}	
				)
				$('select[name="contentspacingselect"]').on(
					'change',
					function(){
						var item=$(this);
						
						if($(this).val()=='custom'){
							$('.customcontentspacing').show();
						} else {
							
							$('.customcontentspacing').hide();
							$('#contentpaddingall').val('').trigger('keyup');
							$('#contentmarginall').val('').trigger('keyup');
							$('#content_lg_paddingall').val('').trigger('keyup');
							$('#content_lg_marginall').val('').trigger('keyup');
							$('#content_md_paddingall').val('').trigger('keyup');
							$('#content_md_marginall').val('').trigger('keyup');
							$('#content_sm_paddingall').val('').trigger('keyup');
							$('#content_sm_marginall').val('').trigger('keyup');
							$('#content_xs_paddingall').val('').trigger('keyup');
							$('#content_xs_marginall').val('').trigger('keyup');
						}
						
						$('input[name="contentspacing"]').val(item.val()).trigger('change');
					}	
				)	
			</cfif>
			
			<cfif request.hasFixedWidth>
			// constrain content
			$('#constraincontenttoggle').change(function(){
				if ($(this).is(':checked')){
					$('#objectconstrainsel').val('constrain').trigger('change').niceSelect('update');
				} else {
					$('#objectconstrainsel').val('').trigger('change').niceSelect('update');
				}
			})
			
			// expanded width
			function toggleExpandedWidth(){
				var expToggle = $('#expandedwidthtoggle');
				if ($(expToggle).is(':checked')){
					var contAlign = $('select[name="contentTextAlign"');
					contAlign.val(contAlign.val() == '' ? "left" : contAlign.val()).trigger('change').niceSelect('update');
					$('#objectwidthsel').val('mura-expanded').trigger('change').niceSelect('update');
				} else {
					$('#objectwidthsel').val('mura-twelve').trigger('change').niceSelect('update');
				}
			}

			$('#expandedwidthtoggle').change(function(){
				toggleExpandedWidth();
			})
			</cfif>

			// numeric input - select on focus
			$('#configuratorContainer input.numeric').on('click', function(){
				$(this).select();
			});

			// numeric input - restrict value
			$('#configuratorContainer input.numeric').on('keyup', function(){
				var v = $(this).val();
				var n = $(this).attr('name').toLowerCase();
				if (n == 'contentmarginleft' || n == 'contentmarginright' || n == 'metamarginleft' || n == 'metamarginright'){
					if (v == 'a'){
						v = 'auto';
					}
					if(!(v=='a' || v=='au' || v=='aut'|| v=='auto')){
						v=v.replace(numRE,'');
					}
				} else {
					v=v.replace(numRE,'');
				}
				$(this).val(v);
			});

			// colorpicker
			$('.mura-colorpicker input[type=text]').on('keyup',function(){
				if ($(this).val().length == 0){
					$(this).parents('.mura-colorpicker').find('.mura-colorpicker-swatch').css('background-color','transparent');
				}
			})

			//LAYOUT BEGIN
			$('.widthnum,.widthuom').on('change',function(){
				var nameandsize=$(this).closest('.bp-tab').data('nameandsize');
				var el = $('#' + nameandsize + 'widthuomval');
				var str = $('#' + nameandsize + 'widthuom').val();
				var num = $('#' + nameandsize + 'widthnum').val();
				console.log(num);
				if (Mura.isNumeric(num) && num != '0'){
					str = num + str;
				} else {
					str='';
				}
				
				$(el).val(str).trigger('change');
			});


			$('.minheightnum,.minheightuom').on('change',function(){
				var nameandsize=$(this).closest('.bp-tab').data('nameandsize');
				var el = $('#' + nameandsize + 'minheightuomval');
				var str = $('#' + nameandsize + 'minheightuom').val();
				var num = $('#' + nameandsize + 'minheightnum').val();
				if (Mura.isNumeric(num)){
					str = num + str;
				} else {
					str='';
				}
				$(el).val(str).trigger('change');
			});
			<!---
			$('.maxheightnum,.maxheightuom').on('change',function(){
				var nameandsize=$(this).closest('.bp-tab').data('nameandsize');
				var el = $('#' + nameandsize + 'maxheightuomval');
				var str = $('#' + nameandsize + 'maxheightuom').val();
				var num = $('#' + nameandsize + 'maxheightnum').val();
				if (Mura.isNumeric(num)){
					str = num + str;
				} else {
					str='';
				}
				$(el).val(str).trigger('change');
			});
			--->
			// Begin #nameAndSize# Margin and Padding
			function updatePadding(nameandsize){
				var t = $('#' + nameandsize + 'paddingtop').val().replace(numRE,'');
				var r = $('#' + nameandsize + 'paddingright').val().replace(numRE,'');
				var b = $('#' + nameandsize + 'paddingbottom').val().replace(numRE,'');
				var l =$('#' + nameandsize + 'paddingleft').val().replace(numRE,'');
				var u = $('#' + nameandsize + 'paddinguom').val();
				if (t.length){ $('#' + nameandsize + 'paddingtopval').val(t + u); } else { $('#' + nameandsize + 'paddingtopval').val(''); }
				if (r.length){ $('#' + nameandsize + 'paddingrightval').val(r + u); } else { $('#' + nameandsize + 'paddingrightval').val(''); }
				if (b.length){ $('#' + nameandsize + 'paddingbottomval').val(b + u); } else { $('#' + nameandsize + 'paddingbottomval').val(''); }
				if (l.length){ $('#' + nameandsize + 'paddingleftval').val(l + u); } else { $('#' + nameandsize + 'paddingleftval').val(''); }
				if (t == r && r == b && b == l){
					$('#' + nameandsize + 'paddingall').val(t);
				} else {
					$('#' + nameandsize + 'paddingall').val('');
					$('#' + nameandsize + 'paddingadvanced').show();
				}
				$('#' + nameandsize + 'paddingtopval').trigger('change');
			}

			$('.paddingall').on('keyup', function(){
				var nameandsize=$(this).closest('.bp-tab').data('nameandsize');
				var v = $('#' + nameandsize + 'paddingall').val().replace(numRE,'');
				$('#' + nameandsize + 'paddingadvanced').hide();
				$('#' + nameandsize + 'paddingtop').val(v);
				$('#' + nameandsize + 'paddingleft').val(v);
				$('#' + nameandsize + 'paddingright').val(v);
				$('#' + nameandsize + 'paddingbottom').val(v);
				updatePadding(nameandsize);
			})

			$('.paddingdimension').on('keyup', function(){
				var nameandsize=$(this).closest('.bp-tab').data('nameandsize');
				updatePadding(nameandsize);
			})

			$('.paddinguom').on('change',function(){
				var nameandsize=$(this).closest('.bp-tab').data('nameandsize');
				updatePadding(nameandsize);
			});
			
			// margin
			function updateMargin(nameandsize){
				var t = $('#' + nameandsize + 'margintop').val().replace(numRE,'');
				var r = $('#' + nameandsize + 'marginright').val();
				if(r != 'auto'){r=r.replace(numRE,'')}
				var b = $('#' + nameandsize + 'marginbottom').val().replace(numRE,'');
				var l =$('#' + nameandsize + 'marginleft').val();
				if(l != 'auto'){l=l.replace(numRE,'')}
				var u = $('#' + nameandsize + 'marginuom').val();
				if (t.length){ $('#' + nameandsize + 'margintopval').val(t + u); } else { $('#' + nameandsize + 'margintopval').val(''); }
				if(r=='auto'){
					$('#' + nameandsize + 'marginrightval').val(r);
				} else {
					if (r.length){ $('#' + nameandsize + 'marginrightval').val(r + u); } else { $('#' + nameandsize + 'marginrightval').val(''); }
				}
				if (b.length){ $('#' + nameandsize + 'marginbottomval').val(b + u); } else { $('#' + nameandsize + 'marginbottomval').val(''); }
				if(l=='auto'){
					$('#' + nameandsize + 'marginleftval').val(r);
				} else {
					if (l.length){ $('#' + nameandsize + 'marginleftval').val(l + u); } else { $('#' + nameandsize + 'marginleftval').val(''); }
				}
				if (t == r && r == b && b == l){
					$('#' + nameandsize + 'marginall').val(t);
				} else {
					$('#' + nameandsize + 'marginall').val('');
					$('#' + nameandsize + 'marginadvanced').show();
				}
				$('#' + nameandsize + 'margintopval').trigger('change');
			}

			$('.marginall').on('keyup', function(){
				var nameandsize=$(this).closest('.bp-tab').data('nameandsize');
				var v = $('#' + nameandsize + 'marginall').val().replace(numRE,'');
				$('#' + nameandsize + 'marginadvanced').hide();
				$('#' + nameandsize + 'margintop').val(v);
				$('#' + nameandsize + 'marginleft').val(v);
				$('#' + nameandsize + 'marginright').val(v);
				$('#' + nameandsize + 'marginbottom').val(v);
				updateMargin(nameandsize);
			})

			$('.margindimension').on('keyup', function(){
				var nameandsize=$(this).closest('.bp-tab').data('nameandsize');
				var val=$(this).val();
				if(!(val=='a' || val=='au' || val=='aut')){
					updateMargin(nameandsize);
				}
			});

			$('.marginuom').each(function(){
				var nameandsize=$(this).closest('.bp-tab').data('nameandsize');
				updateMargin(nameandsize);
			})
					
			$('.displaymodel').on(
				'change',
				function(){
					var bp=$(this).closest('.bp-tab');
					var nameandsize=bp.data('nameandsize')
					
					function hide(){
						var item=$(this);
							item.hide();
							item.find('select').val('').niceSelect('update');
							item.find('input').each(function(){
								if(this.getAttribute('type')=='range'){
									this.value=this.getAttribute('min');
								} else {
									this.value='';
								}	
							})
					}

					function show(){
						var item=$(this);
							item.show();
							item.find('input').each(function(){
								if(this.getAttribute('data-default')){
									this.value=this.getAttribute('data-default');
								}	
							})
							item.find('.labeledUnits').each(function(){
								this.innerHTML=this.getAttribute('data-default');
							})
					}
					
					if($(this).val() === 'block'){
						bp.find('.block-control-' + nameandsize).each(show);
						bp.find('.flex-control-' + nameandsize +',.grid-control-' + nameandsize).each(hide);
						
					} else if($(this).val() === 'grid'){
						bp.find('.grid-control-' + nameandsize).each(show);
						bp.find('.block-control-' + nameandsize + ',.flex-control-' + nameandsize).each(hide)
					} else {
						bp.find('.flex-control-' + nameandsize).each(show);
						bp.find('.block-control-' + nameandsize +',.grid-control-' + nameandsize).each(hide)
					}

					$('input[name="display"].' + nameandsize + 'Style').val(this.value).trigger('change');
			});
		
			//LAYOUT END
			//BEGIN BACKGOUND SELECTORS
			
			
			function updatePositionSelection(sel){
				var v = $(sel).val();
				var el = $(sel).attr('data-numfield');
				if (v == 'px' || v == '%' || v == 'vh' || v == 'vw'){
					$('#' + el).show();
				} else {
					$('#' + el).hide();
				}
			}
		
			// background image
			$('.backgroundimageurl').on('change',function(){
				var self=$(this);
				var v = self.val();
				var imageandsize=self.closest('.bp-tab').data('nameandsize');
				var str = "";
				if (typeof v !='undefined' && v.length > 3){
					str = "url('" + v + "')";
					$('.' + imageandsize + '-css-bg-option').show();
				} else {
					$('.' + imageandsize + '-css-bg-option').hide();
				}
				$('#' + imageandsize + 'backgroundimage').val(str).trigger('change');
			});
			
			$('.backgroundimageurl').each(function(){
				var self=$(this);
				var imageandsize=self.closest('.bp-tab').data('nameandsize');
				var v = $('#' + imageandsize + 'backgroundimageurl').val();
				var str = "";
				if (typeof v !='undefined' && v.length > 3){
					str = "url('" + v + "')";
					$('.' + imageandsize + '-css-bg-option').show();
				} else {
					$('.' + imageandsize + '-css-bg-option').hide();
				}

				//$('#' + imageandsize + 'backgroundimageurl').trigger('change');

				$('#' + imageandsize + 'backgroundpositiony,#' + imageandsize + 'backgroundpositionynum').on('change',function(){
					var el = $('#' + imageandsize + 'backgroundpositionyval');
					var str = $('#' + imageandsize + 'backgroundpositiony').val();
					var num = $('#' + imageandsize + 'backgroundpositionynum').val();
					if (num.length > 0){
						str = num + str;
					}
					$(el).val(str).trigger('change');
				});

				$('#' + imageandsize + 'backgroundpositionx,#' + imageandsize + 'backgroundpositionxnum').on('change',function(){
					var el = $('#' + imageandsize + 'backgroundpositionxval');
					var str = $('#' + imageandsize + 'backgroundpositionx').val();
					var num = $('#' + imageandsize + 'backgroundpositionxnum').val();
					if (num.length > 0){
						str = num + str;
					}
					$(el).val(str).trigger('change');
				});

				$('#' + imageandsize + 'backgroundpositionx,#' + imageandsize + 'backgroundpositiony').on('change',function(){
					updatePositionSelection($(this));
				});

				$('#' + imageandsize + 'backgroundpositionx,#' + imageandsize + 'backgroundpositiony').each(function(){
					updatePositionSelection($(this));
				});
				/*
				$('select[name="custom#attributes.name#backgroundtarget"').on('change',
					function(){
						$('.#attributes.name#_#size#__background_option').hide();
						$('#' + $(this).val() + '_background').show();
					});
				*/
			});
			//END BACKGOUND SELECTORS
			
			// breakpoint toggles	
			$('div.breakpointtoggle').each(function(){		
					var bpId = 'bpicons-' + $(this).attr('id');	
					var tabWrapper = $(this).find('.' + $(this).attr('data-toggle'));	
					var bpIcons = '<div class="mura-ui-row bp-nav-tab">'
					+ '<div class="bp-icon-row" id="' + bpId + '">'
					+ '<span title="Desktop (xl)" data-tab="bp-tab-xl" class=" bp-current">'
					+ '<i class="mi-desktop bp-icon-xl">'
					+ '</i>'
					+ '</span>'
					+ '<span title="Tablet Desktop (lg)" data-tab="bp-tab-lg">'
					+ '<i class="mi-tablet bp-icon-lg mi-rotate-270">'
					+ '</i>'
					+ '</span>'
					+ '<span title="Table Portrait (md)" data-tab="bp-tab-md">'
					+ '<i class="mi-tablet bp-icon-md">'
					+ '</i>'
					+ '</span>'
					+ '<span title="Mobile Landscape (sm)" data-tab="bp-tab-sm">'
					+ '<i class="mi-mobile-phone bp-icon-sm mi-rotate-270">'
					+ '</i>'
					+ '</span>'
					+ '<span title="Mobile Portrait (xs)" data-tab="bp-tab-xs">'
					+ '<i class="mi-mobile-phone bp-icon-xs">'
					+ '</i>'
					+ '</span>'
					+ '</div>'
					+ '</div>';
					$(this).prepend(bpIcons);	
					$(tabWrapper).addClass('bp-tabs-wrapper');	
					// show corresponding on click of icon	
					$('#' + bpId + ' > *').on('click',function(){	
						var targetEl = $(tabWrapper).find('.' + $(this).attr('data-tab'));	
						
						// add marker class to link and tab	 	
						$(this).addClass('bp-current').siblings().removeClass('bp-current');	
						$(targetEl).show().addClass('bp-current').siblings('.bp-tab').removeClass('bp-current').hide();	
					});	
			});

			// Layout breakpoint watcher
			var tab = {
				getBreakpoint: function (input) {
					var breakpoint = $(input).closest('.bp-tab').data('breakpoint');
					
					if (!breakpoint) {
						return false;
					}

					switch(breakpoint) {
						case 'xs': return 'bp-tab-xs';
						case 'sm': return 'bp-tab-sm';
						case 'md': return 'bp-tab-md';
						case 'lg': return 'bp-tab-lg';
					}

					return 'bp-tab-xl';
				},
				hasDefaultValue: function (tab) {
					var hasDefaultValue = true;
					var defaults={
						'px':true,
						'flex':true,
						'rem':true,
						'auto':true,
						'scroll':true,
						'top':true,
						'left':true,
						'no-repeat':true,
						'%':true,
						'100%':true,
						'0':true
					}
					tab.find('input, select').each(function() {
						var value =$(this).val();
						if (value && typeof defaults[value] ==  'undefined') { 
							hasDefaultValue = false; 
						}

						if(!hasDefaultValue){
							return false;
						}
					});

					return hasDefaultValue;
				},
				toggleNotify: function (input) {
					var activeTab = tab.getBreakpoint(input);
					var tabs=$(input).closest('.breakpointtoggle');
					
					if (activeTab) {
						var navTab = $('#' + tabs.attr('id') + ' > .bp-nav-tab > div > span[data-tab=' + activeTab +']');
						var tabContent =  $('#' + tabs.attr('id') + ' > .bp-tabs > .' + activeTab);
						var hasDefaultValue = tab.hasDefaultValue(tabContent);

						if (!hasDefaultValue) {
							navTab.addClass('bp-notify');
						} else {
							navTab.removeClass('bp-notify');
						}
					}
				}
			};

			$('div[data-toggle="bp-tabs"] > .bp-tabs').find('input, select').each(function() {
				tab.toggleNotify(this);
				$(this).on('change', function() {
					tab.toggleNotify(this);
				});
			});

			$('.btn-group').hover(function(){ 
				$(this).addClass('open'); 
			}, function(){ 
				$(this).removeClass('open'); 
			});
		
			//This is in setConfigPanelStates
			//window.configuratorInited=true;
		});
	
		function saveModuleTemplate(){
			var templatename=$.trim($('#templatename').val());
			if(templatename){
				<cfoutput>frontEndProxy.post({cmd:'saveobject',templatename:templatename,instanceid:'#esapiEncode('javascript',attributes.params.instanceid)#'});</cfoutput>
			} else {
				alert("A template name is required.");
				$('#templatename').focus()
			}
		}
			
	</script>
	</cfif>
</cfif>
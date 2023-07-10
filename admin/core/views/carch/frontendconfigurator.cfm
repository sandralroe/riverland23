
<cfsilent>
	<cfset event=request.event>
	<cfset $=rc.$>
	<cfparam name="rc.layoutmanager" default="false">

	<cfif $.useLayoutManager()>
		<cfparam name="rc.sourceFrame" default="sidebar">
	<cfelse>
		<cfparam name="rc.sourceFrame" default="modal">
	</cfif>

	<cfparam name="rc.object" default="">
	<cfparam name="rc.objectname" default="">
	<cfparam name="rc.objecticonclass" default="mi-cog">
	<cfparam name="rc.isnew" default="false">
	<cfparam name="rc.cssDisplay" default="flex">

	<cfif not len(rc.objectname) and len(rc.object) gt 1 or rc.objectname eq 'null' or rc.objectname eq 'undefined' or rc.objectname eq '""'>
		<cfif rc.$.siteConfig().hasDisplayObject(rc.object)>
			<cfset objectDef=rc.$.siteConfig().getDisplayObject(rc.object)>
			<cfset rc.objectname=objectDef.name>
		<cfelse>
			<cfset rc.objectname=ucase(left(rc.object,1)) & right(rc.object,len(rc.object)-1)>
		</cfif>
	</cfif>

	<cfif not len(rc.objecticonclass)>
		<cfset rc.objecticonclass="mi-cog">
	</cfif>
</cfsilent>

<cfinclude template="js.cfm">
<cfif rc.layoutmanager>
<cfoutput>
<cfif rc.sourceFrame  eq 'modal'>
	<div class="mura-header"> 
		<h1 id="configuratorHeader">Loading...</h1>
	</div>
	<div class="block block-constrain">
		<div class="block block-bordered">
		  <div class="block-content">
</cfif>
			<div id="configuratorContainer">
				<cfif rc.sourceFrame eq 'sidebar'>
					<h1 id="configuratorHeader"></h1>
					<a class="mura-close" onclick="frontEndProxy.post({cmd:'showobjects'});"><i class="mi-close"></i></a>
				</cfif>

				<div class="clearfix">
					<div id="configurator"><div class="load-inline"></div></div>
					<!---
					<div style="float: right; width: 30%;"><h2>Preview</h2>
					<iframe id="configuratorPreview" style="width:100%;height:700px;" marginheight="0" marginwidth="0" frameborder="0" src=""></iframe>
					</div>
					--->
				</div>
				<div class="form-actions" style="display:none">
					<cfif  not (isdefined('rc.hasTargetAttr') and rc.hasTargetAttr)>
						<a href="##" class="btn mura-delete" id="deleteObject"><i class="mi-trash"></i> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.delete"))#</a>

						<cfif rc.sourceFrame eq 'modal'>
							<a href="##" class="btn mura-primary" id="saveConfigDraft"><i class="mi-check"></i> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.apply"))#</a>
						<cfelse>
							<a href="##" class="btn mura-clone " id="cloneConfigurator" onclick="frontEndProxy.post({cmd:'cloneobject',instanceid:'#esapiEncode('javascript',rc.instanceid)#'});"><i class="mi-clone"></i> Clone</a>
							<a href="##" class="btn mura-primary" id="closeConfigurator" onclick="frontEndProxy.post({cmd:'showobjects'});"><i class="mi-check"></i> Done</a>
						</cfif>
					<cfelse>
						<a href="##" class="btn mura-primary" id="closeConfigurator" onclick="frontEndProxy.post({cmd:'showobjects'});"><i class="mi-check"></i> Done</a>
					</cfif>
				</div>
				
			</div><!-- /configuratorContainer -->
<cfif rc.sourceFrame eq 'modal'>
		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</cfif>

<cfif len(rc.$.event('preloadOnly'))>
	<script>
		$('##configurator .load-inline').spin(spinnerArgs2);
	</script>
<cfelse>
	<cfinclude template="dsp_configuratorJS.cfm">
	<script>
		$('##configurator .load-inline').spin(spinnerArgs2);
		siteManager.configuratorMode='frontEnd';
		siteManager.layoutmanager=true;
		
		var instanceid='#esapiEncode('javascript',rc.instanceid)#';
		var configOptions={};
		var originParams={};
		var originid='#esapiEncode('javascript',rc.objectid)#';
		window.configuratorInited=false;

		var updateDraft=function(windowInited){

				if(!window.configuratorInited){
					return;
				}
				
				if(typeof currentPanel == 'undefined'){
					currentPanel='';
				}
				
				siteManager.updateAvailableObject();

				var availableObjectSelector=jQuery('##availableObjectSelector');

				if(availableObjectSelector.length){
					$.extend(siteManager.availableObject.params,eval('(' + availableObjectSelector.val() + ')') );
				}

				if (siteManager.availableObjectValidate(siteManager.availableObject.params)) {
					<cfif rc.sourceFrame eq 'modal'>
						jQuery("##configurator").html('<div class="load-inline"></div>');
						$('##configurator .load-inline').spin(spinnerArgs2);
						jQuery(".form-actions").hide();
					</cfif>

					var reload=false;

					if(siteManager.availableObject.params.objectid && siteManager.availableObject.params.objectid != 'none' & siteManager.availableObject.params.objectid != originid){
						reload=siteManager.getPluginConfigurator(siteManager.availableObject.params.objectid);
					}

					//console.log(siteManager.availableObject.params);

					frontEndProxy.post(
					{
						cmd:'setObjectParams',
						instanceid:instanceid,
						params:siteManager.availableObject.params,
						reinit:(reload) ? true : false,
						currentPanel:currentPanel
					});

				}
			}

		$(function(){

			function initConfiguratorProxy(){

				function onFrontEndMessage(messageEvent){

					var parameters=messageEvent.data;
				
					if (parameters["cmd"] == "requestObjectConfigurator"){
						
						var configuratorEl=$('[data-configurator="' + parameters.target + '"]');
						var configurator=[];
					
						if(configuratorEl.length){
							configurator=configuratorEl.val();
						}
						//console.log('getting')
						frontEndProxy.post({
							cmd:'requestedObjectConfigurator',
							configurator:configurator,
							instanceid:'#esapiEncode("javascript",rc.instanceid)#',
							contenthistid:'#esapiEncode("javascript",rc.contenthistid)#'
						});

					} else if (parameters["cmd"] == "setObjectParams") {
						//console.log(parameters)
						if(typeof parameters["complete"] != 'undefined' && !parameters["complete"]){
							var updated=false;
							for(var p in parameters["params"]){
								if(parameters["params"].hasOwnProperty(p)){
									item=$('[name="' + p + '"]');
									if(item.length){
										var propTarget=$('.objectParam[name="' + p + '"],.objectparam[name="' + p + '"],.styleSupport[name="' + p + '"],.stylesupport[name="' + p + '"],.objectStyle[name="' + p + '"], .object_lg_Style[name="' + p + '"], .object_md_Style[name="' + p + '"], .object_sm_Style[name="' + p + '"], .object_xs_Style[name="' + p + '"], .objectstyle[name="' + p + '"], .contentStyle[name="' + p + '"], .content_lg_Style[name="' + p + '"], .content_md_Style[name="' + p + '"], .content_sm_Style[name="' + p + '"], .content_xs_Style[name="' + p + '"], .contentstyle[name="' + p + '"], .metaStyle[name="' + p + '"], .meta_lg_Style[name="' + p + '"], .meta_md_Style[name="' + p + '"], .meta_sm_Style[name="' + p + '"], .meta_xs_Style[name="' + p + '"], .metastyle[name="' + p + '"]');

										propTarget.each(function(){
											var input=$(this);
											input.val(parameters["params"][p]);
											if(input.is('select')){
												input.niceSelect('update');
											}
										});
										
										propTarget.trigger('change');
										updated=true;	
									}
									
								}
							}
							if(!updated){
								updateDraft();
							}
						} else {
							
							if(parameters["params"]){
								originParams=parameters["params"];
							}

							//console.log(parameters)

							if(parameters.params.isbodyobject){
								$(".form-actions").hide();
							}

							if(typeof parameters.params.pinned != 'undefined' && parameters.params.pinned){
								$('##deleteObject, ##cloneConfigurator').hide();
							}
							configOptions={
								'object':'#esapiEncode('javascript',rc.object)#',
								'objectid':'#esapiEncode('javascript',rc.objectid)#',
								'name':'#esapiEncode('javascript',rc.objectname)#',
								'iconclass':'#esapiEncode('javascript',rc.objecticonclass)#',
								'isnew':'#esapiEncode('javascript',rc.isnew)#',
								'regionid':'0',
								'context':'#application.configBean.getContext()#',
								'params':encodeURIComponent(JSON.stringify(parameters["params"])),
								'siteid':'#esapiEncode('javascript',rc.siteid)#',
								'contenthistid':'#esapiEncode('javascript',rc.contenthistid)#',
								'contentid':'#esapiEncode('javascript',rc.contentID)#',
								'parentid':'#esapiEncode('javascript',rc.parentID)#',
								'contenttype':'#esapiEncode('javascript',rc.contenttype)#',
								'contentsubtype':'#esapiEncode('javascript',rc.contentsubtype)#',
								'instanceid':'#esapiEncode('javascript',rc.instanceid)#',
								'cssdisplay':'#esapiEncode('javascript',rc.cssdisplay)#'
							}

							//console.log('configparams',parameters["params"],configOptions.params);

							<cfset configuratorWidth=600>

							<cfif not listFindNoCase('feed,relatedcontent,feed_slideshow,category_summary',rc.object) and $.siteConfig().hasDisplayObject(rc.object)>
								var configurator=siteManager.getPluginConfigurator('#esapiEncode('javascript',rc.objectid)#');

								if(configurator!=''){
									window[configurator](
										configOptions
									);
								} else {
									siteManager.initGenericConfigurator(configOptions);
								}

								jQuery("##configuratorHeader").html('#esapiEncode('javascript','<i class="#rc.objecticonclass#"></i> #rc.objectname#')#');
							<cfelse>
								<cfswitch expression="#rc.object#">
									<cfdefaultcase>
										if(siteManager.objectHasConfigurator(configOptions)){
											siteManager.configuratorMap[configOptions.object].initConfigurator(configOptions);
										} else {
											siteManager.initGenericConfigurator(configOptions);
										}
									</cfdefaultcase>
								</cfswitch>
							</cfif>
							//siteManager.loadObjectPreview(configOptions);
						}
					}
				}

				frontEndProxy.addEventListener(onFrontEndMessage);
				frontEndProxy.post({cmd:'setWidth',width:'#configuratorWidth#'});
				frontEndProxy.post({
					cmd:'requestObjectParams',
					instanceid:'#esapiEncode("javascript",rc.instanceid)#',
					targetFrame:'#esapiEncode("javascript",rc.sourceFrame)#'
					}
				);

			}

			if (top.location != self.location) {
				if(jQuery("##ProxyIFrame").length){
					jQuery("##ProxyIFrame").load(
						function(){
							initConfiguratorProxy()
						}
					);
				} else {
					initConfiguratorProxy();
				}
			}

			<cfif rc.sourceFrame eq 'modal'>
			jQuery("##saveConfigDraft").bind("click",function(){
				window.configuratorInited=true;
				updateDraft();
			});
			<cfelse>
			jQuery('##configuratorContainer').on('change',
				siteManager.getConfiguratorTargets() + ', ##availableObjectSelector',
				updateDraft
			);
			</cfif>

			jQuery("##deleteObject").bind("click",
			function(){
				frontEndProxy.post(
				{
					cmd:'deleteObject',
					instanceid:instanceid
				});
			});

			function editHistoryListenter(event) {
				if((event.ctrlKey || event.metaKey) && event.shiftKey && event.key === 'z') {
					frontEndProxy.post({cmd:'redo'});
				} else if ((event.ctrlKey || event.metaKey) && event.key === 'z') {
					frontEndProxy.post({cmd:'undo'});
				}	
			}
		
			document.removeEventListener('keydown',editHistoryListenter);
			document.addEventListener('keydown',editHistoryListenter);
		});

	</script>
	</cfif>
	</cfoutput>
<cfelse>
<cfinclude template="legacy/frontendconfigurator.cfm">
</cfif>

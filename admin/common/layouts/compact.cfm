<cfsilent><cfparam name="request.action" default="core:cplugin.plugin">
<cfparam name="rc.originalfuseaction" default="#listLast(listLast(request.action,":"),".")#">
<cfparam name="rc.originalcircuit"  default="#listFirst(listLast(request.action,":"),".")#">
<cfparam name="rc.jsLib" default="jquery">
<cfparam name="rc.jsLibLoaded" default="false">
<cfparam name="rc.activetab" default="0">
<cfparam name="rc.activepanel" default="0">
<cfparam name="rc.siteid" default="#session.siteID#"><cfoutput></cfoutput>
<cfparam name="rc.frontEndProxyLoc" default="">
<cfparam name="session.frontEndProxyLoc" default="#rc.frontEndProxyLoc#">
<cfparam name="rc.sourceFrame" default="modal">
<cfset hasAdminAccess=len(session.siteid) and rc.$.currentUser().isLoggedIn() and (rc.$.currentUser().isPrivateUser() || application.permUtility.getModulePerm("00000000000000000000000000000000000",session.siteid))>

<cfif len(rc.frontEndProxyLoc)>
	<cfset session.frontEndProxyLoc=rc.frontEndProxyLoc>
</cfif>
</cfsilent><cfoutput><cfprocessingdirective suppressWhitespace="true"><!DOCTYPE html>
<cfif cgi.http_user_agent contains 'msie'>
	<!--[if IE 8 ]><html class="mura ie ie8" lang="#esapiEncode('html_attr',session.locale)#"><![endif]-->
	<!--[if (gte IE 9)|!(IE)]><!--><html lang="#esapiEncode('html_attr',session.locale)#" class="mura ie"><!--<![endif]-->
<cfelse>
<!--[if IE 9]> <html lang="en_US" class="ie9 mura no-focus"> <![endif]-->
<!--[if gt IE 9]><!--> <html lang="#esapiEncode('html_attr',session.locale)#" class="mura no-focus"><!--<![endif]-->
</cfif>
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

		<title>#esapiEncode('html', application.configBean.getTitle())#</title>
    	<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1.0">
		<meta name="author" content="Mura Software">
		<meta name="robots" content="noindex, nofollow, noarchive">
		<meta http-equiv="cache control" content="no-cache, no-store, must-revalidate">

		<cfif Len(application.configBean.getWindowDocumentDomain())>
			<script type="text/javascript">
				window.document.domain = '#application.configBean.getWindowDocumentDomain()#';
			</script>
		</cfif>

		<!--- global admin scripts --->
		<cfinclude template="includes/html_head.cfm">

		<!-- Utilities to support iframe communication -->
		<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/porthole/porthole.min.js?coreversion=#application.coreversion#" type="text/javascript"></script>
		<link href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/css/admin.min.css?coreversion=#application.coreversion#" rel="stylesheet" type="text/css" />
		#session.dateKey#
		<script type="text/javascript">
			var frontEndProxy = new Porthole.WindowProxy("#esapiEncode('javascript',session.frontEndProxyLoc)##application.configBean.getContext()##application.configBean.getAdminDir()#/assets/js/porthole/proxy.html?cacheid=" + Math.random());

			function getHeight(){
				if(document.all){
					return Math.max(document.body.scrollHeight, document.body.offsetHeight,160);
				} else {
					return Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight,160);
				}
			}

			var resizeTabPane = function(offsetVal){
				if (isNaN(offsetVal)){
					offsetVal = 17;
				}
				// set width of pane relative to side controls
				if ($('##mura-content-body-block').length){

					var blockW = $('##mura-content-body-block').width();
					var controlW = $('##mura-content-body-block .mura__edit__controls').width();
					var newW = (blockW - controlW) - offsetVal;

					$('##mura-content-body-block .block-content.tab-content').css('width',newW + 'px');
					setTimeout(function(){
						resizeBodyEditor();
					}, 50)
				}
				// set heights, accounting for header
				if ($('##dspStatusContainer').length){
					var tabContent = $('##mura-content-body-block>.tab-content');
					var controls = $('##mura-content-body-block .mura__edit__controls');
					var statusH = $('##dspStatusContainer').height();
					var origBlockH = $('##mura-content-body-block').height();
					var origTabH = $(tabContent).height();
					var origControlsH = $(controls).height();
					var newBlockH = origBlockH - statusH;
					var newTabH = origTabH - 90;
					var newControlsH = origControlsH - statusH + 12;

					$('##mura-content-body-block').css('height',newBlockH);
					$(tabContent).css('height',newTabH);
					$(controls).css('height',newControlsH);
				
					frontEndProxy.post({cmd:
						'setHeight',
						height:getHeight(),
						'targetFrame': '#esapiEncode("javascript",rc.sourceFrame)#'
					});
				}

			}

			// set height of ckeditor content area - called by resizeTabPane()
			var resizeBodyEditor = function(){
				if ($('##bodyContainer .cke_contents').length){
					let editor=$('##bodyContainer .cke_contents');
					let padding = 25;
					let editorTop = $('##mura-content-body-render .cke_top').outerHeight() || 0;
					let titleRenderHeight = $('##mura-content-title-render').outerHeight(true) || 0;
					let containerHeight = $('##mura-content-body-block').height() || 0;
					var extendsetContainerPrimaryH =  $("##extendset-container-primary").height() || 0;
					let offsetH = containerHeight - (titleRenderHeight + editorTop + padding + extendsetContainerPrimaryH);
					// also adjust cke height

					offsetH=(offsetH < 200) ? 200 : offsetH;

					editor.css('height','calc((100vh - ' + offsetH +  'px) - 260px)');
				}
			}

			$(window).on("load", function() {
				resizeTabPane();
				$('##mura-content-body-render').show();
			});

			jQuery(document).ready(function(){
				//nice-select
				$('.mura__edit__controls .mura-control-group select:not(.multiSelect)').niceSelect();

				// tabdrop: trigger on page load w/ slight delay
				if ( $( '.mura-tabs').length ) {
					var triggerTabDrop = function(){
						setTimeout(function(){
							$('.mura-tabs').tabdrop({text: '<i class="mi-chevron-down"></i>'});
								$('.tabdrop .dropdown-toggle').parents('.nav-tabs').css('overflow-y','visible');
								$('.tabdrop a.dropdown-toggle .display-tab').html('<i class="mi-chevron-down"></i>');
						}, 10);
					}
					// run on page load
					triggerTabDrop();
					// run on resize
					$(window).resize(function(){
						$('.nav-tabs').css('overflow-y','hidden').find('li.tabdrop').removeClass('open').find('.dropdown-backdrop').remove();
							triggerTabDrop();
					});
					$('.tabdrop .dropdown-toggle').on('click',function(){
						$(this).parents('.nav-tabs').css('overflow-y','visible');
					});
				}
				// /tabdrop

			
				frontEndProxy.post({
					cmd:'setHeight',
					height:getHeight(),
					'targetFrame': '#esapiEncode("javascript",rc.sourceFrame)#'
				});

				jQuery(this).resize(function(e){
					frontEndProxy.post({cmd:
						'setHeight',
						height:getHeight(),
						'targetFrame': '#esapiEncode("javascript",rc.sourceFrame)#'
					});
				});

				frontEndProxy.addEventListener(siteManager.frontEndProxyListener);
					
				// click to close new table actions, category selector filter
				document.onclick = function(e) {
					if (jQuery('##newContentMenu').length > 0){
						if(!(jQuery(e.target).parents().hasClass('addNew')) && !(jQuery(e.target).parents().hasClass('add')) && !(jQuery(e.target).hasClass('add'))){
							jQuery('##newContentMenu').addClass('hide');
						}
					};

					if (jQuery('.actions-menu').length > 0){
						if(!(jQuery(e.target).parents().hasClass('actions-menu')) && !(jQuery(e.target).parents().hasClass('actions-list')) && !(jQuery(e.target).parents().hasClass('show-actions')) && !(jQuery(e.target).hasClass('actions-list'))){
							jQuery('.actions-menu').addClass('hide');
						}
					};

					if(jQuery('##category-select-list').length > 0){
					if(!(jQuery(e.target).parents().hasClass('category-select')) && !(jQuery(e.target).parents().hasClass('categories'))){
							jQuery('##category-select-list').slideUp('fast');
						}
					}
				};
				// /click to close

			});
			
			<cfif isDefined('session.siteid') and len(session.siteid)>
				<cfset site=$.getBean('settingsManager').getSite(session.siteid)>
			<cfelse>
				<cfset site=$.getBean('settingsManager').getSite('default')>
			</cfif>
			<cfset rootpath=$.getBean('utility').getRequestProtocol() & "://" & $.getBean('utility').getRequestHost() & $.globalConfig('serverPort') & $.globalConfig('context')>
			Mura.init({
				inAdmin:true,
				initialProcessMarkupSelector:'',
				siteid:'#esapiEncode("javascript",site.getSiteID())#',
				fileassetpath:'#esapiEncode("javascript",site.getFileAssetPath(complete=1))#',
				rootpath:'#esapiEncode("javascript",rootpath)#',
				adminpath:'#esapiEncode("javascript",$.siteConfig("adminpath"))#',
				corepath:'#esapiEncode("javascript",rootpath)#/core',
				indexfileinapi:true
			});
		</script>
		#rc.ajax#

		<cfif cgi.http_user_agent contains 'msie'>
			<!--[if lte IE 8]>
			<link href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/css/ie.min.css?coreversion=#application.coreversion#" rel="stylesheet" type="text/css" />
			<![endif]-->
		</cfif>
	</head>
	<body id="#esapiEncode('html_attr',rc.originalcircuit)#" class="compact <cfif rc.sourceFrame eq 'modal'>modal-wrapper<cfelse>configurator-wrapper</cfif>">
		<div id="mura-content">
		<cfif rc.sourceFrame eq 'modal'>
			<a id="frontEndToolsModalClose" href="javascript:frontEndProxy.post({cmd:'close'});"><i class="mi-close"></i></a>
			<cfinclude template="includes/dialog.cfm">
		</cfif>

		<div class="main mura-layout-row"></cfprocessingdirective>#body#<cfprocessingdirective suppressWhitespace="true"></div>

		</div> <!-- /mura-content -->

		<cfinclude template="includes/html_foot.cfm">
	</body>
</html></cfprocessingdirective>
</cfoutput>

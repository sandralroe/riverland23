<!--- license goes here --->
<cfoutput>

<!-- Favicons -->
	<link rel="icon" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/ico/favicon.ico" type="image/x-icon" />
	<link rel="shortcut icon" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/ico/favicon.ico" type="image/x-icon" />
	<link rel="apple-touch-icon-precomposed" sizes="144x144" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/ico/apple-touch-icon-144-precomposed.png">
	<link rel="apple-touch-icon-precomposed" sizes="114x114" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/ico/apple-touch-icon-114-precomposed.png">
	<link rel="apple-touch-icon-precomposed" sizes="72x72" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/ico/apple-touch-icon-72-precomposed.png">
	<link rel="apple-touch-icon-precomposed" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/assets/ico/apple-touch-icon-57-precomposed.png">

	<!-- jQuery -->
	<script type="text/javascript" src="#application.configBean.getContext()#/core/vendor/jquery/jquery.min.js?coreversion=#application.coreversion#"></script>
	
	<!-- Mura.js -->
	<script type="text/javascript" src="#application.configBean.getContext()#/core/modules/v1/core_assets/js/mura.min.js?coreversion=#application.coreversion#"></script>

	<!-- OneUI Core JS: Bootstrap, slimScroll, scrollLock, Appear, CountTo, Placeholder, Cookie and App.js -->
	<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/dist/theme.bundle.js?coreversion=#application.coreversion#" type="text/javascript"></script>

	<!-- jQuery UI components -->
	<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/dist/jquery.bundle.js?coreversion=#application.coreversion#" type="text/javascript"></script>

	<!-- Mura Admin modules components -->
	<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/dist/modules.bundle.js?coreversion=#application.coreversion#" type="text/javascript"></script>

	<cfif not(isDefined('url.muraAction') and url.muraAction eq 'cArch.frontEndConfigurator')>
	<!-- CK Editor -->
	<script type="text/javascript" src="#application.configBean.getContext()#/core/vendor/ckeditor/ckeditor.js?coreversion=#application.coreversion#"></script>
	<script type="text/javascript" src="#application.configBean.getContext()#/core/vendor/ckeditor/adapters/jquery.js?coreversion=#application.coreversion#"></script>
	
	<script src="#application.configBean.getContext()##application.configBean.getAdminDir()#/dist/filebrowser.bundle.js?coreversion=#application.coreversion#"></script>
	</cfif>
	<!-- Color Picker -->
	<script type="text/javascript" src="#application.configBean.getContext()#/core/vendor/colorpicker/js/bootstrap-colorpicker.js?coreversion=#application.coreversion#"></script>
	<link href="#application.configBean.getContext()#/core/vendor/colorpicker/css/bootstrap-colorpicker.min.css?coreversion=#application.coreversion#" rel="stylesheet" type="text/css" />
	
	<script type="text/javascript">
	var htmlEditorType='#application.configBean.getValue("htmlEditorType")#';
	var context='#application.configBean.getContext()#';
	var themepath='#application.settingsManager.getSite(rc.siteID).getThemeAssetPath()#';
	var rootpath='#application.settingsManager.getSite(rc.siteID).getRootPath(complete=1)#';
	var rb='#lcase(esapiEncode('javascript',session.rb))#';
	var siteid='#esapiEncode('javascript',session.siteid)#';
	var sessionTimeout=#evaluate("application.configBean.getValue('sessionTimeout') * 60")#;
	var activepanel=#esapiEncode('javascript',rc.activepanel)#;
	var activetab=#esapiEncode('javascript',rc.activetab)#;
	<cfif $.currentUser().isLoggedIn()>var webroot='#esapiEncode('javascript',left($.globalConfig("webroot"),len($.globalConfig("webroot"))-len($.globalConfig("context"))))#';</cfif>
	var fileDelim='#esapiEncode('javascript',$.globalConfig("fileDelim"))#';
	var themeColorOptions=#serializeJSON($.siteConfig().getContentRenderer().getColorOptions())#;
	var moduleThemeOptions=#serializeJSON($.siteConfig().getContentRenderer().getModuleThemeOptions())#;
	</script>

</cfoutput>

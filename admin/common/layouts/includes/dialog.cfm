<!--- license goes here --->
<cfoutput>
<div id="alertDialog" title="Alert" class="hide">
	<span id="alertDialogMessage"></span>
</div>
<cfif isDefined('rc.$') and len(rc.$.event('siteid')) and isObject(rc.$.siteConfig().getRazunaSettings()) and len(rc.$.siteConfig().getRazunaSettings().getApiKey())>
	<link rel="stylesheet" id="theme" href="#$.globalConfig('context')##$.globalConfig('adminDir')#/assets/css/jstree/style.css" type="text/css" media="screen" />
	<script>
	   razuna_folder = "#rc.$.globalConfig('context')##$.globalConfig('adminDir')#/";
	   razuna_servertype="#rc.$.siteConfig().getRazunaSettings().getServerType()#";
	</script>
	<script src="#rc.$.globalConfig('context')##$.globalConfig('adminDir')#/assets/js/razuna.js" type="text/javascript"></script>
	<script src="#rc.$.globalConfig('context')##$.globalConfig('adminDir')#/assets/js/jquery/jquery.jstree.js" type="text/javascript"></script>
	</cfif>
</cfoutput>

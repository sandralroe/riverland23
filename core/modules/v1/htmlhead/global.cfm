<!--- license goes here --->
<cfif request.returnformat neq 'amp' and not $.siteConfig('isRemote')>
<cfif this.deferMuraJS>
<cfoutput>
<script type="text/javascript" src="#$.globalConfig('context')#/core/modules/v1/core_assets/js/mura.min.js?v=#$.globalConfig('version')#" defer="defer"></script>
<script>
(function(root,config){root.queuedMuraCmds=[],root.queuedMuraPreInitCmds=[],root.deferMuraInit=function(){void 0!==root.Mura&&"function"==typeof root.Mura.init?root.Mura.init(config):("function"!=typeof root.Mura&&(root.mura=root.m=root.Mura=function(o){root.queuedMuraCmds.push(o)},root.Mura.preInit=function(o){root.queuedMuraPreInitCmds.push(o)}),setTimeout(root.deferMuraInit))},root.deferMuraInit();}
)(this,{
loginURL:"#variables.$.siteConfig('LoginURL')#",
siteid:"#variables.$.event('siteID')#",
contentid:"#variables.$.content('contentid')#",
contenthistid:"#variables.$.content('contenthistid')#",
changesetid:"#variables.$.content('changesetid')#",
parentid:"#variables.$.content('parentid')#",
context:"#variables.$.globalConfig('context')#",
indexfileinapi:#variables.$.globalConfig().getValue(property='indexfileinapi',defaultValue=true)#,
nocache:#val($.event('nocache'))#,
assetpath:"#variables.$.siteConfig('assetPath')#",
corepath:"#variables.$.globalConfig('corepath')#",
fileassetpath:"#variables.$.siteConfig('fileAssetPath')#",
themepath:"#variables.$.siteConfig('themeAssetPath')#",
reCAPTCHALanguage:"#$.siteConfig('reCAPTCHALanguage')#",
preloaderMarkup: "#esapiEncode('javascript',this.preloaderMarkup)#",
mobileformat: #esapiEncode('javascript',$.event('muraMobileRequest'))#,
windowdocumentdomain: "#application.configBean.getWindowDocumentDomain()#",
layoutmanager:#variables.$.getContentRenderer().useLayoutManager()#,
type:"#esapiEncode('javascript',variables.$.content('type'))#",
subtype:"#esapiEncode('javascript',variables.$.content('subtype'))#",
queueObjects: #esapiEncode('javascript',this.queueObjects)#,
rb:#variables.$.siteConfig().getAPI('json','v1').getSerializer().serialize(variables.$.getClientRenderVariables())#,
#trim(variables.$.siteConfig('JSDateKeyObjInc'))#
});
</script>
</cfoutput>
<cfelse>
<cfoutput>
<script type="text/javascript" src="#$.globalConfig('context')#/core/modules/v1/core_assets/js/mura.min.js?v=#$.globalConfig('version')#"></script>
<script>
Mura.init({
loginURL:"#variables.$.siteConfig('LoginURL')#",
siteid:"#variables.$.event('siteID')#",
contentid:"#variables.$.content('contentid')#",
contenthistid:"#variables.$.content('contenthistid')#",
changesetid:"#variables.$.content('changesetid')#",
parentid:"#variables.$.content('parentid')#",
context:"#variables.$.globalConfig('context')#",
indexfileinapi:#variables.$.globalConfig().getValue(property='indexfileinapi',defaultValue=true)#,
nocache:#val($.event('nocache'))#,
assetpath:"#variables.$.siteConfig('assetPath')#",
corepath:"#variables.$.globalConfig('corepath')#",
fileassetpath:"#variables.$.siteConfig('fileAssetPath')#",
themepath:"#variables.$.siteConfig('themeAssetPath')#",
reCAPTCHALanguage:"#$.siteConfig('reCAPTCHALanguage')#",
preloaderMarkup: "#esapiEncode('javascript',this.preloaderMarkup)#",
mobileformat: #esapiEncode('javascript',$.event('muraMobileRequest'))#,
windowdocumentdomain: "#application.configBean.getWindowDocumentDomain()#",
layoutmanager:#variables.$.getContentRenderer().useLayoutManager()#,
type:"#esapiEncode('javascript',variables.$.content('type'))#",
subtype:"#esapiEncode('javascript',variables.$.content('subtype'))#",
queueObjects: #esapiEncode('javascript',this.queueObjects)#,
rb:#variables.$.siteConfig().getAPI('json','v1').getSerializer().serialize(variables.$.getClientRenderVariables())#,
#trim(variables.$.siteConfig('JSDateKeyObjInc'))#
});
</script>
</cfoutput>
</cfif>
<cfif this.cookieConsentEnabled>
<cfoutput>#$.dspObject_Include(thefile='cookie_consent/index.cfm')#</cfoutput>
</cfif>
</cfif>

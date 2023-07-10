<cfparam name="url.target" default="">
<cfparam name="url.completepath" default="true">
<cfoutput>
<div id="MuraFileBrowserContainer"></div>
<script>

Mura(function(){
	//This set the front end modal window width
	// The default is 'standard'
	var target="#esapiEncode('javascript',url.target)#";
	MuraFileBrowser.config.resourcepath="#esapiEncode('javascript','User_Assets')#";
	MuraFileBrowser.config.selectMode=2;
	MuraFileBrowser.config.displaymode=1;
	<cfif isdefined('url.completepath') and isBoolean(url.completepath) and url.completepath>
		MuraFileBrowser.config.completepath=true;
	</cfif>
	MuraFileBrowser.config.selectCallback=function(item){
		var url=item.url;
		if(typeof url=='string' && url){
			if(url.indexOf('?')>-1){
				url=url + '&cacheid=' + Math.random();
			} else {
				url=url + '?cacheid=' + Math.random();
			}
		}
		siteManager.updateDisplayObjectParams({#esapiEncode('javascript',url.target)#:url},false);
	};

	MuraFileBrowser.config.height=600;

	siteManager.setDisplayObjectModalWidth(1000);

	MuraFileBrowser.render();

});
</script>
</cfoutput>

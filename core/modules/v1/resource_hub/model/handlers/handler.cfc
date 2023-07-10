component extends="mura.baseobject" {

	function onRenderstart(m){
		if(m.getContentRenderer().ssr && (!len(m.event('amp')) || !(isBoolean(m.event('amp')) && !m.event('amp')))){
            m.addToHTMLFootQueue('<link rel="stylesheet" href="#m.siteConfig().getCorePath(complete=true,useProtocol=false)#/modules/v1/resource_hub/assets/css/resource_hub.css">');
		}
	}

}

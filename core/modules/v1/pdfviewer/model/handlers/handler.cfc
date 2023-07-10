component extends="mura.baseobject" {

	function onRenderstart(m){
		if(m.getContentRenderer().ssr && (!len(m.event('amp')) || !(isBoolean(m.event('amp')) && !m.event('amp')))){
            m.addToHTMLFootQueue('<script src="#m.siteConfig().getCorePath(complete=true,useProtocol=false)#/modules/v1/pdfviewer/dist/main.bundle.js" #m.getMuraJSDeferredString()#></script>');
		}
	}

}

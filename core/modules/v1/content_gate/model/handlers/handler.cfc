component extends="mura.cfobject" {

    function onRenderstart(m){
        if(m.getContentRenderer().ssr && (!yesNoFormat(m.event('amp')) && m.siteConfig().hasModule('mxpflagmodule'))){
            m.addToHTMLFootQueue('<script src="#m.siteConfig().getCorePath(complete=true,useProtocol=false)#/modules/v1/content_gate/js/mura.displayobject.content_gate.min.js" #m.getMuraJSDeferredString()#></script>');
        }
    }

}

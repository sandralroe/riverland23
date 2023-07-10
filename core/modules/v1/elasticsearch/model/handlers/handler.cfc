component extends="mura.cfobject" {
    
    function onApplicationLoad(Mura){
        if(len(Mura.siteConfig('elasticAPI'))){
            var contentGateway=getBean("contentGateway");
            var replacementMethods=getBean("elasticSearchMethods");
            contentGateway.injectMethod("getPublicSearch",replacementMethods.publicSearch);
            contentGateway.injectMethod("fullLeft",replacementMethods.fullLeft);
            
            var httpService = getHTTPService();
            httpService.setMethod("put");
            httpService.setUrl(Mura.siteConfig('elasticAPI') & "/_ingest/pipeline/attachment");
            httpService.addParam(type="header",name="Content-Type",value="application/json");
            if(len(Mura.siteConfig('elasticAPIKEY'))){
                httpService.addParam(type="header",name="Authoriztion",value="apikey #Mura.siteConfig('elasticAPIKEY')#");
            }
            httpService.addParam(type="body",value='{
                "description" : "Field for processing file attachments",
                "processors" : [
                    {
                    "attachment" : {
                        "field" : "data"
                    }
                    }
                ]
                }');
        }
    }

    function onAfterContentSave(Mura){
        if(len(Mura.siteConfig('elasticAPI'))){
            var content=Mura.event('contentBean');
            if(content.getApproved() && content.getActive()){
                Mura.getBean('elasticSearchService').processContentForElastic(content);
            }
        }
    }

    function onAfterContentDelete(Mura){
        if(len(Mura.siteConfig('elasticAPI'))){
            var content=Mura.event('contentBean');
            Mura.getBean('elasticSearchService').removeFromElastic(content);
        }
    }

    function onSiteRequestStart(Mura){
        if(isDefined('url.#Mura.siteConfig().getValue(property='elasticRebuildKey',defaultValue="elasticRebuild")#')){
            Mura.getBean('elasticSearchService').rebuildIndex(Mura.event('siteid'));
        }
    }
}
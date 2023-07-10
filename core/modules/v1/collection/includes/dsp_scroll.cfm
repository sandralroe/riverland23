<cfparam name="objectparams.pagenum" default="1">
<cfparam name="objectparams.pagecount" default="1">
<cfif objectparams.pagenum lt objectparams.pagecount>
    <cfparam name="arguments.objectparams.origininstanceid" default="#arguments.objectparams.instanceid#">
    <cfset pageid=createUUID()>
    <cfoutput>
    <script>
        Mura(function(){
            var origininstanceid='#esapiEncode("javascript",arguments.objectparams.origininstanceid)#';
            var lastPage=#esapiEncode('javascript',objectparams.pagecount)#;
            var currentPage=#esapiEncode('javascript',objectparams.pagenum)#;
            var nextPage=currentPage+1;
            var collection=Mura('div[data-instanceid="' + origininstanceid + '"]');
            var scrollcontent=Mura('div[data-instanceid="' + origininstanceid + '"] .mura-collection');
            if(!scrollcontent.length){
                var scrollcontent=Mura('div[data-instanceid="' + origininstanceid + '"] > .mura-object-content');
            }
            var pageEnd=Mura('##mura-page-end-#pageid#');
            if(!pageEnd.length){
                var pageEnds=scrollcontent.find('.mura-collection-page-end');
                if(pageEnds.length){
                    pageEnds.first().before('<div id="mura-page-end-#pageid#" class="mura-collection-page-end"></div>');
                } else {
                    scrollcontent.append('<div id="mura-page-end-#pageid#" class="mura-collection-page-end"></div>');
                }
                pageEnd=Mura('##mura-page-end-#pageid#');
            }
            var pageContainer=pageEnd;
           
            function conditionalScroll(){
                if(!Mura.editing && pageEnd.length && !pageContainer.data('handled')){
                    if(Mura.isScrolledIntoView(pageEnd.node)){
                        if(collection.length){
                            var params= Mura.extend(collection.data(),{transient:true,label:'',origininstanceid:origininstanceid,class:'',objecticonclass:'',stylesupport:''});
                            pageContainer.data('handled',true);
                            params.pagenum=nextPage;
                            pageContainer.appendModule(params).then(function(){
                                var newContent=pageContainer.find('.mura-collection');
                                if(!newContent.length){
                                    newContent=pageContainer.find('.mura-object-content')
                                }
                                pageContainer.hide();
                                newContent.forEach(function(){
                                    scrollcontent.find('.mura-collection-page-end').first().before(Mura(this).html())
                                    pageContainer.html('');
                                })
                            }) 
                        }
                    } else if (!pageContainer.data('handled')){
                        setTimeout(conditionalScroll,250);
                    }
                }
            }
            conditionalScroll();
        })
    </script>
    </cfoutput>
</cfif>
<!--- We don't want to save these --->
<cfset structDelete(objectparams,'pagenum')>
<cfset structDelete(objectparams,'pagecount')>
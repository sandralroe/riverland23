<cfsilent>
    <cfset $=application.serviceFactory.getBean("muraScope").init(rc.siteID)>
    <cfif not len($.event('target'))>
        <cfset $.event('target','markdown')>
    </cfif>
    <cfif not len($.event('label'))>
        <cfset $.event('label','Edit ' & $.event('target'))>
    </cfif>
</cfsilent>
    <cfinclude template="/muraWRM#$.globalConfig().getAdminDir()#/core/views/carch/js.cfm">
    <cfoutput>
    <div class="mura-header">
        <h1>#esapiEncode('html',$.event('label'))#</h1>
    </div> <!-- /.mura-header -->
    
    <div class="block block-constrain">
        <div class="block block-bordered">
              <div class="block-content">
                <div id="configuratorContainer"></div>
                <div class="mura-actions" style="display:none">
                    <div class="form-actions">
                        <button class="btn mura-primary" id="updateBtn"><i class="mi-check-circle"></i>Update</button>
                    </div>
                </div>
            </div> <!-- /.block-content -->
        </div> <!-- /.block-bordered -->
    </div> <!-- /.block-constrain -->
    
    <script>
        Mura(function(Mura){
            var target='#esapiEncode('javascript',$.event('target'))#';
            var index='#esapiEncode('javascript',$.event('index'))#';
            var input=Mura('##' + target);
            var originalTargetArray='';
            var originalTargetValue='';

            siteManager.setDisplayObjectModalWidth(950);

	        siteManager.requestCustomConfigurator(target,function(params){
                //console.log('configurator',params)
              
                Mura.post(Mura.apiEndpoint + '/configurator',{
                    configurator:params.configurator,
                    siteid:Mura.siteid,
                    instanceid:params.instanceid,
                    contenthistid:params.contenthistid
                }).then(function(response){
                    Mura('##configuratorContainer').html(response.data);
                   
                    siteManager.requestDisplayObjectParams(function(params){
                        var parsedValue=params[target];
                        //console.log('parsedValue',parsedValue)
                        //console.log('parsedValue',target,parsedValue)
                        //console.log(0,index,Mura.isNumeric(index))
                        originalTargetValue=parsedValue;
                        //console.log(1,originalTargetValue)

                        if(Mura.isNumeric(index)){
                            if(Array.isArray(parsedValue)){
                                originalTargetArray=parsedValue;
                                try{
                                    parsedValue=parsedValue[index].value;
                                } catch(e){
                                    parsedValue={};
                                }
                            } else {
                                try{
                                    parsedValue=JSON.parse(params[target]);
                                    //console.log(2,parsedValue)
                                    if(Array.isArray(parsedValue)){
                                        originalTargetArray=parsedValue;
                                        
                                        if(typeof parsedValue[index] != 'undefined'){
                                            parsedValue=parsedValue[index].value;
                                            //console.log(3,parsedValue)
                                        }
                                    }
                                }catch(e){
                                    console.log(e)
                                    //console.log(4,parsedValue)
                                    var parsedValue=params[target];
                                }
                            }
                        } else {
                            var parsedValue=params[target];
                        }

                        console.log('parsedValue',parsedValue)
                        if(!parsedValue){
                            parsedValue={};
                        }
                        try {
                            Mura(".objectParam, .objectparam").each(function(){
                                var item=Mura(this);
                                var p=item.data('param') || item.attr('name');

                                if(p){
                                    p=p.toLowerCase();

                                    if(typeof parsedValue[p] != 'undefined'){
                                    
                                        if(item.is(':radio')){
                                            if(item.val().toString()==parsedValue[p].toString()){
                                                item.attr('checked',true);
                                            }

                                        } else {
                                            if(typeof parsedValue[p] == 'object'){
                                                item.val(JSON.stringify(parsedValue[p]));
                                            } else {
                                                item.val(parsedValue[p]);
                                            }

                                            if(item.is('SELECT') && typeof item.niceSelect == 'function'){
                                                item.niceSelect('update');
                                            }

                                            if(typeof CKEDITOR !='undefined' && item.attr('id') && typeof CKEDITOR.instances[item.attr('id')] != 'undefined'){
                                                CKEDITOR.instances[item.attr('id')].setData(item.val());
                                            }
                                        }
                                    }
                                }
                            });
                        } catch(e){
                            console.log('e',e)
                        }
                        wireupExterndalUIWidgets();
                        console.log('doing conditionals',parsedValue)
                        siteManager.updateConfiguratorConditionals(parsedValue);
                        Mura('.mura-actions').show();

                    },'modal',true)
                   
                })
               
            });

            Mura("##updateBtn").click(function(){
                var params={};
                var returnValue={};

                if(typeof CKEDITOR !='undefined'){
                    for(var i in CKEDITOR.instances){
                        CKEDITOR.instances[i].updateElement();
                    }
                }

                Mura("textarea.mura-markdown,textarea.markdownEditor").forEach(function(){
                    var input=Mura(this);
                    if(markdownInstances && typeof markdownInstances[input.attr('name')] != 'undefined'){
                        if(input.length){
                            if (!input.hasClass("markdown-lazy-init")){
                                input.val(markdownInstances[input.attr('name')].getMarkdown())
                            }
                        }
                    }
                })

                Mura(".objectParam, .objectparam").each(function(){
                    var item=Mura(this);
                    if(item.is('SELECT') && item.hasClass('ns-' + item.attr('name'))){
                        item.niceSelect('update');
                        var selected=Mura('div.nice-select.ns-' + item.attr('name'));
                        if(selected.length){
                            selected=selected.find('li.selected');
                        }
                        if(selected.length){
                            item.val(selected.attr('data-value'));
                        }
                    } 

                    if(item.data('param')){
                        returnValue[item.data('param')]=item.val();
                    } else {
                        returnValue[item.attr('name')]=item.val();
                    }
                });

                if(Mura.isNumeric(index) && Array.isArray(originalTargetArray)){
                    if(typeof originalTargetArray[index] == 'undefined' || !originalTargetArray[index]){
                        originalTargetArray[index]={name:"",value:""};
                    }
                    originalTargetArray[index].value=returnValue;
                    params[target]=JSON.stringify(originalTargetArray);
                } else {
                    params[target]=JSON.stringify(returnValue);
                }
                //console.log('originalTargetArray',originalTargetArray,'index',index,'target',target,'params',params);
                siteManager.updateDisplayObjectParams(params,false);
            });
           
        });
    </script>
    </cfoutput>
    
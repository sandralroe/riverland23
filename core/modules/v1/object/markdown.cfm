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
                  <div class="mura-control-group">
                    <textarea style="display:none;" name="#esapiEncode('html_attr',$.event('target'))#" id="#esapiEncode('html_attr',$.event('target'))#" class="objectParam mura-markdown" data-height="400" data-width="100%"></textarea>
                </div>
                <div class="mura-actions">
                    <div class="form-actions">
                        <button class="btn mura-primary" id="updateBtn"><i class="mi-check-circle"></i>Update</button>
                    </div>
                </div>
            </div> <!-- /.block-content -->
        </div> <!-- /.block-bordered -->
    </div> <!-- /.block-constrain -->
    
    <script>
        $(function($){
            var target='#esapiEncode('javascript',$.event('target'))#';
            var index='#esapiEncode('javascript',$.event('index'))#';
            var input=Mura('##' + target);
            var originalTargetArray='';
            var originalTargetValue='';

            siteManager.setDisplayObjectModalWidth(950);
            
            siteManager.requestDisplayObjectParams(function(params){
                var parsedValue=params[target];
                //console.log(0,index,Mura.isNumeric(index))
                originalTargetValue=parsedValue;
                //console.log(1,originalTargetValue)
                if(Mura.isNumeric(index)){
                    if(Array.isArray(parsedValue)){
                        originalTargetArray=parsedValue;
                        parsedValue=parsedValue[index].value;
                    } else {
                        try{
                            parsedValue=JSON.parse(params[target]);
                            //console.log(2,parsedValue)
                            if(Array.isArray(parsedValue)){
                                originalTargetArray=parsedValue;
                                
                                if(typeof parsedValue[index] != 'undefined'){
                                    parsedValue=parsedValue[index].value;
                                    console.log(3,parsedValue)
                                }
                            }
                        }catch(e){
                            console.log(e)
                            //console.log(4,parsedValue)
                            var parsedValue=params[target];
                        }
                    }
                   
                }
               
				markdownInstances[input.attr('name')].setMarkdown(parsedValue);
			},'modal',true);
    
            Mura("##updateBtn").click(function(){
                var params={};
                if(markdownInstances && typeof markdownInstances[target]){
                    input.val(markdownInstances[target].getMarkdown())
                    if(Mura.isNumeric(index) && Array.isArray(originalTargetArray)){
                        if(typeof originalTargetArray[index] == 'undefined' || !originalTargetArray[index]){
                            originalTargetArray[index]={name:"",value:""};
                        }
                        originalTargetArray[index].value=input.val();
                        params[target]=JSON.stringify(originalTargetArray);
                    } else {
                        params[target]=input.val();
                    }
                }
                //console.log(originalTargetArray,params)
                siteManager.updateDisplayObjectParams(params,false);
            });
        });
    </script>
    </cfoutput>
    
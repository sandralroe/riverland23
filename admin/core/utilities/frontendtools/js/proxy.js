let sidebarProxy;
let modalProxy;

const onAdminMessage=function(messageEvent){
    const newLocal = adminDomain
        && (
            messageEvent.origin == 'http://' + adminDomain + serverPort
            || messageEvent.origin == 'https://' + adminDomain + serverPort
        )
        || !adminDomain;
    if (
            newLocal
        ) {

        let parameters=messageEvent.data;

        if (parameters["cmd"] == "setWidth") {
            if(parameters["width"]=='configurator'){
                window.frontEndModalWidth=frontEndModalWidthConfigurator;
            } else if(!isNaN(parameters["width"])){
                window.frontEndModalWidth=parameters["width"];
            } else {
                window.frontEndModalWidth=getConfiguratorWidth();
            }

            if(parameters["targetFrame"]=='sidebar'){
                resizeFrontEndToolsSidebar(decodeURIComponent(parameters["height"]));
            } else {
                resizeFrontEndToolsModal(decodeURIComponent(parameters["height"]));
            }
        } else if(parameters["cmd"] == "openFileManager"){
                Mura.loader().loadjs(
                coreLoc +'vendor/ckfinder/ckfinder.js',
                    function(){
                        let finder = new CKFinder();
                        finder.basePath = coreLoc + 'vendor/ckfinder/';
                        let completepath;
   
                        if(isRemote){
                            completepath="true";
                        } else {
                            completepath=(typeof parameters["completepath"] != 'undefined') ? parameters.completepath.toString() : "true";
                        }

                        finder.selectActionFunction=function(fileURL){

                            let item=Mura('[data-instanceid="' + parameters["instanceid"] + '"]');

                            if(completepath.toString().toLowerCase() == 'true'){
                                item.data(parameters["target"],webroot + fileDelim + fileURL)
                            } else {
                                item.data(parameters["target"],fileURL)
                            }

                            let data=item.data();

                            delete data.runtime;

                            if(item.is('div.mura-object[data-targetattr]')){
                                data.hasTargetAttr=true;
                            }

                            if(parameters["targetFrame"]=='sidebar' && document.getElementById('mura-sidebar-editor').style.display=='none'){
                                Mura('#mura-sidebar-configurator').show();
                            }

                            if(typeof parameters.callback == 'undefined'){
                                if(typeof parameters["targetFrame"] != 'undefined' && parameters["targetFrame"].toLowerCase()=='sidebar'){
                                    sidebarProxy.post({cmd:'setObjectParams',params:data});
                                } else {
                                    modalProxy.post({cmd:'setObjectParams',params:data});
                                }
                            }

                            Mura.processAsyncObject(item.node);
                    }

                    if(Mura(this).attr('data-resourcetype') =='root'){
                        finder.resourceType='Application_Root';
                    } else if(Mura(this).attr('data-resourcetype') == 'site'){
                        finder.resourceType=Mura.siteid + '_Site_Files';
                    } else {
                        finder.resourceType=Mura.siteid + '_User_Assets';
                    }

                    finder.popup();
                }
            );
        } else if(parameters["cmd"] == "close"){
            closeFrontEndToolsModal();

        } else if(parameters["cmd"] == "cloneobject"){
            Mura.cloning=true;
            var source=Mura('div[data-instanceid="' + parameters["instanceid"] + '"]');

            if(source.data('object') == 'container'){
                Mura.resetAsyncObject(source.node);
                Mura.processDisplayObject(source,false,true);
            }

            var newinstanceid=Mura.createUUID();
            var newparams=source.data();

            newparams.instanceid=newinstanceid;

            if(source.data('object') != 'form' && source.data('object') != 'component'){
                var newobjectid=Mura.createUUID();
                newparams.objectid=newobjectid;
            }

            if(source.attr('data-stylesupport')){
                newparams.stylesupport=source.attr('data-stylesupport');
            }

            if(source.data('object') == 'container'){
                newparams.items=source.attr('data-items');
            }

            delete newparams.inited;

            newparams.transient=false;

            source.insertDisplayObjectAfter(newparams)
                .then(function(obj){
                    Mura.cloning=false;
                    if(obj.data('object') == 'container'){
                        Mura.resetAsyncObject(obj.node);
                        Mura.processDisplayObject(obj,false,true);
                    }
                    obj.on('click',Mura.handleObjectClick);
                    initFrontendUI(obj.node,true);
                  
                    Mura.editHistory.record();
                });

        }
        else if(parameters["cmd"] == "saveobject"){
            source=Mura('div[data-instanceid="' + parameters["instanceid"] + '"]');
  
            if(source.data('object') == 'container'){
                Mura.resetAsyncObject(source.node,false);
                Mura.processDisplayObject(source,false,true);
            }

            newinstanceid=Mura.createUUID();
            newparams=source.data();

            let templatename= parameters["templatename"] || '';

            if(!templatename){
                alert("A template name is required.");
                return;
            }
          
            newparams['instanceid'] = newinstanceid;
            delete newparams['inited'];
            delete newparams['isconfigurator'];
            delete newparams['perm'];
            delete newparams['forcelayout'];
            delete newparams['isbodyobject'];
            delete newparams['runtime'];
            delete newparams['startrow'];
            delete newparams['pagenum'];
            delete newparams['nextnid'];
            delete newparams['purgecache'];
            delete newparams['origininstanceid'];

            if(source.data('object') != 'form' && source.data('object') != 'component'){
                newobjectid=Mura.createUUID();
                newparams.objectid=newobjectid;
            }

            if(source.attr('data-stylesupport')){
                newparams.stylesupport=source.attr('data-stylesupport');
            }

            if(source.data('object') == 'container'){
                newparams.items=source.attr('data-items');
            }

            newparams.transient=false;

            let moduleTemplate=Mura.getEntity('moduleTemplate');

            let appendModuleTemplateOption=function(params){
                let option= '<div class="mura-sidebar__objects-list__object-item mura-objectclass mura-customtemplate" data-params="" data-object="'+ Mura.escapeHTML(params.object) + '" data-objectid="' + Mura.escapeHTML(params.objectid) +  '" data-objectname="' + Mura.escape(params.objectname) + '" data-filtername="' + Mura.escapeHTML(templatename.toLowerCase()) + '" data-objecticonclass="mi-square-o"><i class="mi-square-o"></i>' + Mura.escapeHTML(templatename) + '<i class="mi-trash module-delete-icon"></i></div>';
                objContainer
                    .find('#panel-module-templates .mura-panel-body')
                    .append(option);
                objContainer
                    .find('.mura-customtemplate')
                    .last()
                    .data('params',moduleTemplate.get('params'));
                Mura("#mura-templates-empty").hide();
                Mura.initClassObjects();
            }

            let objContainer=Mura('.mura-sidebar__objects-list__object-group-items');

            let saveTemplate=function(fn){ 
                moduleTemplate
                .set('params',newparams)
                .set('name',templatename)
                .save()
                .then(function(){
                    if(typeof fn == 'function'){
                        fn();
                    }
                    alert("Template has been saved");
                }); 
            }

            moduleTemplate
                .loadBy('name',templatename)
                .then(function(){
                    if(moduleTemplate.exists()){
                        if(confirm("A module template with the same name already exists. Would you like to replace it?")){
                            saveTemplate(function(){
                                objContainer.find('.mura-customtemplate[data-filtername="' + Mura.escape(newparams.objectname.toLowerCase()) + '"]').remove();   
                                appendModuleTemplateOption(newparams);
                            }); 
                        }
                    } else {
                        saveTemplate(function(){
                            appendModuleTemplateOption(newparams);
                        }); 
                    }
                });
                
            
        }
        else if(parameters["cmd"] == "setLocation"){
            let newLocation=decodeURIComponent(parameters["location"]);
            window.location=newLocation;
            if(newLocation.indexOf('#') > -1){
                MuraInlineEditor.reload();
            }
        } else if(parameters["cmd"] == "setHeight"){
            if(parameters["targetFrame"]=='sidebar'){
                resizeFrontEndToolsSidebar(decodeURIComponent(parameters["height"]));
            } else {
                resizeFrontEndToolsModal(decodeURIComponent(parameters["height"]));
            }
        } else if(parameters["cmd"] == "undo"){
            Mura.editHistory.undo();
        } else if(parameters["cmd"] == "redo"){
            Mura.editHistory.redo();
        } else if(parameters["cmd"] == "scrollToTop"){
            window.scrollTo(0, 0);
        } else if(parameters["cmd"] == "autoScroll"){
            autoScroll(parameters["y"]);
        } else if(parameters["cmd"] == "setCurrentPanel"){
            let item=Mura('[data-instanceid="' + parameters["instanceid"] + '"]');
            Mura(".mura-object-content,.mura-object-meta").removeClass('mura-object-selected')
            if(parameters["currentPanel"]=='content'){
                item.children('.mura-object-content').addClass('mura-object-selected');
            }	if(parameters["currentPanel"]=='meta'){
                let metaWrapper=item.children('.mura-object-meta-wrapper');
                if(metaWrapper.length){
                    metaWrapper.children('.mura-object-meta').addClass('mura-object-selected');
                }
            }
        } else if(parameters["cmd"] == "requestedObjectConfigurator"){
            //console.log('comingback',parameters)
            modalProxy.post({
                cmd:'customObjectConfiguratorRequest',
                instanceid:parameters.instanceid,
                contenthistid:parameters.contenthistid,
                configurator:parameters.configurator
            });
        } else if(parameters["cmd"] == "requestObjectConfigurator"){
            //console.log('going to ')
            sidebarProxy.post({cmd:'requestObjectConfigurator',target:parameters.target});
        } else if(parameters["cmd"] == "requestObjectParams"){
            let item=Mura('[data-instanceid="' + parameters["instanceid"] + '"]');
            let data=item.data();
           
            delete data.runtime;

            if(item.is('div.mura-object[data-targetattr]')){
                data.hasTargetAttr=true;
            }

            if(parameters["targetFrame"]=='sidebar' && document.getElementById('mura-sidebar-editor').style.display=='none'){
                Mura('#mura-sidebar-configurator').show();
            }
            if(typeof parameters.callback == 'undefined'){
                if(parameters["targetFrame"]=='sidebar'){
                    sidebarProxy.post({cmd:'setObjectParams',params:data});
                } else {
                    modalProxy.post({cmd:'setObjectParams',params:data});
                }
            } else{
                if(parameters["targetFrame"]=='sidebar'){
                    sidebarProxy.post({cmd:parameters.callback,params:data});
                } else {
                    modalProxy.post({cmd:parameters.callback,params:data});
                }
            }
        } else if(parameters["cmd"] == "deleteObject"){
            Mura('[data-instanceid="' + parameters["instanceid"] + '"]').remove();
            closeFrontEndToolsModal();
            MuraInlineEditor.sidebarAction('showobjects');
            MuraInlineEditor.isDirty=true;
            Mura.editHistory.record();
        } else if(parameters["cmd"] == "showobjects"){
            MuraInlineEditor.sidebarAction('showobjects');
        } else if (parameters["cmd"]=="setObjectParams"){	
            if(typeof parameters["complete"] != 'undefined' && !parameters["complete"]){
                sidebarProxy.post(parameters);
                closeFrontEndToolsModal();
            } else {
                let item=Mura('[data-instanceid="' + parameters.instanceid + '"]');

                if(typeof parameters.params == 'object'){
                   
                    delete parameters.params.params;

                    if(item.data('class')){
                        let classes=item.data('class');

                        if(typeof classes != 'Array'){
                            classes=classes.split(' ');
                        }

                        for(const element of classes){
                            if(item.hasClass(element)){
                                item.removeClass(element);
                            }
                        }

                        if(typeof parameters.params.class != 'undefined' && parameters.params.class){

                            let incomingClasses=parameters.params.class;

                            if(typeof incomingClasses != 'Array'){
                                incomingClasses=incomingClasses.split(' ');
                            }

                            for(const element of incomingClasses){
                                if(!item.hasClass(element)){
                                    item.addClass(element);
                                }
                            }
                        }
                    }

                    //console.log(parameters);
                    
                    for(let p in parameters.params){
                        if(parameters.params.hasOwnProperty(p)){
                            if(typeof parameters.params[p] =='object'){
                                item.data(p,JSON.stringify(parameters.params[p]));
                            } else {
                                item.data(p,parameters.params[p]);
                            }       
                        }
                    }

                    if(item.data('trim-params') || item.data('trimparams')){
                        let currentdata=item.data();

                        for(let p in currentdata){
                            if(currentdata.hasOwnProperty(p)){
                                if(!(p=='inited' || p=='objecticonclass' || p=='async' || p=='instanceid' || p=='object' || p=='objectname' || p=='objectid') && typeof parameters.params[p] == 'undefined' ){
                                    item.removeAttr('data-' + p);
                                }
                            }
                        }
                    }

                    item.removeAttr('data-trim-params');
                    item.removeAttr('data-trimparams');
                    MuraInlineEditor.isDirty=true;
                }
                let perm=item.data('perm');
            
                Mura.resetAsyncObject(item.node,false);
                if(perm){
                    item.data('perm',perm);
                }

                item.addClass('mura-active');
                Mura.processAsyncObject(item.node,false).then(function(){
                    closeFrontEndToolsModal();
                    if(parameters.reinit && !item.data('notconfigurable')){
                        openFrontEndToolsModal(item.node,true);
                    }
                }).then(function(){
                    if(parameters["currentPanel"]=='content'){
                        item.children('.mura-object-content').addClass('mura-object-selected');
                    }	if(parameters["currentPanel"]=='meta'){
                        let metaWrapper=item.children('.mura-object-meta-wrapper');
                        if(metaWrapper.length){
                            metaWrapper.children('.mura-object-meta').addClass('mura-object-selected');
                        }
                    }
                    Mura.editHistory.record();
                });
            }
        } else if (parameters["cmd"]=='reloadObjectAndClose') {
            let item;
            if(parameters.instanceid){
                item=Mura('[data-instanceid="' + parameters.instanceid + '"]');
            } else {
                item=Mura('[data-objectid="' + parameters.objectid + '"]');
            }

            Mura.resetAsyncObject(item.node);
            item.addClass('mura-active');
            Mura.processAsyncObject(item.node);
            closeFrontEndToolsModal();
            MuraInlineEditor.isDirty=true;

        } else if(parameters["cmd"] == "setImageSrc"){
            utility('img[data-instanceid="' + parameters.instanceid + '"]')
                .attr('src',parameters.src)
                .each(MuraInlineEditor.checkForImageCroppers);
        } else if (parameters["cmd"] == "openModal"){
            initFrontendUI({href:adminLoc + parameters["src"]});
        }
    }
}

const initModalProxy=function(){
        modalProxy = new Porthole.WindowProxy(adminProxyLoc, 'frontEndToolsModaliframe');
        modalProxy.addEventListener(onAdminMessage);
}

const initSidebarProxy=function(){
        sidebarProxy = new Porthole.WindowProxy(adminProxyLoc, 'frontEndToolsSidebariframe');
        sidebarProxy.addEventListener(onAdminMessage);
}

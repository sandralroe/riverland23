
window.MuraInlineEditor={
    inited: false,
    deInit: function(){
        if(MuraInlineEditor.inited){
            MuraInlineEditor.inited=false;
            if(window.Mura.layoutmanager){
                Mura.deInitLayoutManager();
            }
        }
    },
    init: function(doreset){
        if(typeof doreset == 'undefined'){
            doreset=false;
        }
        if(MuraInlineEditor.inited && !doreset){
            return false;
        }
        
        if(typeof Mura != 'undefined'){
            Mura(document).trigger('beforeLayoutManagerInit')
            let sheet=Mura.getStyleSheet('mura-inline-editor');
            sheet.insertRule(
                '.mura-region-local, .mura-region-inherited, .mura-object[data-object] {	min-height: 30px;	}',
                sheet.cssRules.length
            );

        }

        utility(document)
            .trigger('muraContentEditInit')
            .trigger('ContentEditInit');

        if(nodeType=='Variation'){
            if(!Mura('.mxp-editable').length){
                return false;
            }
        }

        if(targetingVariations){
            return false;
        }

        if(lockableNodes){
            alert(lockableNodeAlertText);
            return false;
        }

        Mura('#clientVariationTargeting').css('text-decoration','line-through');
        Mura('.mura-edit-toolbar-vartargeting').remove();

        if(typeof CKEDITOR != 'undefined'){
            CKEDITOR.disableAutoInline=true;
        }

        MuraInlineEditor.inited=true;
        utility('#adminSave').show();
        utility('#adminStatus').hide();
        utility('#adminAddContent').hide();
        utility('#adminVersionHistory').hide();
        utility('#adminAddContent-suspend').show();
        utility('#adminVersionHistory-suspend').show();

        utility('.mura-editable').removeClass('mura-inactive');
        window.Mura.editing=true;

        utility('#mura-deactivate-editors').click(function(){
            MuraInlineEditor.sidebarAction('showobjects');
        });

        if( nodeType=='Variation'){

            Mura.finalVariations=[]

            Mura('.mxp-editable').each(function(){
                var item=Mura(this);
                Mura.finalVariations.push({
                    original:item.html(),
                    selector:item.selector()
                });

               item.addClass('mura-active');

            });

            let displayVariations=function(){
                if(Mura.variations.length){
                    Mura(".mura-var-undo").show();
                    Mura(".mura-var-cancel").show();
                } else {
                    Mura(".mura-var-undo").hide();
                    Mura(".mura-var-cancel").hide();
                }
                Mura(".mura-var-undo").hide();
                Mura("#mura-var-details").html("");
            }

            let undoVariations=function(){

                if(Mura.variations.length){
                    let current=Mura('.mura-var-current');

                    if(current.length){
                        for(let i=(Mura.variations.length-1);i>=0;i--){
                            let target=Mura(Mura.variations[i].selector);
                            if( current.attr('id')==target.attr('id') ){
                                target.html(Mura.variations[i].original);
                                i=-1;
                            }
                        }
                    } else {
                        let last=Mura.variations.length-1;
                        Mura(Mura.variations[last].selector).html(Mura.variations[last].original);
                        Mura.variations.pop();
                    }

                }

                MuraInlineEditor.resetEditableAttributes();
                Mura(".mxp-editable").each(function(){
                    Mura.processMarkup(this);
                    Mura(this).find(Mura.looseDropTargets).each(function(){
                        Mura.initLooseDropTarget(this);
                    });
                });
                displayVariations();
            }

            const reset=function(){
                while(Mura.variations.length){
                    undoVariations();
                }

                Mura.variations=Mura.origvariations;
                applyVariations();
                displayVariations();
            }

            let trimAttrs=function(e){
                if(!e.attr('class')){
                    e.removeAttr('class');
                }
                if(!e.attr('style')){
                    e.removeAttr('style');
                }
                if(!e.attr('id')){
                    e.removeAttr('id');
                }

                e.removeAttr('contenteditable');
            }

            let compressVariations=function(){
                var vs=[];

                variations.reverse();

                for(const element of Mura.variations){
                    let item=element, added=false;

                    for(const element of vs){
                        if(element.selector==item.selector){
                            added=true;
                            break;
                        }
                    }

                    if(!added){
                        vs.push(item);
                    }
                }

                Mura.variations=vs.slice();

                editingVariations=false;

            }

            let activeEditorIndex=0;
            let activeEditorId='mura-var-editor0';
            let variation;
            let style;

            let commitEdit=function(currentEl){

                if(Mura.currentId && Mura.currentId==currentEl.attr('id')){
                    Mura.currentId='';

                    currentEl.removeClass('mura-var-current');

                    if(!currentEl.attr('class')){
                        currentEl.removeAttr('class');
                    }

                    let instance=CKEDITOR.instances[currentEl.attr('id')];

                    if(instance){
                        instance.updateElement();
                        variation.adjusted=instance.getData();
                        instance.destroy();
                        CKEDITOR.remove(instance);
                    } else {
                        variation.adjusted=currentEl.html();
                    }

                    currentEl.attr('contenteditable','false');
                    
                    Mura.processMarkup(currentEl)

                    currentEl.find('.mura-object[data-object]').each(function(){
                        Mura.initEditableObject(this);
                        Mura(this).addClass('mura-active')
                        Mura(this).on('click',Mura.handleObjectClick);
                    });
                    console.log('commiting edit')
                    currentEl.find(Mura.looseDropTargets).each(function(){
                        Mura.initLooseDropTarget(this);
                    });

                    if(style){
                        currentEl.attr('style',style);
                    } else {
                        currentEl.removeAttr('style');
                    }

                    if(variation.adjusted){
                        if(variation.original != variation.adjusted){
                            Mura.variations.push(variation);
                            displayVariations();
                        }
                    }

                  
                    
                }
            }

            MuraInlineEditor.commitEdit=commitEdit;

            let editAction=function(){

                let currentEl=Mura('.mura-var-target');

                if(!currentEl.length){
                    return;
                }


                Mura('.mura-var-target').each(function(){
                    Mura(this).removeClass('mura-var-target');
                    trimAttrs(Mura(this));
                });


                let style=currentEl.attr('style');
                let hasTempId=true;

                if(Mura.currentId && Mura.currentId==currentEl.attr('id')){
                    return;
                }

                if(Mura.currentId!=''){
                    commitEdit(Mura('#' + Mura.currentId));
                }

                Mura.currentId='';

                if(currentEl.attr('id')){
                    Mura.currentId=currentEl.attr('id');
                    hasTempId=false;
                }

                if(activeEditorId){
                    Mura('#' + activeEditorId).attr('contenteditable',false);
                }

                if(hasTempId){
                    activeEditorIndex++;
                    Mura.currentId='mura-var-editor' + activeEditorIndex;
                    currentEl.attr('id',Mura.currentId);
                    currentEl.data('hastempid',true);
                }

                activeEditorId=Mura.currentId;

                let instance=CKEDITOR.instances[Mura.currentId];
                let editiorEnabled=true;

                MuraInlineEditor.sidebarAction('showeditor');

                utility('.mura-object[data-transient="true"], .mura-cta__item, .mura-cta').remove();

                Mura('#' + Mura.currentId)
                    .find('.mura-object[data-object]')
                    .each(function(){
                        let item=Mura(this);
                        if(item.data('transient')){
                            item.remove();
                        } else if (item.is('div[data-object]')) {
                            Mura.resetAsyncObject(this);
                        }	
                    });

                variation={
                    selector:currentEl.selector(),
                    original:currentEl.html()
                };

                try{
                    currentEl.attr('contenteditable',true);

                    let instance=CKEDITOR.instances[Mura.currentId];

                    if(!instance){

                        Mura('#' + Mura.currentId).find('.mura-object[data-object]').each(function(){
                            Mura.resetAsyncObject(this);
                        });

                        CKEDITOR.disableAutoInline = true;
                        CKEDITOR.inline(
                            document.getElementById( Mura.currentId ),
                            {
                                toolbar: 'QuickEdit',
                                width: "75%",
                                customConfig: 'config.js.cfm',
                                on: {
                                        'instanceReady':function(e){
                                            e.editor.updateElement();
                                            variation.original=e.editor.getData();
                                        }
                                    }
                            }
                        );

                    }

                } catch(err){
                    console.log(err);

                }

                console.log('current Selector:' + variation.selector);
                


                MuraInlineEditor.isDirty=true;

                currentEl.addClass('mura-var-current');
                return false;
            }

            let editVariations=function(){
                editingVariations=true;
                Mura('#adminStatus').hide();
                Mura('#adminSave').show();
                displayVariations();

                Mura(Mura.editableSelector).hover(function(){
                    if(editingVariations){
                        if(Mura.currentId != Mura(this).attr('id')){
                            let prev=Mura('.mura-var-target');
                            prev.removeClass('mura-var-target');

                            if(!prev.attr('class')){
                                prev.removeAttr('class');
                            }

                            Mura(this).addClass('mura-var-target');
                        }
                    }
                },
                function(){
                    if(editingVariations){
                        if(Mura.currentId != Mura(this).attr('id')){
                            Mura(this).removeClass('mura-var-target');
                            if(!Mura(this).attr('class')){
                                Mura(this).removeAttr('class');
                            }
                        }
                    }
                });

                Mura(Mura.editableSelector).on('dblclick',
                    function(event){
                        event.stopPropagation();
                        if(editingVariations){
                            editAction();
                        }
                        Mura(this).focus();
                });

                Mura(Mura.editableSelector + ' a, ' + Mura.editableSelector + ' button').each(
                    function(){
                        var self=Mura(this);

                        if(!self.hasClass('mura')){
                            Mura(this).on('click',function(event){
                                if(editingVariations){
                                    event.preventDefault();
                                }
                            });
                        }

                    }
                );

                Mura(Mura.editableSelector).each(function(){
                    Mura(this).closest('a').each(function(){
                        var self=Mura(this);

                        if(!self.hasClass('mura')){
                            self.on('click',function(event){
                                if(editingVariations){
                                    event.preventDefault();
                                }
                            });
                        }
                    });
                });
            }

            let exitVariations=function(){
                reset();
                Mura('#adminStatus').show();
                Mura('#adminSave').hide();

                let prev=Mura('.mura-var-target');
                prev.removeClass('mura-var-target');

                if(!prev.attr('class')){
                    prev.removeAttr('class');
                }

                editingVariations=false;
            }


            Mura('.mura-inline-undo').on('click',function(){
                undoVariations();
                editVariations();
            });

            editVariations();
            displayVariations();

            let styles='<style type="text/css">';
                styles+='.mxp-editable-active {';
                styles+='    outline: #ccc 4px;';
                styles+='}';
                styles+='.mura-var-current {';
                styles+='	outline-width: 4px;';
                styles+='	outline-style: dotted;';
                styles+='   outline-color: red;';
                styles+='}';
                styles+='.mura-var-target {';
                styles+='    outline-width: 4px;';
                styles+='    outline-color: blue;';
                styles+='}';
                styles+='</style>';

            document.head.innerHTML += styles;

            Mura('.mxp-editable').addClass('mxp-editable-active');
        }

        if(window.Mura.layoutmanager){

            Mura("img").each(function(){MuraInlineEditor.checkforImageCroppers(this);});

            MuraInlineEditor.setAnchorSaveChecks(document);

            utility('.mura-cta__itemm, .mura-cta').remove();

            Mura(".mura-object[data-object]").each(MuraInlineEditor.initObject);

            Mura('div.mura-object[data-object][data-targetattr]').each(function(){
                let item=Mura(this);
                item.addClass("mura-active");
                item.children('.frontEndToolsModal').remove();
                item.children('.mura-fetborder').remove();
                item.prepend(window.Mura.layoutmanagertoolbar);
                if(item.data('objectname')){
                    item.children('.frontEndToolsModal').children('.mura-edit-label').html(item.data('objectname'));
                } else {
                    item.children('.frontEndToolsModal').children('.mura-edit-label').html(Mura.firstToUpperCase(item.data('object')));
                }
                if(item.data('objecticonclass')){
                    item.children('.frontEndToolsModal').children('.mura-edit-label').addClass(item.data('objecticonclass'));
                }
                item.off("click",Mura.handleObjectClick).on("click",Mura.handleObjectClick);
            });
        }


        utility('.mura-editable-attribute').each(
            function(){

                let attribute=utility(this);

            if(attribute.data('attribute')){

                if(window.Mura.layoutmanager){
                    if(attribute.attr('data-attribute')){
                        MuraInlineEditor.initEditableObjectData.call(this);
                        if(!utility(this).closest('.mura-object[data-object]').length){
                            utility(this)
                            .off('dblclick')
                            .on('dblclick',
                                function(){
                                    MuraInlineEditor.initEditableAttribute.call(this);
                                    Mura(this).focus();
                                }
                            );
                        }
                    }

                } else {

                    let attributename=attribute.attr('data-attribute').toLowerCase();

                    attribute.attr('contenteditable','true');
                    attribute.attr('title','');

                    utility(this)
                    .unbind('click')
                    .click(
                        function(){
                            MuraInlineEditor.initEditableObjectData.call(this);
                        }
                    );

                    if(!(attributename in MuraInlineEditor.attributes)){

                        if(attribute.attr('data-type').toLowerCase()=='htmleditor' 
                        && typeof CKEDITOR != 'undefined'
                        && typeof CKEDITOR.instances[attribute.attr('id')] != 'undefined'
                        ){
                            let editor=CKEDITOR.inline(
                            document.getElementById( attribute.attr('id') ),
                            {
                                toolbar: 'QuickEdit',
                                width: "75%",
                                customConfig: 'config.js.cfm'
                            });

                            editor.on('change', function(){
                                if(utility('#adminSave').css('display') == 'none'){
                                    utility('#adminSave').fadeIn();
                                }
                            });
                        }

                    }
                }
            }

        });

        if(window.Mura.layoutmanager) {
            Mura.initLayoutManager(false,doreset);
        }
        utility('.mura-inline-save').click(async function(){
            let changesetid=utility(this).attr('data-changesetid');
            let isApproved=utility(this).data('approved');

            delete MuraInlineEditor.data.removePreviousChangeset;
            
            if(!nodeIsApproved){
                if(Mura.changesetid != '' && Mura.changesetid != changesetid){
                    let proceed=false;
                    if(isApproved){
                        if(confirm(publishitemfromchangeset)){
                            proceed=true;
                        }
                    } else {
                        if(confirm(changesetnotifyexport)){
                            proceed=true;
                        }
                    }
                    
                    if(!proceed){
                        return;
                    }
                }
                
                if(Mura.changesetid != '' && Mura.changesetid != changesetid){
                    if(confirm(removechangeset)){
                        MuraInlineEditor.data.removePreviousChangeset=true;
                    }
                }
            }

            if(changesetid == ''){
                MuraInlineEditor.data.approved=utility(this).attr('data-approved');
                MuraInlineEditor.data.changesetid='';
            } else {
                MuraInlineEditor.data.changesetid=changesetid;
                MuraInlineEditor.data.approved=0;
            }

            MuraInlineEditor.save();
        });

        utility('.mura-inline-cancel').click(function(){
            MuraInlineEditor.reload();
        });

        //clean instances
        if(typeof CKEDITOR != 'undefined'){
            for (let instance in CKEDITOR.instances) {
                if(!utility('#' + instance).length){
                    CKEDITOR.instances[instance].destroy(true);
                }
            }
        }

        return false;
    },
    reload:function(){
        let queryParams=Mura.getQueryStringParams();
        if(typeof queryParams.editlayout == 'undefined'){
            location.reload();
        } else {
            let queryString=Object.keys(queryParams).map(function(key) {
                if(key!='editlayout'){
                    return key + '=' + queryParams[key]
                }
            }).join('&');
            window.location = window.location.href.split("?")[0] + ((queryString) ? '?' + queryString : '') + window.location.hash;
        }	
    },
    initObject:function(){
        var item=Mura(this);
        var objectParams;

        if(item.data('transient')){
            item.remove();
        } else if(Mura.type=='Variation' && 
            !(
                item.is('[data-mxpeditable]')
                || item.closest('.mxp-editable').length
            )
        ){
            return;
        }

        item.addClass("mura-active");

        if(Mura.type =='Variation'){
            objectParams=item.data();
            item.children('.frontEndToolsModal').remove();
            item.children('.mura-fetborder').remove();
            item.prepend(window.Mura.layoutmanagertoolbar );
            if(item.data('objectname')){
                item.children('.frontEndToolsModal').children('.mura-edit-label').html(item.data('objectname'));
            } else if (item.data('object')){
                item.children('.frontEndToolsModal').children('.mura-edit-label').html(Mura.firstToUpperCase(item.data('object')));
            } else {
                item.children('.frontEndToolsModal').children('.mura-edit-label').html("Text");
            }
            if(item.data('objecticonclass')){
                item.children('.frontEndToolsModal').children('.mura-edit-label').addClass(item.data('objecticonclass'));
            }
            item.off("click",Mura.handleObjectClick)
                .on("click",Mura.handleObjectClick);
            item.find("img").each(function(){MuraInlineEditor.checkforImageCroppers(this);});
            item.find('.mura-object[data-object]').each(MuraInlineEditor.initObject);
            Mura.initDraggableObject(item.node);
        } else {
            let lcaseObject=item.data('object');
            if(typeof lcaseObject=='string'){
                lcaseObject=lcaseObject.toLowerCase();
            }
           
            let region=item.closest('.mura-region-local, .mura-object[data-object="container"][data-targetattr]');
            if(region && region.length ){              
                if(region.data('perm') || region.is('.mura-object[data-object="container"][data-targetattr]')){                 
                    objectParams=item.data();
                    if(window.MuraInlineEditor.objectHasConfigurator(item) || (!window.Mura.layoutmanager && window.MuraInlineEditor.objectHasEditor(objectParams)) ){
                        item.children('.frontEndToolsModal').remove();
                        item.children('.mura-fetborder').remove();
                        item.prepend(window.Mura.layoutmanagertoolbar);
                        if(item.data('objectname')){
                            item.children('.frontEndToolsModal').children('.mura-edit-label').html(item.data('objectname'));
                        } else {
                            item.children('.frontEndToolsModal').children('.mura-edit-label').html(Mura.firstToUpperCase(item.data('object')));
                        }
                        if(item.data('objecticonclass')){
                            item.children('.frontEndToolsModal').children('.mura-edit-label').addClass(item.data('objecticonclass'));
                        }
                        item.off("click",Mura.handleObjectClick).on("click",Mura.handleObjectClick);
                        item.find("img").each(function(){MuraInlineEditor.checkforImageCroppers(this);});
                        item.find('.mura-object[data-object]').each(MuraInlineEditor.initObject);
                        Mura.initDraggableObject(item.node);
                    }
                }

            } else if (lcaseObject=='form' || lcaseObject=='component'){
                let entity=Mura.getEntity('content');
                let conditionalApply=function(){
                    objectParams=item.data();
                    if(window.MuraInlineEditor.objectHasConfigurator(item) || (!window.Mura.layoutmanager && window.MuraInlineEditor.objectHasEditor(objectParams)) ){
                        item.addClass('mura-active');
                        item.hover(
                            Mura.initDraggableObject_hoverin,
                            Mura.initDraggableObject_hoverout
                        );
                        item.data('notconfigurable',true);
                        item.children('.frontEndToolsModal').remove();
                        item.children('.mura-fetborder').remove();
                        item.prepend(window.Mura.layoutmanagertoolbar);
                        if(item.data('objectname')){
                            item.children('.frontEndToolsModal').children('.mura-edit-label').html(item.data('objectname'));
                        } else {
                            item.children('.frontEndToolsModal').children('.mura-edit-label').html(Mura.firstToUpperCase(item.data('object')));
                        }
                        if(item.data('objecticonclass')){
                            item.children('.frontEndToolsModal').children('.mura-edit-label').addClass(item.data('objecticonclass'));
                        }
                        item.off("click",Mura.handleObjectClick).on("click",Mura.handleObjectClick);
                        item.find("img").each(function(){MuraInlineEditor.checkforImageCroppers(this);});
                        item.find('.mura-object[data-object]').each(MuraInlineEditor.initObject);
                    }
                }
                
                if(item.data('perm')){
                    conditionalApply()
                } else {
                    if(Mura.isUUID(item.data('objectid'))){
                        entity.loadBy('contentid',item.data('objectid'),{type:lcaseObject}).then(function(bean){
                            bean.get('permissions').then(function(permissions){
                                if(permissions.get('save')){
                                    item.data('perm',true);
                                    conditionalApply()
                                }
                            });
                        });
                    } else {
                        entity.loadBy('title',item.data('objectid'),{type:lcaseObject}).then(function(bean){
                            bean.get('permissions').then(function(permissions){
                                if(permissions.get('save')){
                                    item.data('perm',true);
                                    conditionalApply()
                                }
                            });
                        });
                    }
                }

            }

        }
    },
    resetEditableAttributes:function(){
        if(Mura.currentId && MuraInlineEditor.commitEdit){
            MuraInlineEditor.commitEdit(Mura('#' + Mura.currentId));
        }

        utility('.mura-editable-attribute').each(
            function(){
                let attribute=utility(this);
                
                if(attribute.attr('contenteditable') == 'true'){

                    if(CKEDITOR.instances[attribute.attr('id')]){
                        let instance =CKEDITOR.instances[attribute.attr('id')];
                        instance.updateElement();
                        instance.destroy(true)
                    }

                    attribute.attr('contenteditable','false');
                    attribute.addClass('mura-active');
                    attribute.data('manualedit',false);
                    Mura.processMarkup(this);

                    attribute.find('.mura-object[data-object]').each(function(){
                        Mura.initDraggableObject(this);
                        Mura(this).addClass('mura-active')
                        Mura(this).on('click',Mura.handleObjectClick);
                    });

                    attribute.find(Mura.looseDropTargets).each(function(){
                        Mura.initLooseDropTarget(this);
                    });

                    attribute
                    .off('dblclick')
                    .on('dblclick',
                        function(){
                            MuraInlineEditor.initEditableAttribute.call(this);
                        }
                    );

                }
        });
    },
    initEditableObjectData:function(){
        let attributename=this.getAttribute('data-attribute').toLowerCase();
        let attribute=document.getElementById('mura-editable-attribute-' + attributename);

        if(!(attributename in MuraInlineEditor.attributes)){
            if(attributename in MuraInlineEditor.preprocessed){

                attribute.innerHTML=MuraInlineEditor.preprocessed[attributename];

                if(Mura.processMarkup){
                    Mura.processMarkup(this);
                }
            }


            MuraInlineEditor.attributes[attributename]=attribute;
        }
    },
    initEditableAttribute:function(){
        let attribute=utility(this);

        MuraInlineEditor.sidebarAction('showeditor');
        attribute.attr('contenteditable','true');
        attribute.attr('title','');
        attribute.unbind('dblclick');
        attribute.find('.mura-object[data-object]').each(function(){
            let self=utility(this);

            self.removeAttr('data-perm')
            .removeAttr('draggable');

            if(typeof mura !='undefined' && typeof Mura.resetAsyncObject=='function'){
                Mura.resetAsyncObject(this);
            } else {
                self.html('');
            }

        });

        if(!attribute.data('manualedit')){
            if(attribute.attr('data-type').toLowerCase()=='htmleditor' &&
                typeof(CKEDITOR.instances[attribute.attr('id')]) == 'undefined'
            ){
                let editor=CKEDITOR.inline(
                document.getElementById( attribute.attr('id') ),
                {
                    toolbar: 'QuickEdit',
                    width: "75%",
                    customConfig: 'config.js.cfm'
                });

                editor.on('change', function(){
                    if(utility('#adminSave').css('display') == 'none'){
                        utility('#adminSave').fadeIn();
                    }
                });
            }

            attribute.data('manualedit',true);
        }

        MuraInlineEditor.isDirty=true;

    },
    getAttributeValue: function(attribute){
        let attributeid='mura-editable-attribute-' + attribute;

        if(typeof MuraInlineEditor.attributes[attribute].innerHTML == 'undefined'){
            MuraInlineEditor.attributes[attribute]=document.getElementById(attributeid);
        }
        if(typeof CKEDITOR.instances[attributeid] != 'undefined') {
            CKEDITOR.instances[attributeid].updateElement();
            return CKEDITOR.instances[attributeid].getData();
        } else if (MuraInlineEditor.attributes[attribute].getAttribute('data-type').toLowerCase() == 'htmleditor') {
            return MuraInlineEditor.attributes[attribute].innerHTML;
        } else {
            return MuraInlineEditor.stripHTML(MuraInlineEditor.attributes[attribute].innerHTML.trim());
        }
    },
    save:async function(){
        try{
           
            Mura('#adminSave').addClass('mura-saving');

            Mura('.mura-object-selected').removeClass('mura-object-selected');

            Mura('.mura-object[data-transient="true"], .mura-cta__item, .mura-cta').remove();

            Mura(document)
                .trigger('muraBeforeContentSave')
                .trigger('MuraBeforeContentSave')
                .trigger('beforeContentSave')
                .trigger('BeforeContentSave');

            let nestedObjectAttributes={};

            Mura('.mura-object[data-object] .mura-editable-attribute').forEach(function(){
                var item=utility(this);
                if(item.data('attribute')){
                    nestedObjectAttributes[item.data('attribute')]=item.html();
                }
            });

            //turning this off so that all new approval request just cancel previous
            if(requiresApproval && (MuraInlineEditor.data.approved || MuraInlineEditor.data.changesetid)){
                let hasPendingRequest=await Mura.post(Mura.getAPIEndpoint(),{
                    method:'hasPendingRequest',
                    contentid: MuraInlineEditor.data.contentid,
                    changesetid: MuraInlineEditor.data.changesetid
                })

                if(hasPendingRequest.data.count){
                    if(confirm(cancelPendingApproval)){
                        MuraInlineEditor.data.cancelpendingapproval=true;
                    } else {
                        Mura('.mura-saving').removeClass('mura-saving')
                        return false;
                    }
                }
            }

            let isValid= await this.validate()
     
            if(isValid){
                let count=0;
                  
                Mura('.mura-object[data-object="GatedAsset"],.mura-object[data-object="gatedasset"]').each(function(){
                    Mura.resetAsyncObject(this);
                });

                for (const prop in MuraInlineEditor.attributes) {
                    let attribute=MuraInlineEditor.attributes[prop].getAttribute('data-attribute');

                    Mura(attribute)
                        .find('.mura-object[data-object]')
                        .removeAttr('data-perm')
                        .removeAttr('draggable');

                    Mura(attribute)
                        .find('.mura-object[data-object]')
                        .each(function()
                        {
                            Mura.resetAsyncObject(this)
                        });
                
                    
                    MuraInlineEditor.data[attribute]=MuraInlineEditor.getAttributeValue(attribute);
                    count++;
                }

                Mura('.mxp-editable').each(function(){
                    Mura(this)
                        .find('.mura-object[data-object]')
                        .each(function()
                        {
                            Mura.resetAsyncObject(this)
                        });
                });
                
                let processedRegions={};
            
                Mura('.mura-region-local[data-inited="true"]:not([data-loose="true"])').each(
                    function(){
                        if(typeof processedRegions['objectlist' + this.getAttribute('data-regionid')] =='undefined'){
                            let objectlist=[];
                                
                            Mura(this).children('.mura-object[data-object]').each(function(){

                           
                                Mura.resetAsyncObject(this)
                                let item=Mura(this);
                            

                                if(!item.data('transient')){
                                    let params=item.data();
                                    let objectid='';

                                    delete params['objectid'];
                                    delete params['inited'];
                                    delete params['isconfigurator'];
                                    delete params['perm'];
                                    delete params['async'];
                                    delete params['forcelayout'];
                                    delete params['isbodyobject'];
                                    delete params['runtime'];
                                    delete params['startrow'];
                                    delete params['pagenum'];
                                    delete params['nextnid'];
                                    delete params['origininstanceid'];
                                    delete params['dynamicProps'];

                                    if(!item.data('objectname')){
                                        item.data('objectname',Mura.firstToUpperCase(item.data('object')));
                                    }

                                    objectid=item.data('objectid') || 'N/A';

                                    objectlist.push([item.data('object'),item.data('objectname') , objectid , JSON.stringify(params)])
                                }
                            });

                            processedRegions['objectlist' + this.getAttribute('data-regionid')]=true;
                            MuraInlineEditor.data['objectlist' + this.getAttribute('data-regionid')]=JSON.stringify(objectlist);
                            count++;
                        }
                    }
                );

                Mura.extend(MuraInlineEditor.data,nestedObjectAttributes);

                Mura('div.mura-object[data-targetattr]').each(function(){
                   
                    Mura.resetAsyncObject(this);
                    
                    let item=Mura(this);

                    if(item.data('targetattr')=='objectparams'){
                        if(item.data('displaylist')){
                            MuraInlineEditor.data['displaylist']=item.data('displaylist');
                        }
                        if(item.data('imagesize')){
                            MuraInlineEditor.data['imagesize']=item.data('imagesize');
                        }
                        if(item.data('imagewidth')){
                            MuraInlineEditor.data['imagewidth']=item.data('imagewidth');
                        }
                        if(item.data('imageheight')){
                            MuraInlineEditor.data['imageheight']=item.data('imageheight');
                        }
                        if(item.data('nextn')){
                            MuraInlineEditor.data['nextn']=item.data('nextn');
                        }
                        if(item.data('sortby')){
                            MuraInlineEditor.data['sortby']=item.data('sortby');
                        }
                        if(item.data('sortdirection')){
                            MuraInlineEditor.data['sortdirection']=item.data('sortdirection');
                        }
                    }

                    let params=item.data();
                 
                    delete params['objectid'];
                    delete params['inited'];
                    delete params['isconfigurator'];
                    delete params['perm'];
                    delete params['async'];
                    delete params['forcelayout'];
                    delete params['isbodyobject'];
                    delete params['runtime'];
                    delete params['startrow'];
                    delete params['pagenum'];
                    delete params['nextnid'];
                    delete params['origininstanceid'];
                    delete params['dynamicProps'];

                    MuraInlineEditor.data[item.data('targetattr')]=encodeURIComponent(JSON.stringify(params));

                });
                
                if(nodeType=='Variation'){

                    count=1;

                    if(MuraInlineEditor.commitEdit && Mura.currentId){
                        MuraInlineEditor.commitEdit(Mura('#' + Mura.currentId));
                    }

                    Mura('.mxp-editable').each(function(){
                        let item=Mura(this);
                        let selector=item.selector();
                        let selectorId='#mxp' + Mura.hashCode(selector);
                        let instance=CKEDITOR.instances[item.attr('id')];

                        for(const element of Mura.finalVariations){
                            if(element.selector==selector){
                                if(instance){
                                    instance.updateElement();
                                }
                                   
                                item
                                    .find('.mura-object[data-object]').each(function(){
                                        Mura.resetAsyncObject(this);
                                    })
                                    .find('.mxp-variation-marker').each(function(){
                                       Mura(this).remove();
                                    })

                                element.adjusted=item.html();
                            }
                        }

                    });

                    MuraInlineEditor.data=Mura.extend(
                        MuraInlineEditor.data,
                        {
                            moduleid:Mura.content.get('moduleid'),
                            remoteid:Mura.content.get('remoteid'),
                            remoteurl:Mura.content.get('remoteurl'),
                            type:Mura.content.get('type'),
                            subtype:Mura.content.get('subtype'),
                            parentid:Mura.content.get('parentid'),
                            title:Mura.content.get('title'),
                            body:encodeURIComponent(JSON.stringify(Mura.finalVariations))
                        }
                    );                      
                }
                
                if(count){

                    if(typeof $ != 'undefined' && $.support){
                        $.support.cors = true;
                    }

                    Mura.ajax({
                    type: "POST",
                    xhrFields: { withCredentials: true },
                    crossDomain:true,
                    url: adminLoc,
                    data: MuraInlineEditor.data,
                    success: function(data){
                        let resp = eval('(' + data + ')');

                        if(resp.success){
                            if(nodeType=='Variation'){
                                if(MuraInlineEditor.requestedURL && location.href != MuraInlineEditor.requestedURL){
                                    location.href=MuraInlineEditor.requestedURL
                                } else {
                                    MuraInlineEditor.reload();
                                }
                            } else {
                                let resp = eval('(' + data + ')');
                                if(MuraInlineEditor.requestedURL   && MuraInlineEditor.requestedURL != location.href && !(MuraInlineEditor.requestedURL.indexOf('previewid') > -1) ){
                                    location.href=MuraInlineEditor.requestedURL;
                                    if(location.href.indexOf('#') > -1){
                                        MuraInlineEditor.reload();
                                    }
                                } else if(location.href!=resp.location){
                                    location.href=resp.location;
                                    if(location.href.indexOf('#') > -1){
                                        MuraInlineEditor.reload();
                                    }
                                } else {
                                    MuraInlineEditor.reload();
                                }
                            }
                        } else {

                            utility('#adminSave').removeClass('mura-saving');

                            MuraInlineEditor.data['csrf_token']=resp['csrf_token'];
                            MuraInlineEditor.data['csrf_token_expires']=resp['csrf_token_expires'];

                            let msg='';
                            for(let e in resp.errors){
                                msg=msg + resp.errors[e] + '\n';
                            }

                            alert(msg);
                        }

                    },
                        error: function(data){
                        utility('#adminSave').removeClass('mura-saving');
                        alert("A server error has occurred. Please check your browser console for details.");
                        console.log(JSON.stringify(data));

                    }
                    });
                } else {
                    if(MuraInlineEditor.requestedURL && MuraInlineEditor.requestedURL != location.href){
                        location.href=MuraInlineEditor.requestedURL;
                        if(location.href.indexOf('#') > -1){
                            MuraInlineEditor.reload();
                        }
                    } else {
                        MuraInlineEditor.reload();
                    }

                }
            }
        } catch(err){
            alert("An error has occurred. Please check your browser console for details.");
            console.log(err);
        }

        return false;
    },
    stripHTML: function(html){
        let tmp = document.createElement("DIV");
        tmp.innerHTML = html;
        return tmp.textContent||tmp.innerText;
    },
    validate: async function(){

        if(!Mura.apiEndpoint){
            Mura.apiEndpoint=Mura.context + '/index.cfm/_api/json/v1/';
        }

        const getValidationFieldName=function(theField){
            if(theField.getAttribute('data-label')!=undefined){
                return theField.getAttribute('data-label');
            }else if(theField.getAttribute('label')!=undefined){
                return theField.getAttribute('label');
            }else{
                return theField.getAttribute('name');
            }
        }

        const getValidationIsRequired=function(theField){
            if(theField.getAttribute('data-required')!=undefined){
                return (theField.getAttribute('data-required').toLowerCase() =='true');
            }else if(theField.getAttribute('required')!=undefined){
                return (theField.getAttribute('required').toLowerCase() =='true');
            }else{
                return false;
            }
        }

        const getValidationMessage=function(theField, defaultMessage){
            if(theField.getAttribute('data-message') != undefined){
                return theField.getAttribute('data-message');
            } else if(theField.getAttribute('message') != undefined){
                return theField.getAttribute('message') ;
            } else {
                return getValidationFieldName(theField).toUpperCase() + defaultMessage;
            }
        }

        const getValidationType=function(theField){
            if(theField.getAttribute('data-validate')!=undefined){
                return theField.getAttribute('data-validate').toUpperCase();
            }else if(theField.getAttribute('validate')!=undefined){
                return theField.getAttribute('validate').toUpperCase();
            }else{
                return '';
            }
        }

        const hasValidationMatchField=function(theField){
            if(theField.getAttribute('data-matchfield')!=undefined && theField.getAttribute('data-matchfield') != ''){
                return true;
            }else if(theField.getAttribute('matchfield')!=undefined && theField.getAttribute('matchfield') != ''){
                return true;
            }else{
                return false;
            }
        }

        const getValidationMatchField=function (theField){
            if(theField.getAttribute('data-matchfield')!=undefined){
                return theField.getAttribute('data-matchfield');
            }else if(theField.getAttribute('matchfield')!=undefined){
                return theField.getAttribute('matchfield');
            }else{
                return '';
            }
        }

        const hasValidationRegex=function(theField){
            if(theField.value != undefined){
                return (
                    theField.getAttribute('data-regex')!=undefined && theField.getAttribute('data-regex') != ''
                    || theField.getAttribute('regex')!=undefined && theField.getAttribute('regex') != ''
                    );
            }else{
                return false;
            }
        }

        const getValidationRegex=function(theField){
            if(theField.getAttribute('data-regex')!=undefined){
                return theField.getAttribute('data-regex');
            }else if(theField.getAttribute('regex')!=undefined){
                return theField.getAttribute('regex');
            }else{
                return '';
            }
        }

        let data={};
    
        for (const prop in MuraInlineEditor.attributes) {
            data[prop]=MuraInlineEditor.getAttributeValue(prop);
        }

        let validationType='';
        let validations={properties:{}};
        let rules;
        let theField;
        let theValue;
        
        for (const prop in MuraInlineEditor.attributes) {
            theField=MuraInlineEditor.attributes[prop];
            validationType=getValidationType(theField).toUpperCase();;
            theValue=MuraInlineEditor.getAttributeValue(prop);

            rules=new Array();

            if(getValidationIsRequired(theField))
                {
                    rules.push({
                        required: true,
                        message: getValidationMessage(theField,' is required.')
                    });


                }
            if(validationType != ''){

                if(validationType=='EMAIL' && theValue != '')
                {
                        rules.push({
                            dataType: 'EMAIL',
                            message: getValidationMessage(theField,' must be a valid email address.')
                        });


                }

                else if(validationType=='NUMERIC')
                {
                        rules.push({
                            dataType: 'NUMERIC',
                            message: getValidationMessage(theField,' must be numeric.')
                        });

                }

                else if(validationType=='REGEX' && theValue !='' && hasValidationRegex(theField))
                {
                        rules.push({
                            regex: hasValidationRegex(theField),
                            message: getValidationMessage(theField,' is not valid.')
                        });

                }

                else if(validationType=='MATCH'
                        && hasValidationMatchField(theField) && theValue != theForm[getValidationMatchField(theField)].value)
                {
                    rules.push({
                        eq: theForm[getValidationMatchField(theField)].value,
                        message: getValidationMessage(theField, ' must match' + getValidationMatchField(theField) + '.' )
                    });

                }

                else if(validationType=='DATE' && theValue != '')
                {
                    rules.push({
                        dataType: 'DATE',
                        message: getValidationMessage(theField, ' must be a valid date [MM/DD/YYYY].' )
                    });

                }
            }

            if(rules.length){
                validations.properties[prop]=rules;
            }
        }
        if(nodeType=='Variation' && !MuraInlineEditor.data.title){
            let pathname=location.pathname.split('/');

            if(pathname[pathname.length-1].split('.')[0]=='index'){
                pathname.pop();
                pathname=pathname.join('/');
                pathname=pathname + '/';
            } else {
                pathname=pathname.join('/');
            }
            MuraInlineEditor.data.title=[location.host, pathname.replace(/\/\//g, '/')].join('');
        }
        try{
            //alert(JSON.stringify(validations))
            
            let resp=await Mura.post(
                    Mura.apiEndpoint + '/validate/',
                    {
                        data: encodeURIComponent(JSON.stringify(utility.extend(MuraInlineEditor.data,data))),
                        validations: encodeURIComponent(JSON.stringify(validations))
                    }
                );

            if(typeof resp != 'object'){
                resp=data=eval('(' + resp + ')');
            }
            data=resp.data;

            if(utility.isEmptyObject(data)){
            return true
            } else {
                let msg='';
                for(const e in data){
                    msg=msg + data[e] + '\n';
                }

                alert(msg);

                return false;
            }

        }
        catch(err){
            alert(JSON.stringify(resp));
        }

        return false;

    },
    htmlEditorOnComplete: function(editorInstance) {
        let instance = utility(editorInstance).ckeditorGet();
        instance.resetDirty();
    },
    data:processedData,
    attributes: {},
    preprocessed: preprocessedData,
    pluginConfigurators:pluginConfigurators,
    getPluginConfigurator: function(objectid) {
        for(const element of window.MuraInlineEditor.pluginConfigurators) {
            if(element.objectid == objectid || element.object == objectid) {
                return element.init;
            }
        }

        return "";
    },
    customtaggroups:customtaggroups,
    allowopenfeeds:allowopenfeeds,
    objectHasEditor:function(displayObject){
        if(displayObject.object == 'form') {
            return true;
        } else if(displayObject.object == 'form_responses' || displayObject.object == 'component') {
            return true;
        } else {
            return false;
        }
    },'form':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
    configuratorMap:{
        'container':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'collection':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'text':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'embed':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'feed':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initFeedConfigurator(data);}},
        'form':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'component':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'folder':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'gallery':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'calendar':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'form_responses':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'plugin':{
            'condition':function(){
                return true;
            },
            'initConfigurator':function(data){
                if(data.objectid && data.objectid.toLowerCase() != 'none' && siteManager.getPluginConfigurator(data.objectid)){
                    var configurator = siteManager.getPluginConfigurator(data.objectid);
                    window[configurator](data)
                } else {
                    siteManager.initGenericConfigurator(data);
                }
            }
        },
        'feed_slideshow':{condition:function(){return true;},'initConfigurator':function(data){MuraInlineEditor.initSlideShowConfigurator(data);}},
        'tag_cloud':{condition:function(){return MuraInlineEditor.customtaggroups.length;},'initConfigurator':function(data){siteManager.initTagCloudConfigurator(data);}},
        'category_summary':{condition:function(){return true;},'initConfigurator':function(data){if(siteManager.allowopenfeeds){siteManager.initCategorySummaryConfigurator(data);} else {siteManager.initGenericConfigurator(data);}}},
        'archive_nav':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'calendar_nav':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'category_summary_rss':{condition:function(){return MuraInlineEditor.allowopenfeeds;},'initConfigurator':function(data){siteManager.initCategorySummaryConfigurator(data);}},
        'site_map':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initSiteMapConfigurator(data);}},
        'related_content':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initRelatedContentConfigurator(data);}},
        'related_section_content':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initRelatedContentConfigurator(data);}},
        'system':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'comments':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'favorites':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'forward_email':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'event_reminder_form':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'rater':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'user_tools':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'goToFirstChild':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'navigation':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'sub_nav':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'peer_nav':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'standard_nav':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'portal_nav':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'folder_nav':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'multilevel_nav':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'seq_nav':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'top_nav':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'mailing_list':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}},
        'mailing_list_master':{condition:function(){return true;},'initConfigurator':function(data){siteManager.initGenericConfigurator(data);}}
    },
    objectHasConfigurator:function(displayObject){
        let lcaseObject=displayObject.data('object');
        if(typeof lcaseObject=='string'){
            lcaseObject=lcaseObject.toLowerCase();
        }
        let check;

        if(!displayObject.hasClass){
            return true;
        }
        if(displayObject.hasClass('mura-body-object') || displayObject.is('div.mura-object[data-targetattr]')){
            return true;
        }

        if(lcaseObject!='form' && lcaseObject!='component'){
            let check=displayObject.closest('.mura-region-local');

            if(!check.length){
                displayObject.removeClass('mura-active');
                return false
            }
        }

        check=displayObject.parent().closest('.mura-object[data-object]');

        if(check.length && check.data('object')!='container' && check.data('object').toLowerCase() !='gatedasset'){
            displayObject.removeClass('mura-active');
            return false;
        }

        return true;

    },
    checkforImageCroppers:function(el){

        if(window.mura && window.Mura.editing){
            var img=Mura(el);

            if(Mura.type=='Variation' 
                && !(
                    img.closest('[data-mxpeditable]')
                    || img.closest('.mxp-editable').length
                )
            ){
                return;
            }

            let instanceid=Mura.createUUID();
                img.data('instanceid',instanceid);

                let path=img.attr('src');

            if(path){
                path=path.split( '?' )[0].split('/')
            } else {
                return;
            }
            let fileParts=path[path.length-1].split('.');
            let filename=fileParts[0];
            let fileext;

            if(fileParts.length > 1){
                fileext=fileParts[1].toLowerCase();
            }

            let fileInfo=filename.split('_');
            let fileid=fileInfo[0];

            if(fileid.length==35 && (fileext=='jpg' || fileext=='jpeg' || fileext=='png' || fileext=='webp')){
                fileInfo.shift()


                img.css({display:'inline-block;'});

                let size=fileInfo.join('_');

                if(!size){
                    size='large';
                }

                let actionhref=adminLoc + '?muraAction=cArch.imagedetails&siteid=' + Mura.siteid + '&fileid=' + fileid + '&imagesize=' + size + '&instanceid=' + img.data('instanceid') + '&compactDisplay=true';

                function initCropper(){
                    openFrontEndToolsModal({
                            href:actionhref
                    });
                }


                let a=img.closest('a');


                if(a.length){
                    a.click(function(e){e.preventDefault();});
                    a.attr('onclick',"openFrontEndToolsModal({href:'" + actionhref + "'}); return false;");
                    a.off();
                }

                img=Mura('img[data-instanceid="' + instanceid + '"]' );
                img.on('click',function(e){e.preventDefault();});

                Mura('img[data-instanceid="' + instanceid + '"]' ).on('click',function(){
                    initCropper();
                });
            }

        }
    },
    reloadImg:function(img) {

        let src = img.src;

        let pos = img.indexOf('?');
        if (pos >= 0) {
            src = src.substr(0, pos);
        }

        img.src = src + '?v=' + Math.random();

        return false;
    },
    sidebarAction:function(action){

        if(action=='showobjects'){
            Mura.currentObjectInstanceID='';
            MuraInlineEditor.resetEditableAttributes();
            Mura('.mura-object-selected').removeClass('mura-object-selected');
            Mura('.mura-object-select').removeClass('mura-object-select');
            Mura('.mura-editable-attribute.mura-active').removeClass('mura-active');
            Mura('.mura-container-active').removeClass('mura-container-active');
            Mura('#mura-sidebar-configurator').hide();
            Mura('#mura-sidebar-objects-legacy').hide();
            Mura('#mura-sidebar-objects').show();
            Mura('#mura-sidebar-editor').hide();
        } else if(action=='showlegacyobjects'){
            Mura.currentObjectInstanceID='';
            MuraInlineEditor.resetEditableAttributes();
            Mura('.mura-object-selected').removeClass('mura-object-selected');
            Mura('.mura-container-active').removeClass('mura-container-active');
            Mura('#mura-sidebar-configurator').hide();
            Mura('#mura-sidebar-objects-legacy').show();
            Mura('#mura-sidebar-objects').hide();
            Mura('#mura-sidebar-editor').hide();
        } else if(action=='showconfigurator'){
            MuraInlineEditor.resetEditableAttributes();
            Mura('#mura-sidebar-configurator').hide();
            Mura('#mura-sidebar-objects-legacy').hide();
            Mura('#mura-sidebar-objects').hide();
            Mura('#mura-sidebar-editor').hide();
        } else if(action=='showeditor'){
            Mura.currentObjectInstanceID='';
            Mura('.mura-object-selected').removeClass('mura-object-selected');
            Mura('.mura-container-active').removeClass('mura-container-active');
            Mura('#mura-sidebar-configurator').hide();
            Mura('#mura-sidebar-objects-legacy').hide();
            Mura('#mura-sidebar-objects').hide();
            Mura('#mura-sidebar-editor').show();
        } else if(action=='minimizesidebar'){
            Mura.currentObjectInstanceID='';
            Mura('#mura-sidebar-container').fadeOut();
            Mura('body').removeClass('mura-sidebar-state__pushed--right')
            Mura('body').removeClass('mura-editing')
            Mura('.mura-object[data-object]').removeClass('mura-active').addClass("mura-active-min");
        } else if(action=='restoresidebar'){
            Mura.currentObjectInstanceID='';
            Mura('#mura-sidebar-container').fadeIn();
            Mura('body').addClass('mura-sidebar-state__pushed--right');
            Mura('body').addClass('mura-editing')
            Mura('.mura-object[data-object]').removeClass('mura-active-min').addClass("mura-active");
            Mura('.mura-container-active').removeClass('mura-container-active');

        }

    },
    setAnchorSaveChecks:async function(el){
        async function handleEditCheck(){
            if(MuraInlineEditor.isDirty && !Mura(el).closest('.mura-object[data-object]').length){
                if(confirm(saveasdraftlm)){
                    MuraInlineEditor.requestedURL=window.location;
                    MuraInlineEditor.save();
                    return false;
                } else if(confirm(keepeditingconfirmlm)){
                    return false;
                }
            } else {
                return true;
            }
        }

        let anchors=el.querySelectorAll('a');

        for(const element of anchors){
            if(!Mura(element).closest('.mura').length){
                try{
                    if (typeof(element.onclick) != 'function'
                        && typeof(element.getAttribute('href')) == 'string'
                        && element.getAttribute('href').indexOf('#') == -1
                        && element.getAttribute('href').indexOf('mailto') == -1) {
                            element.onclick = handleEditCheck;
                    }
                } catch(err){}
            }
        }
    },
    isDirty:false
}

window.MuraInlineEditor=MuraInlineEditor;
window.toggleAdminToolbar=toggleAdminToolbar;
window.closeFrontEndToolsModal=closeFrontEndToolsModal;
window.openFrontEndToolsModal=openFrontEndToolsModal;
window.themepath=window.themepath || Mura.themepath;
window.muraInlineEditor=window.MuraInlineEditor;
Mura.handleObjectClick=openToolbar;
Mura.initEditableObject = MuraInlineEditor.initObject;
Mura.initFrontendUI=initFrontendUI;
Mura.lmv=2;

if(nodeType=='Variation'){
    Mura('#mura-edit-var-targetingjs').click(function(e){
        e.preventDefault();

        if(editingVariations){
            return;
        }

        Mura('#adminQuickEdit').css('text-decoration','line-through');
        Mura('.mura-edit-toolbar-content').remove();
        Mura('#adminStatus').hide();
        Mura('#adminSave').show();
        Mura('.mura-inline-cancel').click(function(){
            MuraInlineEditor.reload();
        });

        editingVariations=false;
        window.muraInlineEditor.resetEditableAttributes();

        while(Mura.variations.length){
            let last=Mura.variations.length-1;
            Mura(Mura.variations[last].selector).html(Mura.variations[last].original);
            Mura.variations.pop();
        }

        Mura('.mxp-dynamic-id').each(function(){
            let item=Mura(this);
            item.removeAttr('id');
            item.removeClass('mxp-dynamic-id');
        });


        if(targetingVariations){
            return;
        }

        targetingVariations=true;

        let styles='<style type="text/css">.mxp-editable,  .mxp-editable.mxp-editable-target {';
        styles+='	outline-width: 2px;';
        styles+='	outline-style: solid;';
        styles+='   outline-color: red;';
        styles+='}';
        styles+='.mxp-editable-target {';
        styles+='    outline-width: 2px;';
        styles+='    outline-style: solid;';
        styles+='    outline-color: blue;';
        styles+='}</style>';

        Mura('head').append(styles);

        Mura(function(){
            let selectors=[];

            Mura('p,div,td,h1,h2,h3,h4,h5,article,nav,main,aside,header,footer,a,li,ul,ol,dl,dd,dt').hover(
                function(e){
                    if(!editingVariations){
                        var target=Mura(e.target);
                        if(!target.closest('.mura').length 
                            && !target.closest(".mura-object[data-object]").length){
                            target.addClass('mxp-editable-target');
                        }
                    }
                },
                function(e){
                    Mura(e.target).removeClass('mxp-editable-target');
                }
            )

        });

        Mura(document).click(function(e){

            if(!Mura(e.target).closest(".mura").length && !editingVariations){
                var item=Mura('.mxp-editable-target');

                if(item.length && !item.closest(".mura").length && !item.closest(".mura-object[data-object]").length){
                    if(item.hasClass('mxp-editable')){
                        item.removeClass('mxp-editable');
                    } else {
                        var container=item.closest('.mxp-editable');

                        if(container.length){
                            container.removeClass('mxp-editable');
                        }

                        item.find('.mxp-editable').each(function(){
                            Mura(this).removeClass('mxp-editable');
                        });

                        item.addClass('mxp-editable');
                    }
                }
            }
        });

        Mura(document).on('click','a',function(e){
            if(!editingVariations){
                if(!Mura(this).closest(".mura").length){
                    e.preventDefault();
                }
            }
        });

        Mura('.mura-inline-updatetargeting').click(function(){
            let selectors=[];

            Mura('.mxp-editable').each(function(){
                let item=Mura(this);
                selectors.push(item.selector());
            });
            
            function saveSelectors(){
                Mura.getFeed('variationTargeting')
                    .where()
                    .prop('contentid')
                    .isEQ(Mura.contentid)
                    .getQuery().then(function(collection){
                        if(collection.length()){
                            collection
                                .item(0)
                                .set('targetingjs',JSON.stringify(selectors))
                                .save()
                                .then(function(){
                                    MuraInlineEditor.reload();
                                });
                        } else {
                            Mura.getEntity('variationTargeting')
                                .set('targetingjs',JSON.stringify(selectors))
                                .set('contentid',Mura.contentid)
                                .save()
                                .then(function(){
                                    MuraInlineEditor.reload();
                                });
                        }
                    })
            }

            Mura.getEntity('content').loadBy('remoteid',Mura.remoteid).then(function(entity){
                if(entity.exists()){
                    saveSelectors();
                } else {
                    entity.set(
                    {
                        remoteid:Mura.remoteid,
                        title:Mura.title,
                        remoteurl:Mura.remoteurl,
                        type: Mura.type,
                        siteid: Mura.siteid,
                        contenthistid: Mura.contenthistid,
                        contentid: Mura.contentid,
                        parentid: Mura.parentid,
                        moduleid: Mura.moduleid,
                        id: Mura.contenthistid,
                        approved:1
                    }
                    ).save().then(function(){
                        saveSelectors();
                    })
                }
            })

        })
    });
}
        
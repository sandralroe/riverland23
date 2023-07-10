
window.frontEndModalWidthStandard=1140;
window.frontEndModalWidthConfigurator=600;
window.frontEndModalHeight=0;
window.frontEndModalWidth=0;
window.frontEndModalIE8=document.all && document.querySelector && !document.addEventListener;

const getConfiguratorWidth=function(){
    let check=window.innerWidth-20;
    if(check < frontEndModalWidthStandard){
        return check;
    } else {
        return frontEndModalWidthStandard;
    }
}

const autoScroll=function(y){
    let st = utility(window).scrollTop();
    let o = utility('#frontEndToolsModalBody').offset().top;
    let t = utility(window).scrollTop() + 80;
    let b = utility(window).height() - 50 + utility(window).scrollTop();
    let adjY = y + o;

    if (adjY > b) {
        //Down
        scrollTop(adjY, st + 35);
    } else if (adjY < t) {
        //Up
        scrollTop(adjY, st - 35);
    }
}

const scrollTop=function(y, top){
    utility('html, body').each(function(el){
        el.scrolltop=top;
    });
}

const openFrontEndToolsModal=function(a,isnew){
    return initFrontendUI(a,isnew);
};

const openToolbar=function(event){
    if(!window.Mura.editing){
        return;
    }
    let source = Mura(event.target || event.srcElement);

    if(source.is('.frontEndToolsModal') ){
        event.preventDefault();
        event.stopPropagation();
        openFrontEndToolsModal(this);
    } else if(source.is('.mura-object') ){
        event.preventDefault();
        event.stopPropagation();
        openFrontEndToolsModal(source.node);
    } else if (!source.is('button, input, select, textarea') ) {
        let parentObj=source.closest('.mura-object');
        if(parentObj.length){
            event.preventDefault();
            event.stopPropagation();
            openFrontEndToolsModal(parentObj.children('.frontEndToolsModal').node);
        }
    }
};

const initFrontendUI=function(a,isnew){

    if(typeof a=='undefined' || !a){
        return false;
    }

    let src=a.href;
    let editableObj=utility(a);
    let targetFrame='modal';

    //This is an advance look at the protential configurable object to see if it's a non-configurable component for form
    if(!src){
        if(editableObj.hasClass("mura-object")){
            editableObj=editableObj;
        } else {
            editableObj=editableObj.closest(".mura-object,.mura-async-object");
        }
        
        let lcaseObject=editableObj.data('object');
        if(typeof lcaseObject=='string'){
            lcaseObject=lcaseObject.toLowerCase();
        }

        //If the it's a form of component that's not configurable then go straight to edit it
        if((lcaseObject=='form' || lcaseObject=='component') && editableObj.data('notconfigurable')){
            MuraInlineEditor.sidebarAction('showobjects');

            if(Mura.isUUID(editableObj.data('objectid'))){
                    src=adminLoc + '?muraAction=cArch.editLive&compactDisplay=true&contentid=' + encodeURIComponent(editableObj.data('objectid')) + '&type='+ encodeURIComponent(editableObj.data('object')) + '&siteid='+  Mura.siteid + '&instanceid=' + encodeURIComponent(editableObj.data('instanceid'));
            } else {
                    src=adminLoc + '?muraAction=cArch.editLive&compactDisplay=true&title=' + encodeURIComponent(editableObj.data('objectid')) + '&type='+ encodeURIComponent(editableObj.data('object')) + '&siteid=' + Mura.siteid + '&instanceid=' + encodeURIComponent(editableObj.data('instanceid'));
            }

        }
    }

    //If there's no direct src to goto then we're going to assume it's a display object configurator
    
    if(!src){

        if(editableObj.hasClass("mura-object")){
            editableObj=utility(a).closest(".mura-object,.mura-async-object");
        }
        let cssDisplay='flex';

        let container=editableObj.parent().closest('div[data-object="container"]');
       
        if(container.length){
            cssDisplay=container.children('.mura-object-content').css('display');
            if(cssDisplay!=='block' && cssDisplay!=='grid'){
                cssDisplay='flex';
            }
        } else {
            let region=editableObj.parent().closest('div.mura-region-local');
            
            if(!region.length){
                cssDisplay=region.css('display');
                if(cssDisplay!=='block' && cssDisplay!=='grid'){
                    cssDisplay='flex';
                }   
            }
        }
        
        const legacyMap={
            feed:true,
            feed_slideshow:true,
            feed_no_summary:true,
            feed_slideshow_no_summary:true,
            related_content:true,
            related_section_content:true,
            plugin:true
        }

        if(!legacyMap[editableObj.data('object')]){
            targetFrame='sidebar';
            if(MuraInlineEditor.commitEdit && Mura.currentId){
                MuraInlineEditor.commitEdit(Mura('#' + Mura.currentId));
            }
        }

        /*
            This reloads the element in the dom to ensure that all the latest
            values are present
        */
        
        if(targetFrame=='sidebar' && !isnew && typeof Mura.currentObjectInstanceID != 'undefined' && Mura.currentObjectInstanceID == editableObj.data('instanceid')){
            return;
        }
        
        Mura.currentObjectInstanceID= editableObj.data('instanceid');

        editableObj=Mura('[data-instanceid="' + editableObj.data('instanceid') + '"]');
        editableObj.hide().show();

        Mura('.mura-object-select').removeClass('mura-object-select');
        Mura('.mura-active-target').removeClass('mura-active-target');
        Mura('.mura-container-active').removeClass('mura-container-active');

        if(editableObj.data('object')=='container'){
            editableObj.addClass('mura-container-active');
        } else {
            let container=editableObj.closest('div[data-object="container"]');
            if(container.length){
                let finder=container.find('div[data-instanceid="' + Mura.currentObjectInstanceID + '"]')
                if(finder.length){
                    container.addClass('mura-container-active');
                }
            }
        }
        editableObj.addClass('mura-object-select');

        isnew=isnew || false;

        src= adminLoc + '?muraAction=cArch.frontEndConfigurator&compactDisplay=true&siteid=' + Mura.siteid + '&instanceid=' +  editableObj.data('instanceid') + '&contenthistid=' + Mura.contenthistid + '&contentid=' + Mura.contentid + '&parentid=' + Mura.parentid + '&object=' +  editableObj.data('object') + '&objectid=' +  editableObj.data('objectid') + '&layoutmanager=' +  Mura.layoutmanager + '&objectname=' + encodeURIComponent(editableObj.data('objectname')) + '&contenttype=' + Mura.type + '&contentsubtype=' +encodeURIComponent(Mura.subtype) + '&sourceFrame=' + targetFrame + '&objecticonclass=' + encodeURIComponent(editableObj.data('objecticonclass')) + '&isnew=' + isnew + '&cssDisplay=' + cssDisplay;
        
        if(editableObj.is("div.mura-object[data-targetattr]")){
            src+='&hasTargetAttr=true';
        }
    }

    if(targetFrame=='modal'){
        editableObj=Mura(a);
        let isModal=editableObj.attr("data-configurator");

        //These are for the preview iframes
        let width=editableObj.attr("data-modal-width");

        frontEndModalHeight=0;
        frontEndModalWidth=600;

        if(!isNaN(width) && width){
            frontEndModalWidth = width;
        }

        closeFrontEndToolsModal();

        if(!frontEndModalHeight){
            if (isModal == undefined) {
                frontEndModalWidth = getConfiguratorWidth();
            } else if (isModal == "true") {
                frontEndModalWidth=frontEndModalWidthConfigurator;
            } else {
                frontEndModalWidth = getConfiguratorWidth();
            }
        }

        src=src + "&frontEndProxyLoc=" + frontEndProxyLoc;

        if(Mura.type=='Variation' && Mura.remoteid){
            src+='&remoteid=' + encodeURIComponent(Mura.remoteid);
        }

        if(Mura.type=='Variation' && Mura.title){
            src+='&title=' + encodeURIComponent(Mura.title);
        }

        if(Mura.type=='Variation' && Mura.remoteurl){
            src+='&remoteurl=' + encodeURIComponent(Mura.remoteurl);
        }

        src+='&cacheid=' + Math.random();

        utility("#frontEndToolsModalTarget").html('<div id="frontEndToolsModalContainer">' +
        '<div id="frontEndToolsModalBody">' +
        '<iframe src="' + src + '" id="frontEndToolsModaliframe" scrolling="false" frameborder="0" style="overflow:hidden" name="frontEndToolsModaliframe"></iframe>' +
        '</div>' +
        '</div>');

        frontEndModalHeight=0;
        utility("#frontEndToolsModalBody").css("top",(utility(document).scrollTop()+48) + "px")
        resizeFrontEndToolsModal(0);
        
    } else {

        Mura('.mura-object-selected').removeClass('mura-object-selected');

        editableObj.addClass('mura-object-selected');
        src+='&cacheid=' + Math.random();

        editableObj.trigger('muraConfiguratorInit').trigger('configuratorInit');

        //console.log(src)
        utility('#frontEndToolsSidebariframe').attr('src',src);
        MuraInlineEditor.sidebarAction('showconfigurator');
    }

    return false;
}

const resizeFrontEndToolsSidebar=function(frameHeight){
    const iframe=document.getElementById("frontEndToolsSidebariframe");
    if (iframe){
        iframe.style.height=frameHeight + "px";
    }

}

const resizeFrontEndToolsModal=function(frameHeight){

    if (document.getElementById("frontEndToolsModaliframe")) {

        let frame = document.getElementById("frontEndToolsModaliframe");
        let frameContainer = document.getElementById("frontEndToolsModalContainer");
        let framesrc = frame.getAttribute('src');
        let appliedHeight = 0;

        let isEditText = false; 
        let isFullHeight = framesrc.includes('cArch.editLive');// || framesrc.includes('cArch.edit') || framesrc.includes('html.cfm');;
        let windowHeight = Math.max(frameHeight, utility(window).height());

        frontEndModalWidth=frontEndModalWidth || 600;
        
        utility('#frontEndToolsModalContainer #frontEndToolsModalBody,#frontEndToolsModalContainer #frontEndToolsModaliframe').width(frontEndModalWidth);

        if (isEditText){
            appliedHeight = Math.min(760, utility(window).height()-96);
        } else if(isFullHeight) {
            appliedHeight = utility(window).height()-96;
        } else {
            appliedHeight = frameHeight;
        }

        frame.style.height = appliedHeight + "px";
        frameContainer.style.position = "absolute";
        document.overflow = "auto";

        if(windowHeight > frontEndModalHeight){
            frontEndModalHeight=windowHeight;
            frameContainer.style.height=utility(document).height() + "px";
            setTimeout(function(){
                utility("#frontEndToolsModalClose").fadeIn("fast")
            },1000);
        }
    }

}

const closeFrontEndToolsModal=function(){
    utility('#frontEndToolsModalContainer').remove();
}

const checkToolbarDisplay=function() {
    if(fetDisplay =='none'){
        utility('HTML').removeClass('mura-edit-mode');
        utility(".editableObject").addClass('editableObjectHide');
    } else {
        utility('HTML').addClass('mura-edit-mode');
    }
}

const toggleAdminToolbar=function(){
    let tools=utility("#frontEndTools");

    if(utility('HTML').hasClass('mura-edit-mode')){
        if(typeof tools.fadeOut == 'function'){
            utility("#frontEndTools").fadeOut();
        } else {
            utility("#frontEndTools").hide();
        }

        utility('HTML').removeClass('mura-edit-mode');
        utility(".editableObject").addClass('editableObjectHide');

        if(typeof MuraInlineEditor != 'undefined' && MuraInlineEditor.inited){
            MuraInlineEditor.sidebarAction('minimizesidebar');
            utility(".mura-editable").addClass('mura-inactive');
        }

    } else {
        if(typeof tools.fadeOut == 'function'){
            utility("#frontEndTools").fadeIn().css('display','flex');
        } else {
            utility("#frontEndTools").show().css('display','flex');
        }

        utility('HTML').addClass('mura-edit-mode');
        utility(".editableObject").removeClass('editableObjectHide');

        if(typeof MuraInlineEditor != 'undefined' && MuraInlineEditor.inited){
            MuraInlineEditor.sidebarAction('restoresidebar');
            utility(".mura-editable").removeClass('mura-inactive');
        }
    }

}

const resizeEditableObject=function(target){

    let display="inline";
    let width=0;
    let float;

    utility(target).find(".editableObjectContents").each(
        function(){
            utility(this).find(".frontEndToolsModal").each(
                function(){
                    utility(this).click(function(event){
                        event.preventDefault();
                        openFrontEndToolsModal(this);
                    }
                );
            });

            utility(this).children().each(
                function(el){
                    if (utility(this).css("display") == "block") {
                        display = "block";
                        float=utility(this).css("float");
                        width=utility(this).outerWidth();
                    }
                }
            );

            utility(this).css("display",display).parent().css("display",display);

            if(width){
                utility(this).width(width).parent().width(width);
                utility(this).css("float",float).parent().css("float",float);
            }

    });

    if(utility('HTML').hasClass('mura-edit-mode')){
        utility(target).removeClass('editableObjectHide');
    } else {
        utility(target).addClass('editableObjectHide');
    }

}

const initToolbar=function(){

    checkToolbarDisplay();

    utility(".frontEndToolsModal").each(
        function(){

            let _initToolbar=function(event){
                event.preventDefault();
                openFrontEndToolsModal(this);
            };

            utility(this).off('click',initToolbar).on('click',_initToolbar);
    });

    utility(".editableObject").each(function(){
        resizeEditableObject(this);
    });

    if(typeof modalProxy == 'undefined'){
        initModalProxy();
    }

    if(typeof sidebarProxy == 'undefined'){
        initSidebarProxy();
    }
    

    if(frontEndModalIE8){
        utility("#adminQuickEdit").remove();
    }
};

initToolbar();

//This is only until we remove bs dropdowns from mura-toolbar
if(typeof $ !='undefined'){
    $(function(){
        $("#frontEndTools .dropdown").hover(function(){
            $(this).toggleClass("show");
        });
    })
}
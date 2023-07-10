function domHistory(){
    this.history=[];
    this.undone=[];
    this.hasShallowEdits=false;
    this.selector='body';

    this.hydrate=function(){
        Mura('.mura-object').calculateDisplayObjectStyles();
        MuraInlineEditor.init(true); 
        MuraInlineEditor.sidebarAction('showobjects'); 
        removeDropTargetClasses(Mura('.mura-drop-target'));
        Mura('.mura-object-selected').removeClass('mura-object-selected');
        Mura('.mura-region, .mura-region .mura-editable').removeClass('mura-region-active');
        Mura('.mura-region div[data-object="container"], .mura-region .mura-editable div[data-object="container"], div.mura-object[data-object="container"][data-targetattr]').removeClass('mura-container-active');
    }

    this.undo=function(){ 
        if(this.history.length > 1){
            this.undone.push(document.querySelector(this.selector).cloneNode(true))
            if(!this.hasShallowEdits){
                this.history.pop(); //peel off the current state
            }
            this.hasShallowEdits=false;
            document.querySelector(this.selector).replaceWith(this.history[this.history.length-1].cloneNode(true));
            this.hydrate();
        }
       
        if(!this.history.length){
            this.record();
        }

        return this;
    }

    this.redo=function(){ 
        if(this.undone.length){
            this.history.push(this.undone[this.undone.length-1].cloneNode(true));
            this.undone.pop();
            document.querySelector(this.selector).replaceWith(this.history[this.history.length-1].cloneNode(true));
            this.hydrate();
        }
        return this;
    }


    this.record=function(){
        this.history.push(document.querySelector(this.selector).cloneNode(true));
        if(this.history.length > 10){
            this.history.shift();
        }
        this.undone=[];
        return this;
    }

    this.reset=function(){
        this.history=[];
        return this;
    }

    this.length=function(){
        return this.history.length-1;
    }

    return this;
}

var sortable,
    slice = function(arr, start, end) {
        return Array.prototype.slice.call(arr, start, end)
    },
    dragE;

var elemsWithBoundingRects = [];

var distanceFudge=10;

if(Mura.type=='Variation'){
    var looseDropTargets= '.mxp-editable.mura-region-local .mura-object[data-object="container"], .mxp-editable.mura-region-local div, .mxp-editable.mura-region-local[data-loose="true"] p, .mxp-editable.mura-region-local[data-loose="true"] h1, .mxp-editable.mura-region-local[data-loose="true"] h2, .mxp-editable.mura-region-local[data-loose="true"] h3, .mxp-editable.mura-region-local[data-loose="true"] h4, .mxp-editable.mura-region-local[data-loose="true"] img, .mxp-editable.mura-region-local[data-loose="true"] table, .mxp-editable.mura-region-local[data-loose="true"] article, .mxp-editable.mura-region-local[data-loose="true"] dl, .mxp-editable.mura-region-local[data-loose="true"] main, .mxp-editable.mura-region-local[data-loose="true"] aside, .mxp-editable.mura-region-local[data-loose="true"] footer, .mxp-editable.mura-region-local[data-loose="true"] nav, .mxp-editable.mura-region-local[data-loose="true"] header';
    //var looseDropTargets= 'div,p,h1,h2,h3,h4,img,table,ul,ol,article,dl,main,aside,footer,nav,header';
} else {
    var looseDropTargets= 'div.mura-object[data-object="container"][data-targetattr], .mura-region-local .mura-object[data-object="container"], .mura-region-local div, .mura-region-local[data-loose="true"] p, .mura-region-local[data-loose="true"] h1, .mura-region-local[data-loose="true"] h2, .mura-region-local[data-loose="true"] h3, .mura-region-local[data-loose="true"] h4, .mura-region-local[data-loose="true"] img, .mura-region-local[data-loose="true"] table, .mura-region-local[data-loose="true"] article, .mura-region-local[data-loose="true"] dl, .mura-region-local[data-loose="true"] main, .mura-region-local[data-loose="true"] aside, .mura-region-local[data-loose="true"] footer, .mura-region-local[data-loose="true"] nav, .mura-region-local[data-loose="true"] header';
}

function getClientRect( element ) {

    // Check if we already got the client rect before.
    if ( ! element._boundingClientRect ) {

        // If not, get it then store it for future use.
        element._boundingClientRect = element.getBoundingClientRect();
        elemsWithBoundingRects.push( element );
    }
    return element._boundingClientRect;
}

function clearClientRects() {
	var i;
	for ( i = 0; i < elemsWithBoundingRects.length; i++ ) {
		if ( elemsWithBoundingRects[ i ] ) {
			elemsWithBoundingRects[ i ]._boundingClientRect = null;
		}
	}
	elemsWithBoundingRects = [];
}

function disabledEventPropagation(event) {
    if (event.stopPropagation) {
        event.stopPropagation();
    } else if (window.event) {
        window.event.cancelBubble = true;
    }
}

function initDraggableObject_dragstart(e) {
    //FireFox insists that the dataTranfer has been set
    clearClientRects();
    e.dataTransfer.setData('Text', '');
    e.dataTransfer.dropEffect = 'copy';
    dragEl = this;
    elDropHandled = false;
    newMuraObject = false;
    muraLooseDropTarget = null;
    MuraInlineEditor.sidebarAction('showobjects');
    Mura('.mura-object-selected').removeClass('mura-object-selected');
    Mura('.mura-region, .mura-region .mura-editable').addClass('mura-region-active');
    Mura('.mura-region div[data-object="container"], .mura-region .mura-editable div[data-object="container"], div.mura-object[data-object="container"][data-targetattr]').addClass('mura-container-active');
    Mura(this).addClass('mura-object-selected');
}

function initDraggableObject_dragend() {
    dragEl = null;
    elDropHandled = false;
    newMuraObject = false;
    Mura('.mura-object-selected').removeClass('mura-object-selected');
    Mura('.mura-region, .mura-region .mura-editable').removeClass('mura-region-active');
    Mura('.mura-region div[data-object="container"], .mura-region .mura-editable div[data-object="container"], div.mura-object[data-object="container"][data-targetattr]').removeClass('mura-container-active');
}

function initDraggableObject_dragover(e) {
    e.preventDefault();
    
    e.dataTransfer.dropEffect = 'copy';
    if (dragEl && dragEl != this && !dragEl.contains(this) || newMuraObject) {
        muraLooseDropTarget = this;
        applyDropTargetClasses(e,this);
    }
}

function removeDropTargetClasses(prev){

    if(prev.length){
        prev.removeClass('mura-drop-target')
            .removeClass('mura-append')
            .removeClass('mura-prepend')
            .removeClass('mura-drop-target-left')
            .removeClass('mura-drop-target-right')
            .removeClass('mura-drop-target-top')
            .removeClass('mura-drop-target-bottom');

        if (!prev.attr('class')) {
            prev.removeAttr('class');
        }
    }
}


function getDropTargeting(e,el){
    var data={
        direction:'append',
        class:'bottom'
    }

    var targetRect = getClientRect(el);
    var elemTop = targetRect.top;
    var elemBottom = targetRect.bottom;
    var divide = ((elemBottom - elemTop) / 2) + elemTop;
    var targetClass = el.className;
    var startDir = 'append';
    if (targetClass.indexOf('mura-prepend')){
        startDir = 'prepend';
    }

    if (elemBottom <= elemTop + 15 ){
        if(startDir=='append'){
            data.direction='append';
            data.class='bottom';
        } else {
            data.direction='prepend';
            data.class='top';
        }
    } else if (e.clientY <= divide) {
        data.direction='prepend';
        data.class='top';
    } else {
        data.direction='append';
        data.class='bottom';
    }

    var elemLeft = targetRect.x;
    var elemRight = elemLeft + targetRect.width;
    var divide = ((elemRight - elemLeft) / 2) + elemLeft;

    if (e.clientX <= divide) {
        if(e.clientX <= ((divide - elemLeft) / 2) + elemLeft){
            data.class='left';
            data.direction='prepend';
        }
    } else if(e.clientX > ((elemRight-divide) / 2) + divide){
        data.class='right';
        data.direction='append';
    }        

    return data;
}

function applyDropTargetClasses(e,el){
    var target= Mura(el);

    if(!(target.is('.mura-object') || target.closest('.mura-object').length)){
        var dropTargeting={
            direction:getDropDirection(e, el),
            class:'bottom'
        }

        if(dropTargeting.direction=='prepend'){
            dropTargeting.class="top";
        }
    } else {
        var dropTargeting=getDropTargeting(e, el)
    }
  
    var distance=getDistanceFromActionBorder(e, el,dropTargeting);
    var target= Mura(el);
    var prev = Mura('.mura-drop-target');
    var distanceFudge=15;

    //console.log('dropTargeting',dropTargeting)

    if (prev.length) {
        if(target.node != prev.node){
            removeDropTargetClasses(prev);
        } else  if (target.node == dragEl){
            removeDropTargetClasses(prev);
            return;
        }
    }
   
    target.addClass('mura-drop-target');

    //console.log(dropTargeting)
    function addTargetClasses(){
        target.addClass('mura-' + dropTargeting.direction);
        target.addClass('mura-drop-target-' + dropTargeting.class);
    }

    if (target.data('object') == 'container' && distance > distanceFudge) {
        var container = target.children('.mura-object-content');
        //console.log('Drop is on container with distance from border greater than fudge: ' + distance, 'Add inside container')
        if (container.length) {
            addTargetClasses()  
        } else {
            return;
        }
    } else {
        if(distance < distanceFudge && !(
            dropTargeting.direction=='prepend' && target.node.previousSibling
            || dropTargeting.direction=='append' && target.node.nextSibling
        )){
            //console.log('Drop is on module with distance from border less than fudge: ' + distance, 'So check that module is not inside container');

            var parentCheck=target.parent().parent().closest('.mura-object[data-object="container"]');
            if(parentCheck.length && getDistanceFromActionBorder(e, parentCheck.node,dropTargeting) < distanceFudge){
                console.log('Drop is within fudge distance from border to parent container so use parent container [1]')
                target=parentCheck;
            } 
        }
        addTargetClasses()
    }

}

function getDropTargetFromClasses(el){
    var targetObj=Mura(el);
    var dropTargeting={
        direction:'append',
        class:'top'
    }
    if(targetObj.is('.mura-prepend')){
        dropTargeting.direction='prepend';
    }
    if(targetObj.is('.mura-drop-target-top')){
        dropTargeting.class='top';
    } else if (targetObj.is('.mura-drop-target-bottom')){
        dropTargeting.class='bottom';
    } else if (targetObj.is('.mura-drop-target-left')){
        dropTargeting.class='left';
    } else if (targetObj.is('.mura-drop-target-right')){
        dropTargeting.class='right';
    }

    return dropTargeting;
}

function initDraggableObject_dragleave(e) {    
    removeDropTargetClasses(Mura(this));
    muraLooseDropTarget = null;
}

function getDistanceFromActionBorder(e, target, dropTargeting) {
    var targetRect = getClientRect(target);
    let distance = 0;
    if(dropTargeting.class=='top'){
        distance = e.clientY-targetRect.top;
    } else if(dropTargeting.class=='right'){
        distance = e.clientX-targetRect.right;
    } else  if(dropTargeting.class=='left'){
        distance=targetRect.left-e.clientX;
    } else {
        distance = targetRect.bottom-e.clientY;
    }
    //console.log('distance',distance)
    return distance;
}

function getDropDirection(e, target) {
    var targetRect = getClientRect(target);
    var elemTop = targetRect.top;
    var elemBottom = targetRect.bottom;
    var divide = ((elemBottom - elemTop) / 2) + elemTop;
    var targetClass = target.className;
    var startDir = 'append';
    if (targetClass.indexOf('mura-prepend')){
        startDir = 'prepend';
    }

    if (elemBottom <= elemTop + 15 ){
        return startDir;
    } else if (e.clientY <= divide) {
        return 'prepend';
    } else {
        return 'append';
    }
}


function initDraggableObject_drag(e){
   
    if(typeof e.clientY != 'undefined'){
       
        if (e.clientY < 200 && e.clientY > 1) {
            scroll(-1.0)  
        }

        if (e.clientY > (Mura(window).height() - 200)) {
            scroll(1.0)
        }
    }
  
}

function initDraggableObject_drop(e) {

    var target = Mura('.mura-drop-target').node;

    if (target) {
        if (dragEl || newMuraObject) {
            if (dragEl && dragEl != this) {
                var dropTargeting=getDropTargetFromClasses(target);

                var distance=getDistanceFromActionBorder(e, target,dropTargeting);

                if (target.getAttribute('data-object') == 'container' && distance > distanceFudge) {
                    var container = Mura(target).children('.mura-object-content');
                    container.children('p').remove();
                    console.log('Drop is on container with distance from border greater than fudge: ' + distance, 'Add inside container')
                    if (container.length) {
                       
                        if (!container.node.childNodes.length) {
                            console.log('Container has NO length default append')
                            container.append(dragEl);
                        } else {
                            console.log('Container has length ' + dropTargeting.direction)
                            container[dropTargeting.direction](dragEl);
                        }
                    } else {
                        return;
                    }
                } else {
                    if(distance < distanceFudge && !(
                        dropTargeting.direction=='prepend' && target.previousSibling
                        || dropTargeting.direction=='append' && target.nextSibling
                    )){
                        console.log('Drop is on module with distance from border less than fudge: ' + distance, 'So check that module is not inside container');

                        var parentCheck=Mura(target).parent().parent().closest('.mura-object[data-object="container"]');
                        if(parentCheck.length && getDistanceFromActionBorder(e, parentCheck.node,dropTargeting) < distanceFudge){
                            console.log('Drop is within fudge distance from border to parent container so use parent container [2]')
                            target=parentCheck.node;
                        } 
                    }
                    if (dropTargeting.direction == 'append') {
                        console.log('Droping ' + dropTargeting.direction);
                        if(target.nextSibling){
                            target.parentNode.insertBefore(dragEl, target.nextSibling);
                        } else {
                            target.parentNode.appendChild(dragEl);
                        }
                    } else {
                        console.log('Droping ' + dropTargeting.direction);
                        target.parentNode.insertBefore(dragEl, target);
                    }
                }
               
                //dragEl.setAttribute('data-droptarget',Mura(this).getSelector());
                Mura('#adminSave').show();
                Mura(target).closest('.mura-region-local').data('dirty', true);
                elDropHandled = true;
                disabledEventPropagation(e);
            } else if (dragEl == target) {
                var dropTargeting=getDropTargetFromClasses(target);
                var distance=getDistanceFromActionBorder(e, target,dropTargeting);

                console.log('Drop is on self');

                if(distance < distanceFudge && !(
                    dropTargeting.direction=='prepend' && target.previousSibling
                    || dropTargeting.direction=='append' && target.nextSibling
                )){

                    console.log('Drop is less than fudge distance from border, so check if in container');
                    var parentCheck=Mura(target).parent().parent().closest('.mura-object[data-object="container"]');
                    if(parentCheck.length && getDistanceFromActionBorder(e, parentCheck.node,dropTargeting) < distanceFudge){
                        console.log('Drop is on module in container so move to container');
                        target=parentCheck.node;
                        if (dropTargeting.direction == 'append') {
                            console.log('Droping ' + dropTargeting.direction);
                            if(target.nextSibling){
                                target.parentNode.insertBefore(dragEl, target.nextSibling);
                            } else {
                                target.parentNode.appendChild(dragEl);
                            }
                        } else {
                            console.log('Droping ' + dropTargeting.direction);
                            target.parentNode.insertBefore(dragEl, target);
                        }
                    }
                }

                elDropHandled = true;
                disabledEventPropagation(e);
            } else {
                checkForNew.call(target, e);
            }
        }

        clearClientRects();
        Mura.editHistory.record();
    }


    removeDropTargetClasses(Mura(target));

    muraLooseDropTarget = null;
    newMuraObject = false;

}

function  initDraggableObject_hoverin(e){
    //e.stopPropagation();
    var self = Mura(this);

    if(!self.find('.mura-active-target').length){
        Mura('.mura-active-target').removeClass('mura-active-target');

    
        if (!self.hasClass('mura-object-selected')) {
            Mura(this).addClass('mura-active-target');
        }

    }
     
    if(self.data('object')=='container'){
        self.addClass('mura-container-active');
    } else {
        var container=self.closest('div[data-object="container"]');
        if(container.length){
            container.addClass('mura-container-active');
        }
    }

}

function initDraggableObject_hoverout(e){
    //e.stopPropagation();
    var item=Mura(this);
    item.removeClass('mura-active-target');

    var removeContainerClass=true;

    if(typeof Mura.currentObjectInstanceID != 'undefined'
        && Mura.currentObjectInstanceID){

        if(item.data('object')=='container' && Mura.currentObjectInstanceID == item.data('instanceid')){
            removeContainerClass=false;
        } else{
            var container=item.closest('div[data-object="container"]');

            if(container.length){
                var finder=container.find('div[data-instanceid="' + Mura.currentObjectInstanceID + '"]')
                if(finder.length){
                    removeContainerClass=false;
                }
            }
        }

    }
    if(removeContainerClass){
        item.removeClass('mura-container-active')
    }


    //.calculateDisplayObjectStyles();

}

function initDraggableObject(item) {
    var obj=Mura(item);

    if(!obj.data('pinned')){
        var parentObj = obj.parent().closest('.mura-object[data-object]');
    
        if(!parentObj.length || parentObj.length && (parentObj.data('object')=='container' || parentObj.data('object').toLowerCase()=='gatedasset')){
            if(obj.data('object')=='container'){
                var EventListenerOptions=true;
            } else {
                var EventListenerOptions;
            }

            obj
                .show()
                .off('dragover', initDraggableObject_dragover)
                .off('drag', initDraggableObject_drag)
                .off('dragstart',  initDraggableObject_dragstart)
                .off('drop', initDraggableObject_drop)
                .off('dragleave', initDraggableObject_dragleave)
                .off('dragend',  initDraggableObject_dragend)
                .on('drag',  initDraggableObject_drag)
                .on('dragstart', initDraggableObject_dragstart)
                .on('dragend',  initDraggableObject_dragend)
                .on('dragover', initDraggableObject_dragover)
                .on('dragleave',  initDraggableObject_dragleave)
                .on('drop',  initDraggableObject_drop).attr('draggable',true)
                .hover(
                    initDraggableObject_hoverin,
                    initDraggableObject_hoverout,
                    EventListenerOptions
                );
        }
    } else {
        initPinnedObject(item);
    }
}

function initPinnedObject(item) {
    var obj=Mura(item);
    var parentObj = obj.parent().closest('.mura-object[data-object]');
    
    if(!parentObj.length || parentObj.length && (parentObj.data('object')=='container' || parentObj.data('object').toLowerCase()=='gatedasset')){
        if(obj.data('object')=='container' && obj.data('object').toLowerCase()=='gatedasset'){
            var EventListenerOptions=true;
        } else {
            var EventListenerOptions;
        }

        //Only top level pinned containers and gatedassets can be drop targets
        if(!(!parentObj.length && (
            obj.data('object') == 'container' 
            || obj.data('object').toLowerCase()=='gatedasset'
            )
        )){
            obj
            .show()
            .hover(
                initDraggableObject_hoverin,
                initDraggableObject_hoverout,
                EventListenerOptions
            );
        } else {
            obj
            .show()
            .off('dragover', initDraggableObject_dragover)
            .off('drop', initDraggableObject_drop)
            .off('dragleave', initDraggableObject_dragleave)
            .off('dragend',  initDraggableObject_dragend)
            .on('dragend',  initDraggableObject_dragend)
            .on('dragover', initDraggableObject_dragover)
            .on('dragleave',  initDraggableObject_dragleave)
            .hover(
                initDraggableObject_hoverin,
                initDraggableObject_hoverout,
                EventListenerOptions
            );
        }
    }
}

function applyObjectTargetClass(item, e, self) {
    if (item.closest('.mura-region, div.mura-object[data-object="container"][data-targetattr]').length) {
        var parentObj = item.parent().closest('.mura-object[data-object]');

        while (parentObj.length && parentObj.data('object') != 'container') {
            item = parentObj;
            parentObj = parentObj.parent().closest('.mura-object[data-object]');
        }

        if (item.length) {
            applyDropTargetClasses(e,item.node);
        }
    }
}

function initLooseDropTarget_dragenter(e) {
    e.preventDefault();
    //disabledEventPropagation(e)
    e.dataTransfer.dropEffect = 'copy';

    if (!Mura('.mura-drop-target').length && (dragEl && dragEl != this && !dragEl.contains(this) || newMuraObject)) {

        var item = Mura(this).closest('.mura-object[data-object]');

        if (item.length) {
            applyObjectTargetClass(item, e, this);
        } else {
            applyDropTargetClasses(e, this);
        }

    }


}

function initLooseDropTarget_dragover(e) {

    e.preventDefault();
    
    if (dragEl && dragEl!=this && !dragEl.contains(this)|| newMuraObject) {

        var prev = Mura('.mura-drop-target');
        muraLooseDropTarget = this;

        //Mura('.mura-container-active').removeClass('mura-container-active');

        if (prev.length) {
            removeDropTargetClasses(prev);
        }

        var item = Mura(this).closest('.mura-object[data-object]');

        if (item.length && !(dragEl && dragEl==item.node)) {
            applyObjectTargetClass(item, e, item.node);
        } else {
            applyDropTargetClasses(e, this);
        }

    }
};

function initLooseDropTarget_dragleave(e) {
    removeDropTargetClasses(Mura(this));

    //Mura('.mura-container-active').removeClass('mura-container-active');

    muraLooseDropTarget = null;
  
}

function initLooseDropTarget_drop(e) {
    disabledEventPropagation(e);

    //Mura('.mura-container-active').removeClass('mura-container-active');

    if (dragEl || newMuraObject) {

        var target = Mura('.mura-drop-target').node;

        if (target) {

            if (dragEl && dragEl != target) {
                var dropTargeting=getDropTargetFromClasses(target);
                
               
                if (target.getAttribute('data-object') == 'container') {
                    var container = Mura(target).children('.mura-object-content');
                    container.children('p').remove();
                    if (!container.node.childNodes.length) {
                        container.append(dragEl);
                    } else {
                        container[dropTargeting.direction](dragEl);
                    }
                } else {
                    try {
                        if (dropTargeting.direction == 'append') {
                            if(target.nextSibling){
                                target.parentNode.insertBefore(dragEl, target.nextSibling);
                            } else {
                                target.parentNode.appendChild(dragEl);
                            }
                            
                        } else {
                            target.parentNode.insertBefore(dragEl, target);
                        }
                    } catch (e) {};
                }

                var mDragEl = Mura(dragEl);
                Mura('#adminSave').show();
                mDragEl.addClass('mura-async-object');

                if (!(mDragEl.data('object') == 'text' && mDragEl.data('render') ==
                        'client' && mDragEl.data('async') == 'false')) {
                    mDragEl.data('async', true);
                }

                var closestRegion=Mura(target).closest('.mura-region-local');
                if(closestRegion.length){
                    closestRegion.data('dirty', true);
                }

                if(Mura(target).hasClass('mura-object')){
                    initDraggableObject(target);
                } else {
                    initLooseDropTarget(this)
                }
                elDropHandled = true;
                disabledEventPropagation(e);

            } else if (dragEl == target) {
                elDropHandled = true;
                disabledEventPropagation(e);
            }

            checkForNew.call(target, e);
            Mura.editHistory.record();
        }

    }

    removeDropTargetClasses(Mura('.mura-drop-target'));

    muraLooseDropTarget = null;
    newMuraObject = false;

    if (!Mura(this).attr('class')) {
        Mura(this).removeAttr('class');
    }
}

function initLooseDropTarget(item) {
    Mura(item)
        .off('dragenter',initLooseDropTarget_dragenter)
        .off('dragover', initLooseDropTarget_dragover)
        .off('drop', initLooseDropTarget_drop)
        .off('dragleave', initLooseDropTarget_dragleave)
        .on('dragenter', initLooseDropTarget_dragenter)
        .on('dragover', initLooseDropTarget_dragover)
        .on('dragleave', initLooseDropTarget_dragleave)
        .on('drop', initLooseDropTarget_drop);
}

function initClassObjects() {
    Mura(".mura-objectclass").each(function() {
        var item = Mura(this);

        if (!item.data('inited')) {
            item.attr('draggable', true);

            item.on('dragstart', function(e) {
                    dragEl = null;
                    elDropHandled = false;
                    newMuraObject = true;
                    muraLooseDropTarget = null;
                    Mura('#dragtype').html(item.data('object'));
                    Mura('.mura-sidebar').addClass('mura-sidebar--dragging');
                    Mura('.mura-region, .mura-region .mura-editable').addClass('mura-region-active');
                    Mura('div.mura-object[data-object="container"][data-targetattr], div.mura-object[data-object="container"][data-targetattr] div.mura-object[data-object="container"], .mura-region div[data-object="container"], .mura-region .mura-editable div[data-object="container"]').addClass('mura-container-active');

                    e.dataTransfer.setData("text", JSON.stringify({
                        object: item.data('object'),
                        objectname: item.data('objectname'),
                        objectid: item.data('objectid'),
                        objecticonclass: item.data('objecticonclass'),
                        params: item.data('params')
                    }));
                })
                .on('dragend', function() {
                    Mura('#dragtype').html('');
                    dragEl = null;
                    elDropHandled = false;
                    newMuraObject = false;
                    Mura('.mura-sidebar').removeClass('mura-sidebar--dragging');
                    Mura('.mura-region, .mura-region .mura-editable').removeClass('mura-region-active');
                    Mura('div.mura-object[data-object="container"][data-targetattr], div.mura-object[data-object="container"][data-targetattr] div.mura-object[data-object="container"], .mura-region div[data-object="container"], .mura-region .mura-editable div[data-object="container"]').removeClass('mura-container-active');

                    if(typeof Mura.currentObjectInstanceID != 'undefined' && Mura.currentObjectInstanceID){
                        var current=Mura('div[data-instanceid="' +  Mura.currentObjectInstanceID + '"]');
                        if(current.data('object')=='container'){
                            current.addClass('mura-container-active');
                        }
                        container=current.closest('div[data-object="container"]');
                        if(container.length){
                            var finder=container.find('div[data-instanceid="' + Mura.currentObjectInstanceID + '"]')
                            if(finder.length){
                                container.addClass('mura-container-active');
                            }
                        }
                    }
                })
                .on('drag',initDraggableObject_drag);

            item.data('inited', true);
        }

    });
}

function checkForNew(e) {
    e.preventDefault();

    if (e.stopPropagation) {
        e.stopPropagation();
    }

    var object = e.dataTransfer.getData("text");
    
    if (object != '') {
        try {
            object = JSON.parse(object);
        } catch (e) {
            object = '';
        }
    }

    if (typeof object == 'object' && object.object) {

        var displayObject = document.createElement("DIV");
        var isTemplate = false;
        var instanceid = Mura.createUUID();
        displayObject.setAttribute('data-object', object.object);
        displayObject.setAttribute('data-objectname', object.objectname);
        displayObject.setAttribute('data-objecticonclass', object.objecticonclass);
        displayObject.setAttribute('data-async', true);
        displayObject.setAttribute('data-perm', 'author');
        displayObject.setAttribute('data-instanceid', instanceid);
        displayObject.setAttribute('data-queue', Mura.queueObjects);
        displayObject.setAttribute('class','mura-async-object mura-object mura-active');
        
        if(Mura.type == 'Variation'){
            displayObject.setAttribute('data-mxpeditable',true);
        }

        if (object.objectid) {
            displayObject.setAttribute('data-objectid', object.objectid);
        } else {
            displayObject.setAttribute('data-objectid', Mura.createUUID());
        }

        if(object.params && object.params.objectid) {
            isTemplate = true;
            for(var item in object.params) {
                if(item != 'inited' && item != 'instanceid'){
                    if(typeof object.params[item] == 'object') {
                        displayObject.setAttribute('data-'+ item, JSON.stringify(object.params[item]));//.replace('88888888-8888-8888-8888888888888888',Mura.createUUID()));
                    }  else {
                        displayObject.setAttribute('data-' + item, object.params[item]);
                    }
                }
            }
        }

        var target = Mura(this);

        var dropTargeting=getDropTargetFromClasses(this);
        console.log('dropTargeting',dropTargeting);
        if (target.hasClass('mura-object')) {
            var distance=getDistanceFromActionBorder(e, target.node,dropTargeting);

            if (target.data('object') == 'container' && distance > distanceFudge) {
                var container = target.children('.mura-object-content');
                container.children('p').remove();
                if (!container.node.childNodes.length) {
                    container.append(displayObject);
                } else {
                    container[dropTargeting.direction](displayObject);
                }
            } else {
                if(distance < distanceFudge && !(
                    dropTargeting.direction=='prepend' && target.node.previousSibling
                    || dropTargeting.direction=='append' && target.node.nextSibling
                )){
                    var parentCheck=target.parent().parent().closest('.mura-object[data-object="container"]');
                    if(parentCheck.length && getDistanceFromActionBorder(e, parentCheck.node,dropTargeting) < distanceFudge){
                        console.log('Drop is within fudge distance from border to parent container so use parent container [3]')
                        target=parentCheck;
                    }
                }
                if (dropTargeting.direction == 'append') {
                    if(target.node.nextSibling){
                        target.node.parentNode.insertBefore(displayObject, target.node.nextSibling);
                    } else {
                        target.node.parentNode.appendChild(displayObject);
                    }  
                } else {
                    target.node.parentNode.insertBefore(displayObject,  this);
                }
            }
        } else if (target.hasClass('mura-region-local')) {
            this.appendChild(displayObject);
        } else {
            if (dropTargeting.direction == 'append') {
                if(this.nextSibling){
                    this.parentNode.insertBefore(displayObject,  this.nextSibling);
                } else {
                    this.parentNode.appendChild(displayObject);
                }  
            } else {
                this.parentNode.insertBefore(displayObject, this);
            }
        }

        if(isTemplate){
            Mura.cloning=true;
  
            if(displayObject.getAttribute('data-object') != 'form' && displayObject.getAttribute('data-object') != 'component'){
                displayObject.setAttribute('data-objectid',Mura.createUUID());
            }
        }
        
        Mura.processAsyncObject(displayObject).then(function(){
            if(isTemplate){
                Mura.cloning=false;
                //This is only really needed in some decoupled instances
                Mura(displayObject).find('.mura-object').calculateDisplayObjectStyles(false);
            }
            initDraggableObject(displayObject);

            displayObject=Mura(displayObject);
            openFrontEndToolsModal(displayObject.node, true);
    
            displayObject.on('click',Mura.handleObjectClick);
            var closestRegion=displayObject.closest('.mura-region-local');
            if(closestRegion.length){
                closestRegion.data('dirty', true);
            }
            displayObject.on('dragover', function() {})
            //Mura('#adminSave').show();
            disabledEventPropagation(e);
            Mura.editHistory.record();
        });
    }

}

function loadObjectClass(siteid, classid, subclassid, contentid, parentid,
    contenthistid) {
    var pars =
        'muraAction=cArch.loadclass&compactDisplay=true&layoutmanager=true&siteid=' +
        siteid + '&classid=' + classid + '&subclassid=' + subclassid +
        '&contentid=' + contentid + '&parentid=' + parentid + '&cacheid=' + Math.random();

    if (classid == 'plugins') {
        var d = Mura('#pluginList');
    } else {
        var d = Mura('#classList');

        Mura('#classListContainer').show();
    }

    d.html(Mura.preloaderMarkup);

    Mura.ajax({
        url: Mura.adminpath + "?" + pars,
        success(data) {
            d.html(data);
            initClassObjects();
        }
    });

    return false;
}

function initLayoutManager(el,undoing) {
    if(typeof undoing == 'undefined'){
        undoing=false;
    }
    if (el) {
        var obj = (el.node) ? el : Mura(el);
        el = el.node || el;
    } else {
        var obj = Mura('body');
        el = obj.node;
        
        if(undoing){
            Mura(".mura-objectclass").data('inited',false);
        }
        initClassObjects();

        Mura('body')
            .removeClass('mura-sidebar-state__hidden--right')
            .removeClass('mura-editing')
            .addClass('mura-sidebar-state__pushed--right')
            .addClass('mura-editing');
    }
    
    Mura.editing=true;
   
    Mura(window).trigger("resize");
    
    var iframe = Mura('#frontEndToolsSidebariframe');

    iframe.attr('src',iframe.data('preloadsrc'));
   
    obj.find('.mxp-editable').each(function() {
        var item = Mura(this);

        if (!item.hasClass('mura-region-local')) {
            item.addClass('mura-region-local');
            item.addClass('mura-region');
            item.data('inited', false);
            item.data('loose', true);
            item.data('perm', 'editor');
        }
    });
    
    if(Mura.type=='Variation'){
        var regionSelector='.mura-region-local.mxp-editable';
    } else {
        var regionSelector='.mura-region-local';
    }

	Mura('label.mura-editable-label').show()
	
    obj.find(regionSelector + '[data-inited="false"]').each(function() {

        var region = Mura(this);

        if (!region.data('loose') || (region.data('loose') && (region.html() ==
                '<p></p>') || Mura.trim(region.html()) == '')) {
            region
                .on('drop', initRegion_drop)
                .on('dragover', initRegion_dragover)
                .data('inited', 'true');

        }
    });
  
    obj.find(regionSelector + ' .mura-object[data-object]').each(function() {
        initDraggableObject(this,true)
    });

    obj.find(looseDropTargets).each(function() {
        initLooseDropTarget(this)
    });
    
  
    obj.find('div.mura-object[data-object][data-targetattr], div.mura-object[data-pinned="true"]').each(function(){
        initPinnedObject(this);
    });

    if(!undoing){
        console.log('init edit history')
        Mura.editHistory.reset().record();
    }
}

function initRegion_dragover(e){
    e.preventDefault();
    e.dataTransfer.dropEffect = 'copy';
}

function initRegion_drop(e){
    var dropParent, dropIndex, dragIndex;

    e.preventDefault();

    if (Mura(this).find('.mura-object[data-object]').length) {
        return;
    }

    if (e.stopPropagation) {
        e.stopPropagation();
    }

    if (dragEl && dragEl !== this) {
        dropParent = this.parentNode;
        dragIndex = slice(dragEl.parentNode.children).indexOf(dragEl);
        dropIndex = slice(this.parentNode.children).indexOf(this);
        if (this.parentNode === dragEl.parentNode && dropIndex >
            dragIndex) {
            dropParent.insertBefore(dragEl, this.nextSibling);
        } else {
            this.appendChild(dragEl);
        }

        Mura('#adminSave').show();
        Mura(dragEl).data('async', true);
        Mura(dragEl).addClass('mura-async-object');
        Mura(this).data('dirty', true);
        elDropHandled = true;
        disabledEventPropagation(e);
    } else if (dragEl == this) {
        elDropHandled = true;
        disabledEventPropagation(e);
    }

    checkForNew.call(this, e);

    muraLooseDropTarget = null;
    Mura('.mura-drop-target')
        .removeClass('mura-drop-target')
        .removeClass('mura-append')
        .removeClass('mura-prepend');

    clearClientRects();

    Mura.editHistory.record();
    
    return true;
}

function deInitLayoutManager(){
    Mura.editing=false;
    Mura.editHistory.reset();
    Mura('body').removeClass('mura-editing')
    Mura('body').removeClass('mura-sidebar-state__pushed--right');


    Mura('div.mura-object[data-object="container"][data-targetattr], .mura-region-local .mura-object[data-object]').each(function(){
        
        Mura(this)
            .off('drag', initDraggableObject_drag)
            .off('dragenter', initDraggableObject_dragstart)
            .off('dragover', initDraggableObject_dragover)
            .off('drop', initDraggableObject_drop)
            .off('dragleave', initDraggableObject_dragleave)
            .off('dragstart', initDraggableObject_dragstart)
            .off('dragend', initDraggableObject_dragend)
            .off('mouseover', initDraggableObject_hoverin)
            .off('mouseout', initDraggableObject_hoverout)
            .off('touchstart', initDraggableObject_hoverin)
            .off('touchend', initDraggableObject_hoverout)
            .attr('draggable', false)
            .removeClass('mura-active')
            .removeClass('mura-object-selected')
            .removeClass('mura-object-select')
            .removeClass('mura-active-target')	
    })


    Mura('.mura-region-local')
    .off('drop',initRegion_drop)
    .off('dragover',initRegion_dragover)
    .data('inited', 'false')

    Mura('div.mura-object[data-object="container"][data-targetattr], .mura-region-local .mura-object[data-object="container"], .mura-region-local div, .mura-region-local[data-loose="true"] p, .mura-region-local[data-loose="true"] h1, .mura-region-local[data-loose="true"] h2, .mura-region-local[data-loose="true"] h3, .mura-region-local[data-loose="true"] h4, .mura-region-local[data-loose="true"] img, .mura-region-local[data-loose="true"] table, .mura-region-local[data-loose="true"] article, .mura-region-local[data-loose="true"] dl')
    .off('dragenter', initLooseDropTarget_dragenter)
    .off('dragover', initLooseDropTarget_dragover)
    .off('drop', initLooseDropTarget_drop)
    .off('dragleave', initLooseDropTarget_dragleave);

    Mura('.mura-editable-attribute')
        .each(function(){
        var attribute=Mura(this);

        if(typeof CKEDITOR != 'undefined' && CKEDITOR.instances[attribute.attr('id')]){
            var instance =CKEDITOR.instances[attribute.attr('id')];
            instance.updateElement();
            instance.destroy(true)
        }

        attribute.attr('contenteditable','false');
        attribute.removeClass('mura-active');
        attribute.data('manualedit',false);
        attribute.off('dblclick')
    })
}

function scroll(step) {
    var scrollY = Mura(window).scrollTop();
    window.scrollTo({ top: scrollY + step}); 
    clearClientRects(); 
}

window.addEventListener('scroll', function(e) {
    clearClientRects(); 
});

Mura.initLayoutManager = initLayoutManager;
Mura.deInitLayoutManager = deInitLayoutManager;
Mura.loadObjectClass = loadObjectClass;
Mura.initLooseDropTarget = initLooseDropTarget;
Mura.initDraggableObject = initDraggableObject;
Mura.initPinnedObject = initPinnedObject;
Mura.initDraggableObject_hoverin=initDraggableObject_hoverin;
Mura.initDraggableObject_hoverout=initDraggableObject_hoverout;
Mura.initClassObjects=initClassObjects;
Mura.looseDropTargets=looseDropTargets;
Mura.editHistory=new domHistory();

if(typeof window.Mura.editHistoryListener == 'undefined'){
    window.editHistoryListener=function(event) {
        if(window.Mura.editing){
            if((event.ctrlKey || event.metaKey) && event.shiftKey && event.key === 'z') {
                Mura.editHistory.redo();
            } else if ((event.ctrlKey || event.metaKey) && event.key === 'z') {
                Mura.editHistory.undo();
            }
        }
    }
}

document.removeEventListener('keydown',  window.editHistoryListener);
document.addEventListener('keydown', window.editHistoryListener);


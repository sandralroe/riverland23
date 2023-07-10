require('codemirror/lib/codemirror.css'); // codemirror
require('@toast-ui/editor/dist/toastui-editor.css'); // editor ui
//require('@toast-ui/editor/dist/toastui-editor-contents.css'); // editor content
//require('highlight.js/styles/github.css');

var editor=require('@toast-ui/editor');

getMarkdownEditor=function(config){
    var URL_REGEX = /^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})(\/([^\s]*))?$/;
    var HASH_REGEX = /^(?:\s|^)#[A-Za-z0-9\-\.\_]+(?:\s|$)/
    config.toolbarItems=[
       {
            type: 'button',
            options: {
                name: 'MuraLink',
                className:"tui-link",
                event: 'showMuraLinkPopover',
                tooltip: 'Link'
            }
        },
        {
            type: 'button',
            options: {
                name: 'MuraImage',
                className:"tui-image",
                event: 'showMuraImagePopover',
                tooltip: 'Image'
            }
        },
        {
            type: 'button',
            options: {
                name: 'MuraComponemt',
                className:"tui-more",
                event: 'showMuraComponentPopover',
                tooltip: 'Component'
            }
        },
        'heading',
        'bold',
        'italic',
        'strike',
        'divider',
        'hr',
        'quote',
        'divider',
        'ul',
        'ol',
        'indent',
        'outdent',
        'divider',
        'table',
        'divider',
        'code',
        'codeblock',
        'divider'
    ];
   
    var editorInstance=new editor(config);

    /*
    const defaultRenderer = editorInstance.toMarkOptions.renderer;

    const renderer = defaultRenderer.constructor.factory(defaultRenderer, {
        HR(node) {
            return '---';
        }
    });
    
    Object.assign(editorInstance.toMarkOptions, { renderer });
    */

    // editorInstance.eventManager.listen('convertorAfterHtmlToMarkdownConverted', function(md) {
    //     //return md.replace(/(<([^>]+)>)/ig,'');
    //     return md.replace(/(<([br]+)>)/ig,'\n')
    // });

    //var toolbar = editorInstance.getUI().getToolbar();

     //BEGIN COMPONENT
    var AddComponent=editorInstance.commandManager.addCommand('markdown',{
        name: 'AddComponent',
        exec: function exec(mde, data) {

            var cm = mde.getEditor();
            var doc = cm.getDoc();
        
            var range = mde.getCurrentRange();
        
            var from = {
                line: range.from.line,
                ch: range.from.ch
            };
        
            var to = {
                line: range.to.line,
                ch: range.to.ch
            };
        
            var componentid = data.componentid;
         
        
            Mura.getEntity('content').loadBy('contentid',componentid,{type:"component",fields:"body"})
                .then(function(component){
                    var text=component.get('body');
                    text = editorInstance.importManager.constructor.decodeURIGraceful(text);
                    text = editorInstance.importManager.constructor.escapeMarkdownCharacters(text);
                    doc.replaceRange(text, from, to);
                    cm.focus();
                });
        }
    });
   
    var AddComponent=editorInstance.commandManager.addCommand('wysiwyg',{
        name: 'AddComponent',
        exec: function exec(wwe, data) {
            var sq = wwe.getEditor();
            var componentid = data.componentid;

            Mura.getEntity('content').loadBy('contentid',componentid,{type:"component",fields:"body"})
                .then(function(component){
                    var text=editorInstance.importManager.constructor.decodeURIGraceful(component.get('body'));
                    sq.insertHTML(editorInstance.convertor.toHTML(text));
                    wwe.focus();
                });
        }
    });
   
    editorInstance.addCommand(AddComponent);
   
    editorInstance.eventManager.addEventType('showMuraComponentPopover');

    var CLASS_IMAGE_URL_INPUT = 'te-image-url-input';
    var CLASS_ALT_TEXT_INPUT = 'te-alt-text-input';
    var CLASS_OK_BUTTON = 'te-ok-button';
    var CLASS_CLOSE_BUTTON = 'te-close-button';

    var i18n=editorInstance.i18n;

    var COMPONENT_POPUP_CONTENT = `
        <label for="">Select Component</label>
        <select class="te-select-component"><option value="">Select Component</option></select>
        <div class="te-button-section">
            <button type="button" class="btn ${CLASS_OK_BUTTON}">${i18n.get('OK')}</button>
            <button type="button" class="btn ${CLASS_CLOSE_BUTTON}">${i18n.get('Cancel')}</button>
        </div>
    `;

    var componentPopup=editorInstance.getUI().createPopup({
        header: true,
        title: 'Insert Component',
        className: 'te-popup-add-image tui-editor-popup',
        content: COMPONENT_POPUP_CONTENT,
        //$target: editorInstance.getUI().getToolbar().$el,
        modal:true
    });
   
    var componentSelectInput=Mura(componentPopup.el).find('.te-select-component');
   
    Mura.getFeed('content')
        .where()
        .andProp('moduleAssign').containsValue('00000000000000000000000000000000000')
        .sort('title')
        .getQuery({type:'component',fields:'title'}).then(function(collection){
            collection.forEach(function(item){
                componentSelectInput.append('<option value="'+ Mura.escapeHTML(item.get('contentid')) +  '">'+ Mura.escapeHTML(item.get('title')) +  '</option>')
            })
            //$(componentSelectInput.node).niceSelect();
        });

    componentPopup.on('shown', function(){ componentSelectInput.focus()});
    componentPopup.on('hidden',function(){ componentSelectInput.val('');});

    componentPopup.on('click .te-close-button', function(){componentPopup.hide()});
    componentPopup.on('click .te-ok-button', function(){
        editorInstance.eventManager.emit('command', 'AddComponent', {
            componentid:componentSelectInput.val()
        });
        componentPopup.hide();
    });
   
    editorInstance.eventManager.listen('closeAllPopup', function() {
        componentPopup.hide();
    });

    editorInstance.eventManager.listen('showMuraComponentPopover', function() {
       
        editorInstance.eventManager.emit('closeAllPopup');
        componentPopup.show();

    });
    //END COMPONENT

    //BEGIN IMAGE

   
    editorInstance.eventManager.addEventType('showMuraImagePopover');
    
    var CLASS_IMAGE_URL_INPUT = 'te-image-url-input';
    var CLASS_ALT_TEXT_INPUT = 'te-alt-text-input';
    var CLASS_CAPTION_INPUT = 'te-caption-input';
    var CLASS_OK_BUTTON = 'te-ok-button';
    var CLASS_CLOSE_BUTTON = 'te-close-button';

    var i18n=editorInstance.i18n;

    var IMAGE_POPUP_CONTENT = `
    <div>
        <label for="">${i18n.get('Image URL')}</label>
        <input type="text" name="mdimageurl" class="${CLASS_IMAGE_URL_INPUT}" style="width:75%;float:left;"/>
        <button type="button" class="btn mura-finder" data-target="mdimageurl" data-resourcepath="User_Assets" data-completepath="false" style="width:25%;float:right;">Select Image</button><br/>
        <label for="">Alt Text</label>
        <input type="text" class="${CLASS_ALT_TEXT_INPUT}" />
        <label for="">Caption</label>
        <input type="text" class="${CLASS_CAPTION_INPUT}" />
        <div class="te-button-section">
            <button type="button" class="btn ${CLASS_OK_BUTTON}">${i18n.get('OK')}</button>
            <button type="button" class="btn ${CLASS_CLOSE_BUTTON}">${i18n.get('Cancel')}</button>
        </div>
    </div>
    `;

    var imagePopup=editorInstance.getUI().createPopup({
        header: true,
        title: 'Insert Image',
        className: 'te-popup-add-image tui-editor-popup',
        content: IMAGE_POPUP_CONTENT,
        //$target: editorInstance.getUI().getToolbar().$el,
        modal:true
    });

    var imageEl = imagePopup.el;
    var imageUrlInput = imageEl.querySelector(`.${CLASS_IMAGE_URL_INPUT}`);
    var imageAltTextInput = imageEl.querySelector(`.${CLASS_ALT_TEXT_INPUT}`);
    var imageCaptionInput = imageEl.querySelector(`.${CLASS_CAPTION_INPUT}`);

    imagePopup.on('shown', function(){
        Mura('.te-popup-add-image .tui-popup-wrapper').css('height','300px'); 
        imageUrlInput.focus();
    });
    imagePopup.on('hidden',function(){ 
        Mura('.te-popup-add-image .tui-popup-wrapper').css('height','');
        Mura(imagePopup.el).find('input').val('');
    });

    imagePopup.on('click .te-close-button', function(){imagePopup.hide()});
    imagePopup.on('click .te-ok-button', function(){
        editorInstance.eventManager.emit('command', 'MuraAddImage', {
            imageUrl:imageUrlInput.value,
            altText: imageAltTextInput.value || 'image',
            caption: imageCaptionInput.value || ''
        });
        imagePopup.hide();
    });

    editorInstance.eventManager.listen('closeAllPopup', function() {
        imagePopup.hide();
    });

    editorInstance.eventManager.listen('showMuraImagePopover', function() {
        
        imageUrlInput.value='';
        imageAltTextInput.value='';
        imageCaptionInput.value='';

        editorInstance.eventManager.emit('closeAllPopup');

        imagePopup.show();

        setFinders('button[data-target="mdimageurl"]');

    });

    function forEachArray(arr, iteratee, context) {
        var index = 0;
        var len = arr.length;
      
        context = context || null;
      
        for (; index < len; index += 1) {
          if (iteratee.call(context, arr[index], index, arr) === false) {
            break;
          }
        }
    }

    function decodeURIGraceful(originalURI) {
        const uris = originalURI.split(' ');
        const decodedURIs = [];
        let decodedURI;

        forEachArray(uris, uri => {
        try {
            decodedURI = decodeURIComponent(uri);
            decodedURI = decodedURI.replace(/ /g, '%20');
        } catch (e) {
            decodedURI = uri;
        }

        return decodedURIs.push(decodedURI);
        });

        return decodedURIs.join(' ');
    }

    
    function encodeMarkdownCharacters(text) {
        return text
        .replace(/\(/g, '%28')
        .replace(/\)/g, '%29')
        .replace(/\[/g, '%5B')
        .replace(/\]/g, '%5D')
        .replace(/</g, '%3C')
        .replace(/>/g, '%3E');
    }

    function escapeMarkdownCharacters(text) {
        return text
        .replace(/\(/g, '\\(')
        .replace(/\)/g, '\\)')
        .replace(/\[/g, '\\[')
        .replace(/\]/g, '\\]')
        .replace(/</g, '\\<')
        .replace(/>/g, '\\>');
    }

    var MuraAddImageMD = editorInstance.commandManager.addCommand('markdown',

    {
        name: 'MuraAddImage',

        /**
         * Command Handler
         * @param {MarkdownEditor} mde MarkdownEditor instance
         * @param {object} data data for image
         */
        exec: function exec(mde, data) {
            var cm = mde.getEditor();
            var doc = cm.getDoc();
            var range = mde.getCurrentRange();
            var from = {
            line: range.from.line,
            ch: range.from.ch
            };
            var to = {
            line: range.to.line,
            ch: range.to.ch
            };
            var altText = data.altText,
                imageUrl = data.imageUrl,
                caption = data.caption;
            altText = decodeURIGraceful(altText);
            altText = escapeMarkdownCharacters(altText);
            caption = decodeURIGraceful(caption);
            caption = escapeMarkdownCharacters(caption);
            imageUrl = encodeMarkdownCharacters(imageUrl);

            if(caption){
                caption="*" + caption + "*";
            }

            var replaceText = "![" + altText + "](" + encodeURI(imageUrl) + ")" + caption;
            doc.replaceRange(replaceText, from, to, '+addImage');
            cm.focus();
        }
    });

    editorInstance.addCommand(MuraAddImageMD);

    var MuraAddImageWysiwyg=editorInstance.commandManager.addCommand('wysiwyg',
    {
        name: 'MuraAddImage',
        exec: function exec(wwe, data) {
            var sq = wwe.getEditor();
            var altText = data.altText,
                imageUrl = data.imageUrl,
                caption = data.caption;

            altText = decodeURIGraceful(altText);
            caption = decodeURIGraceful(caption);
            imageUrl = encodeMarkdownCharacters(imageUrl);
            wwe.focus();

            var container=document.createElement('DIV');
            var image=document.createElement('IMG');
            image.setAttribute('src',encodeURI(imageUrl));

            if(altText){
                image.setAttribute('alt',altText);
            }

            container.appendChild(image);

            if(caption){
                var em=document.createElement('EM');
                em.innerHTML=caption;
                container.appendChild(em);
            }
            if(!sq.hasFormat('PRE')) {
            sq.insertHTML(container.innerHTML);
            }
        }
    });

    editorInstance.addCommand(MuraAddImageWysiwyg);
    //END IMAGE

    //BEGIN LINK

    editorInstance.eventManager.addEventType('showMuraLinkPopover');

    var i18n=editorInstance.i18n;
    var LINK_POPUP_CONTENT = `<div>
        <label for="url">${i18n.get('URL')}</label>
        <input type="text" id="mdlinkurl" name="mdlinkurl" class="te-url-input" style="width:75%;float:left;"/>
        <button type="button" class="btn mura-finder" data-target="mdlinkurl" data-resourcepath="User_Assets" data-completepath="false" style="width:25%;float:right;">Select File</button><br/>
        <label for="linkText">${i18n.get('Link text')}</label>
        <input type="text" class="te-link-text-input" />
        <div class="te-button-section">
            <button type="button" class="btn te-ok-button">${i18n.get('OK')}</button>
            <button type="button" class="btn te-close-button">${i18n.get('Cancel')}</button>
        </div></div>
    `;

    var LinkPopup=editorInstance.getUI().createPopup({
        header: true,
        title: 'Insert link',
        className: 'te-popup-add-image tui-editor-popup',
        content: LINK_POPUP_CONTENT,
        //$target: editorInstance.getUI().getToolbar().$el,
        modal:true
    });
   
    $( function() {
        var cache = {};
        $( 'input[name="mdlinkurl"]').autocomplete({
          minLength: 4,
          source( request, response ) {
            var term = request.term;
            if(term.substring(1, 4)=='http' || term.substring(1, 1) == "/"){
                return;
            }
            if ( term in cache ) {
              response( cache[ term ] );
              return;
            }
            
            Mura.getFeed('content')
                .where()
                .andProp('title').containsValue(term)
                .sort('title')
                .getQuery({fields:'title,url'}).then(function(collection){
                    var data=[];
                    collection.forEach(function(item){
                        data.push(item.get('url'));
                    })
              
                    //console.log(data)
                    cache[ term ] = data;
                    response(data);
                });
          }
        });
      } );

    var linkEl = LinkPopup.el;
    var linkInputText = linkEl.querySelector('.te-link-text-input');
    var linkInputURL = linkEl.querySelector('.te-url-input');
 
    LinkPopup.on('click .te-close-button', function(){LinkPopup.hide()});
    LinkPopup.on('click .te-ok-button', function(){
        editorInstance.eventManager.emit('command', 'AddLink', {
            linkText:linkInputText.value,
            url:linkInputURL.value
        });
        LinkPopup.hide()
    });   
    editorInstance.eventManager.listen('showMuraLinkPopover', function() {
        var linkSelectedText = editorInstance.getSelectedText().trim();
        
        linkInputText.value='';
        linkInputURL.value='';

        editorInstance.eventManager.emit('closeAllPopup');

        LinkPopup.show();
        
        setFinders('button[data-target="mdlinkurl"]');
    
        linkInputText.value = linkSelectedText;
        linkInputURL.focus();

        if (URL_REGEX.exec(linkSelectedText) || URL_REGEX.exec(HASH_REGEX)) {
            linkInputURL.value = linkSelectedText;
        }

    });

    editorInstance.eventManager.listen('closeAllPopup', function() {
        LinkPopup.hide();
    });
    //END LINK
    
    return editorInstance;
}
(function () {

    var content=null;
    var variations=[];
    var origvariations=[];
    var editableSelector='.mxp-editable';
    var pathname=location.pathname.split('/');

    if(pathname[pathname.length-1].split('.')[0]=='index'){
        pathname.pop();
        pathname=pathname.join('/');
        pathname=pathname + '/';
    } else {
        pathname=pathname.join('/');
    }

    var loc=[location.host, pathname.replace(/\/\//g, '/')].join('');
    
    if(loc && loc.charAt(loc.length - 1) == '/'){
        loc=loc.substring(0, loc.length - 1);
    }

    var remoteurl=[location.protocol,'//',location.host, pathname.replace(/\/\//g, '/')].join('');
    
    if(remoteurl && remoteurl.charAt(remoteurl.length - 1) == '/'){
        remoteurl=remoteurl.substring(0, remoteurl.length - 1);
    }
    
    var lochash='';
    
    applyingVariationsReset=true;
    targetingVariations=false;

    function getLocation(href) {
        var match = href.match(/^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)([\/]{0,1}[^?#]*)(\?[^#]*|)(#.*|)$/);
        return match && {
            href: href,
            protocol: match[1],
            host: match[2],
            hostname: match[3],
            port: match[4],
            pathname: match[5],
            search: match[6],
            hash: match[7]
        }
    }

    function getRootPath(){
        var parsedLocation=getLocation(getCurrentScriptPath());
        var rootpath=parsedLocation.protocol + "//" + parsedLocation.host;

        return rootpath;
    }

    function getQueryStringParams(queryString) {

        if(typeof location == 'undefined'){
            return {};
        }

        queryString = queryString || location.search;
        var params = {};
        var e,
            a = /\+/g, // Regex for replacing addition symbol with a space
            r = /([^&;=]+)=?([^&;]*)/g,
            d = function(s) {
                    return decodeURIComponent(s.replace(a, " "));
            };

        if (queryString.substring(0, 1) == '?') {
            var q = queryString.substring(1);
        } else {
            var q = queryString;
        }

        while (e = r.exec(q)){
            params[d(e[1]).toLowerCase()] = d(e[2]);
        }
        
        return params;
    }

    function getCurrentScriptParams(){
        var currentscriptArray=getCurrentScript().split('?');
        if(currentscriptArray.length == 2){
            return getQueryStringParams(currentscriptArray[1]);
        } else{
            return {};
        }
    };

	function getCurrentScript() {
         var location;
         var scripts = document.getElementsByTagName('script');
         for(var i=0; i<scripts.length;++i) {
             location = scripts[i].src;
             if(location.indexOf('variation.js') > -1){
                 return location;
             }
         }
     }

    function getCurrentScriptPath() {
        var script = getCurrentScript();
        var path = script.substring(0, script.lastIndexOf('/'));
        return path;
    };

    function loadScript(url, callback) {

        var script = document.createElement("script")
        script.type = "text/javascript";

        if (false && script.readyState) { //IE
            script.onreadystatechange = function () {
                if (script.readyState == "loaded" || script.readyState == "complete") {
                    script.onreadystatechange = null;

                    callback();
                }
            };
        } else { //Others
            script.onload = function () {
                callback();
            };
        }

        script.src = url;
        document.getElementsByTagName("head")[0].appendChild(script);
    }

    function handleVariations(data){

        content=data.data;

        if(!content.remoteid || !content.remoteurl){
            content.remoteid=lochash;
            content.remoteurl=remoteurl;
        }

        if(!content.title){
            content.title=loc;
        }

        var rootpath=getRootPath();

        var config=Mura.extend({},{
            content:content,
            variations:variations,
            ga:content.ga,
            origvariations:origvariations,
            editableSelector:editableSelector,
            siteid:content.siteid,
            contentid:content.contentid,
            contenthistid:content.contenthistid,
            moduleid:content.moduleid,
            parentid:content.parentid,
            changesetid:content.changesetid,
            type:content.type,
            subtype:content.subtype,
            preloaderMarkup:'',
            rootpath:getRootPath(),
            remoteid:content.remoteid,
            remoteurl:content.remoteurl,
            title:content.title
        });

        if(location.search.indexOf("doaction=logout") > -1){
            Mura.ajax({
                type:"POST",
                dataType: 'json',
                xhrFields:{ withCredentials: true },
                crossDomain:true,
                url:apiEndpoint + '/logout',
                success:function(){
                    location.href=remoteurl;
                }
            });
        }

        if(content.initjs){
            try{
            eval('(' + content.initjs + ')');
            } catch(e) {
                console.error(e);
            }
        }

        Mura.init(config);

        Mura.extend(Mura,{
            siteid:content.siteid,
            contentid:content.contentid,
            contenthistid:content.contenthistid,
            moduleid:content.moduleid,
            changesetid:content.changesetid,
            parentid:content.parentid,
            type:content.type,
            subtype:content.subtype
        });

        var remoteFooter=Mura('#mura-remote-footer');

        if(remoteFooter.length){
            remoteFooter.remove();
        }

        var footer=document.createElement('DIV');
        footer.setAttribute('id','mura-remote-footer');
        window.document.body.appendChild(footer);

        var queuedContent='';
        if(content.htmlheadqueue){
            queuedContent += content.htmlheadqueue;
        }
        if(content.htmlfootqueue){
            queuedContent += content.htmlfootqueue;
        }
        Mura('#mura-remote-footer').html(queuedContent);

        Mura.loader()
        .loadcss(rootpath + '/core/modules/v1/core_assets/css/mura.10.min.css')
        .loadcss(rootpath + '/core/modules/v1/core_assets/css/mura.10.skin.css')
        //.loadcss(themepath + '/css/site.min.css');

        if(content.body){
            try{
                Mura.variations=eval('(' + content.body + ')');
                Mura.origvariations=variations.slice();
            } catch(e){
                try{
                    Mura.variations=eval('(' + decodeURIComponent(content.body) + ')');
                    Mura.origvariations=variations.slice();
                } catch(e){
                    console.log(e)
                    Mura.variations=[];
                    Mura.origvariations=[];
                }
            }
        } else {
            Mura.variations=[];
            Mura.origvariations=[];
        }
        
       

        if(content.targetingjs){
            try{
                var selectors=eval('(' + content.targetingjs + ')');
            } catch(e){
                var selectors=[];
            }
        } else {
            var selectors=[];
        }

        Mura(".mxp-editable").forEach(function(){
            var item=Mura(this);
            selectors.push(item.selector());
        });


        if(selectors.length){
            try {
              
               function setTargeting(selectors){
    
                    function applyVariation(el){
                        var found=false;
                        var variation;
                        var attempt=0;

                        for(var i=0;i<Mura.variations.length;i++){
                            if(el.is(Mura.variations[i].selector)){
                                found=true;
                                variation=Mura.variations[i];
                                break;
                            }
                        }
                        if(found){
                            if(!el.find('.mxp-variation-marker').length){
                                variation.original=el.html();
                                el.html(variation.adjusted + '<div class="mxp-variation-marker"/>')
                                .find('.mura-object').processMarkup();
                            }
                        } else {
                            attempt++;
                            if(attempt<250){
                                setTimeout(function(){applyVariation(el)},1);
                            }
                        }
                    }

                    function applyCSSId(el){
                        if(targetingVariations){
                            return;
                        }
                        if(!el.attr('id')){
                            el.attr('id','mxp' + Mura.hashCode(el.selector()));
                            el.addClass('mxp-dynamic-id');
                        }
                        el.data('mxptargetset',true);
                    }

                    function setTarget(selector){
                        if(targetingVariations){
                            return;
                        }
                     
                        var el=Mura(selector);
                       
                        if(el.length){
                            if(!el.find('.mxp-variation-marker').length){
                                el.addClass('mxp-editable');
                                applyCSSId(el);
                                applyVariation(el);
                            }
                        }
                        if(!applyingVariationsReset){
                            setTimeout(function(){setTarget(selector)},1);
                        }
                    }

                    if(typeof selectors =='object'){
                        for(var i=0, len=selectors.length; i < len; i++){
                            setTarget(selectors[i]);
                        }
                    }
                }

                applyingVariationsReset=false;
                setTargeting(selectors);
              
            } catch(e) {
                console.error(e);
            }

             //if mxp load tracking
           
        }
       
    }

    function readCookie(name) {
        var nameEQ = name + "=";
        var ca = document.cookie.split(';');
        for(var i=0;i < ca.length;i++) {
            var c = ca[i];
            while (c.charAt(0)==' ') c = c.substring(1,c.length);
            if (c.indexOf(nameEQ) == 0) return decodeURIComponent(c.substring(nameEQ.length,c.length));
        }
        return "";
    }

    function loadVariations(fn,leadprops){

        leadprops=leadprops || '';
        
        lochash=Mura.hashCode(loc);
       
        var trackingparams='&cb=' + Math.random();

        var mkto_trk=readCookie('_mkto_trk');

        if(mkto_trk){
            console.log('_mkto_trk=' + mkto_trk);
            trackingparams+='&mkto_trk=' + encodeURIComponent(mkto_trk);
        }

        var sp_trk=readCookie('com.silverpop.iMAWebCookie');

        if(sp_trk){
            console.log('com.silverpop.iMAWebCookie=' + sp_trk);
            trackingparams+='&sp_trk=' + encodeURIComponent(sp_trk);
        }

        var mautic_trk=readCookie('mtc_id');

        if(mautic_trk){
            console.log('mautic_trk=' + mautic_trk);
            trackingparams+='&mautic_trk=' + encodeURIComponent(mautic_trk);
        }

        var autopilot_trk=readCookie('_autopilot_session_id');

        if(autopilot_trk){
            console.log('autopilot_trk=' + autopilot_trk);
            trackingparams+='&autopilot_trk=' + encodeURIComponent(autopilot_trk);
        }

        var siteid=getCurrentScriptParams().siteid || "default";
        var rootpath=getRootPath();

        Mura.init({
            rootpath:rootpath,
            siteid:siteid,
			loginurl:rootpath + "/admin/?muraAction=clogin.main"
        });

        Mura.ajax({
            type:"GET",
            dataType: 'json',
            xhrFields:{ withCredentials: true },
            crossDomain:true,
            url:Mura.apiEndpoint + '/content/_variation/'+ lochash + '?' + location.search.slice(1) + '&leadprops=' + leadprops + trackingparams,
            success:function(resp){
                //console.log(resp)
                handleVariations(resp);
                if(typeof fn == 'function'){
                    fn(resp.data);
                }

                Mura('.mxp-loader').hide();
            }
        });

    }

    function init(){
        var callback=function(data){
            //Look for callback method
            if(typeof mxpInitCallback =='function'){
                mxpInitCallback(data);
            }
        }
        if(window.Mura){
            loadVariations(callback);
        } else {
            loadScript(getCurrentScriptPath() + "/mura.min.js",function(){
                loadVariations(callback);
            });
        }
    };

    init();
})();

<cfscript>
    param name="attributes.label" default='Custom Properties';
    param name="attributes.name" default='customprops';
    param name="attributes.value" default=[];
    param name="attributes.condition" default="";
    param name="attributes.valuetype" default="text";
    param name="attributes.configurator" default=[];

    if(isJson(attributes.value)){
    //    attributes.value=deserializeJSON(attributes.value);
    }
  
    if(!isArray(attributes.value)){
      //  attributes.value=[];
    }
   
</cfscript>
<cfoutput>

<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
    <label>#esapiEncode('html',attributes.label)#</label>
    <div id="#esapiEncode('html_attr',attributes.name)#-container"></div>
    <input type='hidden' name="#esapiEncode('html_attr',attributes.name)#" value="#esapiEncode('html_attr',serializeJSON(attributes.value))#" class="objectParam">
    <input type='hidden' data-configurator="#esapiEncode('html_attr',attributes.name)#" value="#esapiEncode('html_attr',serializeJSON(attributes.configurator))#" class="valueConfigurator">
</div> 

<script>
Mura(function(){
    var refName='#esapiEncode('javascript',attributes.name)#';
    var refLabel='#esapiEncode('javascript',attributes.label)#';
    var propRef=Mura(`input[name="${refName}"]`);
    var container=Mura(`##${refName}-container`);
    var props=parseValues(propRef.val());
    var markup='';
    var valuetype='#esapiEncode('javascript',attributes.valuetype)#';
  
    props.push({name:"",value:""});

    function parseValues(valueToParse){
        //console.log('valueToParse',valueToParse)
        if(Array.isArray(valueToParse)){
            return valueToParse;
        }
        try{
            var parsedValue=JSON.parse(valueToParse);
            if(Array.isArray(parsedValue)){
                return parsedValue;
            }
            return [];
        } catch(e){
            console.log(e)
            return [];
        }
    }

    function renderPropValueUI(item,index){
        switch(valuetype){
            case 'markdown':
                return `<input type="hidden" data-index="${index}" data-action="update" data-attr="value" value="${Mura.escape(item.value)}"/>
                    <button type="button" data-index="${index}" class="btn mura-markdown-edit col-xs-12" data-target="#esapiEncode('html_attr',attributes.name)#">Edit</button>`
                break;
            case 'object':
                return `<input type="hidden" data-index="${index}" data-action="update" data-attr="value" value="${Mura.escape(item.value)}"/>
                    <button type="button" data-index="${index}" class="btn mura-object-edit col-xs-12" data-target="#esapiEncode('html_attr',attributes.name)#">Edit</button>`
                break;
            default:
                return `<input type="text" data-index="${index}" data-action="update" data-attr="value" value="${Mura.escape(item.value)}"/>`
        }
       
    }

    function renderValueLabel(){
        switch(valuetype){
            case 'markdown':
            case 'object':
            return '&nbsp;';
                break;
            default:
                return 'Value';
        }
    }

    function initPropsUI(){
   
        var addBtn=`<a href="##" data-action="add" class="btn mura-ui-link ui-advanced addprop"><i class="mi-plus"></i></a>`

        if(props.length){
            var propsUI = props.map(function(item,index){
                return renderProp(item,index);
            }).join("")

            var markup=`
            <div class="row mura-ui-row mura-input-row" id="${refName}-table">
                <div class="col-xs-5"><label>Property</label></div>
                <div class="col-xs-5"><label>${renderValueLabel()}</label></div>
                <div class="col-xs-2"><label>&nbsp;</label></div>
            </div>
            ${propsUI}
            <div class="row mura-ui-row mura-input-row">
                <div class="col-xs-5">&nbsp;</div>
                <div class="col-xs-5">&nbsp;</div>
                <div class="col-xs-2">${addBtn}</div>         
            </div
            `;

        } else {
            var markup=`
            <div class="row mura-ui-row mura-input-row" id="${refName}-table">
                <div class="col-xs-5"><label>Property</label></div>
                <div class="col-xs-5"><label>Value</label></div>
                <div class="col-xs-2"><label>${addBtn}</label></div>
            </div>
            `;
        }

        container.html(markup);

        props.forEach(function(item, index){
            var row= Mura('##' + refName + '-' + index);
            if(typeof item == 'object'){
                row.find('input[data-attr="name"]').val(item.name);
                if(typeof item.value != 'string'){
                    row.find('input[data-attr="value"]').val(JSON.stringify(item.value));
                } else {
                    row.find('input[data-attr="value"]').val(item.value);
                }   
            }
            row.find('.mura-markdown-edit').each(function(){
                var self=Mura(this);
                self.click(function(){
                    openMarkdownEditor(self.data('index'))
                });
            })
            row.find('.mura-object-edit').each(function(){
                var self=Mura(this);
                self.click(function(){
                    openObjectEditor(self.data('index'))
                });
            })
        })
    }

    function openMarkdownEditor(index){
        setTimeout(function(){
            siteManager.openDisplayObjectModal('object/markdown.cfm',
            {
                target:"#esapiEncode('html_attr',attributes.name)#",
                index:index,
                label:refLabel
            });
          },
          500
        );
       
    }

    function openObjectEditor(index){
        setTimeout(function(){
            siteManager.openDisplayObjectModal('object/object.cfm',
            {
                target:"#esapiEncode('html_attr',attributes.name)#",
                index:index,
                label:refLabel
            });
          },
          500
        );
       
    }

    function renderProp(item,index){
        item.name=item.name || '';
        item.value=item.value || '';

        return  `
            <div class="row mura-ui-row mura-input-row" id="${refName}-${index}">
                <div class="col-xs-5"><input type="text" data-index="${index}" data-action="update" data-attr="name"/></div>
                <div class="col-xs-5">${renderPropValueUI(item,index)}</div>
                <div class="col-xs-2"><a href="##" data-index="${index}" data-action="remove" class="btn mura-ui-link ui-advanced removeprop"><i class="mi-trash"></i></a></div>
            </div>
        `;
    }


    function addProp(){
        props.push({name:"",value:""});
        initPropsUI();
    }

    function removeProp(index){
        props.splice(index,1);
        initPropsUI();
        serializeParam();
    }

    function serializeParam(){
        //Using jQuery because it's a jQuery onchange listener
        var final=props.filter(function(item){
            if(item.name || item.value){
                return true;
            }
        })
        jQuery(`input[name="${refName}"]`).val(JSON.stringify(final)).trigger('change');
        //container.find('button').removeAttr('disabled');
    }

    container.on('click','a.mura-ui-link',function(){
        var eventSource=Mura(this);
        if(eventSource.data('action')=='remove'){
            removeProp(eventSource.data('index'));
        } else {
            addProp();
        }
        return false;
    })
    /*
    container.on('keypress','input',function(){
        container.find('button').attr('disabled',true);
    })

    container.on('blur','input',function(){
        container.find('button').removeAttr('disabled');
    })
    */
    container.on('click','a.mura-ui-link i',function(){
        Mura(this).closest('a').trigger('click');
    })   

    container.on('change','input',function(){
        var eventSource=Mura(this);
        var value=eventSource.val();
        if(typeof value == 'object'){
            value=JSON.parse(value);
        }

        props=parseValues(propRef.val());
        props.push({name:"",value:""});
        
        props[eventSource.data('index')][eventSource.data('attr')]=value;
     
        serializeParam();
    })

    initPropsUI();
})
</script>
</cfoutput>
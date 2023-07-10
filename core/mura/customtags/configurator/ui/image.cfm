<cfscript>
    param name="attributes.label" default='Image';
    param name="attributes.name" default='image';
    param name="attributes.value" default='';
    param name="attributes.condition" default="";
    
    if(!isDefined('request.associatedImageURL')){
        Mura=application.Mura.getBean('Mura').init(form.siteid);
        request.associatedImageURL=Mura.getBean('content').loadBy('contenthistid',Mura.event('contenthistid')).getImageURL(complete=Mura.siteConfig('isRemote'));
    }
</cfscript>
<cfoutput>
<div class="mura-control-group"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
    <label class="mura-control-label">#esapiEncode('html',attributes.label)#</label>
    <input type="text" placeholder="URL" id="#esapiEncode('html_attr',attributes.name)#src" name="#esapiEncode('html_attr',attributes.name)#" class="objectParam" value="#esapiEncode('html_attr',attributes.value)#"/>
    <cfif isDefined('request.associatedImageURL') and len(request.associatedImageURL)>
        <div class="btn-group btn-group-sm" role="group" aria-label="Select Image">		
            <button type="button" class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                <i class="mi-image"></i> Select Image <span class="caret"></span>
            </button>
            <ul class="dropdown-menu">
                <li><a class="mura-finder" data-target="#esapiEncode('html_attr',attributes.name)#" data-resourcepath="User_Assets" data-completepath="false" href="javascript:void(0);"><i class="mi-globe"></i> File Manager</a></li>
                <li><a id="#esapiEncode('html_attr',attributes.name)#srcassocurl" href="#request.associatedImageURL#"> <i class="mi-th"></i> Associated Image</a></li>
            </ul>
            <script>
                $(function(){
                    $('###esapiEncode('html_attr',attributes.name)#srcassocurl').click(function(){
                        $('###esapiEncode('html_attr',attributes.name)#src').val($(this).attr('href')).trigger('change');
                        return false;
                    })
                })
            </script>
        </div>
    <cfelse>
        <button type="button" class="btn mura-finder" data-resourcepath="User_Assets" data-target="#esapiEncode('html_attr',attributes.name)#" data-completepath="false"><i class="mi-image"></i> Select Image</button>
    </cfif>
</div>
</cfoutput>
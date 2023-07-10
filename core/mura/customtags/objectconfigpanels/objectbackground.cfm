<cfscript>
    param name="attributes.name" default="";
</cfscript>
<cfoutput>
<script>
    window.configuratorBgInited=false;
</script>
<div class="mura-control-group flex-container-object breakpointtoggle" id="#attributes.name#backgroundid" data-toggle="bp-tabs">
    <div class="bp-tabs">
    <cfloop list="xs,sm,md,lg,xl" index="size">
    <cfif size eq 'xl'>
        <cfset nameAndSize="#attributes.name#">
    <cfelse>
        <cfset nameAndSize="#attributes.name#_#size#_">
    </cfif>
    <div class="bp-tab bp-tab-<cfoutput>#size#</cfoutput><cfif size eq 'xl'> bp-current</cfif>" data-breakpoint="#size#" data-nameandsize="#nameAndSize#" style="display:<cfif size eq 'xl'>block<cfelse>none</cfif>;">
        <cfscript>
            param name="attributes.params.stylesupport.#nameAndSize#backgroundpositionx" default="";
            param name="attributes.params.stylesupport.#nameAndSize#backgroundpositiony" default="";
            param name="attributes.params.stylesupport.#nameAndSize#backgroundimageurl" default="";
        </cfscript>
        <!--- background --->
        <div class="mura-control-group">
            <label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.backgroundcolor'))#</label>
            <div class="input-group mura-colorpicker" id="#nameAndSize#backgroundcustom">
                <span class="input-group-addon"><i class="mura-colorpicker-swatch"></i></span>
                <input type="text" id="#nameAndSize#backgroundcolor" name="backgroundColor" class="#nameAndSize#Style" placeholder="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.selectcolor'))#" autocomplete="off" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].backgroundcolor)#">
            </div>
        </div>
        <div class="mura-control-group">
            <label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.backgroundimage'))#</label>
            <input type="hidden" id="#nameAndSize#backgroundimage" name="backgroundImage" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].backgroundimage)#">
            <input type="text" id="#nameAndSize#backgroundimageurl" name="#nameAndSize#backgroundimageurl" placeholder="URL" class="styleSupport backgroundimageurl" value="#esapiEncode('html_attr',attributes.params.styleSupport['#nameAndSize#backgroundimageurl'])#">
            
            <cfif len(request.associatedImageURL)>
                <div class="btn-group btn-group-sm" role="group" aria-label="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectimage'))#">		
                    <button type="button" class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <i class="mi-image"></i> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectimage'))# <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        <li><a class="mura-finder" data-target="#nameAndSize#backgroundimageurl" data-completepath=<cfif request.$.content('type') eq 'Variation'>"true"<cfelse>"false"</cfif> href="javascript:void(0);"><i class="mi-globe"></i> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.filemanager'))#</a></li>
                        <li><a id="#nameAndSize#backgroundassocurl" href="#request.associatedImageURL#"> <i class="mi-th"></i> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.associatedimage'))#</a></li>
                    </ul>
                    <script>
                        $(function(){
                            $('###nameAndSize#backgroundassocurl').click(function(){
                                $('###nameAndSize#backgroundimageurl').val($(this).attr('href')).trigger('change');
                                return false;
                            })
                        })
                    </script>
                </div>
            <cfelse>
                <button type="button" class="btn mura-finder" data-target="#nameAndSize#backgroundimageurl" data-completepath=<cfif request.$.content('type') eq 'Variation'>"true"<cfelse>"false"</cfif>><i class="mi-image"></i> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectimage'))#</button>
            </cfif>
        </div>
        <div class="mura-control-group mura-ui-grid #nameAndSize#-css-bg-option bg-position" style="display:none;">
            <label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.backgroundposition'))#</label>
            <div class="row mura-ui-row">
                <div class="col-xs-4"><label class="right ui-nested">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.vertical'))#</label></div>
                <div class="col-xs-8">
                    <div class="mura-input-group">
                        <label>
                            <input type="text" id="#nameAndSize#backgroundpositionynum" name="objectBackgroundPositionyNum" class="numeric" placeholder="" value="<cfif val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].backgroundpositiony))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].backgroundpositiony))#</cfif>" style="display: none;">
                        </label>

                        <select id="#nameAndSize#backgroundpositiony" name="#nameAndSize#BackgroundPositionY" class="styleSupport" data-numfield="#nameAndSize#backgroundpositionynum">
                            <cfloop list="Top,Center,Bottom,%,px" index="p">
                                <option value="#lcase(p)#"<cfif attributes.params.stylesupport['#nameAndSize#styles'].backgroundpositiony contains p> selected</cfif>>#p#</option>
                            </cfloop>
                        </select>

                        <input type="hidden" id="#nameAndSize#backgroundpositionyval" name="backgroundPositionY" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].backgroundpositiony)#">

                    </div>
                </div>
            </div>
            <div class="row mura-ui-row">
                <div class="col-xs-4"><label class="right ui-nested">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.horizontal'))#</label></div>
                <div class="col-xs-8">
                    <div class="mura-input-group">
                        <label>
                            <input type="text" id="#nameAndSize#backgroundpositionxnum" name="#nameAndSize#BackgroundPositionxNum" class="numeric" placeholder="" value="<cfif val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].backgroundpositionx))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].backgroundpositionx))#</cfif>" style="display: none;">
                        </label>

                        <select id="#nameAndSize#backgroundpositionx" name="#nameAndSize#BackgroundPositionX" class="styleSupport" data-numfield="#nameAndSize#backgroundpositionxnum">
                            <cfloop list="Left,Center,Right,%,px" index="p">
                                <option value="#lcase(p)#"<cfif attributes.params.stylesupport['#nameAndSize#styles'].backgroundpositionx contains p> selected</cfif>>#p#</option>
                            </cfloop>
                        </select>

                        <input type="hidden" id="#nameAndSize#backgroundpositionxval" name="backgroundPositionX" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].backgroundpositionx)#">

                    </div>
                </div>
            </div>
        </div>
        <div class="mura-control-group #nameAndSize#-css-bg-option" style="display:none;">
            <label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.backgroundrepeat'))#</label>
            <select id="#nameAndSize#backgroundrepeat" name="#nameAndSize#BackgroundRepeat" data-param="backgroundRepeat" class="#nameAndSize#Style">
                <option value="no-repeat"<cfif attributes.params.stylesupport['#nameAndSize#styles'].backgroundrepeat eq 'no-repeat'> selected</cfif>>No-repeat</option>
                <option value="repeat"<cfif attributes.params.stylesupport['#nameAndSize#styles'].backgroundrepeat eq 'repeat'> selected</cfif>>Repeat</option>
                <option value="repeat-x"<cfif attributes.params.stylesupport['#nameAndSize#styles'].backgroundrepeat eq 'repeat-x'> selected</cfif>>Repeat-X</option>
                <option value="repeat-y"<cfif attributes.params.stylesupport['#nameAndSize#styles'].backgroundrepeat eq 'repeat-y'> selected</cfif>>Repeat-Y</option>
            </select>
        </div>
        <div class="mura-control-group #nameAndSize#-css-bg-option" style="display:none;">
            <label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.backgroundsize'))#</label>
            <select id="#nameAndSize#backgroundsize" name="#nameAndSize#BackgroundSize" data-param="backgroundSize" class="#nameAndSize#Style">
                <option value="auto"<cfif attributes.params.stylesupport['#nameAndSize#styles'].backgroundsize eq 'auto'>
                selected</cfif>>Auto</option>
                <option value="contain"<cfif attributes.params.stylesupport['#nameAndSize#styles'].backgroundsize eq 'contain'> selected</cfif>>Contain</option>
                <option value="cover"<cfif attributes.params.stylesupport['#nameAndSize#styles'].backgroundsize eq 'cover'> selected</cfif>>Cover</option>
            </select>
        </div>

        <div class="mura-control-group #nameAndSize#-css-bg-option" style="display:none;">
            <label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.backgroundattachment'))#</label>
            <select name="#nameAndSize#BackgroundAttachment" data-param="backgroundAttachment" class="#nameAndSize#Style">
                <option value="scroll"<cfif attributes.params.stylesupport['#nameAndSize#styles'].backgroundAttachment eq 'scroll'>
                selected</cfif>>Scroll</option>
                <option value="Fixed"<cfif attributes.params.stylesupport['#nameAndSize#styles'].backgroundAttachment eq 'fixed'> selected</cfif>>Fixed</option>
            </select>
        </div>
    </div>
</cfloop>
</div></div>   
</cfoutput>
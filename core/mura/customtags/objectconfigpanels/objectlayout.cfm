
<cfscript>
    param name="attributes.name" default="";
    nameAndSize=attributes.name;
    param name="attributes.params.stylesupport.#nameAndSize#minheightuom" default="";
</cfscript>
<cfoutput>
<script>
    window.configuratorLMInited=false;
</script>


<cfif not $.globalConfig().getValue(property='spacingdispenser',defaultValue=true) and 
len(attributes.params.stylesupport['#attributes.name#styles'].margintop
    & attributes.params.stylesupport['#attributes.name#styles'].marginbottom
    & attributes.params.stylesupport['#attributes.name#styles'].marginleft
    & attributes.params.stylesupport['#attributes.name#styles'].marginright
    & attributes.params.stylesupport['#attributes.name#styles'].marginall
    & attributes.params.stylesupport['#attributes.name#styles'].paddingtop
    & attributes.params.stylesupport['#attributes.name#styles'].paddingbottom
    & attributes.params.stylesupport['#attributes.name#styles'].paddingleft
    & attributes.params.stylesupport['#attributes.name#styles'].paddingright
    & attributes.params.stylesupport['#attributes.name#styles'].paddingall
)>
    <cfset attributes.params['#attributes.name#spacing']='custom'>
</cfif>

<cfif arrayLen(request.spacingoptions)>
    <!---<cfif attributes.name eq 'object'>
        <cfset hasConstrainOption=false>
        <cfloop array="#request.spacingoptions#" index="t">
            <cfif t.value eq 'constrain'>
                <cfset hasConstrainOption=false>
                <cfbreak>
            </cfif>
        </cfloop>
    </cfif>--->
    <div class="mura-control-group  mura-ui-grid">
        <cfif $.globalConfig().getValue(property='spacingdispenser',defaultValue=true)>
            <label>Spacing Styles</label>
            <cfset request.spacingoptionlabels = []>
            <cfset request.spacingoptionvalues = []>  
            <div class="row mura-flex">
                <select class="dispenser-select" data-nameandsize="#attributes.name#" id="#attributes.name#Spacing"  data-delim=" " data-param="#attributes.name#Spacing">
                    <option value="">--</option>
                    <!---<cfif attributes.name eq 'object' and not hasConstrainOption>
                        <option value="constrain">#esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.constraincontent'))#</option>
                        <cfset request.spacingoptionlabels = [application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.constraincontent')]>
                        <cfset request.spacingoptionvalues = ['constrain']>
                    <cfelse>
                        <cfset request.spacingoptionlabels = []>
                        <cfset request.spacingoptionvalues = []>            
                    </cfif>--->
                    <cfloop array="#request.spacingoptions#" index="t">
                        <cfif (not structKeyExists(t,'modules') or t.module eq '*' or listFindNoCase(t.modules,attributes.params.object)) and not (structKeyExists(t,'omitmodules') and listFindNoCase(t.omitmodules,attributes.params.object))>
                            <option value="#t.value#">#esapiEncode('html',t.name)#</option>
                            <cfset arrayAppend(request.spacingoptionlabels,t.name)>
                            <cfset arrayAppend(request.spacingoptionvalues,t.value)>
                        </cfif>
                    </cfloop>
                </select>
                <input name="#attributes.name#spacing" id="#attributes.name#Spacingdispenserval" class="<cfif attributes.name eq 'object'>classtoggle </cfif>objectParam" type="hidden" value="#esapiEncode('html_attr',attributes.params['#attributes.name#spacing'])#">
            </div>
            <!--- if saved theme values --->
            <cfset request["#attributes.name#spacingoptions"] = []>
            <cfset request["#attributes.name#spacingoptionsclasses"] = listToArray(attributes.params['#attributes.name#spacing'], ' ')>
            <cfloop array="#request.spacingoptionvalues#" item="c">
                <cfif arrayFind(request["#attributes.name#spacingoptionsclasses"],c) or (attributes.name eq 'object' and listFind(attributes.params.class,c,' '))>
                 <cfset arrayAppend(request["#attributes.name#spacingoptions"],c)> 
                </cfif> 
            </cfloop>	
          
            <!--- if saved values match available options --->
            <cfif arrayLen(request["#attributes.name#spacingoptions"])>
                <div class="dispense-to" data-select="#attributes.name#Spacing" data-delim=" " data-param="#attributes.name#Spacing">
                    <cfloop array="#request["#attributes.name#spacingoptions"]#" index="o">
                        <cfset labelIndex=arrayFind(request.spacingoptionvalues,o)>
                        <cfset oo = (labelIndex) ? request.spacingoptionlabels[labelIndex] : o>
                        <div class="dispense-option" data-value="#o#">
                            <span class="drag-handle"><i class="mi-navicon"></i></span>
                            <span class="dispense-label">#oo#</span>
                            <a class="dispense-option-close"><i class="mi-minus-circle"></i></a>
                        </div>
                    </cfloop>
                </div>
            </cfif>	
        <cfelse>
            <label>Spacing</label>
            <select name="#attributes.name#spacingselect" class="spacingselect" data-nameandsize="#attributes.name#">
                <option value="">--</option>
                  <option value="constrain">#esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.constraincontent'))#</option>
                <cfloop array="#request.spacingoptions#" index="option">
                    <option value="#option.value#"<cfif attributes.params['#attributes.name#spacing'] eq option.value> selected</cfif>>#esapiEncode('html',option.name)#</option>
                </cfloop>
                <option value="custom"<cfif attributes.params['#attributes.name#spacing'] eq 'custom'> selected</cfif>>Custom</option>
            </select>
            <input name="#attributes.name#spacing" class="objectParam" type="hidden" value="#esapiEncode('html_attr',attributes.params['#attributes.name#spacing'])#">
        </cfif>
    </div>
</cfif>
<div class="mura-control-group flex-container-object breakpointtoggle" id="#attributes.name#layoutid" data-toggle="bp-tabs">
    <div class="bp-tabs">
        <cfloop list="xs,sm,md,lg,xl" index="size">
            <cfsilent>
                <cfif size eq 'xl'>
                    <cfset nameAndSize="#attributes.name#">
                <cfelse>
                    <cfset nameAndSize="#attributes.name#_#size#_">
                </cfif>
                
                <cfset targetStyles=attributes.params.stylesupport['#nameAndSize#styles']>
                <cfif targetStyles.marginleft eq targetStyles.marginRight
                    and targetStyles.marginleft eq targetStyles.marginTop
                    and targetStyles.marginleft eq targetStyles.marginBottom>
                    <cfset targetStyles.marginAll=targetStyles.marginleft>
                </cfif>

                <cfif targetStyles.paddingleft eq targetStyles.paddingRight
                    and targetStyles.paddingleft eq targetStyles.paddingTop
                    and targetStyles.paddingleft eq targetStyles.paddingBottom>
                    <cfset targetStyles.paddingAll=targetStyles.paddingleft>
                </cfif>

                <cfparam name="attributes.params.stylesupport.#nameAndSize#paddinguom" default="">
                <cfparam name="attributes.params.stylesupport.#nameAndSize#marginuom" default="">
                <cfparam name="attributes.params.stylesupport.#nameAndSize#minheightuom" default="">
            </cfsilent>
            <div class="bp-tab bp-tab-#size#<cfif size eq 'xl'> bp-current</cfif>" data-breakpoint="#size#" data-nameandsize="#nameAndSize#" style="display:<cfif size eq 'xl'>block<cfelse>none</cfif>;">        
                <div class="mura-control-group custom#attributes.name#spacing"<cfif not $.globalConfig().getValue(property='spacingdispenser',defaultValue=true) and arrayLen(request.spacingoptions) and attributes.params['#attributes.name#spacing'] neq 'custom'>style="display:none;"</cfif>>
                    <div class="mura-control-group mura-ui-grid">
                        <label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.margin'))#</label>
                    
                        <div class="row mura-ui-row">
                            <div class="col-xs-12 center">
                                <div class="mura-input-group">
                                    <label sclass="mura-serial">
                                        <input type="text" name="margin" id="#nameAndSize#marginall" class="numeric serial marginall" value="<cfif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].marginall))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].marginall))#</cfif>">
                                    </label>
                                    <select id="#nameAndSize#marginuom" name="#nameAndSize#marginuom" class="styleSupport">
                                        <cfloop list="#request.objectlayoutuom#" index="u">
                                            <option value="#u#"<cfif attributes.params.stylesupport['#nameAndSize#marginuom'] eq u or not len(attributes.params.styleSupport['#nameAndSize#marginuom']) and u eq request.preferreduom> selected</cfif>>#u#</option>
                                        </cfloop>
                                    </select>
                                <a class="btn ui-advanced mura-ui-link" data-reveal="#nameAndSize#marginadvanced" href="##"><i class="mi-arrows"></i></a>
                                </div>
                            </div>
                        </div>
                        <cfset hideAdvanced=(
                            attributes.params.stylesupport['#nameAndSize#styles'].margintop eq attributes.params.stylesupport['#nameAndSize#styles'].marginbottom
                            and attributes.params.stylesupport['#nameAndSize#styles'].margintop eq attributes.params.stylesupport['#nameAndSize#styles'].marginleft
                            and attributes.params.stylesupport['#nameAndSize#styles'].margintop eq attributes.params.stylesupport['#nameAndSize#styles'].marginright
                        )>
                        <div id="#nameAndSize#marginadvanced" class="mura-ui-inset" <cfif hideAdvanced>style="display: none;"</cfif>>
                            <div class="row mura-ui-row">
                                <div class="col-xs-3"></div>
                                <div class="col-xs-6">
                                    <label class="mura-serial">
                                        <input type="text" name="#nameAndSize#MarginTop" id="#nameAndSize#margintop" class="numeric serial margindimension" value="<cfif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].margintop))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].margintop))#</cfif>">
                                    </label>
                                    <input type="hidden" name="marginTop" id="#nameAndSize#margintopval" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].margintop)#">
                                </div>
                                <div class="col-xs-3"></div>
                            </div>
                    
                            <div class="row mura-ui-row">
                                <div class="col-xs-5">
                                        <div class="mura-input-group">
                                            <label class="mura-serial">
                                                <input type="text" name="#nameAndSize#MarginLeft" id="#nameAndSize#marginleft" class="numeric serial pull-right margindimension" value="<cfif  attributes.params.stylesupport['#nameAndSize#styles'].marginleft eq 'auto'>auto<cfelseif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].marginleft))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].marginleft))#</cfif>">
                                                <cfif attributes.name neq 'object'><a class="btn pull-right input-auto" data-auto-input="#nameAndSize#marginleft" href="##"><span>a</span></a></cfif>
                                            </label>
                                        </div>
                                    <input type="hidden" name="marginLeft" id="#nameAndSize#marginleftval" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].marginleft)#">
                                </div>
                                <div class="col-xs-2">
                                    <i class="mi-arrows ui-inset-icon"></i>
                                </div>
                                <div class="col-xs-5">
                                    <div class="mura-input-group">
                                        <label class="mura-serial">
                                            <input type="text" name="#nameAndSize#MarginRight" id="#nameAndSize#marginright" class="numeric serial pull-left margindimension" value="<cfif  attributes.params.stylesupport['#nameAndSize#styles'].marginright eq 'auto'>auto<cfelseif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].marginright))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].marginright))#</cfif>">
                                            <cfif attributes.name neq 'object'><a class="btn pull-left input-auto" data-auto-input="#nameAndSize#marginright" href="##"><span>a</span></a></cfif>
                                        </label>
                                    </div>
                                    <input type="hidden" name="marginRight" id="#nameAndSize#marginrightval" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].marginright)#">
                                </div>
                            </div>
                    
                            <div class="row mura-ui-row">
                                <div class="col-xs-3"></div>
                                <div class="col-xs-6">
                                    <label class="mura-serial">
                                        <input type="text" name="#nameAndSize#MarginBottom" id="#nameAndSize#marginbottom" class="numeric serial margindimension" value="<cfif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].marginbottom))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].marginbottom))#</cfif>">
                                    </label>
                                    <input type="hidden" name="marginBottom" id="#nameAndSize#marginbottomval" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].marginbottom)#">
                                </div>
                                <div class="col-xs-3"></div>
                            </div>
                        </div>
                    
                    </div>
                    
                    <!--- padding --->
                    <div class="mura-control-group mura-ui-grid">
                        <label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.padding'))#</label>
                        <div class="row mura-ui-row">
                            <div class="col-xs-12 center">
                                <div class="mura-input-group">
                                    <label class="mura-serial">
                                        <input type="text" name="padding" id="#nameAndSize#paddingall" class="numeric serial paddingall" value="<cfif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].paddingall))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].paddingall))#</cfif>">
                                    </label>
                                    <select id="#nameAndSize#paddinguom" name="#nameAndSize#paddinguom" class="styleSupport">
                                        <cfloop list="#request.objectlayoutuom#" index="u">
                                            <option value="#u#"<cfif attributes.params.styleSupport['#nameAndSize#paddinguom'] eq u or not len(attributes.params.styleSupport['#nameAndSize#paddinguom']) and u eq request.preferreduom> selected</cfif>>#u#</option>
                                        </cfloop>
                                    </select>
                                </div>
                                <a class="btn ui-advanced mura-ui-link" data-reveal="#nameAndSize#paddingadvanced" href="##"><i class="mi-arrows"></i></a>
                            </div>
                        </div>
                        
                        <cfset hideAdvanced=(
                            attributes.params.stylesupport['#nameAndSize#styles'].paddingtop eq attributes.params.stylesupport['#nameAndSize#styles'].paddingbottom
                            and attributes.params.stylesupport['#nameAndSize#styles'].paddingtop eq attributes.params.stylesupport['#nameAndSize#styles'].paddingleft
                            and attributes.params.stylesupport['#nameAndSize#styles'].paddingtop eq attributes.params.stylesupport['#nameAndSize#styles'].paddingright
                        )>
                        <div id="#nameAndSize#paddingadvanced" class="mura-ui-inset" <cfif hideAdvanced>style="display: none;"</cfif>>
                            <div class="row mura-ui-row">
                                <div class="col-xs-3"></div>
                                <div class="col-xs-6">
                                    <label class="mura-serial">
                                        <input type="text" name="#nameAndSize#PaddingTop" id="#nameAndSize#paddingtop" class="numeric serial paddingdimension" value="<cfif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].paddingtop))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].paddingtop))#</cfif>">
                                    </label>
                                    <input type="hidden" name="paddingTop" id="#nameAndSize#paddingtopval" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].paddingtop)#">
                                </div>
                                <div class="col-xs-3"></div>
                            </div>
                    
                            <div class="row mura-ui-row">
                                <div class="col-xs-1"></div>
                                <div class="col-xs-4">
                                    <label class="mura-serial">
                                        <input type="text" name="#nameAndSize#PaddingLeft" id="#nameAndSize#paddingleft" class="numeric serial pull-right paddingdimension" value="<cfif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].paddingleft))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].paddingleft))#</cfif>">
                                    </label>
                                    <input type="hidden" name="paddingLeft" id="#nameAndSize#paddingleftval" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].paddingleft)#">
                                </div>
                                <div class="col-xs-2">
                                    <i class="mi-arrows ui-inset-icon"></i>
                                </div>
                                <div class="col-xs-4">
                                    <label class="mura-serial">
                                        <input type="text" name="#nameAndSize#PaddingRight" id="#nameAndSize#paddingright" class="numeric serial pull-left paddingdimension" value="<cfif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].paddingright))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].paddingright))#</cfif>">
                                    </label>
                                    <input type="hidden" name="paddingRight" id="#nameAndSize#paddingrightval" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].paddingright)#">
                                </div>
                                <div class="col-xs-1"></div>
                            </div>
                    
                            <div class="row mura-ui-row">
                                <div class="col-xs-3"></div>
                                <div class="col-xs-6">
                                    <label class="mura-serial">
                                        <input type="text" name="#nameAndSize#PaddingBottom" id="#nameAndSize#paddingbottom" class="numeric serial paddingdimension" value="<cfif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].paddingbottom))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].paddingbottom))#</cfif>">
                                    </label>
                                    <input type="hidden" name="paddingBottom" id="#nameAndSize#paddingbottomval" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].paddingbottom)#">
                                </div>
                                <div class="col-xs-3"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <cfif attributes.name eq 'content' or not request.hasFixedWidth>
                    <cfif attributes.params.object neq 'container'>
                        <div class="mura-control-group">
                            <label>Text Alignment</label>
                            <select name="#nameAndSize#TextAlign" data-param="textAlign" class="#nameAndSize#Style">
                                <option value="">--</option>
                                <option value="left"<cfif attributes.params.stylesupport['#nameAndSize#styles'].textalign eq 'left'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.left')#</option>
                                <option value="right"<cfif attributes.params.stylesupport['#nameAndSize#styles'].textalign eq 'right'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.right')#</option>
                                <option value="center"<cfif attributes.params.stylesupport['#nameAndSize#styles'].textalign eq 'center'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.center')#</option>
                                <option value="justify"<cfif attributes.params.stylesupport['#nameAndSize#styles'].textalign eq 'justify'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.justify')#</option>
                            </select>
                        </div>
                    </cfif>
                    <!--- If the module is a container this toggle visible if is block---> 
                    <cfset useSlider=false>
                    <cfset widthNum=val(attributes.params.stylesupport['#nameAndSize#styles'].width)>
                    <!--- slider ui is experimental and causes each device target to need to be explicitly sized instead of being able to inherit from the next size up if not set --->
                    <div class="mura-control-group" <cfif request.hasFixedWidth and attributes.params.object eq 'container'> style="display:none;"</cfif>>
                        <label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.width'))#<cfif useSlider and attributes.name eq 'object'> (<span id="#nameAndSize#widthlabel"><cfif widthNum>#widthNum#%<cfelse>Unset</cfif></span>)</cfif></label>
                        <div class="row mura-ui-row">
                            <cfparam name="attributes.params.stylesupport.#nameAndSize#widthuom" default="">
                            <cfparam name="attributes.params.stylesupport.#nameAndSize#styles.width" default="">
                            <cfif not len(attributes.params.stylesupport['#nameAndSize#widthuom'])
                                and len(attributes.params.stylesupport['#nameAndSize#styles'].width)>
                                <cfset attributes.params.stylesupport['#nameAndSize#widthuom']=reReplace(attributes.params.stylesupport['#nameAndSize#styles'].width,"[^a-z%]","","all")>
                            </cfif>
                            
                            <cfif useSlider and attributes.name eq 'object'>
                                <div class="mura-control-group">
                                <label class="mura-serial">
                                    <input type="range" min="0" max="100" step="8.333333333333333" name="#nameAndSize#width" id="#nameAndSize#widthnum" style="width:100%" class="numeric serial widthnum" value="#widthNum#">
                                </label>
                                <input type="hidden" id="#nameAndSize#widthuom" name="#nameAndSize#widthuom" class="widthuom" value="%">
                                </div>
                                <input type="hidden" name="width" id="#nameAndSize#widthuomval" class="#nameAndSize#Style widthuomval" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].width)#">
                                <script>
                                    jQuery('###nameAndSize#widthnum').on('change',function(){
                                        if(this.value==='0'){
                                            jQuery('###nameAndSize#widthlabel').html('Unset');
                                        } else {
                                            jQuery('###nameAndSize#widthlabel').html(parseInt(this.value) + '%');
                                        }   
                                    })
                                </script>
                            <cfelse>
                                <div class="mura-input-group">
                                    <label class="mura-serial">
                                        <input type="text" name="#nameAndSize#width" id="#nameAndSize#widthnum" class="numeric serial widthnum" value="<cfif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].width))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].width))#</cfif>">
                                    </label>
                                    <select id="#nameAndSize#widthuom" name="#nameAndSize#widthuom" class="widthuom">
                                        <cfloop list="#request.objectlayoutuomext#" index="u">
                                            <option value="#u#"<cfif attributes.params.stylesupport['#nameAndSize#widthuom'] eq u> selected</cfif>>#u#</option>
                                        </cfloop>
                                    </select>
                                </div>
                                <input type="hidden" name="width" id="#nameAndSize#widthuomval" class="#nameAndSize#Style widthuomval" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].width)#">
                            </cfif>
                        </div>
                    </div>
                </cfif>
                <div class="mura-control-group">
                    <label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.minimumheight'))#</label>
                    <cfparam name="attributes.params.stylesupport.#nameAndSize#minheightuom" default="">
                    <cfparam name="attributes.params.stylesupport.#nameAndSize#styles.minheight" default="">
                    <cfif not len(attributes.params.stylesupport['#nameAndSize#minheightuom'])
                        and len(attributes.params.stylesupport['#nameAndSize#styles'].minheight)>
                        <cfset attributes.params.stylesupport['#nameAndSize#minheightuom']=reReplace(attributes.params.stylesupport['#nameAndSize#styles'].minheight,"[^a-z%]","","all")>
                    </cfif>
                    <div class="row mura-ui-row">
                        <div class="mura-input-group">
                            <label class="mura-serial">
                                <input type="text" name="#nameAndSize#minheight" id="#nameAndSize#minheightnum" class="numeric serial minheightnum" value="<cfif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].minheight))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].minheight))#</cfif>">
                            </label>
                            <select id="#nameAndSize#minheightuom" class="minheightuom" name="#nameAndSize#minheightuom">
                                <cfloop list="#request.objectlayoutuomext#" index="u">
                                    <option value="#u#"<cfif attributes.params.stylesupport['#nameAndSize#minheightuom'] eq u or not len(attributes.params.styleSupport['#nameAndSize#minheightuom']) and u eq request.preferreduom> selected</cfif>>#u#</option>
                                </cfloop>
                            </select>
                        </div>
                        <input type="hidden" name="minHeight" id="#nameAndSize#minheightuomval" class="#nameAndSize#Style minheightuomval" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].minheight)#">
                    </div>
                </div>
                <!---
                <label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.maximumheight'))#</label>
                <cfparam name="attributes.params.stylesupport.#nameAndSize#maxheightuom" default="">
                <cfparam name="attributes.params.stylesupport.#nameAndSize#styles.maxheight" default="">
                <cfif not len(attributes.params.stylesupport['#nameAndSize#maxheightuom'])
                    and len(attributes.params.stylesupport['#nameAndSize#styles'].maxheight)>
                    <cfset attributes.params.stylesupport['#nameAndSize#maxheightuom']=reReplace(attributes.params.stylesupport['#nameAndSize#styles'].maxheight,"[^a-z%]","","all")>
                </cfif>
                <div class="row mura-ui-row">
                    <div class="mura-input-group">
                        <label class="mura-serial">
                            <input type="text" name="#nameAndSize#maxheight" id="#nameAndSize#maxheightnum" class="numeric serial maxheightnum" value="<cfif len(trim(attributes.params.stylesupport['#nameAndSize#styles'].maxheight))>#val(esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].maxheight))#</cfif>">
                        </label>
                        <select id="#nameAndSize#maxheightuom" class="maxheightuom" name="#nameAndSize#maxheightuom">
                            <cfloop list="#request.objectlayoutuomext#" index="u">
                                <option value="#u#"<cfif attributes.params.stylesupport['#nameAndSize#maxheightuom'] eq u or not len(attributes.params.styleSupport['#nameAndSize#maxheightuom']) and u eq request.preferreduom> selected</cfif>>#u#</option>
                            </cfloop>
                        </select>
                    </div>
                    <input type="hidden" name="maxHeight" id="#nameAndSize#maxheightuomval" class="#nameAndSize#Style maxheightuomval" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].maxheight)#">
                </div>
                --->
                  <!--- text alignment --->
                  <cfset initialDisplay=attributes.params.stylesupport['#nameAndSize#Styles'].display>
                  <cfif attributes.name neq 'meta'> 
                    <cfif attributes.params.object eq 'container' and  attributes.name eq "content">
                        <!--- How to display the contents of the container --->
                        <div class="mura-control-group">
                            <label>Display</label>
                            <select class="displaymodel">
                                <cfif size neq 'xl'><option value="">--</option></cfif>
                                <option value="flex"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].display eq 'flex' or size eq 'xl' and not len(attributes.params.stylesupport['#nameAndSize#Styles'].display)> selected</cfif>>flex</option>
                                <option value="block"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].display eq 'block'> selected</cfif>>block</option>
                                <option value="grid"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].display eq 'grid'> selected</cfif>>grid</option>
                            </select>
                            <input type="hidden" name="display" class="#nameAndSize#Style" value="#esapiEncode('html_attr', attributes.params.stylesupport['#nameAndSize#Styles'].display)#">
                        </div>
                    </cfif>
                    <!--- How to place itself within a block, grid or flex container --->
                    <cfif attributes.name eq "object">
                        <cfif request.cssdisplay eq 'block'>
                            <div class="mura-control-group float-container-#nameAndSize# float-control-#nameAndSize#">
                                <label>Float</label>
                                <select name="#nameAndSize#Float" data-param="float" class="#nameAndSize#Style">
                                <option value="">--</option>
                                <option value="left"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].float eq 'left' or listFind(attributes.params.class,'mura-left',' ')> selected</cfif>>left</option>
                                <option value="right"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].float eq 'right' or listFind(attributes.params.class,'mura-right',' ')> selected</cfif>>right</option>
                                <!---<option value="none"<cfif attributes.params.stylesupport.objectStyles.float eq 'none'> selected</cfif>>none</option>--->
                                </select>
                            </div>
                        <cfelseif request.cssdisplay eq 'grid'>
                            <!--- 
                                Grid items on item in container:
                                grid-column-start
                                grid-column-end
                                grid-row-start
                                grid-row-end
                                grid-column
                                grid-row
                                grid-area
                                justify-self
                                align-self
                                place-self
                            --->
                            <div class="mura-control-group grid-container-#nameAndSize# grid-control-#nameAndSize#">
                                <cfset gridColumnNum=val(listLast(listLast(attributes.params.stylesupport['#nameAndSize#styles'].gridColumn,'/'),' '))>
                                <label>Grid Column Span ( <span class="labeledUnits" data-default="Unset" id="#nameAndSize#gridlColumnLabel"><cfif gridColumnNum>#gridColumnNum#<cfelse>Unset</cfif></span> )</label>
                                <input type="range" min="0" max="12" step="1" name="#nameAndSize#gridColumnSelector" id="#nameAndSize#gridColumnSelector" style="width:100%" class="numeric serial" value="#gridColumnNum#">
                                <input type="hidden" name="gridColumn" id="#nameAndSize#gridColumn" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].gridColumn)#">
                            </div>
                            <script>
                                jQuery('###nameAndSize#gridColumnSelector').on('change',function(){
                                    var translatedVal='';
                                    if(this.value==='0'){
                                        jQuery('###nameAndSize#gridlColumnLabel').html('Unset');    
                                    } else {
                                        jQuery('###nameAndSize#gridlColumnLabel').html(this.value);
                                        translatedVal=' auto / span ' + parseInt(this.value);
                                    }   
                                    jQuery('###nameAndSize#gridColumn').val(translatedVal).trigger('change');
                                })
                            </script>
                            <div class="mura-control-group grid-container-#nameAndSize# grid-control-#nameAndSize#">
                                <label><a class="mura-external-link" href="https://developer.mozilla.org/en-US/docs/Web/CSS/justify-self" target="_moz">Justify Self <i class="mi-question-circle"></i></a></label>
                                <select name="#nameAndSize#JustifySelf" data-param="justifySelf" class="#nameAndSize#Style">
                                    <option value="">--</option>
                                    <option value="start"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].justifySelf eq 'start'> selected</cfif>>Left (start)</option>
                                    <option value="end"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].justifySelf eq 'end'> selected</cfif>>Right (end)</option>
                                    <option value="stretch"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].justifySelf eq 'stretch'> selected</cfif>>Stretch</option>
                                    <option value="center"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].justifySelf eq 'center'> selected</cfif>>Center</option>
                                </select>
                            </div>
                            <div class="mura-control-group grid-container-#nameAndSize# grid-control-#nameAndSize#">
                                <label><a class="mura-external-link" href="https://developer.mozilla.org/en-US/docs/Web/CSS/align-self" target="_moz">Align Self <i class="mi-question-circle"></i></a></label>
                                <select name="#nameAndSize#AlignSelf" data-param="alignSelf" class="#nameAndSize#Style">
                                    <option value="">--</option>
                                    <option value="start"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].alignSelf eq 'start'> selected</cfif>>Top (start)</option>
                                    <option value="end"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].alignSelf eq 'end'> selected</cfif>>Bottom (end)</option>
                                    <option value="stretch"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].alignSelf eq 'stretch'> selected</cfif>>Stretch</option>
                                    <option value="center"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].alignSelf eq 'center'> selected</cfif>>Center</option>
                                </select>
                            </div>
                            <div class="mura-control-group grid-container-#nameAndSize# grid-control-#nameAndSize#">
                                <label><a class="mura-external-link" href="https://developer.mozilla.org/en-US/docs/Web/CSS/place-self" target="_moz">Place Self <i class="mi-question-circle"></i></a></label>
                                <input type="text" name="placeSelf" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].placeSelf)#">
                            </div>
                            
                      
                        <cfelse>
                            <div class="mura-control-group flex-container-#nameAndSize# flex-control-#nameAndSize#">
                                <label><a class="mura-external-link" href="https://developer.mozilla.org/en-US/docs/Web/CSS/align-self" target="_moz">Align Self <i class="mi-question-circle"></i></a></label>
                                <select name="#nameAndSize#AlignSelf" data-param="alignSelf" class="#nameAndSize#Style">
                                    <option value="">--</option>
                                    <option value="flex-start"<cfif listFindNoCase('flex-start,start',attributes.params.stylesupport['#nameAndSize#Styles'].alignSelf)> selected</cfif>>Top (flex-start)</option>
                                    <option value="flex-end"<cfif listFindNoCase('flex-end,end',attributes.params.stylesupport['#nameAndSize#Styles'].alignSelf)> selected</cfif>>Bottom (flex-end)</option>
                                    <option value="stretch"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].alignSelf eq 'stretch'> selected</cfif>>Stretch</option>
                                    <option value="center"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].alignSelf eq 'center'> selected</cfif>>Center</option>
                                    <option value="baseline"<cfif attributes.params.stylesupport['#nameAndSize#Styles'].alignSelf eq 'baseline'> selected</cfif>>Baseline</option>
                                </select>
                            </div>
                        </cfif>
                    </cfif>
                </cfif>

                <cfif attributes.params.object eq 'container'>
                    <cfif attributes.name eq 'content'>
                        <!---
                            FLEX items on container:
                        --->
                        <div class="mura-control-group flex-control-#nameAndSize#" style="<cfif initialDisplay neq 'flex'>display:none;</cfif>">
                            <label><a class="mura-external-link" href="https://developer.mozilla.org/en-US/docs/Web/CSS/justify-content" target="_moz">Justify Content <i class="mi-question-circle"></i></a></label>
                            <select name="justifyContent" class="#nameAndSize#Style">
                                <option value="">--</option>
                                <option value="flex-start"<cfif listFindNoCase('flex-start,start',attributes.params.stylesupport['#nameAndSize#styles'].justifyContent)> selected</cfif>>Left (flex-start)</option>
                                <option value="flex-end"<cfif listFindNoCase('flex-end,end',attributes.params.stylesupport['#nameAndSize#styles'].justifyContent)> selected</cfif>>Right (flex-end)</option>
                                <option value="center"<cfif attributes.params.stylesupport['#nameAndSize#styles'].justifyContent eq 'center'> selected</cfif>>Center</option>
                                <option value="space-between"<cfif attributes.params.stylesupport['#nameAndSize#styles'].justifyContent eq 'space-between'> selected</cfif>>Distribute Space Between</option>
                                <option value="space-around"<cfif attributes.params.stylesupport['#nameAndSize#styles'].justifyContent eq 'space-around'> selected</cfif>>Distribute Space Around</option>
                                <option value="space-evenly"<cfif attributes.params.stylesupport['#nameAndSize#styles'].justifyContent eq 'justify'> selected</cfif>>Space Evenly</option>
                            </select>
                        </div>
                        <!--- text alignment --->
                        <div class="mura-control-group flex-control-#nameAndSize#" style="<cfif  initialDisplay neq 'flex'>display:none;</cfif>">
                            <label><a class="mura-external-link" href="https://developer.mozilla.org/en-US/docs/Web/CSS/align-items" target="_moz">Align Items <i class="mi-question-circle"></i></a></label>
                            <select name="alignItems" class="#nameAndSize#Style">
                                <option value="">--</option>
                                <option value="flex-start"<cfif listFindNoCase('flex-start,start',attributes.params.stylesupport['#nameAndSize#Styles'].alignItems)> selected</cfif>>Top (flex-start)</option>
                                <option value="flex-end"<cfif listFindNoCase('flex-end,end',attributes.params.stylesupport['#nameAndSize#Styles'].alignItems)> selected</cfif>>Bottom (flex-end)</option>
                                <option value="center"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignItems eq 'center'> selected</cfif>>Center</option>
                                <option value="stretch"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignItems eq 'stretch'> selected</cfif>>Stretch</option>
                                <option value="baseline"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignItems eq 'baseline'> selected</cfif>>Baseline</option>
                            </select>
                        </div>

                        <div class="mura-control-group flex-control-#nameAndSize#" style="<cfif initialDisplay neq 'flex'>display:none;</cfif>">
                            <label><a class="mura-external-link" href="https://developer.mozilla.org/en-US/docs/Web/CSS/align-content" target="_moz">Align Content <i class="mi-question-circle"></i></a></label>
                            <select name="alignContent" class="#nameAndSize#Style">
                                <option value="">--</option>
                                <option value="flex-start"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'flex-start'> selected</cfif>>Top (flex-start)</option>
                                <option value="flex-end"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'flex-end'> selected</cfif>>Bottom (flex-end)</option>
                                <option value="center"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'center'> selected</cfif>>Center</option>
                                <option value="stretch"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'stretch'> selected</cfif>>Stretch</option>
                                <cfif attributes.name eq 'content'>
                                    <option value="space-between"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'space-between'> selected</cfif>>Distribute Space Between</option>
                                    <option value="space-around"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'space-around'> selected</cfif>>Distribute Space Around</option>
                                </cfif>  
                            </select>
                        </div>

                        <!---
                            GRID items on container:
                            grid-template-columns
                            grid-template-rows
                            grid-template-areas
                            grid-template
                            grid-column-gap
                            grid-row-gap
                            grid-gap
                            justify-items
                            align-items
                            place-items
                            justify-content
                            align-content
                            place-content
                            grid-auto-columns
                            grid-auto-rows
                            grid-auto-flow
                            grid
                        --->
                            <div class="mura-control-group grid-control-#nameAndSize#" style="<cfif initialDisplay neq 'grid'>display:none;</cfif>">
                                <cfset gridNum=val(listLast(listFirst(attributes.params.stylesupport['#nameAndSize#styles'].grid),'('))>
                                <cfif nameAndSize eq 'content' and not gridNum>
                                    <cfset gridNum=1>
                                </cfif>
                                <label>Grid Columns ( <span class="labeledUnits" id="#nameAndSize#gridlabel" data-default="#gridNum#"> <cfif gridNum>#gridNum#<cfelse>Unset</cfif></span> )</label>
                                <input type="range" min=<cfif nameAndSize eq 'content'>"1"<cfelse>"0"</cfif> max="12" step="1" name="#nameAndSize#gridSelector" id="#nameAndSize#gridSelector" style="width:100%" class="numeric serial" value="#gridNum#">
                                <input type="hidden" data-default="auto-flow / repeat(1,1fr)"  name="grid" id="#nameAndSize#grid" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].grid)#">
                            </div>
                            <script>
                                jQuery('###nameAndSize#gridSelector').on('change',function(){
                                    var translatedVal='';
                                    if(this.value==='0'){
                                        jQuery('###nameAndSize#gridlabel').html('Unset');    
                                    } else {
                                        jQuery('###nameAndSize#gridlabel').html(' ' + parseInt(this.value) + ' ');
                                        translatedVal='auto-flow / repeat(' + this.value + ', 1fr)';
                                    }   
                                    jQuery('###nameAndSize#grid').val(translatedVal).trigger('change');
                                })
                            </script>
                            <div class="mura-control-group grid-control-#nameAndSize#" style="<cfif initialDisplay neq 'grid'>display:none;</cfif>">
                                <cfset gridColumnGapNum=val(attributes.params.stylesupport['#nameAndSize#styles'].gridColumnGap)>
                                <label>Grid Column Gap ( <span class="labeledUnits" data-default="Unset" id="#nameAndSize#gridlColumnGapLabel"><cfif gridColumnGapNum>#gridColumnGapNum#rem<cfelse>Unset</cfif></span> )</label>
                                <input type="range" min="0" max="12" step="1" name="#nameAndSize#gridColumnGapSelector" id="#nameAndSize#gridColumnGapSelector" style="width:100%" class="numeric serial" value="#gridColumnGapNum#">
                                <input type="hidden" name="gridColumnGap" id="#nameAndSize#gridColumnGap" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].gridColumnGap)#">
                            </div>
                            <script>
                                jQuery('###nameAndSize#gridColumnGapSelector').on('change',function(){
                                    var translatedVal='';
                                    if(this.value==='0'){
                                        jQuery('###nameAndSize#gridlColumnGapLabel').html('Unset');    
                                    } else {
                                        jQuery('###nameAndSize#gridlColumnGapLabel').html(' ' + parseInt(this.value) + 'rem ');
                                        translatedVal=this.value + 'rem';
                                    }   
                                    jQuery('###nameAndSize#gridColumnGap').val(translatedVal).trigger('change');
                                })
                            </script>
                            <div class="mura-control-group grid-control-#nameAndSize#" style="<cfif initialDisplay neq 'grid'>display:none;</cfif>">
                                <cfset gridRowGapNum=val(attributes.params.stylesupport['#nameAndSize#styles'].gridRowGap)>
                                <label>Grid Row Gap ( <span class="labeledUnits" data-default="Unset" id="#nameAndSize#gridlRowGapLabel"> <cfif gridRowGapNum>#gridRowGapNum#rem<cfelse>Unset</cfif></span> )</label>
                                <input type="range" min="0" max="12" step="1" name="#nameAndSize#gridRowGapSelector" id="#nameAndSize#gridRowGapSelector" style="width:100%" class="numeric serial" value="#gridRowGapNum#">
                                <input type="hidden" name="gridRowGap" id="#nameAndSize#gridRowGap" class="#nameAndSize#Style" value="#esapiEncode('html_attr',attributes.params.stylesupport['#nameAndSize#styles'].gridRowGap)#">
                            </div>
                            <script>
                                jQuery('###nameAndSize#gridRowGapSelector').on('change',function(){
                                    var translatedVal='';
                                    if(this.value==='0'){
                                        jQuery('###nameAndSize#gridlRowGapLabel').html('Unset');    
                                    } else {
                                        jQuery('###nameAndSize#gridlRowGapLabel').html(' ' + parseInt(this.value) + 'rem ');
                                        translatedVal=this.value + 'rem';
                                    }   
                                    jQuery('###nameAndSize#gridRowGap').val(translatedVal).trigger('change');
                                })
                            </script>
                    </cfif>
                </cfif>	

                 <!--- How to place module's meta and content elements --->
                <cfif attributes.name eq 'object'>
                    <div class="mura-control-group">
                        <label><a class="mura-external-link" href="https://developer.mozilla.org/en-US/docs/Web/CSS/align-content" target="_moz">Align Content <i class="mi-question-circle"></i></a></label>
                        <select name="alignContent" class="#nameAndSize#Style">
                            <option value="">--</option>
                            <option value="flex-start"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'flex-start'> selected</cfif>>Top (flex-start)</option>
                            <option value="flex-end"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'flex-end'> selected</cfif>>Bottom (flex-end)</option>
                            <option value="center"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'center'> selected</cfif>>Center</option>
                            <option value="stretch"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'stretch'> selected</cfif>>Stretch</option>
                            <cfif attributes.name eq 'content'>
                                <option value="space-between"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'space-between'> selected</cfif>>Distribute Space Between</option>
                                <option value="space-around"<cfif attributes.params.stylesupport['#nameAndSize#styles'].alignContent eq 'space-around'> selected</cfif>>Distribute Space Around</option>
                            </cfif>  
                        </select>
                    </div>
                </cfif>
            </div>
        </cfloop>
    </div>
</div>
</cfoutput>

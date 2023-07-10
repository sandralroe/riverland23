<cfimport prefix="ui" taglib="../../../mura/customtags/configurator/ui">
<cfscript>

    personaOptions=[];
    
    if(Mura.getServiceFactory().containsBean('persona')){
        
        personas=Mura.getFeed('persona').getIterator();

        if(personas.hasNext()){
            while(personas.hasNext()){
                persona=personas.next();
                arrayAppend(
                    personaOptions,
                    {
                        name=persona.get('name'),
                        value=persona.get('personaid')
                    }
                );
            }
        }
    }

    categories=Mura.getFeed('category')
        .where()
        //.prop('isInterestGroup').isEQ(1)
        .sort('filename')
        .getIterator();

    categoryOptions=[];
 
    if(categories.hasNext()){
        while(categories.hasNext()){
            category=categories.next();
            arrayAppend(
                categoryOptions,
                {
                    name=category.get('filename'),
                    value=category.get('categoryid')
                }
            );
        }
    }

    rsSubTypes=application.classExtensionManager.getSubTypes(siteID=rc.siteID,activeOnly=true);

    rs=queryExecute("select * from rsSubTypes where type in ('Page','Link','File')",{},{dbtype="query"});

    subtypeOptions=[];
    for(type in ['Page','Link','File']){
        //arrayAppend(subtypeOptions,{name=type,value='#type#'});
        rs=queryExecute("select * from rsSubTypes where type = :type",{type={cfssqltype="varchar",value=type}},{dbtype="query"});
        if(rs.recordcount){
            for(row=1;row<=rs.recordcount;row++){
                if(rs.subtype[row] != 'Default' && !arrayFind(subtypeOptions,rs.subtype[row])){
                    arrayAppend(subtypeOptions,{name='#rs.subtype[row]#',value=rs.subtype[row]});
                }  
            }
        }
    }
    // var content=rc.$.getBean('content').loadBy(contenthistid=rc.contenthistid);

    param name="objectparams.personaids" default="";
    param name="objectparams.categoryids" default="";
    param name="objectparams.subtypes" default="";
    param name="objectparams.showtextsearch" default="true";
    param name="objectparams.sortBy" default="releaseDate";
    param name="objectparams.sortDirection" default="desc";
</cfscript>
<cf_objectconfigurator>
    <cfif arrayLen(personaOptions)>
        <ui:dispenser name="personaids" label="Personas" options="#personaOptions#" value="#objectparams.personaids#">
    </cfif>
    <cfif arrayLen(categoryOptions)>
        <ui:dispenser name="categoryids" label="Categories" options="#categoryOptions#" value="#objectparams.categoryids#">
    </cfif>
    <ui:dispenser name="subtypes" label="Content Types" options="#subtypeOptions#" value="#objectparams.subtypes#">
    <cfif !Mura.getContentRenderer().ssr>
        <cfoutput>
        <div class="mura-control-group">
            <label class="mura-control-label">Show Text Search?</label>
            <select name="showtextsearch" data-displayobjectparam="modalimages" class="objectParam">
                <cfloop list="True,False" index="i">
                    <option value="#lcase(i)#"<cfif objectparams.showtextsearch eq i> selected</cfif>>#i#</option>
                </cfloop>
            </select>
        </div>
        </cfoutput>
    </cfif>
    <cfoutput>
    <div class="mura-control-group">
        <label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'collections.sortby')#</label>
        <select name="sortby"class="objectParam">
            <option value="orderno" <cfif objectparams.sortBy eq 'orderno'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.manual")#</option>
            <option value="releaseDate" <cfif objectparams.sortBy eq 'releaseDate'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.releasedate")#</option>
            <option value="lastUpdate" <cfif objectparams.sortBy eq 'lastUpdate'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.updatedate")#</option>
            <option value="created" <cfif objectparams.sortBy eq 'created'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.created")#</option>
            <option value="menuTitle" <cfif objectparams.sortBy eq 'menuTitle'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.menutitle")#</option>
            <option value="title" <cfif objectparams.sortBy eq 'title'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.longtitle")#</option>
            <option value="rating" <cfif objectparams.sortBy eq 'rating'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.rating")#</option>
            <cfif rc.$.getServiceFactory().containsBean('marketingManager')>
                <option value="mxpRelevance" <cfif objectparams.sortBy eq 'mxpRelevance'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.mxpRelevance')#</option>
            </cfif>
            <cfif isBoolean(application.settingsManager.getSite(session.siteid).getHasComments()) and application.settingsManager.getSite(session.siteid).getHasComments()>
                <option value="comments" <cfif objectparams.sortBy eq 'comments'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.comments")#</option>
            </cfif>
            <cfset rsExtend=application.configBean.getClassExtensionManager().getExtendedAttributeList(rc.siteid)>
            <cfloop query="rsExtend">
            <option value="#esapiEncode('html_attr',rsExtend.attribute)#" <cfif objectparams.sortBy eq rsExtend.attribute>selected</cfif>>#esapiEncode('html',rsExtend.Type)#/#esapiEncode('html',rsExtend.subType)# - #esapiEncode('html',rsExtend.attribute)#</option>
            </cfloop>
        </select>
    </div>
    <div class="mura-control-group">
        <label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'collections.sortdirection')#</label>
        <select name="sortdirection" class="objectParam">
            <option value="asc" <cfif objectparams.sortDirection eq 'asc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.ascending")#</option>
            <option value="desc" <cfif objectparams.sortDirection eq 'desc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.descending")#</option>
        </select>
    </div>
</cfoutput>
    <div class="mura-layout-row" id="layoutcontainer">
    </div>

    <!--- Include global config object options --->
    <cfinclude template="#$.siteConfig().lookupDisplayObjectFilePath('object/configurator.cfm')#">
        
    <cfoutput>
    <script>
        $(function(){

            setLayoutOptions=function(){
                $('input[name="layout"]').val($('##layoutSel').val());
                siteManager.updateAvailableObject();
                siteManager.availableObject.params.source = siteManager.availableObject.params.source || '';

                var params=siteManager.availableObject.params;

                params.layout=params.layout || 'default';

                //console.log(params)

                $.ajax(
                    {
                        type: 'post',
                        dataType: 'text',
                    url: './?muraAction=cArch.loadclassconfigurator&compactDisplay=true&siteid=' + configOptions.siteid + '&instanceid=#esapiEncode("url",rc.instanceid)#&classid=collection&contentid=' + contentid + '&parentid=' + configOptions.parentid + '&contenthistid=' + configOptions.contenthistid + '&regionid=' + configOptions.regionid + '&objectid=' + configOptions.objectid + '&contenttype=' + configOptions.contenttype + '&contentsubtype=' + configOptions.contentsubtype + '&container=layout&cacheid=' + Math.random(),

                    data:{params:encodeURIComponent(JSON.stringify(params))},
                    success:function(response){
                        $('##layoutcontainer').html(response);
                        
                        $('.mura ##configurator select').each(function(){
                            var self=$(this);
                            self.addClass('ns-' + self.attr('name')).niceSelect();
                        });
                        $('##layoutcontainer .mura-file-selector').fileselector();
                    }
                })
            }

    
            setLayoutOptions();
        

        });
    </script>
    </cfoutput>
</cf_objectconfigurator>
 
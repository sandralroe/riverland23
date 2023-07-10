<cfscript>
    param name="attributes.label" default='My Fieldlist';
    param name="attributes.name" default='fieldlist';
    param name="attributes.value" default='';
    param name="attributes.condition" default="";
    //param name="attributes.options" default=[{name='Title',value='title'},{name='Image',value='image'},{name='Custom',value='custom'}];
    param name="attributes.options" default=[];
    param name="attributes.default" default='Image,Date,Title,Summary,Credits,Tags';
    if(!len(attributes.value)){
        attributes.value=attributes.default;
    }

    attributes.fieldoptions='';
    attributes.fieldoptionlabels='';

    if(arraylen(attributes.options)){
        attributes.fieldoptions='';
        attributes.fieldoptionslabels='';
        for(i=1;i<=arrayLen(attributes.options);i++){
            if(isSimpleValue(attributes.options[i])){
                attributes.fieldoptions=listAppend(attributes.fieldoptions,attributes.options[i]);
                attributes.fieldoptionlabels=listAppend(attributes.fieldoptionlabels,attributes.options[i]);
            } else {
                attributes.fieldoptions=listAppend(attributes.fieldoptions,attributes.options[i].name);
                attributes.fieldoptionlabels=listAppend(attributes.fieldoptionlabels,attributes.options[i].value);
            }

        }

        valueArray=listToArray(attributes.value);;
        attributes.value='';
        for(i=1;i<=arrayLen(valueArray);i++){
            if(listFindNoCase(attributes.fieldoptions, valueArray[i])){
                attributes.value=listAppend(attributes.value,valueArray[i]);
            }
        }
    }
    if(attributes.fieldoptions==attributes.fieldoptionlabels){
        fieldoptionstring="&fieldoptions=#esapiEncode('url',attributes.fieldoptions)#";
    } else {
        fieldoptionstring="&fieldoptions=#esapiEncode('url',attributes.fieldoptions)#&fieldoptionlabels=#esapiEncode('url',attributes.fieldoptionlabels)#";
    }
</cfscript>
<cfoutput>

    <div class="mura-control-group" id="availableFields"<cfif len(attributes.condition)> data-condition="#esapiEncode('html_attr',attributes.condition)#" style="display:none;"</cfif>>
        <label>
            <div>#esapiEncode('html_attr',attributes.label)#</div>
            <button id="editFields" class="btn"><i class="mi-pencil"></i> #application.rbFactory.getKeyValue(session.rb,'collections.edit')#</button>
        </label>

        <div id="sortableFields" class="sortable-sidebar">
            <ul id="displayListSort" class="displayListSortOptions">
                <cfloop list="#attributes.value#" index="i">
                    <li class="ui-state-highlight">#trim(i)#</li>
                </cfloop>
            </ul>
            <input type="hidden" id="displaylist" class="objectParam" value="#esapiEncode('html_attr',attributes.value)#" name="#esapiEncode('html_attr',attributes.name)#"  data-displayobjectparam="#esapiEncode('html_attr',attributes.name)#"/>
        </div>
    </div>

    <script>
        $(function(){
            $('##editFields').click(function(){
                frontEndProxy.post({
                    cmd:'openModal',
                    src:'?muraAction=cArch.selectfields&siteid=#esapiEncode("url",attributes.siteid)#&contenthistid=#esapiEncode("url",attributes.contenthistid)#&instanceid=#esapiEncode("url",attributes.instanceid)#&compactDisplay=true&paramname=#esapiEncode('url',attributes.name)#&displaylist=' + $("##displaylist").val()  + '#fieldoptionstring#'
                    }
                );
            });
    
            $("##displayListSort").sortable({
                update: function(event) {
                    event.stopPropagation();
                    $("##displaylist").val("");
                    $("##displayListSort > li").each(function() {
                        var current = $("##displaylist").val();
    
                        if(current != '') {
                            $("##displaylist").val(current + "," + $(this).html());
                        } else {
                            $("##displaylist").val($(this).html());
                        }
                    });
    
                    updateDraft();
                }
            }).disableSelection();           
        });
    </script>
</cfoutput>
<cfif this.SSR>
    <cfoutput>
        <div id="exp-selected-confirmation">
            <div>
                <div>
                    Thank you!
                </div>
                <div>Your experience is being updated!</div>
                <div>#this.preloaderMarkup#</div>
            </div>
        </div>
    </cfoutput>
    <cfscript>
        param name="objectparams.selfidstart" default="I am a";
        param name="objectparams.selfidmiddle" default="who";
        param name="objectParams.selfidend" default="your product.";
        param name="objectParams.displayType" default="inline";
        param name="objectParams.customlinks" default="";
        param name="objectParams.mode" default="preview only";

        stages=m.getFeed('stage').where().prop('selfidq').isNEQ('null').getIterator();
        personas=m.getFeed('persona').where().prop('selfidq').isNEQ('null').getIterator();
        hasStageOrPersona=(len(m.mxp.getTrackingProperty(property='stageid')) or len(m.mxp.getTrackingProperty(property='personaid')));
    </cfscript>
    <style>
        <cfinclude template="assets/css/matrix_selector.min.css" />
    </style>
    <cfif personas.getRecordCount() gt 1 or personas.getRecordCount() eq 1 and stages.getRecordCount() gt 1>
        <cfoutput>
            <cfsavecontent variable="matrixSelectorForm">
                <div class="mura-matrix-selector">
                    <form id="mura_matrix-selector-form" class="mura-form form-inline" data-autowire="false">
                        <div class="select-wrap">
                            <cfif personas.getRecordCount() gt 1>
                                <cfif len(objectparams.selfidstart)><label>#esapiEncode('html',objectparams.selfidstart)#</label></cfif>
                                <select id="mxp_personaid" name="personaid" class="form-control">
                                    <option value="">---</option>
                                    <cfloop condition="personas.hasNext()">
                                        <cfset persona=personas.next()>
                                        <option value="#persona.getPersonaID()#"<cfif m.MXP.getTrackingProperty('personaid') eq  persona.getPersonaID()> selected</cfif>>#esapiEncode('html',persona.getSelfIDQ())#</option>
                                    </cfloop>
                                </select>
                            <cfelse>
                                <input id="mxp_personaid" type="hidden" name="personaid" value="#personas.next().getPersonaID()#">
                            </cfif>
                            <cfif stages.getRecordCount() gt 1>
                                <cfif len(objectparams.selfidmiddle)><label>#esapiEncode('html',objectparams.selfidmiddle)#</label></cfif>
                                <select id="mxp_stageid" name="stageid" class="form-control">
                                    <option value="">---</option>
                                    <cfloop condition="stages.hasNext()">
                                        <cfset stage=stages.next()>
                                        <option value="#stage.getStageID()#"<cfif m.MXP.getTrackingProperty('stageid') eq  stage.getStageID()> selected</cfif>>#esapiEncode('html',stage.getSelfIDQ())#</option>
                                    </cfloop>
                                </select>
                            <cfelse>
                                <input id="mxp_stageid" type="hidden" name="stageid" value="#stages.next().getStageID()#">
                            </cfif>
                            <cfif len(objectparams.selfidend)><label>#esapiEncode('html',objectparams.selfidend)#</label></cfif>
                            <input type="hidden" name="mxp_matrix_select" value="true">
                            <button class="btn-dark" id="mxp_do_preview" style="display:none;" onClick="doMatrixPreview();" type="button">Preview</button>
                            <cfif isDefined('session.mura.mxp.preview') and session.mura.mxp.preview and objectparams.mode eq 'preview and save'><button class="btn-dark" id="mxp_do_save" type="submit">Save</button></cfif>
                            <cfif hasStageOrPersona><button class="btn-outline-dark" onClick="clearMatrixPreview();" type="button">Clear</button></cfif>
                        </div>
                    </form>
                </div>
            </cfsavecontent>
             <cfsavecontent variable="footerLinks">
                <cfif IsArray(objectParams.customlinks) AND arrayLen(objectParams.customlinks)>
                    <ul class="list-inline">
                        <cfloop array="#objectParams.customlinks#" index="link">
                            <li class="list-inline-item">
                                <a href="#link.value#">#link.name#</a>
                            </li>
                        </cfloop>
                    </ul>                    
                </cfif>
            </cfsavecontent>
            <cfswitch expression="#objectParams.displayType#">
                <cfcase value="inline">
                    #matrixSelectorForm#
                    <div class="mura-matrix-selector__inner__footer">
                        #footerLinks#
                    </div>
                </cfcase>
                <cfcase value="widget">
                    <cfif m.currentUser().isSuperUser() OR m.currentUser().isAdminUser()>
                        <div class="alert alert-info">Matrix Selector</div>
                    </cfif>
                    <div class="mura-matrix-selector__widget #objectParams.widgetposition#" id="exp_widget">
                        <button class="btn btn-light" id="exp_widget_toggle" onClick="toggleMatrixWidget()">
                            <cfif hasStageOrPersona><span class="text-success">Experience Optimized</span><cfelse> Optimize Your Experience</cfif>
                        </button>
                        <div class="mura-matrix-selector__widget__inner">
                            #matrixSelectorForm#
                            <div class="mura-matrix-selector__widget__inner__footer">
                                #footerLinks#
                            </div>
                        </div>
                    </div>
                </cfcase>
                <cfcase value="eyebrow">
                    <div class="mura-matrix-selector__eyebrow">
                        <div class="mura-matrix-selector__eyebrow__inner">
                            #matrixSelectorForm#
                            <div class="mura-matrix-selector__eyebrow__inner__footer">
                                #footerLinks#
                            </div>
                        </div>
                    </div>
                </cfcase>
            </cfswitch>
        </cfoutput>
    </cfif>
    <script>
        Mura(function(){
            Mura('#mxp_personaid, #mxp_stageid').on('change',function(){
                Mura('#mxp_do_preview').show();
                Mura('#mxp_do_save').hide();
            });

            Mura('#mura_matrix-selector-form').on('submit',function(e){
                e.preventDefault();
                doMatrixSave();
                return false;
            });
        });
        function toggleMatrixWidget() {
            var widget = document.getElementById("exp_widget");
            for (let cssClass of widget.classList) {
                console.log(cssClass);
            }
            if (widget.classList.contains('open')){
                widget.classList.remove('open');
            } else {
                widget.classList.add('open');
            }
            
        }
        function doMatrixSave() {
            showMatrixConfirmation()
            Mura.getEntity('matrix_selector').invoke(
                'saveExperience',
                {
                    'personaid': Mura('#mxp_personaid').val(),
                    'stageid': Mura('#mxp_stageid').val()
                },
                'post'
            ).then(function(){
                window.location = window.location.href.split("?")[0];
            })
        }

        function doMatrixPreview() {
            showMatrixConfirmation()
            Mura.getEntity('matrix_selector').invoke(
                'previewExperience',
                {
                    'personaid': Mura('#mxp_personaid').val(),
                    'stageid': Mura('#mxp_stageid').val()
                },
                'post'
            ).then(function(){
                window.location = window.location.href.split("?")[0];
            })
        }
        function showMatrixConfirmation() {
            Mura("#exp-selected-confirmation").addClass("show");
        } 
        function clearMatrixPreview() {
            showMatrixConfirmation()
            Mura.getEntity('matrix_selector').invoke(
                'clearExperience',
                { },
                'post'
            ).then(function(){
                window.location = window.location.href.split("?")[0];
            })
        }
    </script>
<cfelse>
	<cfset objectParams.render="client">
	<cfset objectParams.async=false>
</cfif>
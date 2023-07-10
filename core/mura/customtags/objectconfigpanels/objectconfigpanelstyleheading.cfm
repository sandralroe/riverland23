<cfoutput>
<div class="mura-panel-group" id="panels-style-meta">

		<!--- panel 1: heading (metalabel) --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading panel-meta">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-meta" href="##panel-style-meta-1">Position
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-meta-1" class="panel-collapse collapse">
            <div class="mura-panel-body">
            <!--- panel contents --->
			<!--- heading position --->
			<div class="mura-control-group">
				<label>Position</label>
				<select name="labelposition" class="classtoggle">
				<option value="mura-object-label-top"<cfif listFind(attributes.params.class,'mura-object-label-top',' ')> selected</cfif>>Top</option>
				<option value="mura-object-label-left"<cfif listFind(attributes.params.class,'mura-object-label-left',' ')> selected</cfif>>Left</option>
				<option value="mura-object-label-right"<cfif listFind(attributes.params.class,'mura-object-label-right',' ')> selected</cfif>>Right</option>
				</select>
			</div>

			<!--- heading alignment --->
			<div class="mura-control-group">
				<label>Align</label>
                <select id="metalabelfloat" name="metalabelfloat" data-param="float" class="metaStyle">
                    <!--- heading alignment --->
                    <cfif attributes.params.object eq "text">
                        <!--- text module heading defaults to left --->
                        <option value="left"<cfif not len(attributes.params.stylesupport.metastyles.float) or attributes.params.stylesupport.metastyles.float eq 'none' or attributes.params.stylesupport.metastyles.float eq 'left'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.left')#</option>
                        <option value="center"<cfif attributes.params.stylesupport.metastyles.float eq 'center'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.center')#</option>
                    <cfelse>
                        <!--- other modules e.g. collection default to center (none) --->
                        <option value="none"<cfif not len(attributes.params.stylesupport.metastyles.float) or attributes.params.stylesupport.metastyles.float eq 'none'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.center')#</option>
                        <option value="left"<cfif attributes.params.stylesupport.metastyles.float eq 'left'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.left')#</option>
                    </cfif>
                    <!--- right alignment is last for all modules --->
					<option value="right"<cfif attributes.params.stylesupport.metastyles.float eq 'right'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.right')#</option>
				</select>
				<input id="metalabeltextAlign" type="hidden" name="textAlign" class="metaStyle" value="#attributes.params.stylesupport.metastyles.textAlign#"/>
				<script>
					$("##metalabelfloat").on('change',function(){
						var val=$(this).val();
						if(val=='left' || val=='right'){
							$('##metalabeltextAlign').val(val).trigger('change');
						} else {
							$('##metalabeltextAlign').val('').trigger('change');
						}
					})
				</script>
			</div>
            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

		<!--- panel 2: layout --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading panel-meta">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-meta" href="##panel-style-meta-2">Layout
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-meta-2" class="panel-collapse collapse">
            <div class="mura-panel-body">

            <!--- panel contents --->
			<cfset attributes.name='meta'>
			<cfinclude template="objectlayout.cfm">
			
            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

		<!--- panel 3: layout --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading panel-meta">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-meta" href="##panel-style-meta-3">Text Color
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-meta-3" class="panel-collapse collapse">
            <div class="mura-panel-body">
                <cfset attributes.name='meta'>
				<cfinclude template="objecttext.cfm">
            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

		<!--- panel 4: background --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading panel-meta">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-meta" href="##panel-style-meta-4">Background
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-meta-4" class="panel-collapse collapse">
            <div class="mura-panel-body">
            <!--- panel contents --->
			

			<cfset attributes.name='meta'>
			<cfinclude template="objectbackground.cfm">

            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

		<!--- panel 5: custom --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading panel-meta">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-meta" href="##panel-style-meta-5">Custom
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-meta-5" class="panel-collapse collapse">
            <div class="mura-panel-body">
            <!--- panel contents --->
            <div class="mura-control-group">
                <label>
                Z-Index
                </label>
                <input name="zIndex" class="metaStyle numeric" type="text" value="#esapiEncode('html_attr',attributes.params.stylesupport.metastyles.zindex)#" maxlength="5">
            </div>
            <div class="mura-control-group">
                <label>
                    CSS ID
                </label>
                <input name="metacssid" class="objectParam" type="text" value="#esapiEncode('html_attr',attributes.params.metacssid)#" maxlength="255">
            </div>
            <div class="mura-control-group">
                <label>
                    CSS Class
                </label>
                <input name="metacssclass" class="objectParam" type="text" value="#esapiEncode('html_attr',attributes.params.metacssclass)#" maxlength="255">
            </div>

            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

</div> <!--- /.mura-panel-group --->

</cfoutput>

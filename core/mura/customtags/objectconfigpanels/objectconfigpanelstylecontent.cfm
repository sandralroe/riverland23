<cfoutput>

<div class="mura-panel-group" id="panels-style-content">

		<!--- panel 1: layout --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading panel-content">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-content" href="##panel-style-content-1">Layout
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-content-1" class="panel-collapse collapse">
            <div class="mura-panel-body">
            <!--- panel contents --->			
				<!---
				<div class="mura-control-group">					<label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.minimumheight'))#</label>

					<div class="row mura-ui-row">
						<cfif not len(attributes.params.stylesupport.contentminheightuom)
							and len(attributes.params.stylesupport.contentstyles.minheight)>
							<cfset attributes.params.stylesupport.contentminheightuom=reReplace(attributes.params.stylesupport.contentstyles.minheight,"[^a-z]","","all")>
						</cfif>
							<div class="mura-input-group">
								<label class="mura-serial">
									<input type="text" name="contentminheight" id="contentminheightnum" class="numeric serial" value="<cfif len(trim(attributes.params.stylesupport.contentstyles.minheight))>#val(esapiEncode('html_attr',attributes.params.stylesupport.contentstyles.minheight))#</cfif>">
								</label>
								<select id="contentminheightuom" name="contentminheightuom" class="styleSupport">
									<cfloop list="#request.objectlayoutuomext#" index="u">
										<option value="#u#"<cfif attributes.params.stylesupport.contentminheightuom eq u or not len(attributes.params.styleSupport.contentminheightuom) and u eq request.preferreduom> selected</cfif>>#u#</option>
									</cfloop>
								</select>
							</div>
							<input type="hidden" name="minHeight" id="contentminheightuomval" class="contentStyle" value="#esapiEncode('html_attr',attributes.params.stylesupport.contentstyles.minheight)#">
					</div>
				</div>
			--->
				<cfset attributes.name='content'>
				<cfinclude template="objectlayout.cfm">

				
            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

		<!--- panel 2: theme --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading panel-content">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-content" href="##panel-style-content-2">Text Color
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-content-2" class="panel-collapse collapse">
            <div class="mura-panel-body">
            <!--- panel contents --->
			<!--- text color --->
			<cfset attributes.name='content'>
			<cfinclude template="objecttext.cfm">

            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->


		<!--- panel 3: background --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading panel-content">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-content" href="##panel-style-content-3">Background
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-content-3" class="panel-collapse collapse">
            <div class="mura-panel-body">
            <!--- panel contents --->
			<cfset attributes.name='content'>
			<cfinclude template="objectbackground.cfm">

            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

		<!--- panel 4: custom --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading panel-content">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-content" href="##panel-style-content-4">Custom
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-content-4" class="panel-collapse collapse">
            <div class="mura-panel-body">
            <!--- panel contents --->
            <div class="mura-control-group">
                <label>
                Z-Index
                </label>
                <input name="zIndex" class="contentStyle numeric" type="text" value="#esapiEncode('html_attr',attributes.params.stylesupport.contentstyles.zindex)#" maxlength="5">
            </div>
            <div class="mura-control-group">
                <label>
                    CSS ID
                </label>
                <input name="contentcssid" class="objectParam" type="text" value="#esapiEncode('html_attr',attributes.params.contentcssid)#" maxlength="255">
            </div>
            <div class="mura-control-group">
                <label>
                    CSS Class
                </label>
                <input name="contentcssclass" class="objectParam" type="text" value="#esapiEncode('html_attr',attributes.params.contentcssclass)#" maxlength="255">
            </div>
            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

</div> <!--- /.mura-panel-group --->

</cfoutput>

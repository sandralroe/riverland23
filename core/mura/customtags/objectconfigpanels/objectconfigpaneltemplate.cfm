<cfsilent>
<cfparam name="attributes.params.objectname" default="">
<cfset templatename="">
<cfif attributes.params.objectname neq attributes.params.object>
	<cfset templatename=attributes.params.objectname>
</cfif>
</cfsilent>
<cfoutput>
<div class="mura-panel-group" id="panels-style-meta">
		<!--- panel 1: label --->
    <div class="panel mura-panel">
		
			<div class="mura-control-group">
				<label class="mura-control-label">Save As</label>
				<input id="templatename" name="templatename" type="text" maxlength="100" value="" placeholder="Enter Template Name"/>
				<button class="btn mura-save" id="saveModuleTemplate" onclick="saveModuleTemplate();"><i class="mi-check-circle"></i> Save</button>
				<input id="objectname" name="objectname" type="hidden" class="objectParam" maxlength="100" value="#esapiEncode('html_attr',attributes.params.objectname)#"/>
			</div>
    </div>
</div> <!--- /.mura-panel-group --->

</cfoutput>

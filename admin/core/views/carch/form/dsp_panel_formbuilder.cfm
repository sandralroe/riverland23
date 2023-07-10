 <!--- license goes here --->

<cfset tabList=listAppend(tabList,"tabBasic")>
<cfinclude template="head_formbuilder.cfm">
	<cfoutput>
	<div class="mura-panel" id="tabBasic">
		<div class="mura-panel-heading" role="tab" id="heading-basic">
			<h4 class="mura-panel-title">
				<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##content-panels" href="##panel-basic" aria-expanded="true" aria-controls="panel-basic">#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.basic")#</a>
			</h4>
		</div>
		<div id="panel-basic" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-basic" aria-expanded="false" style="height: 0px;">
			<div class="mura-panel-body">

			<span id="extendset-container-tabbasictop" class="extendset-container"></span>

			<input type="hidden" id="menuTitle" name="menuTitle" value="">
				<div class="mura-control-group">
					<label>
				#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.title')#
			</label>
				<input type="text" id="title" name="title" value="#esapiEncode('html_attr',rc.contentBean.getTitle())#"  maxlength="255" required="true" message="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.titlerequired')#">
			</div>

			<cfif rc.type neq 'Form' and  rc.type neq 'Component' >
				<div class="mura-control-group">
					<label>
				<a href="##" rel="tooltip" title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"tooltip.contentSummary"))#">
					#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.summary")#
						 <i class="mi-question-circle"></i></a>
				<a href="##" id="editSummaryLink" onclick="javascript: toggleDisplay('editSummary','#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.expand')#','#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.close')#'); editSummary();return false">
					[#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.expand")#]
				</a>
			</label>
					<div class="mura-control justify" id="editSummary" style="display:none;">
				<cfoutput><textarea name="summary" id="summary" cols="96" rows="10"><cfif application.configBean.getValue("htmlEditorType") neq "none" or len(rc.contentBean.getSummary())>#esapiEncode('html',rc.contentBean.getSummary())#<cfelse><p></p></cfif></textarea></cfoutput>
			</div>
		</div>
			</cfif>

			<cfsavecontent variable="bodyContent">
				<div class="mura-control-group">
					<div id="bodyContainer" class="mura-control justify">
						<cfinclude template="dsp_formbuilder.cfm">
					</div>
				</div>
			</cfsavecontent>

			<span id="extendSetsBasic"></span>

			<!--- parentid placeholder --->
			<input type="hidden" name="parentid" value="#esapiEncode('html_attr',rc.parentid)#">

			<cfif rc.type eq 'Form'>
				<cfif application.configBean.getValue(property='formpolls',defaultValue=false)>
				<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.formpresentation')#</label>
					<label for="rc" class="checkbox">
						<input name="responseChart" type="CHECKBOX" value="1" <cfif rc.contentBean.getresponseChart() eq 1>checked </cfif> class="checkbox"> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.ispoll')#
					</label>
					</div>
				</cfif>
				<div class="mura-control-group">
					<label>
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.confirmationmessage')#
					</label>
					<textarea name="responseMessage" rows="4">#esapiEncode('html',rc.contentBean.getresponseMessage())#</textarea>
				</div>
				<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.responsesendto')#</label>
					<input type="text" name="responseSendTo" value="#esapiEncode('html_attr',rc.contentBean.getresponseSendTo())#">
				</div>
			</cfif>

			<span id="extendset-container-basic" class="extendset-container"></span>
			<span id="extendset-container-tabbasicbottom" class="extendset-container"></span>

			</div>
		</div>
	</div>
</cfoutput>

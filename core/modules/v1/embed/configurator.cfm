 <!--- license goes here --->
<cfsilent>
	<cfparam name="objectParams.source" default="">
</cfsilent>
<cf_objectconfigurator params="#objectParams#">
<cfoutput>
<div id="availableObjectParams"
	data-object="embed"
	data-name="#esapiEncode('html_attr','#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.embed')#')#"
	data-objectid="none">
	<div class="mura-layout-row">
		<div class="mura-control-group">
			<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.enterembedcode')#</label>
			<textarea name="source" class="objectParam" style="height:150px">#objectParams.source#</textarea>
			<input type="hidden" class="objectParam" name="render" value="client">
			<input type="hidden" class="objectParam" name="async" value="false">
		</div>
	</div>

	</div>
	<!--- Include global config object options --->
	<cfinclude template="#$.siteConfig().lookupDisplayObjectFilePath('object/configurator.cfm')#">

</cfoutput>
</cf_objectconfigurator>
<cfabort>

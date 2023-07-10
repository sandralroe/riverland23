<!--- license goes here --->
<cfsilent>
	<cfset content=rc.$.getBean("content").loadBy(contentID=rc.objectid)>
	<cfset displayRSS=isDefined("params.displayRSS") and yesNoFormat(params.displayRSS)>
</cfsilent>
<cfoutput>
<cf_objectconfigurator>
<div id="availableObjectParams"
	data-object="category_summary"
	data-name="#esapiEncode('html_attr','#content.getMenuTitle()# - #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.categorysummary')#')#"
	data-objectid="#content.getContentID()#">
	<div class="mura-layout-row">
		<div class="mura-control-group">
			<label class="mura-control-label">
				#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayrss')#
			</label>
			<label class="radio">
				<input name="displayRSS" type="radio" value="1" class="objectParam radio" <cfif displayRSS>checked</cfif>>
				#application.rbFactory.getKeyValue(session.rb,'collections.yes')#
			</label>
			<label class="radio">
				<input name="displayRSS" type="radio" value="0" class="objectParam radio" <cfif not displayRSS>checked</cfif>>
			#application.rbFactory.getKeyValue(session.rb,'collections.no')#
			</label>
		</div>
	</div>
</div>
</cf_objectconfigurator>
</cfoutput>

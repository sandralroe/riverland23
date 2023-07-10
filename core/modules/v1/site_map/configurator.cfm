 <!--- license goes here --->
<!--- license goes here --->
<cfsilent>
	<cfset content=rc.$.getBean("content").loadBy(contentID=rc.objectid)>

	<cfif not isDefined("objectParams.mapclass") or not len (objectParams.mapclass)>
		<cfset objectParams.mapclass="mura-site-map">
	</cfif>
</cfsilent>
<cf_objectconfigurator params="#objectParams#">
<cfoutput>
<div id="availableObjectParams"
	data-object="site_map"
	data-name="#esapiEncode('html_attr','Site Map')#"
	data-objectid="#hash('site_map')#">
	<div class="mura-layout-row">
		<div class="mura-control-group">
			<label>
				#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayformat')#
			</label>
			<div class="mura-control">
				<label class="radio-inline">
					<input name="mapclass" type="radio" value="mura-site-map" class="objectParam radio" <cfif objectParams.mapclass eq "mura-site-map">checked</cfif>>
						#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.default')#
				</label>
				<label class="radio-inline">
					<input name="mapclass" type="radio" value="mura-site-map-tree" class="objectParam radio" <cfif objectParams.mapclass eq "mura-site-map-tree">checked</cfif>>
					#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.treeview')#
				</label>
			</div>
		</div>
	</div>
</cfoutput>
</cf_objectconfigurator>

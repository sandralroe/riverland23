<!--- license goes here --->
<cfset rc.rsAdZones = application.advertiserManager.getadzonesBySiteID(rc.siteid, '')/>
<cfoutput>
<cfif rc.layoutmanager>
	<div class="mura-layout-row">
		<div class="mura-control-group">
		<cfloop query="rc.rsAdZones">
			#contentRendererUtility.renderObjectClassOption(
				object='adZone',
				objectid=rc.rsAdZones.adZoneID,
				objectname="#application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.adzone')#
						-
						#rc.rsAdZones.name#"
			)#
		</cfloop>
		</div>
	</div>
<cfelse>
	<div class="mura-layout-row">
		<div class="mura-control-group">
			<select name="availableObjects" id="availableObjects" class="multiSelect"
			        size="#evaluate((application.settingsManager.getSite(rc.siteid).getcolumnCount() * 6)-4)#">
				<cfloop query="rc.rsAdZones">
					<option value="{'object':'adZone','name','esapiEncode('html_attr','#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.adzone')# - #rc.rsAdZones.name#')#',objectid:'#rc.rsAdZones.adZoneID#'}">
						#application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.adzone')#
						-
						#rc.rsAdZones.name#
					</option>
				</cfloop>
			</select>
		</div>
	</div>
</cfif>
</cfoutput>

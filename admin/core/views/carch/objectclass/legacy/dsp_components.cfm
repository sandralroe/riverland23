<!--- license goes here --->
<cfoutput>
	<cfset rc.rsUserDefinedTemplates = application.contentManager.getComponents("00000000000000000000000000000000000", rc.siteid)/>
	<cfif rc.layoutmanager>
		<div class="mura-layout-row">
			<div class="mura-control-group">
		<cfloop query="rc.rsUserDefinedTemplates">
			#contentRendererUtility.renderObjectClassOption(
				object='component',
				objectid=rc.rsUserDefinedTemplates.contentid,
				objectname=application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.type.component')
							& ' - '
							& rc.rsUserDefinedTemplates.menutitle
			)#
		</cfloop>
		</div>
	</div>
	<cfelse>
		<div class="mura-layout-row">
			<div class="mura-control-group">
				<select name="availableObjects" id="availableObjects" class="multiSelect"
				        size="#evaluate((application.settingsManager.getSite(rc.siteid).getcolumnCount() * 6)-4)#">
					<cfloop query="rc.rsUserDefinedTemplates">
						<cfset title=application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.type.component')
							& ' - '
							& rc.rsUserDefinedTemplates.menutitle>
						<option title="#esapiEncode('html_attr',title)#" value="{'object':'Component','name':'#esapiEncode('html_attr',title)#','objectid':'#rc.rsUserDefinedTemplates.contentid#'}">
							#esapiEncode('html',title)#
						</option>
					</cfloop>
				</select>
			</div>
		</div>
	</cfif>

</cfoutput>

<!--- license goes here --->
<cfset rc.rsForms = application.contentManager.getComponentType(rc.siteid, 'Form')/>
<cfoutput>
<cfif rc.layoutmanager>
	<div class="mura-layout-row">
		<div class="mura-control-group">
		<cfloop query="rc.rsForms">
			<cfsilent>
			<cfset title=iif(rc.rsForms.responseChart eq 1,
					      de('#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.poll')#'),
					      de('#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.datacollector')#'))
						& ' - '
						& rc.rsForms.menutitle>
			</cfsilent>
			#contentRendererUtility.renderObjectClassOption(
				object='form',
				objectid=rc.rsForms.contentid,
				objectname=title
			)#
		</cfloop>
		</div>
	</div>
<cfelse>
	<div class="mura-layout-row">
		<div class="mura-control-group">
			<select name="availableObjects" id="availableObjects" class="multiSelect"
			        size="#evaluate((application.settingsManager.getSite(rc.siteid).getcolumnCount() * 6)-4)#">
				<cfloop query="rc.rsForms">
					<cfset title=iif(rc.rsForms.responseChart eq 1,
					      de('#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.poll')#'),
					      de('#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.datacollector')#'))
						& ' - '
						& rc.rsForms.menutitle>
					<option title="#esapiEncode('html_attr',title)#" value="{object:'form',name:'#esapiEncode('html_attr',title)#',objectid:'#rc.rsForms.contentid#'}">
						#esapiEncode('html',title)#
					</option>
					<cfif rc.rsForms.responseChart neq 1>
						<cfset title=application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.dataresponses')
							& ' - '
							& rc.rsForms.menutitle>
						<option title="#esapiEncode('html_attr',title)#" value="{'object':'form_responses','name':'#esapiEncode('html_attr',title)#','objectid':'#rc.rsForms.contentid#'}">
							#esapiEncode('html',title)#
						</option>
					</cfif>
				</cfloop>
			</select>
		</div>
	</div>
</cfif>
</cfoutput>

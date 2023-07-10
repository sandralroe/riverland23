<!--- license goes here --->
<cfset rc.rslist = application.feedManager.getFeeds(rc.siteid, 'Remote')/>
<cfoutput>
<cfif rc.layoutmanager>
	<div class="mura-layout-row">
		<div class="mura-control-group">
		<cfloop query="rc.rslist">
			<cfset title=rc.rslist.name
				& ' - '
				& application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.remotefeed')>

			#contentRendererUtility.renderObjectClassOption(
				object='feed',
				objectid=rc.rslist.feedid,
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
				<cfloop query="rc.rslist">

					<cfset title=rc.rslist.name
						& ' - '
						& application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.remotefeed')>

					<option title="#esapiEncode('html_attr',title)#" value="{'object':'feed','name':'#esapiEncode('javascript',title)#','objectid':'#rc.rslist.feedID#'}">
						#esapiEncode('html',title)#
					</option>
				</cfloop>
			</select>
		</div>
	</div>
</cfif>
</cfoutput>

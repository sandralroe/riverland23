<!--- license goes here --->
<cfset rc.rslist = application.feedManager.getFeeds(rc.siteid, 'Local')/>
<cfoutput>
<cfif rc.layoutmanager>
	<div class="mura-layout-row">
		<div class="mura-control-group">
		<cfloop query="rc.rslist">
			<cfset title=rc.rslist.name
				& ' - '
				& application.rbFactory.getKeyValue(session.rb,
					                                    'sitemanager.content.fields.localindexslideshow')>
			#contentRendererUtility.renderObjectClassOption(
				object='feed_slideshow',
				objectid=rc.rslist.feedid,
				objectname=title
			)#
		</cfloop>
		</div>
	</div>
<cfelse>
	<div class="mura-layout-row">
		<div class="mura-control-group">
			<select name="availableObjects"
					id="availableObjects"
			        class="multiSelect"
				        size="#evaluate((application.settingsManager.getSite(rc.siteid).getcolumnCount() * 6)-4)#">
				<cfloop query="rc.rslist">

					<cfset title=rc.rslist.name
						& ' - '
						& application.rbFactory.getKeyValue(session.rb,
					                                    'sitemanager.content.fields.localindexslideshow')>

					<option title="#esapiEncode('html_attr',title)#" value="{'object':'feed_slideshow','objectid':'#rc.rslist.feedID#','name':'#esapiEncode('javascript',title)#'}">
						#esapiEncode('html',title)#
					</option>
				</cfloop>
			</select>
		</div>
	</div>
</cfif>
</cfoutput>

<!--- license goes here --->
<cfset rc.rsmailinglists = application.contentUtility.getMailingLists(rc.siteid)/>
<cfoutput>
<cfif rc.layoutmanager>
	<div class="mura-layout-row">
		<div class="mura-control-group">
		#contentRendererUtility.renderObjectClassOption(
				object='mailing_list_master',
				objectid=createUUID(),
				objectname=application.rbFactory.getKeyValue(session.rb,
				                                    'sitemanager.content.fields.mastermailinglistsignupform')
			)#
		<cfloop query="rc.rsmailinglists">
			#contentRendererUtility.renderObjectClassOption(
				object='mailing_list',
				objectid=rc.rsmailinglists.mlid,
				objectname="#application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.mailinglist')# - #rc.rsmailinglists.name#"
			)#
		</cfloop>
		</div>
	</div>
<cfelse>
	<div class="mura-layout-row">
		<div class="mura-control-group">
		<select name="availableObjects" id="availableObjects" class="multiSelect"
		        size="#evaluate((application.settingsManager.getSite(rc.siteid).getcolumnCount() * 6)-4)#">

			<option value="{'object':'mailing_list_master','name':'#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.mastermailinglistsignupform'))#','objectid':'none'}">
				#application.rbFactory.getKeyValue(session.rb,
			                                    'sitemanager.content.fields.mastermailinglistsignupform')#
			</option>
			<cfloop query="rc.rsmailinglists">
				<option value="{'object':'mailing_list','name':'#esapiEncode('html_attr','Mailing List - #rc.rsmailinglists.name#')#','objectid':'#rc.rsmailinglists.mlid#'}">
					#application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.mailinglist')#
					-
					#rc.rsmailinglists.name#
				</option>
			</cfloop>
		</select>
		</div>
	</div>
</cfif>
</cfoutput>

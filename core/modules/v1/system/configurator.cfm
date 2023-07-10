 <!--- license goes here --->
<cfsilent>
	<cfset rc.rsObjects = application.contentManager.getSystemObjects(rc.siteid)/>
	<cfquery name="rc.rsObjects" dbtype="query">
		select * from rc.rsObjects where object not like '%nav%'
		<cfif not application.settingsManager.getSite(rc.siteid).getHasComments()>
			and object != 'comments'
		</cfif>
		and object != 'payPalCart'
		and object != 'related_content'
		and object != 'tag_cloud'
		and object != 'goToFirstChild'
		and object != 'event_reminder_form'
		and object != 'forward_email'
	</cfquery>
</cfsilent>
<cf_objectconfigurator>
<cfoutput>
	<div class="mura-layout-row">
		<div class="mura-control-group">
			<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectsystemobject')#</label>
			<select name="object" class="objectParam">
				<option  value="#esapiEncode('html_attr','Select System Object')#">
					#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectsystemobject')#
				</option>
				<cfloop query="rc.rsObjects">
					<option <cfif rc.object eq rc.rsobjects.object>selected </cfif>title="#esapiEncode('html_attr',rc.rsObjects.name)#" value="#esapiEncode('javascript',rc.rsobjects.object)#">
						#esapiEncode('html',rc.rsObjects.name)#
					</option>
				</cfloop>
			</select>
		</div>
	</div>
	<input name="objectid" type="hidden" class="objectParam" value="#esapiEncode('html_attr',rc.contentid)#">
</cfoutput>
</cf_objectconfigurator>

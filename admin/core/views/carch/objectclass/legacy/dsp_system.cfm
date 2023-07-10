<!--- license goes here --->
<cfsilent>
	<cfset rc.rsObjects = application.contentManager.getSystemObjects(rc.siteid)/>
	<cfquery name="rc.rsObjects" dbtype="query">
		select * from rc.rsObjects where object not like '%nav%'
		<cfif not application.settingsManager.getSite(rc.siteid).getHasComments()>
			and object != 'comments'
		</cfif>
	</cfquery>
</cfsilent>
<cfoutput>
<cfif rc.layoutmanager>
	<div class="mura-layout-row">
		<div class="mura-control-group">
		<cfloop query="rc.rsObjects">
			#contentRendererUtility.renderObjectClassOption(
				object=rc.rsObjects.object,
				objectid=createUUID(),
				objectname=rc.rsObjects.name
			)#
		</cfloop>
		</div>
	</div>
<cfelse>
	<div class="mura-layout-row">
		<div class="mura-control-group">
			<select name="availableObjects" id="availableObjects" class="multiSelect"
			        size="#evaluate((application.settingsManager.getSite(rc.siteid).getcolumnCount() * 6)-4)#">
				<cfloop query="rc.rsObjects">
					<option title="#esapiEncode('html_attr',rc.rsObjects.name)#" value='{"object":"#esapiEncode('javascript',rc.rsobjects.object)#","name":"#esapiEncode('javascript',rc.rsObjects.name)#","objectid":"#createUUID()#"}'>
						#esapiEncode('html',rc.rsObjects.name)#
					</option>
				</cfloop>
			</select>
		</div>
	</div>
</cfif>
</cfoutput>

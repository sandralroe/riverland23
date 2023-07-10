<!--- license goes here --->

<cfoutput>
	<cfset rc.originalfuseaction=listLast(request.action,".")>
	<div class="nav-module-specific btn-group">
		<cfswitch expression="#rc.originalfuseaction#">
			<cfcase value="assignments">
				<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'changesets.backtochangesets')#" href="./?muraAction=cChangesets.list&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i> #application.rbFactory.getKeyValue(session.rb,'changesets.backtochangesets')#</a>
				<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'changesets.vieweditform')#" href="./?muraAction=cChangesets.edit&siteid=#esapiEncode('url',rc.siteid)#&changesetID=#esapiEncode('html',rc.changesetID)#"><i class="mi-pencil"></i> #application.rbFactory.getKeyValue(session.rb,'changesets.vieweditform')#</a>
				<cfif not rc.changeset.getPublished()>
					<cfset rc.previewLink="#rc.$.getBean('content').loadBy(filename='').getURL(complete=1,queryString='changesetID=#rc.changesetID#')#">
					<a class="btn" href="##" onclick="return preview('#esapiEncode('javascript',rc.previewLink)#','');"><i class="mi-globe"></i> #application.rbFactory.getKeyValue(session.rb,'changesets.previewchangeset')#</a>
				</cfif>
			</cfcase>
			<cfcase value="list">
				<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'changesets.addchangeset')#" href="./?muraAction=cChangesets.edit&changesetID=&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,'changesets.addchangeset')#</a>
				<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
				<a class="btn <cfif rc.originalfuseaction eq 'module'> active</cfif>" href="./?muraAction=cPerm.leveledmodule&contentid=00000000000000000000000000000000014&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000014"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,'changesets.permissions')#</a>
				</cfif>
			</cfcase>
			<cfcase value="edit">
				<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'changesets.backtochangesets')#" href="./?muraAction=cChangesets.list&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i> #application.rbFactory.getKeyValue(session.rb,'changesets.backtochangesets')#</a>
				<cfif not rc.changeset.getIsNew()>
					<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'changesets.viewassignments')#" href="./?muraAction=cChangesets.assignments&siteid=#esapiEncode('url',rc.siteid)#&changesetID=#rc.changeset.getChangesetID()#"><i class="mi-reorder"></i> #application.rbFactory.getKeyValue(session.rb,'changesets.viewassignments')#</a>
					<cfif not rc.changeset.getPublished()>
						<cfset rc.previewLink="#application.settingsManager.getSite(rc.siteid).getWebPath(complete=1)##$.getURLStem(rc.siteid,"")#?changesetID=#rc.changesetID#">
						<a class="btn" href="##" onclick="return preview('#esapiEncode('javascript',rc.previewLink)#','');"><i class="mi-globe"></i> #application.rbFactory.getKeyValue(session.rb,'changesets.previewchangeset')#</a>
				</cfif>
				</cfif>
			</cfcase>
		</cfswitch>
	</div>
</cfoutput>
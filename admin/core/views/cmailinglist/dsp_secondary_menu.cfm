<!--- license goes here --->

<cfoutput>
<!---<li<cfif rc.originalfuseaction eq "edit"> class="current"</cfif>><a href="./?muraAction=cMailingList.edit&siteid=#esapiEncode('url',rc.siteid)#&mlid=">Add Mailing List</a></li>--->

	<cfset rc.originalfuseaction=listLast(request.action,".")>
	<div class="nav-module-specific btn-group">	
		<cfswitch expression="#rc.originalfuseaction#">
			<cfcase value="list">
				<a class="btn" title="Add Mailing List" href="./?muraAction=cMailingList.edit&siteid=#esapiEncode('url',rc.siteid)#&mlid="><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.addmailinglist')#</a>
				<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
				<a class="btn" href="./?muraAction=cPerm.module&contentid=00000000000000000000000000000000009&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000009"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.permissions')#</a>
				</cfif>
			</cfcase>
			<cfcase value="edit">
				<a class="btn" href="./?muraAction=cMailingList.list&&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i> #application.rbFactory.getKeyValue(session.rb,"mailinglistmanager.backtomailinglists")#</a>
				<cfif rc.mlid neq ''>
				<a class="btn" href="./?muraAction=cMailingList.listmembers&mlid=#rc.mlid#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i> #application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.vieweditmembers')#
				<a class="btn" href="./?muraAction=cMailingList.download&mlid=#rc.mlid#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-download"></i> #application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.downloadmembers')#</a>
				</cfif>	
			</cfcase>
			<cfcase value="listmembers">
				<a class="btn" href="./?muraAction=cMailingList.list&&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i> #application.rbFactory.getKeyValue(session.rb,"mailinglistmanager.backtomailinglists")#</a>
				<a class="btn" href="./?muraAction=cMailingList.Edit&mlid=#rc.mlid#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i> #application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.editmailinglist')#</a>
				<a class="btn" href="./?muraAction=cMailingList.download&mlid=#rc.mlid#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-download"></i> #application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.downloadmembers')#</a>		
			</cfcase>
		</cfswitch>
	</div>

</cfoutput>
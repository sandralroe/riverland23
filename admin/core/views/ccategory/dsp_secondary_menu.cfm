<!--- license goes here --->


<cfoutput>
<cfset rc.originalfuseaction=listLast(request.action,".")>
<div class="nav-module-specific btn-group">
	<cfswitch expression="#rc.originalfuseaction#">
		<cfcase value="list">
				<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,"categorymanager.addnewcategory")#" href="./?muraAction=cCategory.edit&categoryID=&parentID=&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,"categorymanager.addnewcategory")#</a>
			<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
				<a class="btn <cfif rc.originalfuseaction eq 'module'> active</cfif>" href="./?muraAction=cPerm.module&contentid=00000000000000000000000000000000010&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000010"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,'categorymanager.permissions')#</a>
			</cfif>
		</cfcase>
		<cfdefaultcase>
			<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,"categorymanager.addnewcategory")#" href="./?muraAction=cCategory.list&categoryID=&parentID=&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i> #application.rbFactory.getKeyValue(session.rb,"categorymanager.backtocategories")#</a>
		</cfdefaultcase>
	</cfswitch>
</div>
</cfoutput>

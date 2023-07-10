<!--- license goes here --->

<cfoutput>
	<cfset rc.originalfuseaction=listLast(request.action,".")>
	<div class="nav-module-specific btn-group">
		<cfswitch expression="#rc.originalfuseaction#">
			<cfcase value="pending">
				<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'approvalchains.backtoapprovalchains')#" href="./?muraAction=cchain.list&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i> #application.rbFactory.getKeyValue(session.rb,'approvalchains.backtoapprovalchains')#</a>
				<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'approvalchains.vieweditform')#" href="./?muraAction=cchain.edit&siteid=#esapiEncode('url',rc.siteid)#&chainID=#esapiEncode('html',chain.getChainID())#"><i class="mi-pencil"></i> #application.rbFactory.getKeyValue(session.rb,'approvalchains.vieweditform')#</a>
			</cfcase>
			<cfcase value="list">
				<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'approvalchains.addapprovalchain')#" href="./?muraAction=cchain.edit&chainID=&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,'approvalchains.addapprovalchain')#</a>
				<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
					<a class="btn <cfif rc.originalfuseaction eq 'module'> active</cfif>" href="./?muraAction=cPerm.leveledmodule&contentid=00000000000000000000000000000000019&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000019"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,'approvalchains.permissions')#</a>
				</cfif>
			</cfcase>
			<cfcase value="edit">
				<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'approvalchains.backtoapprovalchains')#" href="./?muraAction=cchain.list&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i> #application.rbFactory.getKeyValue(session.rb,'approvalchains.backtoapprovalchains')#</a>
				<cfif not chain.getIsNew()>
					<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'approvalchains.pendingrequests')#" href="./?muraAction=cchain.pending&siteid=#esapiEncode('url',rc.siteid)#&chainID=#chain.getChainID()#"><i class="mi-reorder"></i> #application.rbFactory.getKeyValue(session.rb,'approvalchains.pendingrequests')#</a>
				</cfif>
			</cfcase>
		</cfswitch>
	</div>
</cfoutput>

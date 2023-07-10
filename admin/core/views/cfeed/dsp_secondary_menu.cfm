<!--- license goes here --->


<cfoutput>
<cfset rc.originalfuseaction=listLast(request.action,".")>
	<div class="nav-module-specific btn-group">
	<cfswitch expression="#rc.originalfuseaction#">
		<cfcase value="list">
			<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'collections.addlocalindex')#" href="./?muraAction=cFeed.edit&feedID=&siteid=#esapiEncode('url',rc.siteid)#&type=Local"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,'collections.addlocalindex')#</a>
			<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'collections.addremotefeed')#" href="./?muraAction=cFeed.edit&feedID=&siteid=#esapiEncode('url',rc.siteid)#&type=Remote"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,'collections.addremotefeed')#</a>
			<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
			<a class="btn <cfif rc.originalfuseaction eq 'module'> active</cfif>" href="./?muraAction=cPerm.module&contentid=00000000000000000000000000000000011&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000011"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,'collections.permissions')#</a>
			</cfif>
		</cfcase>
		<cfdefaultcase>
			<a class="btn" href="./?muraAction=cFeed.list&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i> #application.rbFactory.getKeyValue(session.rb,"collections.backtocollections")#</a>
			<cfif isDefined('rc.feedBean') and not rc.feedBean.getIsNew()>
				<cfif rc.feedBean.getType() eq 'Local'>
					<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'collections.view')#" href="#endpoint#/?feedID=#rc.feedBean.getfeedID()#" target="_blank"><i class="mi-rss"></i> #application.rbFactory.getKeyValue(session.rb,'collections.viewfeed')#</a>
				<cfelse>
					<a class="btn" title="#application.rbFactory.getKeyValue(session.rb,'collections.view')#" href="#rc.feedBean.getChannelLink()#" target="_blank"><i class="mi-rss"></i> #application.rbFactory.getKeyValue(session.rb,'collections.viewfeed')#</a>
				</cfif>
			</cfif>
		</cfdefaultcase>
	</cfswitch>
	</div>
</cfoutput>
<!--- license goes here --->

<cfoutput>
	<cfset rc.originalfuseaction=listLast(request.action,".")>
	<div class="nav-module-specific btn-group">
	<cfswitch expression="#rc.originalfuseaction#">
		<cfcase value="list">
			<a class="btn" href="./?muraAction=cEmail.edit&emailid=&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,"email.addemail")#</a>
			<a class="btn<cfif rc.originalfuseaction eq "showAllBounces"> active</cfif>" href="./?muraAction=cEmail.showAllBounces&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-compress"></i> #application.rbFactory.getKeyValue(session.rb,"email.bouncedemails")#</a>
			<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
				<a  class="btn" href="./?muraAction=cPerm.module&contentid=00000000000000000000000000000000005&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000005"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,"email.permissions")#</a>
			</cfif>
		</cfcase>
		<cfdefaultcase>
			<a class="btn" href="./?muraAction=cEmail.list&&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i> #application.rbFactory.getKeyValue(session.rb,"email.backtolist")#</a>
		</cfdefaultcase>
	</cfswitch>
	</div>
</cfoutput>
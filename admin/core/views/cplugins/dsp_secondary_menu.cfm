<!--- license goes here --->

<cfoutput>

	<cfset rc.originalfuseaction=listLast(request.action,".")>
	<div class="nav-module-specific btn-group">	
		<cfswitch expression="#rc.originalfuseaction#">
			<cfcase value="list">
			  <cfif listFind(session.mura.memberships,'S2')>
				<a class="btn" href="#application.configBean.getContext()##application.configBean.getAdminDir()#/?muraAction=cSettings.list&plugins##tabPlugins"><i class="mi-plus-circle"></i> #application.rbFactory.getKeyValue(session.rb,'layout.addplugin')#</a>
				</cfif>
			</cfcase>
		</cfswitch>
	</div>
</cfoutput>
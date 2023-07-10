<!--- license goes here --->
<cfoutput>
<cfset started=false>
<div id="tab#ucase(replace(local.category,' ','','all'))#" class="tab-pane<cfif local.category is 'Application'> active</cfif>">

	<div class="block block-bordered">
		<!-- block header -->
		<div class="block-header">
			<h3 class="block-title">#replace(local.category,' ','','all')# Plugins</h3>
		</div> <!-- /.block header -->
		<div class="block-content">


		<cfloop query="rscategorylist">
		<cfif not started>
			<table class="mura-table-grid">
			<tr>
			<th class="actions"></th>
			<th class="var-width">#application.rbFactory.getKeyValue(session.rb,"plugin.name")#</th>
			<th>#application.rbFactory.getKeyValue(session.rb,"plugin.directory")#</th>
			<th>#application.rbFactory.getKeyValue(session.rb,"plugin.category")#</th>
			<th>#application.rbFactory.getKeyValue(session.rb,"plugin.version")#</th>
			<th class="hidden-xs">#application.rbFactory.getKeyValue(session.rb,"plugin.provider")#</th>
			<!--- <th>#application.rbFactory.getKeyValue(session.rb,"plugin.providerurl")#</th> --->
			<th>Plugin ID</th>
			</tr>
		</cfif>
			<tr>
			<td class="actions">
				<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
				<div class="actions-menu hide">
					<ul class="actions-list">
					<cfif listFind(session.mura.memberships,'S2')>
								<li class="edit"><a href="./?muraAction=cSettings.editPlugin&moduleID=#rscategorylist.moduleID#"><i class="mi-pencil"></i>#application.rbFactory.getKeyValue(session.rb,'plugin.edit')#</a></li>
<!--- 					<cfelse>
						<li class="edit disabled"><a>#application.rbFactory.getKeyValue(session.rb,'plugin.edit')#</a></li> --->
					</cfif>
					<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
								<li class="permissions"><a href="./?muraAction=cPerm.module&contentid=#rscategorylist.moduleID#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rscategorylist.moduleID#"><i class="mi-group"></i>#application.rbFactory.getKeyValue(session.rb,'plugin.permissions')#</a></li>
<!--- 					<cfelse>
						<li class="permissions disabled"><a>#application.rbFactory.getKeyValue(session.rb,'plugin.permissions')#</a></li> --->
					</cfif>
					</ul>
				</div>
			</td>
			<td class="var-width"><a class="alt" href="#application.configBean.getContext()#/plugins/#rscategorylist.directory#/">#esapiEncode('html',rscategorylist.name)#</a></td>
			<td>#esapiEncode('html',rscategorylist.directory)#</td>
			<td>#esapiEncode('html',rscategorylist.category)#</td>
			<td>#esapiEncode('html',rscategorylist.version)#</td>
			<td class="hidden-xs"><a class="alt" href="#rscategorylist.providerurl#" target="_blank">#esapiEncode('html',rscategorylist.provider)#</a></td>
			<td>#rscategorylist.pluginID#</td>
			</tr>
			<cfset started=true>
		</cfloop>
		<cfif started>
			</table>
		</cfif>
		<cfif not started>
			<div class="help-block-empty">#application.rbFactory.getKeyValue(session.rb,"plugin.noresults")#</div>
		</cfif>

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.tab-pane -->
</cfoutput>

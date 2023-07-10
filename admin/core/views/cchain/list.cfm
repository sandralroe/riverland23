<!--- license goes here --->
<cfinclude template="js.cfm">
<cfset chains=$.getBean('approvalChainManager').getChainFeed(rc.siteID).setSortBy('name').getIterator()>
<cfset isEditor=listFindNoCase('editor,module',$.getBean('permUtility').getModulePermType('00000000000000000000000000000000019',rc.siteid))>
<cfoutput>
<div class="mura-header">
	<h1>#application.rbFactory.getKeyValue(session.rb,"approvalchains")#</h1>

	<cfinclude template="dsp_secondary_menu.cfm">

</div> <!-- /.mura-header -->
<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">
		  <cfif not chains.hasNext()>
			  <div class="help-block-empty">#application.rbFactory.getKeyValue(session.rb,"approvalchains.noapprovalchains")#</div>
		  <cfelse>
			<table class="mura-table-grid">
			<thead>
				<tr>
					<th class="actions"></th>
					<th class="var-width">#application.rbFactory.getKeyValue(session.rb,"approvalchains.name")#</th>
					<th>#application.rbFactory.getKeyValue(session.rb,"approvalchains.lastupdate")#</th>
				</tr>
			</thead>
			<tbody class="nest">
				<cfloop condition="chains.hasNext()">
				<cfset chain=chains.next()>
				<tr>
					<td class="actions">
						<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
						<div class="actions-menu hide">
							<ul class="actions-list">
								<li class="edit">
									<a href="./?muraAction=cchain.edit&chainID=#chain.getChainID()#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i>#application.rbFactory.getKeyValue(session.rb,'approvalchains.edit')#</a>
								</li>
								<li class="change-sets">
									<a href="./?muraAction=cchain.pending&chainID=#chain.getChainID()#&siteid=#esapiEncode('url',chain.getSiteID())#"><i class="mi-reorder"></i>#application.rbFactory.getKeyValue(session.rb,'approvalchains.pendingrequests')#</a>
								</li>
								<cfif isEditor>
								<li class="delete">
									<a href="./?muraAction=cchain.delete&chainID=#chain.getChainID()#&siteid=#esapiEncode('url',rc.siteid)##rc.$.renderCSRFTokens(context=chain.getChainID(),format='url')#" onClick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'approvalchains.deleteconfirm'))#',this.href)"><i class="mi-trash"></i>#application.rbFactory.getKeyValue(session.rb,'categorymanager.delete')#</a>
								</li>
								</cfif>
							</ul>
						</div>
					</td>
					<td class="var-width">
						<a title="#application.rbFactory.getKeyValue(session.rb,'approvalchains.edit')#" href="./?muraAction=cchain.pending&chainID=#chain.getChainID()#&siteid=#esapiEncode('url',rc.siteid)#">#esapiEncode('html',chain.getName())#</a>
					</td>
					<td>
						<cfif isDate(chain.getLastUpdate())>
						#LSDateFormat(chain.getLastUpdate(),session.dateKeyFormat)# #LSTimeFormat(chain.getLastUpdate(),"medium")#
						</cfif>
					</td>
				</tr>
				</cfloop>
			</tbody>
			</table>
			</cfif>
		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</cfoutput>

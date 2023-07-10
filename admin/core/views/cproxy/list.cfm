<!--- License goes here --->

<cfset proxies=$.getFeed('proxy').setSiteID(session.siteid).getIterator()>
<cfset isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('00000000000000000000000000000000020',rc.siteid))>
<cfoutput>
<div class="mura-header">
	<h1>API Proxies</h1>

    <div class="nav-module-specific btn-group">
        <a class="btn" href="./?muraAction=cproxy.edit&proxyid=&siteid=&#esapiEncode('url',rc.siteid)#"><i class="mi-plus-circle"></i> Add New API Proxy</a>
		<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
			<a class="btn" href="./?muraAction=cPerm.leveledmodule&contentid=00000000000000000000000000000000020&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000020"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,'approvalchains.permissions')#</a>
		</cfif>
    </div>
</div> <!-- /.mura-header -->

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">

		  <cfif not proxies.hasNext()>
			  <div class="help-block-empty">There currently are no api proxies configured for this site.</div>
		  <cfelse>
			<table class="mura-table-grid">
			<thead>
				<tr>
					<th class="actions"></th>
					<th class="var-width">Name</th>
					<th>Last Update</th>
				</tr>
			</thead>
			<tbody class="nest">
				<cfloop condition="proxies.hasNext()">
				<cfset proxy=proxies.next()>
				<tr>
					<td class="actions">
						<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
						<div class="actions-menu hide">
							<ul class="actions-list">
								<li class="edit">
									<a href="./?muraAction=cproxy.edit&proxyid=#proxy.getproxyid()#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i>Edit</a>
								</li>
								<cfif isEditor>
									<li class="delete">
										<a href="./?muraAction=cproxy.delete&proxyid=#proxy.getproxyid()#&siteid=#esapiEncode('url',rc.siteid)##rc.$.renderCSRFTokens(context=proxy.getproxyid(),format='url')#" onClick="return confirmDialog('Delete API Proxy?',this.href)"><i class="mi-trash"></i>Delete</a>
									</li>
								</cfif>
							</ul>
						</div>
					</td>
					<td class="var-width">
						<a title="Edit" href="./?muraAction=cproxy.edit&proxyid=#proxy.getproxyid()#&siteid=#esapiEncode('url',rc.siteid)#">#esapiEncode('html',proxy.getName())#</a>
					</td>
					<td>
						<a title="Edit" href="./?muraAction=cproxy.edit&proxyid=#proxy.getproxyid()#&siteid=#esapiEncode('url',rc.siteid)#">#LSDateFormat(proxy.getLastUpdate(),session.dateKeyFormat)# #LSTimeFormat(proxy.getLastUpdate(),"medium")#</a>
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

<!--- License goes here --->

<cfset services=$.getFeed('oauthClient').setSiteID(session.siteid).getIterator()>

<cfoutput>
<div class="mura-header">
	<h1>Web Services</h1>

    <div class="nav-module-specific btn-group">
        <a class="btn" href="./?muraAction=cwebservice.edit&clientid=&siteid=&#esapiEncode('url',rc.siteid)#"><i class="mi-plus-circle"></i> Add New Web Service</a>
    </div>
</div> <!-- /.mura-header -->

<cfif not rc.$.siteConfig('useSSL')>
   <div class="alert alert-error"><span>When using web services in production, this site should be set to use SSL (HTTPS).</span></div>
</cfif>

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">

		  <cfif not services.hasNext()>
			  <div class="help-block-empty">There currently are no web services configured for this site.</div>
		  <cfelse>
			<table class="mura-table-grid">
			<thead>
				<tr>
					<th class="actions"></th>
					<th class="var-width">Name</th>
					<th class="var-width">Auth Mode</th>
					<th>Last Update</th>
				</tr>
			</thead>
			<tbody class="nest">
				<cfloop condition="services.hasNext()">
				<cfset service=services.next()>
				<tr>
					<td class="actions">
						<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
						<div class="actions-menu hide">
							<ul class="actions-list">
								<li class="edit">
									<a href="./?muraAction=cwebservice.edit&clientid=#service.getClientID()#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i>Edit</a>
								</li>
								<li class="delete">
									<a href="./?muraAction=cwebservice.delete&clientid=#service.getClientID()#&siteid=#esapiEncode('url',rc.siteid)##rc.$.renderCSRFTokens(context=service.getClientID(),format='url')#" onClick="return confirmDialog('Delete Web Service?',this.href)"><i class="mi-trash"></i>Delete</a>
								</li>
							</ul>
						</div>
					</td>
					<td class="var-width">
						<a title="Edit" href="./?muraAction=cwebservice.edit&clientid=#service.getClientID()#&siteid=#esapiEncode('url',rc.siteid)#">#esapiEncode('html',service.getName())#</a>
					</td>
					<td>
						<cfif service.getGrantType() eq 'client_credentials'>OAuth2 (client_credentials)<cfelseif service.getGrantType() eq 'authorization_code'>OAuth2 (authorization_code)<cfelseif service.getGrantType() eq 'implicit'>OAuth2 (implicit)<cfelseif service.getGrantType() eq 'password'>OAuth2 (password)<cfelse>Basic</cfif>
					</td>
					<td>
						#LSDateFormat(service.getLastUpdate(),session.dateKeyFormat)# #LSTimeFormat(service.getLastUpdate(),"medium")#
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

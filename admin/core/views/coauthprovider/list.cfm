<!--- License goes here --->
<cfset providersList = "Google,Facebook,GitHub,Microsoft"/>
<cfset providersAdded = $.getFeed('oauthProvider').setSiteID(session.siteid).getIterator()>
<cfset providersAddedList = ""/>

<cfloop condition="providersAdded.hasNext()">
    <cfset providerAdded=providersAdded.next()>
    <cfset providersAddedList = listAppend(providersAddedList, providerAdded.getName())/>
</cfloop>

<cfset showAddButton = false/> 

<cfloop list="#providersList#" index="providerIndex">
    <cfif not listFindNoCase(providersAddedList, providerIndex)>
        <cfset showAddButton = true/> 
    </cfif>
</cfloop>

<cfset providers = $.getFeed('oauthProvider').setSiteID(session.siteid).getIterator()>

<cfoutput>
<div class="mura-header">
	<h1>OAuth Providers</h1>

    <div class="nav-module-specific btn-group">
    	<cfif showAddButton>
        	<a class="btn" href="./?muraAction=coauthprovider.edit&providerid=&siteid=&#esapiEncode('url',rc.siteid)#"><i class="mi-plus-circle"></i> Add New OAuth Provider</a>
    	</cfif>
    </div>
</div> <!-- /.mura-header -->

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">

		  <cfif not providers.hasNext()>
			  <div class="help-block-empty">There currently are no oauth providers configured for this site.</div>
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
				<cfloop condition="providers.hasNext()">
				<cfset provider=providers.next()>
				<tr>
					<td class="actions">
						<a class="show-actions" href="javascript:;" onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
						<div class="actions-menu hide">
							<ul class="actions-list">
								<li class="edit">
									<a href="./?muraAction=coauthprovider.edit&providerid=#provider.getproviderid()#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i>Edit</a>
								</li>
								<li class="delete">
									<a href="./?muraAction=coauthprovider.delete&providerid=#provider.getproviderid()#&siteid=#esapiEncode('url',rc.siteid)##rc.$.renderCSRFTokens(context=provider.getproviderid(),format='url')#" onClick="return confirmDialog('Delete OAuth Provider?',this.href)"><i class="mi-trash"></i>Delete</a>
								</li>
							</ul>
						</div>
					</td>
					<td class="var-width">
						<a title="Edit" href="./?muraAction=coauthprovider.edit&providerid=#provider.getproviderid()#&siteid=#esapiEncode('url',rc.siteid)#">#esapiEncode('html',provider.getName())#</a>
					</td>
					<td>
						<a title="Edit" href="./?muraAction=coauthprovider.edit&providerid=#provider.getproviderid()#&siteid=#esapiEncode('url',rc.siteid)#">#LSDateFormat(provider.getLastUpdate(),session.dateKeyFormat)# #LSTimeFormat(provider.getLastUpdate(),"medium")#</a>
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

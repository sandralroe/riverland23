<!--- License goes here --->
<cfparam name="rc.keywords" default="">
<cfoutput>

<div class="mura-header">
 <h1>Trash Bin</h1>

 <div class="nav-module-specific btn-group">
 	<a class="btn" href="./?muraAction=cSettings.editSite&siteID=#esapiEncode('url',rc.siteID)#"><i class="mi-arrow-circle-left"></i> Back to Site Settings</a>
	<cfif listFind(session.mura.memberships,'S2')>
		<a class="btn" href="./?muraAction=cTrash.empty&siteID=#esapiEncode('url',rc.siteID)#&sinceDate=#esapiEncode('html_attr',$.event('sinceDate'))#&beforeDate=#esapiEncode('html_attr',$.event('beforeDate'))#" onclick="return confirmDialog('Empty Site Trash?', this.href);"><i class="mi-trash"></i>Empty Trash</a>
	</cfif>
 </div>

 <div class="mura-item-metadata">
	 <form class="form-inline" novalidate="novalidate" id="siteSearch" name="siteSearch" method="post">
		<div class="mura-search mura-control-group">
			<label>Search for contents</label>
			<div class="mura-control-inline">
				<label>#application.rbFactory.getKeyValue(session.rb,"params.from")#</label>
				<input type="text" name="sinceDate" id="startDate" class="datepicker mura-custom-datepicker" placeholder="Start Date" value="#LSDateFormat($.event('sinceDate'),session.dateKeyFormat)#" />
				
				<label>#application.rbFactory.getKeyValue(session.rb,"params.to")#</label>
				<input type="text" name="beforeDate" id="endDate" class="datepicker mura-custom-datepicker" placeholder="End Date" value="#LSDateFormat($.event('beforeDate'),session.dateKeyFormat)#" />
				
				<input type="text" name="keywords" id="search" value="#esapiEncode('html_attr',rc.keywords)#" placeholder="Search">
				<button type="button" class="btn btn-default" onclick="submitForm(document.forms.siteSearch);">
					<i class="mi-search"></i>
				</button>
			</div>
		</div>
		<input type="hidden" name="muraAction" value="cTrash.list">
		<input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.siteid)#">
	</form>
 </div>

</div> <!-- /.mura-header -->

<div class="block block-constrain">
	 <div class="block block-bordered">
		 <div class="block-content">
		 <cfif rc.trashIterator.hasNext()>
		 <table class="mura-table-grid">
		 <tr>
			 <th class="actions"></th>
			 <th class="var-width">Label</th>
			 <th>Type</th>
			 <th>SubType</th>
			 <th>SiteID</th>
			 <th>Date Deleted</th>
			 <th class="hidden-xs">Deleted By</th>
		 </tr>
		 <cfif not isNumeric(rc.pageNum)>
			 <cfset rc.pagenum=1>
		 </cfif>
		 <cfset rc.trashIterator.setPage(rc.pageNum)>
		 <cfloop condition="rc.trashIterator.hasNext()">
		 <cfset trashItem=rc.trashIterator.next()>
		 <tr>
			 <td class="actions">
				 <ul>
					 <li class="edit"><a title="Edit" href="?muraAction=cTrash.detail&objectID=#trashItem.getObjectID()#&keywords=#esapiEncode('url',rc.keywords)#&pageNum=#esapiEncode('url',rc.pageNum)#&sinceDate=#esapiEncode('url',$.event('sinceDate'))#&beforeDate=#esapiEncode('url',$.event('beforeDate'))#"><i class="mi-pencil"></i></a></li>
				 </ul>
			 </td>
			 <td class="var-width"><a href="?muraAction=cTrash.detail&objectID=#trashItem.getObjectID()#&keywords=#esapiEncode('url',rc.keywords)#&pageNum=#esapiEncode('url',rc.pageNum)#&sinceDate=#esapiEncode('url',$.event('sinceDate'))#&beforeDate=#esapiEncode('url',$.event('beforeDate'))#">#esapiEncode('html',left(trashItem.getObjectLabel(),80))#</a></td>
			 <td>#esapiEncode('html',trashItem.getObjectType())#</td>
			 <td>#esapiEncode('html',trashItem.getObjectSubType())#</td>
			 <td>#esapiEncode('html',trashItem.getSiteID())#</td>
			 <td>#LSDateFormat(trashItem.getDeletedDate(),session.dateKeyFormat)# #LSTimeFormat(trashItem.getDeletedDate(),"short")#</td>
			 <td class="hidden-xs">#esapiEncode('html',trashItem.getDeletedBy())#</td>
			 </tr>
		 </cfloop>
		 </table>

		 <cfif rc.trashIterator.pageCount() gt 1>
			 <ul class="pagination">
				 <cfif rc.pageNum gt 1>
								 <li><a href="?muraAction=cTrash.list&siteid=#esapiEncode('url',rc.siteid)#&keywords=#esapiEncode('url',rc.keywords)#&pageNum=#evaluate('rc.pageNum-1')#"><i class="mi-angle-left"></i></a></li>
				 </cfif>
				 <cfloop from="1"  to="#rc.trashIterator.pageCount()#" index="i">

					 <cfif rc.pageNum eq i>
						 <li class="active"><a href="##">#i#</a></li>
					 <cfelse>
						 <li><a href="?muraAction=cTrash.list&siteid=#esapiEncode('url',rc.siteid)#&keywords=#esapiEncode('url',rc.keywords)#&pageNum=#i#&sinceDate=#esapiEncode('url',$.event('sinceDate'))#&beforeDate=#esapiEncode('url',$.event('beforeDate'))#">#i#</a></li>
					 </cfif>

				 </cfloop>
				<cfif rc.pageNum lt rc.trashIterator.pageCount()>
					<li>
						<a href="?muraAction=cTrash.list&siteid=#esapiEncode('url',rc.siteid)#&keywords=#esapiEncode('url',rc.keywords)#&pageNum=#evaluate('rc.pageNum+1')#&sinceDate=#esapiEncode('url',$.event('sinceDate'))#&beforeDate=#esapiEncode('url',$.event('beforeDate'))#"><i class="mi-angle-right"></i></a>
					</li>
				</cfif>
			 </ul>
		 </cfif>
		 <cfelse>
			 <div class="help-block-empty">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.notrash'))#</div>
		 </cfif>
	 </div> <!-- /.block-content -->
 </div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->

</cfoutput>

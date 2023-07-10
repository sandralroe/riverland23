<!--- license goes here --->
<cfoutput>

<div class="mura-header">
	<h1>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager')#</h1>
	<cfinclude template="dsp_secondary_menu.cfm">
</div> <!-- /.mura-header -->

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">

			<table class="mura-table-grid">
			<tr>
				<th class="actions"></th>
				<th class="var-width">#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.currentmailinglists')#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.type')#</th>
			</tr></cfoutput>
			<cfif rc.rslist.recordcount>
			<cfoutput query="rc.rslist">
				<tr>
					<td class="actions">
						<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
						<div class="actions-menu hide">	
							<ul class="mailingLists actions-list">
								<li class="edit"><a href="./?muraAction=cMailingList.edit&mlid=#rc.rslist.mlid#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.edit')#</a></li>
								<li class="permissions"><a href="./?muraAction=cMailingList.listmembers&mlid=#rc.rslist.mlid#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-group"></i>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.viewmembership')#</a></li>
									<cfif not rc.rslist.ispurge>
										<li class="delete"><a href="./?muraAction=cMailingList.update&action=delete&mlid=#rc.rslist.mlid#&siteid=#esapiEncode('url',rc.siteid)#" onClick="return confirmDialog('#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.deleteconfirm')#',this.href);"><i class="mi-trash"></i>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.delete')#</a></li>
									<!--- <cfelse><li class="delete disabled"><span><i class="mi-trash"></i></span></li> --->
									</cfif>
								</ul>
							</div>		
						</td>
						<td class="var-width"><a title="Edit" href="./?muraAction=cMailingList.edit&mlid=#rc.rslist.mlid#&siteid=#esapiEncode('url',rc.siteid)#">#esapiEncode('html',rc.rslist.name)# (#rc.rslist.members#)</a></td>
						<td><cfif rc.rslist.ispublic>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.public')#<cfelse>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.private')#</cfif></td>
					</tr>
			</cfoutput>
			<cfelse>
			<tr>
					<td nowrap class="noResults" colspan="3"><cfoutput>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.nolists')#</cfoutput></td>
				</tr>
			</cfif>
			</table>

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
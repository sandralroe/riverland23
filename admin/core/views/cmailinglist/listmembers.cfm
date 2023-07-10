<!--- license goes here --->
<cfoutput>
<div class="mura-header">
	<h1>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager')#</h1>
	<cfinclude template="dsp_secondary_menu.cfm">
</div> <!-- /.mura-header -->

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">
					
		<form novalidate="novalidate" action="./?muraAction=cMailingList.updatemember" name="form1" method="post" onsubmit="return validate(this);">
		<div class="mura-control-group">
			<label>
				#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.email')#
			</label>
			<input type=text name="email" class="text" required="true" message="#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.emailrequired')#">
		</div>
		<div class="mura-control-group">
			<label>
				#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.firstname')#
			</label>
			<input type=text name="fname" class="text" />
		</div>

		<div class="mura-control-group">
			<label>
				#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.lastname')#
			</label>
			<input type=text name="lname" class="text" />
		</div>

		<div class="mura-control-group">
			<label>
				#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.company')#
			</label>
			<input type=text name="company" class="text" />
		</div>

		<div class="mura-control-group">
			<label for="a" class="radio">
				<input type="radio" name="action" id="a" value="add" checked> 
				#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.subscribe')#
			</label> 
			<label id="d" class="radio">
				<input type="radio" id="d" name="action" value="delete"> 
				 #application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.unsubscribe')#
			</label>
		</div>
		<div class="mura-actions">
			<div class="form-actions">
				<button class="btn mura-primary" onclick="submitForm(document.forms.form1);"><i class="mi-check-circle"></i>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.submit')#</button>
			</div>
		</div>
		<input type=hidden name="mlid" value="#esapiEncode('html_attr',rc.mlid)#">
		<input type=hidden name="siteid" value="#esapiEncode('html_attr',rc.siteid)#">
		<input type=hidden name="isVerified" value="1">
		</form>

		</div> <!-- /.block-content -->

		<div class="block-content">

			<h2>#rc.listBean.getname()#</h2>

			<table id="metadata" class="mura-table-grid">
			<tr>
				<th class="actions"></th>
				<th class="var-width">#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.emails')# (#rc.rslist.recordcount#)</th>
				<th>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.name')#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.company')#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.verified')#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.created')#</th>
			</tr></cfoutput>
			<cfif rc.rslist.recordcount>
			<cfoutput query="rc.rslist" startrow="#rc.startrow#" maxrows="#rc.nextN.RecordsPerPage#">
				<tr>
					<td class="actions">
						<ul class="mailingListMembers actions-list">
							<li class="delete"><a href="./?muraAction=cMailingList.updatemember&action=delete&mlid=#rc.rslist.mlid#&email=#esapiEncode('url',rc.rslist.email)#&siteid=#esapiEncode('url',rc.siteid)#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.deletememberconfirm'))#',this.href);"><i class="mi-trash"></i>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.delete')#</a></li>
						</ul>
					</td>
					<td class="var-width"><a href="mailto:#esapiEncode('html',rc.rslist.email)#">#esapiEncode('html',rc.rslist.email)#</a></td>
					<td>#esapiEncode('html',rc.rslist.fname)#&nbsp;#esapiEncode('html',rc.rslist.lname)#</td>
					<td>#esapiEncode('html',rc.rslist.company)#</td>
					<td><cfif rc.rslist.isVerified eq 1>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.yes')#<cfelse>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.no')#</cfif></td>
					<td>#LSDateFormat(rc.rslist.created,session.dateKeyFormat)#</td>
				</tr>
			</cfoutput>
			<cfelse>
			<tr>
			<td class="noResults" colspan="6"><cfoutput>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.nomembers')#</cfoutput></td>
			</tr>
			</cfif>
			</table>

			<cfinclude template="dsp_list_members_next_n.cfm">

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->

<!--- license goes here --->

<cfset tabList="tabBasic">

<cfoutput>
<div class="mura-header">
	<h1>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager')#</h1>
	<cfinclude template="dsp_secondary_menu.cfm">
</div> <!-- /.mura-header -->

<form novalidate="novalidate" action="./?muraAction=cMailingList.update" method="post" enctype="multipart/form-data" name="form1" onsubmit="return validate(this);">

<div class="block block-constrain">

<cfif rc.listBean.getispurge() neq 1>
	<cfif rc.mlid eq ''>
	<div class="block block-bordered">
		<div class="block-content">
		<div class="mura-control-group">
			<label>
				#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.name')#
			</label>
			<input type="text" name="Name" value="#esapiEncode('html_attr',rc.listBean.getname())#" required="true" message="#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.namerequired')#">
		</div>
	<cfelse>
		<ul class="mura-tabs nav-tabs" data-toggle="tabs">
		<cfloop from="1" to="#listlen(tabList)#" index="t">
		<li<cfif t eq 1> class="active"</cfif>><a href="###listGetAt(tabList,t)#" onclick="return false;"><span>#listGetAt(tabLabelList,t)#</span></a></li>
		</cfloop>
		</ul>

		<div class="tab-content">
		<div id="tabBasic" class="tab-pane active">
			<div class="block block-bordered">
                <div class="block-content">

			<div class="mura-control-group">
				<label>
					#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.name')#
				</label>
					<input type=text name="Name" value="#esapiEncode('html_attr',rc.listBean.getname())#" required="true" message="#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.namerequired')#">
			</div>
	</cfif>

	<div class="mura-control-group">
		<label>
			#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.type')#
		</label>
			<label for="isPublicYes" class="radio inline">
				<input type="radio" value="1" id="isPublicYes" name="isPublic" <cfif rc.listBean.getisPublic() eq 1>checked</cfif>>
				#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.public')#
			</label>
			<label for="isPublicNo" class="radio inline">
				<input type="radio" value="0" id="isPublicNo" name="isPublic" <cfif rc.listBean.getisPublic() neq 1>checked</cfif>>
				#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.private')#
			</label>
				<input type=hidden name="ispurge" value="0">
	</div>

<cfelse>
	<ul class="mura-tabs nav-tabs" data-toggle="tabs">
	<cfloop from="1" to="#listlen(tabList)#" index="t">
	<li<cfif t eq 1> class="active"</cfif>><a href="###listGetAt(tabList,t)#" onclick="return false;"><span>#listGetAt(tabLabelList,t)#</span></a></li>
	</cfloop>
	</ul>

		<div class="tab-content">

		<div id="tabBasic" class="tab-pane active">
			<div class="block block-bordered">
				<!-- block header -->
				<div class="block-header">
					<h3 class="block-title">#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.basic')#</h3>
				</div> <!-- /.block header -->
				<div class="block-content">
			<div class="mura-control-group">
				<label>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.masterdonotemaillistname')#</label>
				<input type="text" name="Name" value="#esapiEncode('html_attr',rc.listBean.getname())#" required="true" message="#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.namerequired')#">
				<input type=hidden name="ispurge" value="1"><input type=hidden name="ispublic" value="1">
			</div>
</cfif>

	<div class="mura-control-group">
		<label>
			#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.description')#
		</label>
		<textarea id="description" name="description" rows="6">#esapiEncode('html',rc.listBean.getdescription())#</textarea>
		<input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.siteid)#">
	</div>

	<div class="mura-control-group">
		<label>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.uploadlistmaintenancefile')#</label>
		<label for="da" class="radio inline">
			<input type="radio" name="direction" id="da" value="add" checked>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.addaddressestolist')#
		</label>
		<label for="dm" class="radio inline">
			<input type="radio" name="direction" id="dm" value="remove"> #application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.removeaddressesfromlist')#
		</label>
		<label for="dp" class="radio inline">
			<input type="radio" name="direction" id="dp" value="replace"> #application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.replaceemaillistwithnewfile')#
		</label>
	</div>

	<div class="mura-control-group">
	<label>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.uploademailaddressfile')#</label>
	<input type="file" name="listfile" accept="text/plain" >
	</div>

	<cfif rc.mlid neq ''>
		<div class="mura-control-group">
			<label for="cm" class="checkbox inline">
			<input type="checkbox" id="cm" name="clearMembers" value="1" /> #application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.clearoutexistingmembers')#
			</label>
		</div>


			</div> <!-- /.block-content -->
		</div> <!-- /.block-bordered -->

		</div> <!-- /.tab-pane -->
	<cfelse>
		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
	</cfif>

	<div class="mura-actions">
		<div class="form-actions">
			<cfif rc.mlid eq ''>
				<button type="button" class="btn mura-primary" onclick="submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.add')#</button>
				<input type=hidden name="mlid" value="#createuuid()#">
			<cfelse>
				<cfif not rc.listBean.getispurge()>
					<button type="button" class="btn" onclick="submitForm(document.forms.form1,'delete','#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.deleteconfirm'))#');"><i class="mi-trash"></i>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.delete')#</button>
				</cfif>
				<button type="button" class="btn mura-primary" onclick="submitForm(document.forms.form1,'update');"><i class="mi-check-circle"></i>#application.rbFactory.getKeyValue(session.rb,'mailinglistmanager.update')#</button>
				<input type=hidden name="mlid" value="#rc.listBean.getmlid()#">
			</cfif>
			<input type="hidden" name="action" value="">
		</div>
	</div>


	</div> <!-- /.block-constrain -->
</form>

</cfoutput>

 <!--- license goes here --->
<cfinclude template="js.cfm">
<cfoutput>
<div id="allBounces">
	<div class="mura-header">
		<h1>#application.rbFactory.getKeyValue(session.rb,"email.bouncedemailaddresses")#</h1>
		<cfinclude template="dsp_secondary_menu.cfm">
	</div> <!-- /.mura-header -->		

	<div class="block block-constrain">
		<div class="block block-bordered">
		  <div class="block-content">

				<form class="form-inline form-well" novalidate="novalidate" action="./?muraAction=cEmail.showAllBounces" method="post" name="form1" id="filterBounces">
				<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,"email.filterbynumberofbounces")#:</label>
					<select name="bounceFilter" class="mura-constrain mura-numeric">
						<option value="">#application.rbFactory.getKeyValue(session.rb,"email.all")#</option>
						<cfloop from="1" to="5" index="i">
						  <option value="#i#"<cfif isDefined('rc.bounceFilter') and rc.bounceFilter eq i> selected</cfif>>#i#</option>
						</cfloop>
					</select>
				</div>
				<div class="mura-actions">
					<div class="form-actions">	
						<input type="button" class="btn mura-primary" onclick="submitForm(document.forms.form1);" value="#application.rbFactory.getKeyValue(session.rb,"email.filter")#" />
						<input type="hidden" name="siteID" value="#esapiEncode('html_attr',rc.siteid)#">
					</div>
				</div>
			</form>
		</cfoutput>

			<cfif rc.rsBounces.recordcount>
				<cfoutput>
					<h2>#application.rbFactory.getKeyValue(session.rb,"email.emailaddressbounces")#</h2>
				</cfoutput>
				<cfset bouncedEmailList = "">

				<form novalidate="novalidate" action="./?muraAction=cEmail.deleteBounces" method="post" name="form2" id="bounces">
				
					<ul class="metadata">
						<cfoutput query="rc.rsBounces">
							<li>#esapiEncode('html',email)# - #esapiEncode('html',bounceCount)#</li>
							<cfset bouncedEmailList = listAppend(bouncedEmailList,email)>
						</cfoutput>
					</ul>
					<cfoutput>
					<input type="hidden" value="#bouncedEmailList#" name="bouncedEmail" />
					<input type="hidden" name="siteID" value="#esapiEncode('html_attr',rc.siteid)#">
					<input type="button" class="btn" onclick="submitForm(document.forms.form2,'delete','Delete bounced emails from mailing lists?');" value="#application.rbFactory.getKeyValue(session.rb,"email.delete")#" />
					</cfoutput>
				</form>
			</cfif>


		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->

</div>
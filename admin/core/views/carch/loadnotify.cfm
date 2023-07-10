 <!--- license goes here --->
<cfset request.layout=false>
<cfset rc.perm=application.permUtility.getnodePerm(rc.crumbdata)/>
<cfset rc.rsNotify=application.contentUtility.getNotify(rc.crumbdata) />
<cfoutput>
<div class="mura-control-group">
<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.sendto')#</label>
	<select id="notifyEditor" name="notify" multiple="multiple" <cfif rc.perm eq 'editor'> onChange="javascript: this.selectedIndex==0?document.contentForm.approved.checked=true:document.contentForm.approved.checked=false;"</cfif>>
	<option value="" selected>None</option>
	<cfloop query="rc.rsnotify">
	<option value="#rc.rsnotify.userID#">#rc.rsnotify.lname#, #rc.rsnotify.fname# (#application.rbFactory.getKeyValue(session.rb,'sitemanager.permissions.#rc.rsnotify.type#')#)</option>
	</cfloop>
	</select>
</div>
<div class="mura-control-group">
	<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.message')#</label>
	<textarea name="message" rows="5" id="messageEditor">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.messagetext')#
	</textarea>
</div>
</cfoutput>


<!--- license goes here --->
<cfset request.layout=false>
<cfset contentBean=application.serviceFactory.getBean("content")>

<cfset contentBean.loadBy(contentHistID=rc.contenthistID,siteID=rc.siteID)>

<cfif not contentBean.exists()>
	<cfset contentBean.loadBy(contentid=rc.parentID)>
</cfif>

<cfset crumbdata=application.contentManager.getCrumbList(contentBean.getContentID(),contentBean.getSiteID())>
<cfset perm=application.permUtility.getnodePerm(crumbdata)/>
<cfset contentBean.loadBy(contentHistID=rc.contenthistID,siteID=rc.siteID)>
<cfset rsNotify=application.contentUtility.getNotify(crumbdata) />
<cfset rsAssigned=application.serviceFactory.getBean("contentDAO").getExpireAssignments(contentBean.getContentHistID())>
<cfset assignedList=valueList(rsAssigned.userID)>
<cfoutput>
	<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.expiresnotifyselect')#</label>
	<select id="expiresnotify" name="expiresnotify" size="6" multiple class="multiSelect">
	<option value="">None</option>
	<cfloop query="rsnotify">
	<option value="#rsnotify.userID#"<cfif listFind(assignedList,rsNotify.userid)> selected</cfif>>#rsnotify.lname#, #rsnotify.fname# (#application.rbFactory.getKeyValue(session.rb,'sitemanager.permissions.#rsnotify.type#')#)</option>
	</cfloop>
	</select>
</cfoutput>
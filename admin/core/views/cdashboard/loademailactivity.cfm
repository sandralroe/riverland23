<!--- license goes here --->
<cfset request.layout="false">
<cfinclude template="act_defaults.cfm">
<cfsilent>
	  <cfset emailStart=createDate(year(now()),month(now()),1)>
	  <cfset emailStop=createDate(year(now()),month(now()),day(now()))>
	  <cfset rsList = application.emailManager.getEmailActivity(rc.siteID,3,emailStart,emailStop) >
	  <cfset emailLimit = application.settingsManager.getSite(rc.siteID).getEmailBroadcasterLimit()>
	  <cfset emailsSent = application.emailManager.getSentCount(rc.siteID,emailStart,emailStop)>
	  <cfif emailLimit eq 0>
	  	<cfset emailLimitText = application.rbFactory.getKeyValue(session.rb,"dashboard.unlimited")>
		<cfset emailsRemainingText = application.rbFactory.getKeyValue(session.rb,"dashboard.unlimited")>
	  <cfelse>
	  	<cfset emailLimitText = emailLimit>
		<cfset emailsRemainingText = emailLimit - emailsSent>
	  </cfif>
</cfsilent>  

<cfoutput>
<h2><i class="mi-envelope"></i> #application.rbFactory.getKeyValue(session.rb,"dashboard.emailbroadcasts")# <span>(#lsDateFormat(emailStart,session.dateKeyFormat)# - #lsDateFormat(emailStop,session.dateKeyFormat)#)</span></h2>
<dl><dt>#application.rbFactory.getKeyValue(session.rb,"dashboard.emailssent")#:</dt><dd>#emailsSent#</dd><dt>#application.rbFactory.getKeyValue(session.rb,"dashboard.emailsalloted")#:</dt><dd>#emailLimitText#</dd><dt>#application.rbFactory.getKeyValue(session.rb,"dashboard.emailsremaining")#:</dt><dd>#emailsRemainingText#</dd></dl>

<!---<h3>Recent Campaign Activity</h3>--->
<table class="mura-table-grid">
<thead>
<tr>
	<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.title")#</th><th>#application.rbFactory.getKeyValue(session.rb,"dashboard.sent")#</th><th>#application.rbFactory.getKeyValue(session.rb,"dashboard.opens")#</th><th>#application.rbFactory.getKeyValue(session.rb,"dashboard.clicks")#</th><th>#application.rbFactory.getKeyValue(session.rb,"dashboard.bounces")#</th>
</tr>
</thead>
<tbody>
<cfif rslist.recordcount>
<cfloop query="rsList">
<cfsilent>
<cfset clicks=application.emailManager.getStat(rslist.emailid,'returnClick')/>
<cfset opens=application.emailManager.getStat(rslist.emailid,'emailOpen')/>
<cfset sent=application.emailManager.getStat(rslist.emailid,'sent')/>
<cfset bounces=application.emailManager.getStat(rslist.emailid,'bounce')/>
</cfsilent>				  
<tr>
<td class="title"><a href="./?muraAction=cEmail.edit&siteid=#esapiEncode('url',rc.siteid)#&emailID=#rslist.emailID#">#rsList.subject#</td><td>#sent#</td><td>#opens#</td><td>#clicks#</td><td>#bounces#</td>
</tr>
</cfloop>
<cfelse>
<tr><td class="noResults" colspan="5">#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"dashboard.noemails"),rc.span)#</td></tr>
</cfif>
</tbody>
</table></cfoutput>
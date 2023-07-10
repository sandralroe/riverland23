 <!--- license goes here --->
<cfinclude template="js.cfm">
<cfoutput>
<h1>#application.rbFactory.getKeyValue(session.rb,"email.clickdetail")#</h1>

<cfinclude template="dsp_secondary_menu.cfm">

<strong>#application.rbFactory.getKeyValue(session.rb,"email.userswhoclicked")#:</strong></cfoutput>
<cfif rc.rsReturnsByUser.recordcount>
	<ul class="metadata">
	<cfoutput query="rc.rsReturnsByUser">
	<li>#esapiEncode('html',rc.rsReturnsByUser.email)#</li>
	</cfoutput>
	</ul>
</cfif>
<cfoutput><strong>#application.rbFactory.getKeyValue(session.rb,"email.toplinks")#:</strong></cfoutput>
<cfif rc.rsReturns.recordcount>
	<ul class="metadata">
	<cfoutput query="rc.rsReturns">
	<li>#esapiEncode('html',rc.rsReturns.url)# - #esapiEncode('html',rc.rsReturns.returnCount)#</li>
	</cfoutput>
	</ul>
</cfif>
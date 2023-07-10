 <!--- license goes here --->
<cfoutput>
<h1>#application.rbFactory.getKeyValue(session.rb,"email.bouncedemailaddresses")#</h1>

<cfinclude template="dsp_secondary_menu.cfm">

<h2>#application.rbFactory.getKeyValue(session.rb,"email.emailaddressbounces")#</h2></cfoutput>
<cfif rc.rsBounces.recordcount>
	<ul class="metadata">
		<cfoutput query="rc.rsBounces">
			<li>#esapiEncode('html',email)# - #esapiEncode('html',bounceCount)#</li>
		</cfoutput>
	</ul>
</cfif>

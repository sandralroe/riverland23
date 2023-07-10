<!--- license goes here --->
<cfsilent>
<cfset variables.rsPre=variables.$.getBean('contentGateway').getKids('00000000000000000000000000000000000',variables.$.event('siteID'),variables.$.content('contentID'),'default',now(),100,variables.$.event('keywords'),0,variables.$.content('sortBy'),variables.$.content('sortDirection'),variables.$.event('categoryID'),variables.$.event('relatedID'),variables.$.event('tag'))>
<cfif variables.$.siteConfig('extranet') eq 1 and variables.$.event('r').restrict eq 1>
	<cfset variables.rs=variables.$.queryPermFilter(variables.rsPre)/>
<cfelse>
	<cfset variables.rs=variables.rsPre/>
</cfif>
</cfsilent>
<cfif rs.recordcount>
	<cfset variables.redirect=variables.$.createHREF(variables.rs.type,variables.rs.filename,variables.rs.siteid,variables.rs.contentid,"","","",variables.$.globalConfig('context'),variables.$.globalConfig('stub'),variables.$.globalConfig('indexFile'))>
	<cfif not request.muraExportHTML>
		<cfset variables.$.redirect(variables.redirect) />
	<cfelse>
		<cfoutput><script>location.href='#JSStringFormat(variables.redirect)#';</script></cfoutput>
	</cfif>
</cfif>

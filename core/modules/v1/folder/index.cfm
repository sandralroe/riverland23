<!--- license goes here --->
<cfsilent>
	<cfset objectparams.sourcetype='children'>
	<cfset objectparams.source=$.content('contentid')>

	<!--- This allows you to hide the standard options of sorting and pagination --->
	<cfset objectparams.standardOptions=true>
	<!-- This allows you to force a layout.--->
	<cfset objectparams.forceLayout=false>
	<!-- Folders should not be limited --->
	<cfset objectparams.maxitems="">

	<!--- This is for legacy support.  You don't need this when using layout manager --->
	<cfif not $.getContentRenderer().useLayoutManager()>
		<cfset objectparams.displaylist=$.content('displayList')>
		<cfset objectparams.sortBy=$.content('sortBy')>
		<cfset objectparams.sortDirection=$.content('sortDirection')>
		<cfset objectparams.nextn=$.content('nextn')>
		<cfset objectparams.layout='default'>
	</cfif>
</cfsilent>
<cfoutput>
	#$.dspObject_include(
		thefile="collection/index.cfm",
		params=objectParams
	)#
</cfoutput>

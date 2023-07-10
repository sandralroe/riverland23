<!--- license goes here --->

<!--- Either the user provides a name or the tag
uses the query string as the key --->
<cfparam name="attributes.detail" type="string" default="Default Mura Tracer Detail">

<cfif thisTag.executionMode IS "Start">
	<cfset request.muraScope.event('lastMuraTracer', request.muraScope.initTracePoint("Mura Tracer: " & attributes.detail)) />
<cfelseif thisTag.executionMode IS "End">
	<cfset request.muraScope.commitTracePoint(request.muraScope.event('lastMuraTracer')) />
</cfif>
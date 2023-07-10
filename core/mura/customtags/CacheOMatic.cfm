<!--- license goes here --->

<!--- Either the user provides a name or the tag
uses the query string as the key --->
<cfparam name="request.siteID" default="default">
<cfparam name="request.purgeCache" default="false">
<cfparam name="attributes.key" default="#CGI.script_name##CGI.query_string#">
<cfparam name="attributes.timespan" default="#createTimeSpan(0,0,30,0)#">
<cfparam name="attributes.scope" default="application">
<cfparam name="attributes.nocache" default="0">
<cfparam name="attributes.purgeCache" default="#request.purgeCache#">
<cfparam name="attributes.siteid" default="#request.siteid#">
<cfparam name="attributes.cacheFactory" default="#application.settingsManager.getSite(attributes.siteid).getCacheFactory(name='output')#">
<cfparam name="request.forceCache" default="false">
<cfparam name="request.cacheItem" default="true">
<cfparam name="request.cacheItemTimeSpan" default="">

<cfset variables.tempKey=attributes.key & request.muraOutputCacheOffset>

<cfif not isBoolean(request.cacheItem)>
  <cfset request.cacheItem=true/>
</cfif>

<cfif not isBoolean(attributes.nocache)>
  <cfset attributes.nocache=false/>
</cfif>

<cfif not isBoolean(request.forceCache)>
  <cfset request.forceCache=false/>
</cfif>

<cfif not isBoolean(attributes.purgeCache)>
  <cfset attributes.purgeCache = false />
</cfif> 

<cfif attributes.purgeCache and attributes.cacheFactory.has(variables.tempKey)>
  <cfset attributes.cacheFactory.purge(variables.tempKey) />
</cfif>

<cfif thisTag.executionMode IS "Start">
  <cfset request.cacheItem=true/>
   <cfset request.cacheItemTimeSpan="">
</cfif>

<cfif request.cacheItem and NOT attributes.nocache AND (application.settingsManager.getSite(attributes.siteid).getCache()  OR request.forceCache IS true)>
  <cfset cacheFactory=attributes.cacheFactory/>
       
  <cfif thisTag.executionMode IS "Start">

    <cfif cacheFactory.has( variables.tempKey )>
      <cftry>
        <cfset content=cacheFactory.get( variables.tempKey )>
        <cfoutput>#content#</cfoutput>
        <cfsetting enableCFOutputOnly="No">
        <cfexit method="EXITTAG">   
        <cfcatch></cfcatch>
      </cftry>
    </cfif>
  <cfelse>
   <cfif isDate(request.cacheItemTimeSpan)>
      <cfset cacheFactory.set( key=variables.tempKey, context=thisTag.generatedContent, obj=thisTag.generatedContent, timespan=request.cacheItemTimeSpan)>
   <cfelse>
      <cfset cacheFactory.set( key=variables.tempKey, context=thisTag.generatedContent, obj=thisTag.generatedContent, timespan=attributes.timespan)>
   </cfif>
  </cfif>
</cfif>
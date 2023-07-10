<!--- License goes here --->
<cfset request.cacheItem = false />
<cfif Len($.siteConfig('reCAPTCHASiteKey')) and Len($.siteConfig('reCAPTCHASecret'))>
  <cfoutput>#$.dspReCAPTCHAContainer()#</cfoutput>
<cfelse>
  <cfinclude template="/cfformprotect/cffp.cfm" />
</cfif>
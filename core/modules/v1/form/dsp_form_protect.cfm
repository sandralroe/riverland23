<!--- license goes here --->
<cfset request.cacheItem = false />
<cfif Len($.siteConfig('reCAPTCHASiteKey')) and Len($.siteConfig('reCAPTCHASecret'))>
  <cfoutput><div class="form-group">#$.dspReCAPTCHAContainer()#</div></cfoutput>
<cfelse>
  <cfinclude template="/cfformprotect/cffp.cfm" />
</cfif>

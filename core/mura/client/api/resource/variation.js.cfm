<!---   
EMBED: 
<script src="https://domain.com/{siteid}/variation" async> 
--->
<cfcontent reset="yes" type="application/javascript">
<cfparam name="session.siteid" default="#url.siteid#">
<cfif not structKeyExists(session,"rb")>
	<cfset application.rbFactory.resetSessionLocale()>
</cfif>
<cfinclude template="/muraWRM/core/modules/v1/core_assets/js/mura.min.js">
<cfinclude template="/muraWRM/core/modules/v1/core_assets/js/variation.js">
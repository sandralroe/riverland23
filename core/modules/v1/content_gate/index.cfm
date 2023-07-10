<cfsilent>
<cfparam name="objectparams.formid" default="#m.siteConfig('gatedFormID')#">
<cfparam name="objectparams.selector" default='a[href*="/gated/"]'>
<cfparam name="objectparams.assetlabel" default=''>
<cfset objectparams.render="client">
<cfset objectparams.async=false>
<cfset objectparams.queue=false>
</cfsilent>

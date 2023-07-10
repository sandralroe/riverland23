<!--- license goes here --->
<cfif not this.deferMuraJS and not $.siteConfig('isRemote')>
<cfoutput><script type="text/javascript">
<!--
!window.jQuery && document.write(unescape('%3Cscript type="text/javascript" src="#variables.$.globalConfig('context')#/core/vendor/jquery/jquery.min.js"%3E%3C/script%3E'))
//-->
</script></cfoutput>
</cfif>

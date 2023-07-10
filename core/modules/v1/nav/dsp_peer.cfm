<!--- license goes here --->
<cfset navOutput=dspPeerNav()>
<cfif len(navOutput)>
  <cfoutput>
    <nav id="navPeer" role="navigation" aria-label="Secondary"<cfif this.navPeerWrapperClass neq ""> class="#this.navPeerWrapperClass#"</cfif>>
      <cfif len(this.navPeerWrapperBodyClass)><div class="#this.navPeerWrapperBodyClass#"></cfif>
      #navOutput#
      <cfif len(this.navPeerWrapperBodyClass)></div></cfif>
    </nav>
  </cfoutput>
</cfif>

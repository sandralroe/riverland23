<!--- license goes here --->
<cfset navOutput=dspSubNav()>
<cfif len(navOutput)>
  <cfoutput>
    <nav id="navSub" role="navigation" aria-label="Secondary"<cfif this.navSubWrapperClass neq ""> class="mura-nav-sub #this.navSubWrapperClass#"</cfif>>
      <cfif len(this.navSubWrapperBodyClass)><div class="#this.navSubWrapperBodyClass#"></cfif>
      #navOutput#
      <cfif len(this.navSubWrapperBodyClass)></div></cfif>
    </nav>
  </cfoutput>
</cfif>

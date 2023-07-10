<!--- license goes here --->

<!--- This outputs peer nav and the sub nav of the page you are on if there is any. It omits top level nav for the sake of redundancy and dead-ends if there is no content below the page you are on. Usually works best when used in conjunction with the breadcrumb nav since it changes as you get deeper into a site. --->
<cfset navOutput=dspStandardNav()>
<cfif len(navOutput)>
  <cfoutput>
    <nav id="navStandard" role="navigation" aria-label="Secondary"<cfif this.navStandardWrapperClass neq ""> class="mura-nav-standard #this.navStandardWrapperClass#"</cfif>>
      <cfif len(this.navStandardWrapperBodyClass)><div class="#this.navStandardWrapperBodyClass#"></cfif>
      #navOutput#
      <cfif len(this.navStandardWrapperBodyClass)></div></cfif>
    </nav>
  </cfoutput>
</cfif>

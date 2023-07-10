<!--- license goes here --->

<!--- Works just like the standard nav, but omits items in a portal to avoid potentially unmanageably long sub nav for something like a news portal with 100 items --->
<cfset navOutput=dspFolderNav()>
<cfif len(navOutput)>
  <cfoutput>
    <nav id="navFolder" role="navigation" aria-label="Secondary"<cfif this.navFolderWrapperClass neq ""> class="mura-nav-folder #this.navFolderWrapperClass#"</cfif>>
      <cfif len(this.navFolderWrapperBodyClass)><div class="#this.navFolderWrapperBodyClass#"></cfif>
      #navOutput#
      <cfif len(this.navFolderWrapperBodyClass)></div></cfif>
    </nav>
  </cfoutput>
</cfif>

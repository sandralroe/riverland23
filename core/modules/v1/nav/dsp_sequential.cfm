<!--- License goes here --->
<!--- Outputs nav of portal and calendar child content in sequence in the form of "Previous 1 2 3 4 5 Next" --->
<cfif not listFind("Folder,Gallery",variables.$.content('type')) and arrayLen($.event('crumbData')) gt 1>
	<cfoutput>
			<nav id="navSequential" role="navigation" aria-label="Secondary" class="mura-nav-sequential #this.navSequentialWrapperClass#">
				#variables.$.dspSequentialNav()#
			</nav>
	</cfoutput>
</cfif>
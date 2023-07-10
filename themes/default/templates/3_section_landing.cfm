<cfoutput>
<!DOCTYPE html>
<html lang="en"<cfif Mura.hasFETools()> class="mura-edit-mode"</cfif>>
	<cfinclude template="inc/html_head.cfm" />
	<body id="#Mura.getTopID()#" class="depth-#Mura.content('depth')# #Mura.createCSSHook(Mura.content('menuTitle'))#">
		<cfinclude template="inc/navbar.cfm" />
		<cfset pageTitle = Mura.content('type') neq 'Page' ? Mura.content('title') : ''>
		   #Mura.dspObject(
        object="header",
        objectParams=urlDecode(Mura.content('headerParams')),
        targetattr='headerParams'
    )#
				<div><div class="bctransbox"><div class="container"><nav aria-label="breadcrumb">#$.dspCrumbListLinks(class="")#</nav></div></div>
			<div><div class="container">#Mura.dspObjects(5)#</div></div>
					<div class="module-brand"><div class="container">#Mura.dspObjects(6)#</div></div>
					<div class="bg-light"><div class="container">#Mura.dspObjects(7)#</div></div>
	
		<cfinclude template="inc/footer.cfm" />
		<cfinclude template="inc/html_foot.cfm" />
	</body>
</html>
</cfoutput>
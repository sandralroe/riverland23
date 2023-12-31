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
			<div>
				<div class="bctransbox">
					<div class="container">
						<nav aria-label="breadcrumb">#$.dspCrumbListLinks(class="")#</nav>
					</div>
				</div>
				<div class="container">
				<cfset pageTitle = Mura.content('type') neq 'Page' ? Mura.content('title') : ''>
				 <h1>#$.content('title')#</h1>
				#Mura.dspBody(
					body=Mura.content('body')
					, pageTitle=pageTitle
					, crumbList=false
					, showMetaImage=false
				)#  
				</div>
			</div>
	
		<cfinclude template="inc/footer.cfm" />
		<cfinclude template="inc/html_foot.cfm" />
	</body>
</html>
</cfoutput>
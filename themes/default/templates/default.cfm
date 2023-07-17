<cfoutput>
<!DOCTYPE html>
<html lang="en"<cfif Mura.hasFETools()> class="mura-edit-mode"</cfif>>
	<cfinclude template="inc/html_head.cfm" />
	<body id="#Mura.getTopID()#" class="depth-#Mura.content('depth')# #Mura.createCSSHook(Mura.content('menuTitle'))#">
		<cfinclude template="inc/navbar.cfm" />
		<div class="container p-3">
  <div class="row">
    <div class="col">
    <h1>#$.content('title')#</h1>
	<div><div class="bctransbox"><div class="container"><nav aria-label="breadcrumb">#$.dspCrumbListLinks(class="")#</nav></div></div>
		<cfset pageTitle = Mura.content('type') neq 'Page' ? Mura.content('title') : ''>
			#Mura.dspBody(
				body=Mura.content('body')
				, pageTitle=pageTitle
				, crumbList=false
				, showMetaImage=false
			)#  
    </div>
   
  </div>
</div>
		<cfinclude template="inc/footer.cfm" />
		<cfinclude template="inc/html_foot.cfm" />
	</body>
</html>
</cfoutput>

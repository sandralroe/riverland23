<cfoutput>
	#Mura.dspObject(
		object="header",
		objectParams=urlDecode(Mura.content('headerParams')),
		targetattr='headerParams'
	)#
<div class="bg-green"><div class="container sectionmargins">#Mura.dspObjects(3)#</div></div>
	<div class="container mt-3">
	#Mura.dspObject(
		object="folder",
		params=objectParams
	)#
	</div>
	
</cfoutput>

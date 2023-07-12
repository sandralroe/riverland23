<cfoutput>

		<cfif len($.dspObjects(3))>
	<cfelse><div class="sectionmargins">
			<div class="container">
			#Mura.dspObjects(3)#<!---Pre-Footer Display Region--->
			</div></cfif>
		

		<div class="container">
			#Mura.dspObject(
				object="folder",
				params=objectParams
			)#
		</div>
</cfoutput>

<cfoutput>

		<cfif len($.dspObjects(3))><div class="sectionmargins">
			<div class="container">
			#Mura.dspObjects(3)#<!---Pre-Footer Display Region--->
			</div>
		</div><cfelse>say something here</cfif>
		

		<div class="container">
			#Mura.dspObject(
				object="folder",
				params=objectParams
			)#
		</div>
</cfoutput>

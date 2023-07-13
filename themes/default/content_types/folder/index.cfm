<cfoutput>
<div class="sectionmargins">
	<div class="container">
	 #Mura.renderEditableAttribute(attribute="body",type="htmlEditor")#
	</div>
	<div class="container">
		#Mura.dspObject(
		object="folder",
		params=objectParams
		)#
	</div>
</cfoutput>
